//
//  HouseViewController.m
//  shadow
//
//  Created by iaccepted on 15/5/7.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//

#import "HouseViewController.h"
#import <OpenGLES/ES2/glext.h>
#import "DepthProgram.h"
#import "NormalProgram.h"
#import "ShadowMapProgram.h"
#import "assimpModel.h"
#import "Camera.h"
#import <glm/glm.hpp>
#import <glm/gtc/matrix_transform.hpp>
#import <glm/gtc/type_ptr.hpp>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

GLfloat cube[] =
{
    -0.5, 0.5, 0.0, 0.0, 1.0,
    -0.5, -0.5, 0.0, 0.0, 0.0,
    0.5, -0.5, 0.0, 1.0, 0.0,
    -0.5, 0.5, 0.0, 0.0, 1.0,
    0.5, -0.5, 0.0, 1.0, 0.0,
    0.5, 0.5, 0.0, 1.0, 1.0
};


@interface HouseViewController () {
    glm::mat4 _shadowMVP;
    Model model;
    Camera camera;
}
@property (strong, nonatomic) EAGLContext *context;
@property (nonatomic) DepthProgram *depthProgram;
@property (nonatomic) NormalProgram *normalProgram;
@property (nonatomic) ShadowMapProgram *shadowMapProgram;
@property (nonatomic) GLuint depthFbo;
@property (nonatomic) GLuint depthTexture;
@property (nonatomic, assign) GLuint vao;
@property (nonatomic, assign) GLuint vbo;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation HouseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    
    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    [self setupGL];
}

- (void)dealloc
{
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)setLight {
    
    GLuint lightColor, lightDirection;
    lightColor = glGetUniformLocation(self.normalProgram.program, "light.color");
    lightDirection = glGetUniformLocation(self.normalProgram.program, "light.direction");
    
    glUniform3f(lightColor, 1.0, 1.0, 1.0);
    glUniform3f(lightDirection, 1.0f, 1.0f, 1.0f);
}


- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    //init and link depthProgram and normalProgram
    _depthProgram = [[DepthProgram alloc] linkProgramWithShaderName:@"depth"];
    _normalProgram = [[NormalProgram alloc] linkProgramWithShaderName:@"normal"];
    _shadowMapProgram = [[ShadowMapProgram alloc] linkProgramWithShaderName:@"Shader"];
    
    glGenVertexArraysOES(1, &_vao);
    glBindVertexArrayOES(_vao);
    glGenBuffers(1, &_vbo);
    glBindBuffer(GL_ARRAY_BUFFER, _vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(cube), cube, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLvoid *)0);
    
    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLvoid *)(3 * sizeof(GLfloat)));
    
    glBindVertexArrayOES(0);
    
    
    const char *path = [self getPath:@"box/newest" : @"obj"];
    model.loadModel(path);
    model.bindVertexData();
    model.bindTexturesData();
    
    [self initDepthFramebuffer];

    glEnable(GL_DEPTH_TEST);
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    if (self.depthProgram.program) {
        glDeleteProgram(self.depthProgram.program);
        self.depthProgram.program = 0;
    }
    
    if (self.normalProgram.program) {
        glDeleteProgram(self.normalProgram.program);
        self.normalProgram.program = 0;
    }
}

#pragma mark - render

- (void) renderNormal
{
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glUseProgram(self.normalProgram.program);
    [self setLight];
    
    GLuint shadowProjectionMatrixLoc = glGetUniformLocation(self.normalProgram.program, "shadowMVP");
    glUniformMatrix4fv(shadowProjectionMatrixLoc, 1, GL_FALSE, glm::value_ptr(_shadowMVP));
    
    
    GLuint modelViewProjectionLocation, normalMatrixLocation;
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    
    modelViewProjectionLocation = glGetUniformLocation(self.normalProgram.program, "MVP");
    normalMatrixLocation = glGetUniformLocation(self.normalProgram.program, "normalMatrix");
    
    glm::mat4 modelMatrix, viewMatrix, projection, modelView, modelViewProjection, normalMatrix;
    
    modelMatrix = glm::rotate(modelMatrix, glm::radians(-90.0f),  glm::vec3(1.0f, 0.0f, 0.0f));
    modelMatrix = glm::translate(modelMatrix, glm::vec3(0.0f, 0.0f, -0.75f));
    modelMatrix = glm::scale(modelMatrix, glm::vec3(0.006f, 0.006f, 0.006f));
    viewMatrix = camera.getView();
    projection = glm::perspective(glm::radians(45.0f), aspect, 0.1f, 100.0f);
    
    modelView = viewMatrix * modelMatrix;
    modelViewProjection = projection * modelView;
    normalMatrix = glm::transpose(glm::inverse(modelView));
    
    glUniformMatrix4fv(normalMatrixLocation, 1, GL_FALSE, glm::value_ptr(normalMatrix));
    glUniformMatrix4fv(modelViewProjectionLocation, 1, GL_FALSE, glm::value_ptr(modelViewProjection));
    
    model.drawNormal(self.normalProgram.program, _depthTexture);
}

-(void)renderDepth
{
    glUseProgram(self.depthProgram.program);
    glBindFramebuffer(GL_FRAMEBUFFER, _depthFbo);
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    glClearDepthf(1.0f);
    glClear(GL_DEPTH_BUFFER_BIT);
    glm::mat4 lightView = glm::lookAt(glm::vec3(-40, -10, 12), glm::vec3(0), glm::vec3(0, 1, 0));
    float aspect = self.view.frame.size.width / self.view.frame.size.height;
    glm::mat4 lightProjection = glm::perspective(glm::radians(75.0f), aspect, 0.1f, 100000.0f);
    glm::mat4 lightModel;
    lightModel = glm::rotate(lightModel, glm::radians(-90.0f),  glm::vec3(1.0f, 0.0f, 0.0f));
    lightModel = glm::translate(lightModel, glm::vec3(0.0f, 0.0f, -0.75f));
    lightModel = glm::scale(lightModel, glm::vec3(0.006f, 0.006f, 0.006f));
    _shadowMVP = lightProjection * lightView * lightModel;
    
    GLuint MVPLoc = glGetUniformLocation(self.depthProgram.program, "shadowMVP");
    glUniformMatrix4fv(MVPLoc, 1, GL_FALSE, glm::value_ptr(_shadowMVP));
    model.drawDepth();
}

- (void) drawShadowMapping
{
    glClearColor(1.0f, 1.0f, 1.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glUseProgram(self.shadowMapProgram.program);
    
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, _depthTexture);
    glUniform1i(glGetUniformLocation(self.shadowMapProgram.program, "shadowMap"), 0);
    
    glBindVertexArrayOES(_vao);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    glBindVertexArrayOES(0);
}


#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glUseProgram(self.depthProgram.program);
    glBindFramebuffer(GL_FRAMEBUFFER, _depthFbo);
    [self renderDepth];
    [view bindDrawable];
    [self drawShadowMapping];
    //[self renderNormal];
}


#pragma mark - framebuffer

-(void)initDepthFramebuffer
{
    glGenTextures(1, &_depthTexture);
    glBindTexture(GL_TEXTURE_2D, _depthTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_FUNC_EXT, GL_LEQUAL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_MODE_EXT, GL_COMPARE_REF_TO_TEXTURE_EXT);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, self.view.frame.size.width, self.view.frame.size.height, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_INT, 0);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glGenFramebuffers(1, &_depthFbo);
    glBindFramebuffer(GL_FRAMEBUFFER, _depthFbo);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, self.depthFbo, 0);
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

#pragma mark - get resource path
- (const char *)getPath:(NSString *)filename :(NSString *)type {
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:type];
    const char *pathString = [path UTF8String];
    return pathString;
}
@end

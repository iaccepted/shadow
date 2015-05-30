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
#import "SSAOProgram.h"
#import "assimpModel.h"
#import "Camera.h"
#import <glm/glm.hpp>
#import <glm/gtc/matrix_transform.hpp>
#import <glm/gtc/type_ptr.hpp>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#define kNear 1.5
#define kFar 100.0

#define kWindowWidth  self.view.frame.size.width
#define kWindowHeight self.view.frame.size.height


GLfloat cube[] =
{
    -1.0, 1.0, 0.0, 0.0, 1.0,
    -1.0, -1.0, 0.0, 0.0, 0.0,
    1.0, -1.0, 0.0, 1.0, 0.0,
    -1.0, 1.0, 0.0, 0.0, 1.0,
    1.0, -1.0, 0.0, 1.0, 0.0,
    1.0, 1.0, 0.0, 1.0, 1.0
};

GLfloat screenXYs[] =
{
    -1.0, 1.0,
    -1.0, -1.0,
    1.0, -1.0,
    -1.0, 1.0,
    1.0, -1.0,
    1.0, 1.0
};

typedef struct depthLocations
{
    GLuint shadowMVPLocation;
}depthLocations;

typedef struct normalLocations
{
    GLuint MVPLocation;
    GLuint shadowMVPLocation;
    GLuint normalMatrixLocation;
}normalLocations;

typedef struct ssaoLocations
{
    GLuint depthTextureLocation;
    GLuint projectionMatrixLocation;
    GLuint winParamesLocation;
}ssaoLocations;


@interface HouseViewController () {
    glm::mat4 _shadowMVP;
    glm::mat4 _projectionMatrix;
    glm::mat4 _modelMatrix;
    depthLocations _depthLocations;
    normalLocations _normalLocations;
    ssaoLocations _ssaoLocations;
    Model model;
    Camera camera;
}
@property (strong, nonatomic) EAGLContext *context;

#pragma mark - program
@property (nonatomic, strong) DepthProgram *depthProgram;
@property (nonatomic, strong) NormalProgram *normalProgram;
@property (nonatomic, strong) SSAOProgram *ssaoProgram;
@property (nonatomic, strong) ShadowMapProgram *shadowMapProgram;

#pragma mark - fbo
@property(nonatomic, assign) GLuint ssaoFbo;
@property (nonatomic, assign) GLuint depthFbo;
@property (nonatomic, assign) GLuint normalFbo;

#pragma mark - texture
//深度纹理，存储深度信息
@property (nonatomic, assign) GLuint lightDepthTexture;
@property (nonatomic, assign) GLuint cameraDepthTexture;

//ssao纹理，存储ao信息
@property (nonatomic, assign) GLuint ssaoTexture;
//正常渲染效果纹理，存储正常渲染出的效果图
@property (nonatomic, assign) GLuint normalTextue;

#pragma mark - 存储ssao中使用的坐标信息
@property (nonatomic, assign) GLuint ssaoVao;
@property (nonatomic, assign) GLuint ssaoVbo;

#pragma mark - 存储显示绘制的纹理结果的坐标信息
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
    _ssaoProgram = [[SSAOProgram alloc] linkProgramWithShaderName:@"ssao"];
    
    //提前获得需要的uniform变量对location，从而在渲染的时候直接使用，加快速度
    model.getLocations(_normalProgram.program);
    
    [self bindShowTexture];
    [self bindSSAOData];
    
    
    const char *path = [self getPath:@"box/newest" : @"obj"];
    model.loadModel(path);
    model.bindVertexData();
    model.bindTexturesData();
    
    [self initDepthFramebuffer];
    [self initSSAOFramebuffer];
    [self initNormalFramebuffer];

    [self initMatrix];
    [self getLocations];
    glEnable(GL_DEPTH_TEST);
}

- (void)bindShowTexture
{
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
    glBindBuffer(GL_ARRAY_BUFFER, 0);

}

- (void)bindSSAOData
{
    glGenVertexArraysOES(1, &_ssaoVao);

    glBindVertexArrayOES(_ssaoVao);
    glGenBuffers(1, &_ssaoVbo);
    glBindBuffer(GL_ARRAY_BUFFER, _ssaoVbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(screenXYs), screenXYs, GL_STATIC_DRAW);
    
    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, 2 * sizeof(GLfloat), (GLvoid *)0);
    
    glBindVertexArrayOES(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
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

#pragma mark - initMatrix
- (void)initMatrix
{
    GLfloat aspect = self.view.frame.size.width / self.view.frame.size.height;
    _projectionMatrix = glm::perspective(glm::radians(45.0f), aspect, 1.5f, 100.0f);
    _modelMatrix = glm::rotate(_modelMatrix, glm::radians(-90.0f),  glm::vec3(1.5f, 0.0f, 0.0f));
    _modelMatrix = glm::translate(_modelMatrix, glm::vec3(0.0f, 0.0f, -0.75f));
    _modelMatrix = glm::scale(_modelMatrix, glm::vec3(0.006f, 0.006f, 0.006f));
}

#pragma mark - location
-(void)getLocations
{
    /**get the first pass**/
    _depthLocations.shadowMVPLocation = glGetUniformLocation(self.depthProgram.program, "shadowMVP");
    
    /**get the second pass**/
    _normalLocations.shadowMVPLocation = glGetUniformLocation(self.normalProgram.program, "shadowMVP");
    _normalLocations.MVPLocation = glGetUniformLocation(self.normalProgram.program, "MVP");
    _normalLocations.normalMatrixLocation = glGetUniformLocation(self.normalProgram.program, "normalMatrix");
    
    
    /**get the ssao pass**/
    _ssaoLocations.depthTextureLocation = glGetUniformLocation(self.ssaoProgram.program, "depthTexture");
    _ssaoLocations.winParamesLocation = glGetUniformLocation(self.ssaoProgram.program, "winParames");
    _ssaoLocations.projectionMatrixLocation = glGetUniformLocation(self.ssaoProgram.program, "P");
}

#pragma mark - render

-(void)renderDepth
{
    glUseProgram(self.depthProgram.program);
    glBindFramebuffer(GL_FRAMEBUFFER, _depthFbo);
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    glClearDepthf(1.0f);
    glClear(GL_DEPTH_BUFFER_BIT);
    
    /***为实现ssao查看效果，暂时让光源的位置就在相机处，这样产生的深度信息与正常渲染的颜色缓存位置匹配**/
    glm::mat4 lightView =glm::lookAt(glm::vec3(0, 0.48, 4.3), glm::vec3(0.0, 0.0, -1.0), glm::vec3(0.0, 1.0, 0.0));
    //glm::mat4 lightView = camera.getView();
    
    _shadowMVP = _projectionMatrix * lightView * _modelMatrix;
    
    glUniformMatrix4fv(_depthLocations.shadowMVPLocation, 1, GL_FALSE, glm::value_ptr(_shadowMVP));
    
    glEnable(GL_POLYGON_OFFSET_FILL);
    glPolygonOffset(2.0f, 4.0f);
    model.drawDepth();
    glDisable(GL_POLYGON_OFFSET_FILL);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

- (void) renderNormal
{
    glUseProgram(self.normalProgram.program);
    glBindFramebuffer(GL_FRAMEBUFFER, self.normalFbo);
    glViewport(0, 0, kWindowWidth, kWindowHeight);
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    [self setLight];
    
    glm::mat4 bias = glm::mat4 (glm::vec4(0.5f, 0.0f, 0.0f, 0.0f),
                                glm::vec4(0.0f, 0.5f, 0.0f, 0.0f),
                                glm::vec4(0.0f, 0.0f, 0.5f, 0.0f),
                                glm::vec4(0.5f, 0.5f, 0.5f, 1.0f));
    
    glm::mat4 depthBiasMVP = bias * _shadowMVP;
    
    glUniformMatrix4fv(_normalLocations.shadowMVPLocation, 1, GL_FALSE, glm::value_ptr(depthBiasMVP));
    
    glm::mat4 viewMatrix, modelView, modelViewProjection, normalMatrix;
    
    viewMatrix = camera.getView();
    
    modelView = viewMatrix * _modelMatrix;
    modelViewProjection = _projectionMatrix * modelView;
    normalMatrix = glm::transpose(glm::inverse(modelView));
    
    glUniformMatrix4fv(_normalLocations.normalMatrixLocation, 1, GL_FALSE, glm::value_ptr(normalMatrix));
    glUniformMatrix4fv(_normalLocations.MVPLocation, 1, GL_FALSE, glm::value_ptr(modelViewProjection));
    
    model.drawNormal(self.normalProgram.program, _lightDepthTexture);
}

- (void)renderSSAO
{
    glUseProgram(self.ssaoProgram.program);
    glBindFramebuffer(GL_FRAMEBUFFER, _ssaoFbo);
    glClearColor(1.0, 1.0, 1.0, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    glUniformMatrix4fv(_ssaoLocations.projectionMatrixLocation, 1, GL_FALSE,glm::value_ptr(_projectionMatrix));
    ////winRatio, near, far, winWidth
    glUniform4f(_ssaoLocations.winParamesLocation, self.view.frame.size.width / self.view.frame.size.height, kNear, kFar, self.view.frame.size.width);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, self.cameraDepthTexture);
    glUniform1i(_ssaoLocations.depthTextureLocation, 0);
    
    glBindVertexArrayOES(_ssaoVao);
    glBindBuffer(GL_ARRAY_BUFFER, _ssaoVbo);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindVertexArrayOES(0);
}

/**在颜色纹理上施加AO**/
- (void)renderResult
{
    
}

- (void) drawShadowMapping
{
    glUseProgram(self.shadowMapProgram.program);
    
    glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glViewport(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    glActiveTexture(GL_TEXTURE0);
    //glBindTexture(GL_TEXTURE_2D, _lightDepthTexture);
    glBindTexture(GL_TEXTURE_2D, _ssaoTexture);
    //glBindTexture(GL_TEXTURE_2D, _normalTextue);
    //glBindTexture(GL_TEXTURE_2D, _cameraDepthTexture);
    glUniform1i(glGetUniformLocation(self.shadowMapProgram.program, "shadowMap"), 0);
    
    glBindVertexArrayOES(_vao);
    glDrawArrays(GL_TRIANGLES, 0, 6);
    glBindVertexArrayOES(0);
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    [self renderDepth];
    [self renderNormal];
    [self renderSSAO];
    [view bindDrawable];
    [self drawShadowMapping];
}

#pragma mark - 初始化不同阶段要使用的Framebuffer

- (void)initSSAOFramebuffer
{
    /*测试使用的图片数据*/
//    GLubyte image[(int)kWindowWidth][(int)kWindowHeight][3];
//    for (int i = 0; i < (int)kWindowWidth; ++i) {
//        for (int j = 0; j < (int)kWindowHeight; ++j) {
//            image[i][j][1] =  255;
//            image[i][j][0] = image[i][j][2] = 0;
//         }
//    }
    glGenTextures(1, &_ssaoTexture);
    glBindTexture(GL_TEXTURE_2D, _ssaoTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, kWindowWidth, kWindowHeight, 0, GL_RGB, GL_UNSIGNED_BYTE, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glGenFramebuffers(1, &_ssaoFbo);
    glBindFramebuffer(GL_FRAMEBUFFER, _ssaoFbo);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, self.ssaoTexture, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

-(void)initDepthFramebuffer
{
    glGenTextures(1, &_lightDepthTexture);
    glBindTexture(GL_TEXTURE_2D, _lightDepthTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_FUNC_EXT, GL_LEQUAL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_MODE_EXT, GL_COMPARE_REF_TO_TEXTURE_EXT);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, kWindowWidth, kWindowHeight, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_INT, 0);
    
    glBindTexture(GL_TEXTURE_2D, 0);
    glGenFramebuffers(1, &_depthFbo);
    glBindFramebuffer(GL_FRAMEBUFFER, _depthFbo);
    
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, self.lightDepthTexture, 0);
    
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

- (void)initNormalFramebuffer
{
    glGenTextures(1, &_normalTextue);
    glBindTexture(GL_TEXTURE_2D, _normalTextue);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, kWindowWidth, kWindowHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, 0);
    glBindTexture(GL_TEXTURE_2D, 0);
    
    glGenTextures(1, &_cameraDepthTexture);
    glBindTexture(GL_TEXTURE_2D, _cameraDepthTexture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_FUNC_EXT, GL_LEQUAL);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_COMPARE_MODE_EXT, GL_COMPARE_REF_TO_TEXTURE_EXT);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_DEPTH_COMPONENT, kWindowWidth, kWindowHeight, 0, GL_DEPTH_COMPONENT, GL_UNSIGNED_INT, 0);
    glBindTexture(GL_TEXTURE_2D, 0);

    
    //GLuint depthBuffer;
    //glGenRenderbuffers(1, &depthBuffer);
    //glBindRenderbuffer(GL_RENDERBUFFER, depthBuffer);
    //glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT24_OES, kWindowWidth, kWindowHeight);
    
    glGenFramebuffers(1, &_normalFbo);
    glBindFramebuffer(GL_FRAMEBUFFER, _normalFbo);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, self.normalTextue, 0);
//    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthBuffer);
    glFramebufferTexture2D(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_TEXTURE_2D, self.cameraDepthTexture, 0);
    glBindFramebuffer(GL_FRAMEBUFFER, 0);
}

#pragma mark - 手势识别
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint current = [touch locationInView:self.view];
    CGPoint previous = [touch previousLocationInView:self.view];
    
    float diffx = current.x - previous.x;
    float diffy = current.y - previous.y;
    
    if(diffx > 0.0f) {
        camera.progressKeyBoard(RIGHT);
    } else {
        camera.progressKeyBoard(LEFT);
    }
    
    if(diffy > 0.0f) {
        camera.progressKeyBoard(BACK);
    } else {
        camera.progressKeyBoard(FRONT);
    }
}

- (void) motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        camera = Camera();
    }
}

#pragma mark - get resource path
- (const char *)getPath:(NSString *)filename :(NSString *)type {
    NSString *path = [[NSBundle mainBundle] pathForResource:filename ofType:type];
    const char *pathString = [path UTF8String];
    return pathString;
}
@end

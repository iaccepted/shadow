//
//  NormalProgram.m
//  shadow
//
//  Created by iaccepted on 15/5/7.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//

#import "NormalProgram.h"



@implementation NormalProgram

- (id)linkProgramWithShaderName:(NSString *)name
{
    GLuint vertShader, fragShader;
    NSString *vpath, *fpath;
    
    // Create shader program.
    self.program = glCreateProgram();
    
    // Create and compile vertex shader.
    vpath = [self getPath:@"normal" :@"vsh"] ;
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vpath]) {
        NSLog(@"Failed to compile vertex shader");
        exit(-1);
    }
    
    // Create and compile fragment shader.
    fpath = [self getPath:@"normal" :@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fpath]) {
        NSLog(@"Failed to compile fragment shader");
        exit(-1);
    }
    
    // Attach vertex shader to program.
    glAttachShader(self.program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(self.program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(self.program, ATTRIB_POSITION, "vposition");
    glBindAttribLocation(self.program, ATTRIB_NORMAL, "vnormal");
    glBindAttribLocation(self.program, ATTRIB_TEXTCOORD, "textcoord");
    
    // Link program.
    if (![self linkProgram:self.program]) {
        NSLog(@"Failed to link program: %d", self.program);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (self.program) {
            glDeleteProgram(self.program);
            self.program = 0;
        }
        exit(-1);
    }
    
    uniformLocs[UNIFORM_MVP] = glGetUniformLocation(self.program, "MVP");
    uniformLocs[UNIFORM_SHADOW_MVP] = glGetUniformLocation(self.program, "shadowMVP");
    uniformLocs[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(self.program, "normalMatrix");
    uniformLocs[UNIFORM_SHADOW_MAP] = glGetUniformLocation(self.program, "shadowMap");
    uniformLocs[UNIFORM_LIGHT_DIRECTION] = glGetUniformLocation(self.program, "light.direction");
    uniformLocs[UNIFORM_LIGHT_COLOR] = glGetUniformLocation(self.program, "light.color");
    uniformLocs[UNIFORM_AMBIENT] = glGetUniformLocation(self.program, "material.ambient");
    uniformLocs[UNIFORM_DIFFUSE] = glGetUniformLocation(self.program, "material.diffuse");
    uniformLocs[UNIFORM_SPECULAR] = glGetUniformLocation(self.program, "material.specular");
    uniformLocs[UNIFORM_SHININESS] = glGetUniformLocation(self.program, "material.shininess");
    uniformLocs[UNIFORM_ALPHA] = glGetUniformLocation(self.program, "material.alpha");
    
    
    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(self.program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(self.program, fragShader);
        glDeleteShader(fragShader);
    }
    return self;

}

@end

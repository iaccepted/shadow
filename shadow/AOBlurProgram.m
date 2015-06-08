//
//  AOBlurProgram.m
//  shadow
//
//  Created by iaccepted on 15/6/8.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//

#import "AOBlurProgram.h"

@implementation AOBlurProgram

- (id)linkProgramWithShaderName: (NSString *) name
{
    GLuint vertShader, fragShader;
    NSString *vpath, *fpath;
    
    // Create shader program.
    self.program = glCreateProgram();
    
    // Create and compile vertex shader.
    vpath = [self getPath:name :@"vsh"] ;
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vpath]) {
        NSLog(@"Failed to compile vertex shader");
        exit(-1);
    }
    
    // Create and compile fragment shader.
    fpath = [self getPath:name :@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fpath]) {
        NSLog(@"Failed to compile fragment shader");
        exit(-1);
    }
    
    glAttachShader(self.program, vertShader);
    glAttachShader(self.program, fragShader);
    
    glBindAttribLocation(self.program, 0, "screenPosXY");
    
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

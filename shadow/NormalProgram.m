//
//  NormalProgram.m
//  shadow
//
//  Created by iaccepted on 15/5/7.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//

#import "NormalProgram.h"

//enum
//{
//    NORMAL_ATTRIB_POSITION,
//    NORMAL_ATTRIB_NORMAL,
//    NORMAL_ATTRIB_TEXTCOORD,
//    NORMAL_ATTRIB_NUM
//};
//
//enum{
//    NORMAL_UNIFORM_SHADOW_MVP,
//    NORMAL_UNIFORM_MVP,
//    NORMAL_UNIFORM_NORMAL_MATRIX,
//    NORMAL_UNIFORM_SHADOW_MAP,
//    NORMAL_UNIFORM_LIGHT_DIRECTION,
//    NORMAL_UNIFORM_LIGHT_COLOR,
//    NORMAL_UNIFORM_AMBIENT,
//    NORMAL_UNIFORM_DIFFUSE,
//    NORMAL_UNIFORM_SPECULAR,
//    NORMAL_UNIFORM_SHININESS,
//    NORMAL_UNIFORM_ALPHA,
//    NORMAL_UNIFORM_NUM
//};

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
    glBindAttribLocation(self.program, 0, "vposition");
    glBindAttribLocation(self.program, 1, "vnormal");
    glBindAttribLocation(self.program, 2, "textcoord");
    
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

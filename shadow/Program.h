//
//  Program.h
//  shadow
//
//  Created by iaccepted on 15/5/7.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/ES2/gl.h>

@interface Program : NSObject

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (NSString *)getPath:(NSString *)filename :(NSString *)type;

@property(nonatomic, assign) GLuint program;

@end

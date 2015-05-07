//
//  DepthProgram.h
//  shadow
//
//  Created by iaccepted on 15/5/7.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//

#import "Program.h"

enum
{
    DEPTH_ATTRIB_POSITION
};

enum{
    DEPTH_UNIFORM_SHADOW_MVP,
    DEPTH_UNIFORM_NUM
};

GLuint depthUniforms[DEPTH_UNIFORM_NUM];

@interface DepthProgram : Program
{
    
}
- (id)linkProgramWithShaderName: (NSString *) name;

@end

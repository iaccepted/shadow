//
//  DepthProgram.h
//  shadow
//
//  Created by iaccepted on 15/5/7.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//

#import "Program.h"

enum{
    UNIFORM_SHADOW_MVP,
    UNIFORM_NUM
};

@interface DepthProgram : Program
{
    GLuint uniformLocs[UNIFORM_NUM];
}
- (id)linkProgramWithShaderName: (NSString *) name;

@end

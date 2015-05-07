//
//  NormalProgram.h
//  shadow
//
//  Created by iaccepted on 15/5/7.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//

#import "Program.h"



enum{
    UNIFORM_MVP,
    UNIFORM_SHADOW_MVP,
    UNIFORM_NORMAL_MATRIX,
    UNIFORM_SHADOW_MAP,
    UNIFORM_LIGHT_DIRECTION,
    UNIFORM_LIGHT_COLOR,
    UNIFORM_AMBIENT,
    UNIFORM_DIFFUSE,
    UNIFORM_SPECULAR,
    UNIFORM_SHININESS,
    UNIFORM_ALPHA,
    UNIFORM_NUM
};

@interface NormalProgram : Program
{
    GLuint uniformLocs[UNIFORM_NUM];
}
- (id)linkProgramWithShaderName: (NSString *) name;

@end

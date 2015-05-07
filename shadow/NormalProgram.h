//
//  NormalProgram.h
//  shadow
//
//  Created by iaccepted on 15/5/7.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//

#import "Program.h"

enum
{
    NORMAL_ATTRIB_POSITION,
    NORMAL_ATTRIB_NORMAL,
    NORMAL_ATTRIB_TEXTCOORD,
    NORMAL_ATTRIB_NUM
};

enum{
    NORMAL_UNIFORM_SHADOW_MVP,
    NORMAL_UNIFORM_MVP,
    NORMAL_UNIFORM_NORMAL_MATRIX,
    NORMAL_UNIFORM_SHADOW_MAP,
    NORMAL_UNIFORM_LIGHT_DIRECTION,
    NORMAL_UNIFORM_LIGHT_COLOR,
    NORMAL_UNIFORM_AMBIENT,
    NORMAL_UNIFORM_DIFFUSE,
    NORMAL_UNIFORM_SPECULAR,
    NORMAL_UNIFORM_SHININESS,
    NORMAL_UNIFORM_ALPHA,
    NORMAL_UNIFORM_NUM
};
GLuint normalUniforms[NORMAL_UNIFORM_NUM];

@interface NormalProgram : Program
{
    
}
- (id)linkProgramWithShaderName: (NSString *) name;

@end

//
//  ShadowMapProgram.h
//  shadow
//
//  Created by iaccepted on 15/5/7.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//

#import "Program.h"

@interface DrawTextureProgram : Program

- (id)linkProgramWithShaderName: (NSString *) name;

@end

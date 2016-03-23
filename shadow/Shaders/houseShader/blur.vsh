//
//  blur.vsh
//  shadow
//
//  Created by iaccepted on 15/6/8.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//

attribute highp vec2 screenPosXY;
varying highp vec2 uv;

void main()
{
    gl_Position = vec4(screenPosXY, 0.0, 1.0);
    uv = (screenPosXY + vec2(1.0, 1.0)) * 0.5;
}
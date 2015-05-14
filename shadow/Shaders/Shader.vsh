//
//  Shader.vsh
//  ddfs
//
//  Created by iaccepted on 15/5/7.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//

attribute vec4 vposition;
attribute vec2 textcoord;

uniform sampler2D shadowMap;

varying lowp vec4 color;

void main()
{
    gl_Position = vposition;
    color = vec4(texture2D(shadowMap, textcoord).rgb, 1.0);
    //color = vec4(1.0, 0.0, 0.0, 1.0);
}

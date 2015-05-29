//
//  Shader.fsh
//  ddfs
//
//  Created by iaccepted on 15/5/7.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//

uniform sampler2D shadowMap;

varying lowp vec2 ftextcoord;

void main()
{
    highp vec4 rgb = texture2D(shadowMap, ftextcoord);
    gl_FragColor = rgb;
}

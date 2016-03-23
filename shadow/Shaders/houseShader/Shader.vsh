//
//  Shader.vsh
//  ddfs
//
//  Created by iaccepted on 15/5/7.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//

attribute vec4 vposition;
attribute vec2 textcoord;

varying lowp vec2 ftextcoord;

void main()
{
    gl_Position = vposition;
    ftextcoord = textcoord;
    //color = vec4(texture2D(shadowMap, textcoord).rgb, 1.0);
    //color = vposition;
}

//
//  Shader.fsh
//  ddfs
//
//  Created by iaccepted on 15/5/7.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//

uniform sampler2D texture;

varying lowp vec2 ftextcoord;

void main()
{
    gl_FragColor = texture2D(texture, ftextcoord);
    //highp vec2 uv = vec2(ftextcoord.x, 1.0-ftextcoord.y);
    //gl_FragColor = vec4(texture2D(texture, uv).yyy, 1.0);
}

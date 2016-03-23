/*
 fshader.glsl
 opengl
 
 Created by iaccepted on 15/4/9.
 Copyright (c) 2015年 iaccepted. All rights reserved.
 */
#extension GL_EXT_shadow_samplers : require

varying highp vec3 fposition;
varying highp vec2 ftextcoord;
varying highp vec4 fshadowCoord;
varying highp vec3 feyeNormal;

uniform int flag;

uniform sampler2D texture;


struct Light
{
    highp vec3  direction;
    lowp vec3 color;
};

struct Material
{
    highp vec3  ambient;
    highp vec3  diffuse;
    highp vec3  specular;
    highp float shininess;
    highp float alph;
};

uniform Light light;
uniform Material material;

//uniform sampler2DShadow depthTexture;
uniform sampler2D depthTexture;

const lowp float kShadowAmount = 0.4;

const highp float g_minVariance = 0.003;

highp float linstep(in highp float low, in highp float high, in highp float v)
{
    return clamp((v-low) / (high - low), 0.0, 1.0);
}

//利用切比雪夫不等式计算遮挡的概率上界
highp float chebyshev_upper_bound(in highp vec2 uv, in highp float t)
{
    highp vec2 moments = texture2D(depthTexture, uv).xy;
    
    //highp float p = smoothstep(depthCurrent - 0.2, depthCurrent, moments.x);
    
    highp float p = 0.0;
    if (t <= moments.x) {
        return 1.0;
    }
    highp float variance = moments.y - (moments.x * moments.x);
    variance = max(variance, g_minVariance);
    
    highp float d = t - moments.x;
    highp float p_max = variance / (variance + d * d);

    return linstep(0.10, 1.0, p_max);
//    return smoothstep(0.30, 1.0, p_max);
}

/*code on github*/
 
//highp float chebyshev_upper_bound(in highp vec2 uv, in highp float t)
//{
//    highp vec2 moments = texture2D(depthTexture, uv).xy;
//    
//    highp float p = 0.0;
//    if (t <= moments.x) {
//        p = 1.0;
//    }
//    highp float variance = moments.y - (moments.x * moments.x);
//    variance = max(variance, 0.0001);
//    
//    highp float d = t - moments.x;
//    highp float p_max = variance / (variance + d * d);
//    p_max = linstep(0.2, 1.0, p_max);
//    
//    return min(max(p, p_max), 1.0);
//}

void main()
{
    lowp vec4 textColor = texture2D(texture, ftextcoord);
    
    highp vec3 lightDirection = normalize(light.direction);
    highp float diff = max(dot(lightDirection, feyeNormal), 0.0);
    highp vec3 ambient;
    highp vec3 diffuse;
    if (textColor[0] < 0.0001 && textColor[1] < 0.0001 && textColor[2] < 0.0001) {
        //ambient
        ambient = material.ambient * light.color;
        //diffuse
        diffuse = diff * material.diffuse * light.color;
    }
    else
    {
        //ambient
        ambient = vec3(textColor * vec4(material.ambient * light.color, 1.0));
        //diffuse
        diffuse = vec3(textColor * diff * vec4(material.diffuse * light.color, 1.0));
    }
    
    highp vec3 viewDirection = normalize(fposition);
    highp vec3 reflectDirection = normalize(reflect(-light.direction, feyeNormal));
    highp float spec = pow(max(dot(viewDirection, reflectDirection), 0.0), material.shininess);
    highp vec3 specular = spec * material.specular * light.color;

    highp vec2 depthUV = fshadowCoord.xy / fshadowCoord.w;
    highp float depthCurrent = fshadowCoord.z / fshadowCoord.w;

    highp float factor = chebyshev_upper_bound(depthUV, depthCurrent);
    
    factor = 0.85 * factor + 0.15;
    gl_FragColor = factor * vec4(ambient + specular + diffuse, 1.0);
//    gl_FragColor = vec4(ambient + specular + diffuse, 1.0);
    //gl_FragColor = vec4(factor * (ambient + specular +  diffuse), material.alph);
    
//    //使用shadow2DProj函数得结果     depthTexture是samper2DShadow类型
//    highp float r = (1.0 - kShadowAmount) + kShadowAmount * shadow2DProjEXT(depthTexture, fshadowCoord);
//    gl_FragColor = vec4(r * (ambient + specular + diffuse), material.alph);
}

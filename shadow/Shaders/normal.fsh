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

//uniform sampler2D shadowMap;
uniform sampler2DShadow shadowMap;
const lowp float kShadowAmount = 0.4;

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

    //test
//    highp float r = texture2D(shadowMap,  (fshadowCoord / fshadowCoord.w).xy).z;
//    //highp float r = fshadowCoord.z / fshadowCoord.w;
//    gl_FragColor = vec4(r, r, r, material.alph);
    
    //highp float r = tposition.z / tposition.w;
    //gl_FragColor = vec4(r, r, r, material.alph);

    //使用shadow2DProj函数得结果     shadowMap是samper2DShadow类型
        highp float r = (1.0 - kShadowAmount) + kShadowAmount * shadow2DProjEXT(shadowMap, fshadowCoord);
        gl_FragColor = vec4(r * (ambient + specular + diffuse), material.alph);
    
    //直接计算深度然后比较    shadowMap 是 samper2D类型
//    highp float r = texture2D(shadowMap,  (fshadowCoord / fshadowCoord.w).xy).z;
//    highp float visibility = 1.0;
//    if( r < (fshadowCoord.z / fshadowCoord.w) + 0.005)
//    {
//        visibility = 0.4;
//    }
//    gl_FragColor = vec4(visibility * (ambient + specular + diffuse), material.alph);
//    highp float r = texture2D(shadowMap,  (fshadowCoord).xy).z;
//    highp float visibility = 1.0;
//    if( r < (fshadowCoord.z) + 0.005)
//    {
//        visibility = 0.4;
//    }
//    gl_FragColor = vec4(visibility * (ambient + specular + diffuse), material.alph);
}

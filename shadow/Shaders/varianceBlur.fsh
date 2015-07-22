varying highp vec2 uv;

uniform sampler2D inTexture;
uniform highp vec2 textSize;//width and height

//highp float gaussian[9];
//
//void init()
//{
//    gaussian[0] = 1.0 / 16.0;
//    gaussian[1] = 2.0 / 16.0;
//    gaussian[2] = 1.0 / 16.0;
//    gaussian[3] = 2.0 / 16.0;
//    gaussian[4] = 4.0 / 16.0;
//    gaussian[5] = 2.0 / 16.0;
//    gaussian[6] = 1.0 / 16.0;
//    gaussian[7] = 2.0 / 16.0;
//    gaussian[8] = 1.0 / 16.0;
//}
//
//void main()
//{
//    int blurSize = 3;
//    
//    init();
//    
//    highp vec2 rate = vec2(1.0 / textSize);
//    highp vec2 baseCenter = vec2(float(-blurSize / 2));
//    highp vec2 result = vec2(0.0);
//    
//    
//    
//    for (int i = 0; i < blurSize; ++i) {
//        for (int j = 0; j < blurSize; ++j) {
//            highp vec2 offset = (baseCenter + vec2(float(i), float(j))) * rate;
//            result += gaussian[i * blurSize + j] * texture2D(inTexture, uv + offset).xy;
//        }
//    }
//    
//    gl_FragColor = vec4(result, 0.0, 1.0);
//}

//void main()
//{
//    int blurSize = 5;
//    
//    highp vec2 rate = 1.0 / textSize;
//    highp vec2 baseCenter = vec2(float(-blurSize / 2));
//    highp vec2 result = vec2(0.0);
//    
//    
//    
//    for (int i = 0; i < blurSize; ++i) {
//        for (int j = 0; j < blurSize; ++j) {
//            highp vec2 offset = (baseCenter + vec2(float(i), float(j))) * rate;
//            result += texture2D(inTexture, uv + offset).xy;
//        }
//    }
//    result /= float(blurSize * blurSize);
//    
//    gl_FragColor = vec4(result.xy, 0.0, 1.0);
//}

//void main()
//{
//    int blurSize = 7;
//    
//    highp vec2 rate = 1.0 / textSize;
//    highp vec2 baseCenter = vec2(float(-blurSize / 2));
//    highp vec2 result = vec2(0.0);
//    highp vec2 offset = vec2(0.0);
//    
//    for (int i = 0; i < blurSize; ++i) {
//        offset = (baseCenter + vec2(0, float(i))) * rate;
//        result += texture2D(inTexture, uv + offset).xy;
//    }
//    
//    for (int i = 0; i < blurSize; ++i) {
//        offset = (baseCenter + vec2(float(i), 0)) * rate;
//        result += texture2D(inTexture, uv + offset).xy;
//    }
//    
//    result /= float((blurSize * 2) - 1);
//    gl_FragColor = vec4(result.xy, 0.0, 1.0);
//}

void main()
{
    highp vec2 result = vec2(0.0);
    highp vec2 rate = 1.0 / textSize;

    
    result += texture2D(inTexture, uv + (vec2(-3.0) * rate)).xy * (1.0 / 64.0);
    result += texture2D(inTexture, uv + (vec2(-2.0) * rate)).xy * (6.0 / 64.0);
    result += texture2D(inTexture, uv + (vec2(-1.0) * rate)).xy * (15.0 / 64.0);
    result += texture2D(inTexture, uv + (vec2(0.0) * rate)).xy * (20.0 / 64.0);
    result += texture2D(inTexture, uv + (vec2(1.0) * rate)).xy * (15.0 / 64.0);
    result += texture2D(inTexture, uv + (vec2(2.0) * rate)).xy * (6.0 / 64.0);
    result += texture2D(inTexture, uv + (vec2(3.0) * rate)).xy * (1.0 / 64.0);
    
    gl_FragColor = vec4(result.xy, 0.0, 1.0);
}
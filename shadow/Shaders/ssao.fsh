#extension GL_OES_standard_derivatives : require

varying highp vec2 uv;

uniform sampler2D depthTexture;
uniform sampler2D colorTexture;
uniform highp mat4 P;
uniform highp vec4 winParames;//winRatio, near, far, winWidth

uniform highp float radius;
highp float distanceThreshold = 5.0;

const int samplesCount = 8;
highp float samplesCountF = 8.0;

highp vec2 poisson[samplesCount];


//0 vec2( -0.94201624,  -0.39906216 );
//1    vec2(  0.94558609, -0.76890725),
//2	vec2( -0.094184101, -0.92938870 ),
//3    vec2(  0.34495938,   0.29387760 ),
//4    vec2( -0.91588581,   0.45771432 ),
//5    vec2( -0.81544232,  -0.87912464 ),
//6    vec2( -0.38277543,   0.27676845 ),
//7    vec2(  0.97484398,   0.75648379 ),
//8    vec2(  0.44323325,  -0.97511554 ),
//9    vec2(  0.53742981,  -0.47373420 ),
//10    vec2( -0.26496911,  -0.41893023 ),
//11    vec2(  0.79197514,   0.19090188 ),
// 12   vec2( -0.24188840,   0.99706507 ),
// 13   vec2( -0.81409955,   0.91437590 ),
//  14  vec2(  0.19984126,   0.78641367 ),
//  15  vec2(  0.14383161,  -0.14100790 )


//重建点在view space中的坐标
highp vec3 calculatePosition(in highp vec2 uv2)
{
    highp vec3 viewRay = vec3( -(uv2.x * 2.0 - 1.0) * winParames[0], uv2.y * 2.0 - 1.0, P[1][1]);
    viewRay = normalize(viewRay);
    highp float d = mix(winParames[1], winParames[2], texture2D(depthTexture, uv2).r);
    highp float t = d / viewRay.z;
    return vec3( viewRay.x * t, viewRay.y * t, d );
}

//重建点的法线信息
highp vec3 calculateNormal(in highp vec3 pos)
{
    return normalize(cross(dFdx(pos), dFdy(pos)));
}

//采样偏移，poisson分布的随机数
void initPoisson()
{
    poisson[0] = vec2( -0.94201624,  -0.39906216 );
    poisson[1] = vec2(  0.94558609, -0.76890725);
    poisson[2] = vec2( -0.094184101, -0.92938870 );
    poisson[3] = vec2(  0.34495938,   0.29387760 );
    poisson[4] = vec2( -0.91588581,   0.45771432 );
    poisson[5] = vec2( -0.81544232,  -0.87912464 );
    poisson[6] = vec2( -0.38277543,   0.27676845 );
    poisson[7] = vec2(  0.97484398,   0.75648379 );
}

void main()
{
    initPoisson();
    highp vec2 filterRadius = vec2(radius / winParames[3], radius / (winParames[3] / winParames[0]));
    highp vec3 viewPos = calculatePosition(uv);
    highp vec3 viewNorm = calculateNormal(viewPos);
    highp float ambientOcclusion = 0.0;
    for (int i = 0; i < samplesCount; ++i) {
        highp vec2 sampleTextcoord = uv + (poisson[i] * filterRadius);
        highp vec3 samplePos = calculatePosition(sampleTextcoord);
        highp vec3 sampleDir = normalize(samplePos - viewPos);
        highp float dotNS = max(dot(viewNorm, sampleDir), 0.0);
        highp float distanceSV = distance(viewPos, samplePos);
        highp float a = 1.0 - smoothstep(distanceThreshold, distanceThreshold * 2.0, distanceSV);
        highp float b = dotNS;
        
        ambientOcclusion += (a * b);
    }
    highp float factor = 1.0 - (ambientOcclusion / samplesCountF);

    //gl_FragColor = vec4(factor, factor, factor, 1.0);
    gl_FragColor = factor * texture2D(colorTexture, uv);
}

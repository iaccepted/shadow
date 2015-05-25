varying vec2 uv;

uniform sampler2D depthTexture;

uniform vec4 winParames;//winRatio, near, far, winWidth
vec2 filterRadius = (10.0 / winParames[3], 10.0 / (winParames[3] / winParames[0]));
float distanceThreshold = 5.0;

const int samplesCount = 8;

const vec2 poisson[] = vec2[](
	vec2( -0.94201624,  -0.39906216 ),
	vec2( -0.094184101, -0.92938870 ),
    vec2(  0.34495938,   0.29387760 ),
    vec2( -0.91588581,   0.45771432 ),
    vec2( -0.81544232,  -0.87912464 ),
    vec2( -0.38277543,   0.27676845 ),
    vec2(  0.97484398,   0.75648379 )
    vec2(  0.44323325,  -0.97511554 ),
    vec2(  0.53742981,  -0.47373420 ),
    vec2( -0.26496911,  -0.41893023 ),
    vec2(  0.79197514,   0.19090188 ),
    vec2( -0.24188840,   0.99706507 ),
    vec2( -0.81409955,   0.91437590 ),
    vec2(  0.19984126,   0.78641367 ),
    vec2(  0.14383161,  -0.14100790 )
                              );

vec3 calculatePosition(in vec2 uv2)
{
    vec3 viewRay = vec3( -(uv2.x * 2.0 - 1.0) * winParames[0], uv2.y * 2.0 - 1.0, P[1][1]);
    viewRay = normalize(viewRay);
    float d = mix(winParames[1], winParames[2], texture2D(depthTexture, uv2).r);
    float t = d / viewRay.z;
    return vec3( viewRay.x * t, viewRay.y * t, d );
}

vec3 calculateNormal(in vec3 pos)
{
    return normalize(cross(dFdx(pos), dFdy(pos)));
}

void main()
{
    //重建点在view space中的坐标
    vec3 viewPos = calculatePosition(uv);
    
    vec3 viewNorm = calculateNormal(origPos);
    
    float ambientOcclusion = 0;
    for (int i = 0; i < sampleSize; ++i) {
        vec2 sampleTextcoord = uv + (poisson[i] * filterRadius);
        vec3 samplePos = calculatePosition(sampleTextcoord);
        vec3 sampleDir = normalize(samplePos - viewPos);
        float dotNS = max(dot(viewNorm, sampleDir), 0.0);
        float distanceSV = distance(viewPos, samplePos);
        
        float a = 1.0 - smoothstep(distanceThreshold, distanceThreshold * 2, distanceSV);
        float b = dotNS;
        
        ambientOcclusion += (a * b);
    }
    gl_FragColor.r = 1 - (ambientOcclusion / samplesCount);
}
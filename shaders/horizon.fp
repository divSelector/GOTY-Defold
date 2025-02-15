varying mediump vec2 var_texcoord0;

uniform lowp vec4 horizon;
uniform lowp vec4 top_color;
uniform lowp vec4 bottom_color;

float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

void main()
{
    vec2 res = vec2(1.78, 1.0);
    vec2 uv = var_texcoord0.xy * res.xy;

    float horizonParallax = horizon.x;
    float horizonTime = horizon.y;
    float horizonSpeed = horizon.z;
    float horizonStarThreshold = horizon.w;

    float scrollOffset = horizonParallax + horizonSpeed;

    float horizonCurvature = 0.1;
    float horizonHeight = 0.3;  // 0.3

    float curve = horizonHeight - horizonCurvature * pow(uv.x - 0.5, 2.0);

    float mixFactor = smoothstep(curve - 0.02, curve + 0.02, uv.y);

    vec3 topColor = vec3(top_color.x, top_color.y, top_color.z);
    vec3 bottomColor = vec3(bottom_color.x, bottom_color.y, bottom_color.z);

    vec3 color = mix(bottomColor, topColor, mixFactor);

    if (mixFactor > 0.6) {
        // vec2 starPos = floor(uv * 300.0); // Grid for star placement, large grid = smaller stars
        vec2 starPos = floor((uv + vec2(scrollOffset * 0.05, 0.0)) * 300.0); 
        float star = rand(starPos); // Randomly place stars

        if (star > horizonStarThreshold) { // Threshold for star density
            // float twinkle = 0.5 + 0.5 * sin(horizonTime + starPos.x * 10.0); // Twinkling effect
            // color += vec3(1.0) * twinkle; // Bright white stars

            // float glow = smoothstep(0.90, 1.0, star); // Controls glow spread
            // vec3 purpleTint = vec3(0.6, 0.2, 0.8);    // Purple color
            // color += purpleTint * glow * 0.3;         // Blend purple into sky

            float twinkle = 0.5 + 0.5 * sin(horizonTime * 3.0 + starPos.x * 10.0);

            // Bright white star
            vec3 starColor = vec3(1.0) * twinkle;

            // Create a purple glow around the star
            float glow = smoothstep(0.93, 0.98, star); // Controls glow radius
            vec3 glowColor = vec3(0.4, 0.1, 0.5); // Soft purple color

            // Blend the glow into the surrounding space (not affecting the star itself)
            color = mix(color, glowColor, glow * 0.6); 

            // Add the bright star on top
            color += starColor * 0.5;

        }
    }

    gl_FragColor = vec4(color, 1.0);
}

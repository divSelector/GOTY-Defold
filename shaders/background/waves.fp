varying mediump vec2 var_texcoord0;

uniform lowp vec4 waves;
uniform lowp vec4 top_color;
uniform lowp vec4 bottom_color;

void main()
{
    vec2 res = vec2(1.78, 1.0);
    vec2 uv = var_texcoord0.xy * res.xy;

    float waveParallax = waves.x;
    float waveFrequency = waves.y;
    float waveAmplitude = waves.z;
    float waveSpeed = waves.w;

    float scrollOffset = waveSpeed * waveParallax;

    float wave1 = waveAmplitude * sin(waveFrequency * (uv.x + scrollOffset));
    float wave2 = waveAmplitude * cos(waveFrequency * (uv.x + scrollOffset) + 3.14159 / 2.0);
    float wave3 = waveAmplitude * sin(waveFrequency * (uv.x + scrollOffset) + 1.14159);
    float wave4 = waveAmplitude * cos(waveFrequency * (uv.x + scrollOffset) + 3.14159);
    float wave5 = waveAmplitude * sin(waveFrequency * (uv.x + scrollOffset) + 4.71239);

    float combinedWave = max(wave1, max(wave2, max(wave3, max(wave4, wave5))));

    vec3 topColor = vec3(top_color.x, top_color.y, top_color.z);
    vec3 bottomColor = vec3(bottom_color.x, bottom_color.y, bottom_color.z);

    vec3 color = mix(bottomColor, topColor, step(combinedWave, uv.y));

    gl_FragColor = vec4(color, 1.0);
}

#version 330 core
out vec4 FragColor;

in vec3 vColor;
in vec2 TexCoord;

uniform vec3 testColor;
uniform sampler2D texture1;
uniform sampler2D texture2;

void main()
{
    // FragColor = vec4(testColor, 1.0f); // IGNORE
    // FragColor = vec4(vColor, 1.0f); // IGNORE
    FragColor = mix(texture(texture1, TexCoord), texture(texture2, TexCoord), 0.2);
}

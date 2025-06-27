#version 330 core
out vec4 FragColor;

in vec3 vColor;
in vec2 TexCoord;

uniform vec3 testColor;
uniform sampler2D ourTexture;

void main()
{
    FragColor = vec4(testColor, 1.0f); // IGNORE
    FragColor = vec4(vColor, 1.0f); // IGNORE
    FragColor = texture(ourTexture, TexCoord);
}

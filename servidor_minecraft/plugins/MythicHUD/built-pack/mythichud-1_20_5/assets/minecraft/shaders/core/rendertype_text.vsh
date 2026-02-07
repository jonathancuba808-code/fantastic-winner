#version 150

#moj_import <fog.glsl>
#moj_import <light.glsl>

in vec3 Position;
in vec4 Color;
in vec2 UV0;
in ivec2 UV2;

uniform sampler2D Sampler0;

uniform mat4 ModelViewMat;
uniform mat4 ProjMat;
uniform mat3 IViewRotMat;
uniform int FogShape;
uniform vec2 ScreenSize;

out float vertexDistance;
out vec4 vertexColor;
out vec2 texCoord0;

#define MH_VERSION 5
#define MH_OFFSET 67
#define XP_HIDE false
#define XP_OFFSET vec3(-10600.0, -10600.0, -10600.0)
#define XP_COLOR vec3(0.501, 1.0, 0.125)
#define XP_COLOR_SHADOW vec3(0.0, 0.0, 0.0)

// Function to convert a vertical ascent into a ID.
float get_id(float offset) {
    if (offset <= 0.0)
        return 0.0;
    return trunc(offset / 1000.0);
}

bool is_at(int offset, int vertex, int pos) { return (((vertex == 1 || vertex == 2) && offset == pos) || ((vertex == 0 || vertex == 3) && offset == (pos + 8))); }
bool is_at(int offset, int vertex, int pos0, int pos1) { return is_at(offset, vertex, pos0) || is_at(offset, vertex, pos1); }
bool is_at(int offset, int vertex, int pos0, int pos1, int pos2, int pos3) { return is_at(offset, vertex, pos0, pos1) || is_at(offset, vertex, pos2, pos3); }
bool within(vec3 a, vec3 b, float threshold) { return abs(length(a - b)) < threshold; }

void main() {
    vec3 pos = Position;

    vertexDistance = fog_distance(IViewRotMat * Position, FogShape);
    vertexColor = Color;
    texCoord0 = UV0;

    vec2 pixel = vec2(ProjMat[0][0], ProjMat[1][1]) / 2.0;
    int guiScale = int(round(pixel.x / (1 / ScreenSize.x)));
    vec2 guiSize = ScreenSize / guiScale;

    float id = get_id((round(MH_OFFSET - Position.y)) * -1);

    // Detect if GUI text.
    if (id > 99 && Color.a != 0.0) {
        float yOffset = 0.0;
        float xOffset = 0.0;
        float layer = 0.0;
        vec2 scale = vec2(1, 1);
        bool outlined = false;

        switch (int(id)) {
    case 100:
                        xOffset = int(guiSize.x * (-0.0/100));
                        yOffset = int(guiSize.y * (92.0/100));
                        layer = -4.0E-4;
    break;
    case 101:
                        xOffset = int(guiSize.x * (-0.0/100))-16;
                        yOffset = int(guiSize.y * (92.0/100))-28;
                        layer = -3.0000000000000003E-4;
    break;
    case 102:
                        xOffset = int(guiSize.x * (-0.0/100))-13;
                        yOffset = int(guiSize.y * (92.0/100))-21;
                        layer = -2.0E-4;
    break;
    case 103:
                        xOffset = int(guiSize.x * (-0.0/100))-14;
                        yOffset = int(guiSize.y * (92.0/100))-14;
                        layer = -1.0E-4;
    break;
    case 104:
                        xOffset = int(guiSize.x * (-50.0/100))+44;
                        yOffset = int(guiSize.y * (0.0/100))+32;
                        layer = -8.000000000000001E-4;
    break;
    case 105:
                        xOffset = int(guiSize.x * (-50.0/100))-187;
                        yOffset = int(guiSize.y * (0.0/100))+32;
                        layer = -7.000000000000001E-4;
    break;
    case 106:
                        xOffset = int(guiSize.x * (-50.0/100));
                        yOffset = int(guiSize.y * (0.0/100))+58;
                        layer = -6.000000000000001E-4;
    break;
    case 107:
                        xOffset = int(guiSize.x * (-50.0/100))-7;
                        yOffset = int(guiSize.y * (0.0/100))+24;
                        layer = -5.0E-4;
    break;
    case 108:
                        xOffset = int(guiSize.x * (-50.0/100))-6;
                        yOffset = int(guiSize.y * (0.0/100))+24;
                        layer = -4.0E-4;
    break;
    case 109:
                        xOffset = int(guiSize.x * (-50.0/100))-96;
                        yOffset = int(guiSize.y * (0.0/100))+29;
                        layer = -3.0000000000000003E-4;
                        outlined = true;
    break;
    case 110:
                        xOffset = int(guiSize.x * (-50.0/100))-96;
                        yOffset = int(guiSize.y * (0.0/100))+32;
                        layer = -3.0000000000000003E-4;
                        outlined = true;
    break;
    case 111:
                        xOffset = int(guiSize.x * (-50.0/100))-117;
                        yOffset = int(guiSize.y * (0.0/100))+44;
                        layer = -2.0E-4;
    break;
    case 112:
                        xOffset = int(guiSize.x * (-50.0/100))-18;
                        yOffset = int(guiSize.y * (0.0/100))+44;
                        layer = -1.0E-4;
    break;
}


        // -2800.0 is required for forge comp
        if ((Position.z != 1000.0 && Position.z != -2800.0) || outlined) {
            pos.y -= (id*1000) + 500 + MH_OFFSET;
            pos.x -= (guiSize.x * 0.5);

            pos.x *= scale.x;
            pos.y *= scale.y;

            pos.y += guiSize.y;
            // force align guiScale 3
            if (guiScale == 3) {
                pos.x += 1.45;
            }

            pos -= vec3(xOffset, yOffset, 0.0);
            pos.z += layer + 309.0;
        }
    } else if (XP_HIDE) {
        int offset = int(round(guiSize.y - Position.y));
        int vID = gl_VertexID % 4;

        if ((within(Color.rgb, XP_COLOR, 0.002) && is_at(offset, vID, 26, 27)) || (within(Color.rgb, XP_COLOR_SHADOW, 0.002) && is_at(offset, vID, 25, 26, 27, 28))) {
            pos += XP_OFFSET;
        }
    }

    gl_Position = ProjMat * ModelViewMat * vec4(pos, 1);
}

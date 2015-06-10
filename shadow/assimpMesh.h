#ifndef __MESH_H__
#define __MESH_H__

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>
#include <vector>
#include <string>

using namespace std;

struct Vertex
{
    glm::vec3 position;
    glm::vec3 normal;
    glm::vec2 textcoord;
    
    Vertex() : position(0, 0, 0), normal(0, 0, 0), textcoord(0, 0){}
};

class Mesh
{
private:
    GLuint vao, vbo, ebo;
public:
    Mesh();
    void draw();
    void bindData(unsigned int, unsigned int, unsigned int);
    GLuint getIndex()
    {
        return material_index;
    }
    vector<Vertex> vertices;
    vector<unsigned int> indices;
    unsigned int cntIndex;
    unsigned int material_index;
};

#endif
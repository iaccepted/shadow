#ifndef __MODEL_H__
#define __MODEL_H__

#include <vector>
#include <map>

#include <glm/glm.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <assimp/Importer.hpp>
#include <assimp/scene.h>
#include <assimp/postprocess.h>

#include "assimpMesh.h"

typedef struct {
    GLuint ambient_loc;
    GLuint diffuse_loc;
    GLuint specular_loc;
    GLuint shininess_loc;
    GLuint alph_loc;
    GLuint shadowMap_loc;
    GLuint texture_loc;
}uniformLocs;

struct Material
{
    glm::vec3 ambient;
    glm::vec3 diffuse;
    glm::vec3 specular;
    float shininess;
    float alph;
    GLuint texture;
    string fileName;
    bool hasMap;
    
    Material() : ambient(glm::vec3(0.0f)), diffuse(glm::vec3(0.0f)), specular(glm::vec3(0.0f)), shininess(32.0f), alph(1.0f), texture(0), hasMap(false){}
    
    void init(aiColor4D ambient, aiColor4D diffuse, aiColor4D specular, float s, float a, string fileName, bool hasMap)
    {
        this->shininess = s;
        this->alph = a;
        this->ambient.r = ambient.r;
        this->ambient.g = ambient.g;
        this->ambient.b = ambient.b;
        this->diffuse.r = diffuse.r;
        this->diffuse.g = diffuse.g;
        this->diffuse.b = diffuse.b;
        this->specular.r = specular.r;
        this->specular.g = specular.g;
        this->specular.b = specular.b;
        this->texture = 3;
        this->fileName = fileName;
        this->hasMap = hasMap;
    }
};

class Model
{
public:
    Model();
    void getLocations(unsigned int program);
    void drawNormal(unsigned int program, unsigned int depthTexture);
    void drawDepth();
    void loadModel(const char *);
    void bindVertexData();
    void bindTexturesData();
private:
    std::vector<Mesh> meshs;
    
    void processMesh(aiMesh *);
    map<GLuint, Material> materials;
    uniformLocs locs;
};

#endif
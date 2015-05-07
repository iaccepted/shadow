#include <assimp/Importer.hpp>
#include <assimp/scene.h>
#include <assimp/postprocess.h>
#include <iostream>

#import <UIKit/UIKit.h>
//#import <QuartzCore/QuartzCore.h>

#include "assimpmodel.h"

using namespace Assimp;
using namespace std;

Model::Model()
{
}

void Model::drawNormal(unsigned int program, unsigned int depthTexture)
{
    GLuint ambient_loc = glGetUniformLocation(program, "material.ambient");
    GLuint diffuse_loc = glGetUniformLocation(program, "material.diffuse");
    GLuint specular_loc = glGetUniformLocation(program, "material.specular");
    GLuint shininess_loc = glGetUniformLocation(program, "material.shininess");
    GLuint alph_loc = glGetUniformLocation(program, "material.alph");
    
    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, depthTexture);
    glUniform1i(glGetUniformLocation(program, "shadowMap"), 1);
    
    for (GLuint i = 0; i < meshs.size(); ++i)
    {
        Material *material = &materials[meshs[i].getIndex()];
        
        glUniform3f(ambient_loc, material->ambient.r, material->ambient.g, material->ambient.b);
        glUniform3f(diffuse_loc, material->diffuse.r, material->diffuse.g, material->diffuse.b);
        glUniform3f(specular_loc, material->specular.r, material->specular.g, material->specular.b);
        glUniform1f(shininess_loc, material->shininess);
        glUniform1f(alph_loc, material->alph);
        
        glActiveTexture(GL_TEXTURE0);
        glBindTexture(GL_TEXTURE_2D, material->texture);
        glUniform1i(glGetUniformLocation(program, "texture"), 0);
        
        this->meshs[i].draw();
    }
}

void Model::drawDepth()
{
    for(size_t i = 0; i < meshs.size(); ++i)
    {
        this->meshs[i].draw();
    }
}


void Model::bindVertexData()
{
    for(unsigned int i = 0; i < meshs.size(); ++i)
    {
        this->meshs[i].bindData(0, 1, 2);
    }
}

void Model::loadModel(const char *path)
{
    Importer importer;
    const aiScene *scene = importer.ReadFile(path, aiProcess_Triangulate | aiProcess_FlipUVs | aiProcess_GenNormals);
    if (!scene || scene->mFlags == AI_SCENE_FLAGS_INCOMPLETE || !scene->mRootNode)
    {
        std::cerr << "Failed to load model : " << importer.GetErrorString() << endl;
        exit(-1);
    }
    materials.clear();
    
    for (GLuint i = 0; i < scene->mNumMeshes; ++i)
    {
        aiColor4D ambient, diffuse, specular;
        float shininess, alph;
        GLuint index = scene->mMeshes[i]->mMaterialIndex;
        if (materials.find(index) == materials.end())
        {
            aiMaterial *mtl = scene->mMaterials[index];
            if (AI_SUCCESS != mtl->Get(AI_MATKEY_COLOR_AMBIENT, ambient))
            {
                ambient = aiColor4D(0.0f, 0.0f, 0.0f, 0.0f);
            }
            if (AI_SUCCESS != mtl->Get(AI_MATKEY_COLOR_DIFFUSE, diffuse))
            {
                diffuse = aiColor4D(0.0f, 0.0f, 0.0f, 0.0f);
            }
            if (AI_SUCCESS != mtl->Get(AI_MATKEY_COLOR_SPECULAR, specular))
            {
                specular = aiColor4D(0.0f, 0.0f, 0.0f, 0.0f);
            }
            if (AI_SUCCESS != mtl->Get(AI_MATKEY_SHININESS, shininess))
            {
                shininess = 32.0f;
            }
            if (AI_SUCCESS != mtl->Get(AI_MATKEY_OPACITY, alph))
            {
                alph = 1.0f;
            }
            bool flag = mtl->GetTextureCount(aiTextureType_DIFFUSE);
            string fileName;
            if(flag)
            {
                aiString path;
                mtl->GetTexture(aiTextureType_DIFFUSE, 0, &path);
                fileName = path.C_Str();
                //cout << fileName << endl;
                for(size_t i = 0; i < fileName.length(); ++i)
                {
                    if(fileName[i] == '\\')fileName[i] = '/';
                }
            }
            materials[index].init(ambient, diffuse, specular, shininess, alph, fileName, flag);
        }
        processMesh(scene->mMeshes[i]);
    }
}

void Model::processMesh(aiMesh *mesh)
{
    meshs.push_back(Mesh());
    vector<Vertex> &vertices = meshs.back().vertices;
    vector<GLuint> &indices = meshs.back().indices;
    //vector<Texture> &textures = meshs.back().textures;
    
    for(unsigned int i = 0; i < mesh->mNumVertices; ++i)
    {
        vertices.push_back(Vertex());
        glm::vec3 &position = vertices.back().position;
        
        position.x = mesh->mVertices[i].x;
        position.y = mesh->mVertices[i].y;
        position.z = mesh->mVertices[i].z;
        
        glm::vec3 &normal = vertices.back().normal;
        normal.x = mesh->mNormals[i].x;
        normal.y = mesh->mNormals[i].y;
        normal.z = mesh->mNormals[i].z;
        
        glm::vec2 &textcoord = vertices.back().textcoord;
        
        if(mesh->HasTextureCoords(0))
        {
            textcoord.x = mesh->mTextureCoords[0][i].x;
            textcoord.y = mesh->mTextureCoords[0][i].y;
        }
    }
    
    for(unsigned int i = 0; i < mesh->mNumFaces; ++i)
    {
        aiFace face = mesh->mFaces[i];
        for (unsigned short j = 0; j < face.mNumIndices; ++j)
        {
            indices.push_back(face.mIndices[j]);
        }
    }
    meshs.back().cntIndex = (unsigned int)indices.size();
    GLuint index = mesh->mMaterialIndex;
    meshs.back().material_index = index;
}

void Model::bindTexturesData()
{
    for(auto beg = materials.begin(); beg != materials.end(); ++beg)
    {
        if(!(beg->second.hasMap))continue;
        NSString *fileName = [NSString stringWithUTF8String:(beg->second.fileName.c_str())];
        CGImageRef spriteImage = [UIImage imageNamed:fileName].CGImage;
        if(!spriteImage)
        {
            NSLog(@"Failed to load image : %@",  fileName);
            exit(1);
        }
        int width = (int)CGImageGetWidth(spriteImage);
        int height = (int)CGImageGetHeight(spriteImage);
        
        GLubyte *spriteData = (GLubyte *)calloc(width*height*4, sizeof(GLubyte));
        CGContextRef spriteContext = CGBitmapContextCreate(spriteData, width, height, 8, width * 4, CGImageGetColorSpace(spriteImage), kCGImageAlphaPremultipliedLast);
        
        CGContextDrawImage(spriteContext, CGRectMake(0, 0, width, height), spriteImage);
        CGContextRelease(spriteContext);
 
        glGenTextures(1, &(beg->second.texture));
        //cout << beg->second.texture << " : " << beg->second.fileName << endl;
        glBindTexture(GL_TEXTURE_2D, (beg->second.texture));
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, spriteData);
        glBindTexture(GL_TEXTURE_2D, 0);
    }
}
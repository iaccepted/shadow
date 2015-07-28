//
//  assimpMesh.cpp
//  iaccepted
//
//  Created by iaccepted on 15/4/17.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//


#include "assimpMesh.h"
#include <iostream>

typedef unsigned GLuint;

Mesh::Mesh()
{
}

void Mesh::bindData(unsigned int posLoc, unsigned int normalLoc, unsigned int textLoc)
{
    glGenVertexArraysOES(1, &vao);
    glGenBuffers(1, &vbo);
    glGenBuffers(1, &ebo);
    
    glBindVertexArrayOES(vao);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    
    glBufferData(GL_ARRAY_BUFFER, vertices.size() * sizeof(Vertex), &vertices[0], GL_STATIC_DRAW);
    
    glVertexAttribPointer(posLoc, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, position));
    glEnableVertexAttribArray(posLoc);
    
    glVertexAttribPointer(normalLoc, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, normal));
    glEnableVertexAttribArray(normalLoc);
    
    glVertexAttribPointer(textLoc, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid *)offsetof(Vertex, textcoord));
    glEnableVertexAttribArray(textLoc);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, ebo);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, indices.size() * sizeof(unsigned int), &indices[0], GL_STATIC_DRAW);
    
    glBindVertexArrayOES(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);

    vertices.clear();
    indices.clear();
}

void Mesh::draw()
{
    glBindVertexArrayOES(vao);
    glDrawElements(GL_TRIANGLES, cntIndex, GL_UNSIGNED_INT, 0);
    glBindVertexArrayOES(0);
}
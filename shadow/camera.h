//
//  Camera.h
//  opengl
//
//  Created by iaccepted on 15/4/11.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//

#ifndef opengl_Camera_h
#define opengl_Camera_h

#import <glm/glm.hpp>
#import <glm/gtc/matrix_transform.hpp>
#import <glm/gtc/type_ptr.hpp>

enum toward
{
    FRONT,
    BACK,
    LEFT,
    RIGHT
};

class Camera {
private:
    glm::vec3 position;
    glm::vec3 front;
    glm::vec3 up;
    glm::vec3 right;
    float speed;
    glm::mat4 view;
    
public:
    
    Camera();
    glm::mat4 getView();
    
    void progressKeyBoard(toward);
};
#endif

//
//  camera.cpp
//  opengl
//
//  Created by iaccepted on 15/4/11.
//  Copyright (c) 2015年 iaccepted. All rights reserved.
//

#include <stdio.h>
#include "camera.h"

Camera::Camera() : position(glm::vec3(0.0f, 0.0f, 3.0f)), front(glm::vec3(0.0f, 0.0f, -1.0f)), up(glm::vec3(0.0f, 1.0f, 0.0f)), right(glm::normalize(glm::cross(up, front))), speed(0.01){}

glm::mat4 Camera::getView() {
    return glm::lookAt(position, position + front, up);
}

void Camera::progressKeyBoard(toward dir)
{
    switch (dir)
    {
        case FRONT:
            position += front * speed;
            break;
        case BACK:
            position -= front * speed;
            break;
        case LEFT:
            position -= right * speed;
            break;
        case RIGHT:
            position += right * speed;
            break;
        default:
            break;
    }
}

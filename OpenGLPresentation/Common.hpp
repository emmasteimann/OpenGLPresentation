#ifndef _COMMON_HPP_
#define _COMMON_HPP_

#include <iostream>
#include <vector>
#include <string>
//#include <GL/glew.h>
#import <OpenGL/OpenGL.h>
#include <assimp/cimport.h>
#include <assimp/config.h>
#include <assimp/scene.h>
#include <assimp/postprocess.h>
#include <assimp/vector3.h>
#include <glm/glm.hpp>
#include <glm/gtx/transform.hpp>
#include <glm/gtc/type_ptr.hpp>
#include "Tools.hpp"

#define PI 3.14159265f
#define WIDTH 512
#define HEIGHT 512
#define COLORBITS 32
#define FOV 45.0f
#define ASPECTRATIO (GLfloat) WIDTH / (GLfloat) HEIGHT
#define NEARPLANE 0.01f
#define FARPLANE 100.0f
#define CAMERA_DISTANCE 2.0f
#define ANIMATION_TICKS_PER_SECOND 20.0
#define MULTISAMPLING 4
#define MAXBONESPERMESH 60 //This value has to be changed in the shader code as well, boneMatrices[MAXBONESPERMESH]

using std::string;
using std::cerr;
using std::cout;
using std::endl;

#endif
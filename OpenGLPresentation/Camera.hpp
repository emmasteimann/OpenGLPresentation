#ifndef _CAMERA_HPP_
#define _CAMERA_HPP_

#include "Common.hpp"
#include <glm/glm.hpp>

class Camera {
  public:
	  Camera(GLfloat fDistance, GLfloat fHeight, GLfloat fAngle);
	  ~Camera();

	  void SetDistance(GLfloat distance);
	  void SetHeight(GLfloat height);
	  void SetAngle(GLfloat angle);
	  glm::mat4 GetProjectionMatrix();
	  glm::mat4 GetViewMatrix();

  private:
	  glm::vec3 m_vPosition;
	  glm::vec3 m_vUpVector;
	  glm::mat4 m_mProjection;
	  GLfloat m_fDistance;
	  GLfloat m_fHeight;
	  GLfloat m_fAngle;
};

#endif
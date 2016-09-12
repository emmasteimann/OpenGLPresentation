#include "camera.hpp"

#include <glm/gtx/transform.hpp>
#include <glm/gtx/transform2.hpp>
#include <glm/gtc/matrix_transform.hpp>
#include <glm/gtc/type_ptr.hpp>

Camera::Camera(GLfloat fDistance, GLfloat fHeight, GLfloat fAngle) {
	SetDistance(fDistance);
	SetHeight(fHeight);
	SetAngle(fAngle);
	
	m_vUpVector = glm::vec3(0.0f, 1.0f, 0.0f);
	m_mProjection = glm::perspective(85.0f, ASPECTRATIO, 1.0f, 150.0f);
  
  float fNewAngle = m_fAngle;

  //clamp the angle to -90 < angle < 90 because it simplifies the calculation
  if (fNewAngle >= 90.0f)
  {
    fNewAngle = 89.0f;
  }

  if (fNewAngle <= -90.0f)
  {
    fNewAngle = -89.0f;
  }

  float fRadianAngle = -1.0f * fNewAngle * PI / 180.0f;

  m_vPosition.x = 0.0f;
  m_vPosition.y = m_fHeight + CAMERA_DISTANCE * sin(fRadianAngle);
  m_vPosition.z = CAMERA_DISTANCE * cos(fRadianAngle);
}

Camera::~Camera() {
	//
}

void Camera::SetDistance(GLfloat fDistance) {
	m_fDistance = fDistance;
}

void Camera::SetHeight(GLfloat fHeight) {
	m_fHeight = fHeight;
}

void Camera::SetAngle(GLfloat fAngle) {
	m_fAngle = fAngle;
}

glm::mat4 Camera::GetProjectionMatrix() {
	return m_mProjection;
}

glm::mat4 Camera::GetViewMatrix() {
	return glm::lookAt(m_vPosition, glm::vec3(0.0f, m_fHeight, 0.0f), m_vUpVector);
}
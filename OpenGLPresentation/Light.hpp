#ifndef _LIGHT_HPP_
#define _LIGHT_HPP_

#include <glm/glm.hpp>

class Light {
public:
	Light(glm::vec3 vPosition, glm::vec4 vAmbient, glm::vec4 vDiffuse);
	~Light();

	void SetPosition(glm::vec3 vPosition);
	glm::vec3 GetPosition();
	void SetAmbient(glm::vec4 vAmbient);
	glm::vec4 GetAmbient();
	void SetDiffuse(glm::vec4 vDiffuse);
	glm::vec4 GetDiffuse();

private:
	glm::vec3 m_vPosition;
	glm::vec4 m_vAmbient;
	glm::vec4 m_vDiffuse;
};

#endif
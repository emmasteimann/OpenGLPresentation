#include "Light.hpp"

Light::Light(glm::vec3 vPosition, glm::vec4 vAmbient, glm::vec4 vDiffuse) {
	SetPosition(vPosition);
	SetAmbient(vAmbient);
	SetDiffuse(vDiffuse);
}

Light::~Light() {
	//
}

void Light::SetPosition(glm::vec3 vPosition) {
	m_vPosition = vPosition;
}

glm::vec3 Light::GetPosition() {
	return m_vPosition;
}

void Light::SetAmbient(glm::vec4 vAmbient) {
	m_vAmbient = vAmbient;
}

glm::vec4 Light::GetAmbient() {
	return m_vAmbient;
}

void Light::SetDiffuse(glm::vec4 vDiffuse) {
	m_vDiffuse = vDiffuse;
}

glm::vec4 Light::GetDiffuse() {
	return m_vDiffuse;
}
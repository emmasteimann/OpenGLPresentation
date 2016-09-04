#include "Common.hpp"
#include "Tools.hpp"
//
//bool ExtensionSupported(const char* extensionsString) {
//	char* extensionsList = (char*) glGetString(GL_EXTENSIONS);
//	size_t extensionsLength = strlen(extensionsString);
//	size_t nextExtensionLength = 0;
//
//	if ((!extensionsString) || (!extensionsList)) {
//		return false;
//	}
//
//	while (*extensionsList) {
//		nextExtensionLength = strcspn(extensionsList, " ");	
//		
//		if ((nextExtensionLength == extensionsLength) && (strncmp(extensionsList, extensionsString, extensionsLength) == 0)) {
//			return true;
//		}
//
//		extensionsList += nextExtensionLength + 1;
//	}
//
//	return false;
//}
//
//bool CheckErrors() {
//	GLenum errCode;
//	const GLubyte* errStr;
//	bool foundErrors = false;
//
//	while ((errCode = glGetError()) != GL_NO_ERROR) {
//		foundErrors = true;
//		errStr = gluErrorString(errCode);
//
//		if (errStr != NULL) {
//			std::cerr << errStr;
//		}
//    else {
//			std::cerr << "UNKNOWN GL ERROR";
//		}
//
//		std::cerr << " ! <<< "  << std::endl << std::endl;
//	}
//
//	return foundErrors;
//}

std::string GetFullPath(const std::string _path, const std::string _texturePath) {
	std::string path = ReplaceString(_path, "\\", "/");
	path = path.substr(0, path.find_last_of('/') + 1);
	std::string textureFilename = ReplaceString(_texturePath, "\\", "/");

	return path + textureFilename;
}

std::string ReplaceString(std::string _str, const std::string &pattern, const std::string &replacement) {
	string::size_type pos = _str.find(pattern, 0);

	while (string::npos != pos) {
		_str.replace(pos, pattern.length(), replacement);
		pos = _str.find(pattern, 0);
	}

	return _str;
}
#ifndef UTILITY_HHP
#define UTILITY_HHP

bool CheckErrors();
bool ExtensionSupported(const char* extensionsString);
std::string GetFullPath(const std::string path, const std::string texturePath);
std::string ReplaceString(std::string _str, const std::string &pattern, const std::string &replacement);

#endif
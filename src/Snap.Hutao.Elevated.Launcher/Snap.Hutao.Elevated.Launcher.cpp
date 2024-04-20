#define _CRT_SECURE_NO_WARNINGS
#pragma comment(linker, "/SUBSYSTEM:windows /ENTRY:mainCRTStartup")
#include <Windows.h>
#include <string>

static std::wstring strtowstr(const char *str)
{
	size_t size = std::strlen(str);
	std::wstring wstr(size, 0);
	mbstowcs(&wstr[0], str, size);
	return wstr;
}

int main(int argc, char* argv[])
{
	auto pkgFamilyName = argc == 1 ? L"60568DGPStudio.SnapHutao_wbnnev551gwxy" : strtowstr(argv[1]);
	auto lpFile = L"shell:AppsFolder\\" + pkgFamilyName + L"!App";

	SHELLEXECUTEINFO sei{};
	sei.cbSize = sizeof(SHELLEXECUTEINFO);
	sei.fMask = SEE_MASK_NOCLOSEPROCESS;
	sei.hInstApp = NULL;
	sei.hwnd = NULL;
	sei.lpDirectory = NULL;
	sei.lpFile = lpFile.c_str();
	sei.lpParameters = L"";
	sei.lpVerb = L"runas";
	sei.nShow = SW_SHOW;
	ShellExecuteEx(&sei);
	if (sei.hProcess != 0)
	{
		CloseHandle(sei.hProcess);
	}
}
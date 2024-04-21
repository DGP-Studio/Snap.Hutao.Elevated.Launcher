#pragma comment(linker, "/SUBSYSTEM:windows /ENTRY:wmainCRTStartup")
#include <Windows.h>
#include <string>

const wchar_t* SHELL_FOLDER = LR"(shell:AppsFolder\)";
const wchar_t* RELEASE_FAMILY_NAME = L"60568DGPStudio.SnapHutao_wbnnev551gwxy";
const wchar_t* APP = L"!App";

int wmain(int argc, wchar_t* argv[])
{
	std::wstring pkgFamilyName = argc == 1 ? RELEASE_FAMILY_NAME : argv[1];
	std::wstring lpFile = SHELL_FOLDER + pkgFamilyName + APP;

	SHELLEXECUTEINFO sei;
	sei.cbSize = sizeof(sei);
	sei.fMask = SEE_MASK_NOCLOSEPROCESS;
	sei.lpFile = lpFile.c_str();
	sei.lpVerb = L"runas";
	sei.nShow = SW_SHOW;
	bool ret = ShellExecuteEx(&sei);
	CloseHandle(sei.hProcess);

	return 0;
}
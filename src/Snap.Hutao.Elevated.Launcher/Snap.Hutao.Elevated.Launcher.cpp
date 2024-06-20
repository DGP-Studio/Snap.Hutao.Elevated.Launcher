#include <stdio.h>
#include <Windows.h>

const wchar_t* SHELL_FOLDER = LR"(shell:AppsFolder\)";
const wchar_t* RELEASE_FAMILY_NAME = L"60568DGPStudio.SnapHutao_wbnnev551gwxy";
const wchar_t* APP = L"!App";

int wmain(int argc, wchar_t* argv[])
{
	const wchar_t* pkgFamilyName = argc == 1 ? RELEASE_FAMILY_NAME : argv[1];
	wchar_t lpFile[128];

	swprintf(lpFile, 128, L"%s%s%s", SHELL_FOLDER, pkgFamilyName, APP);

	SHELLEXECUTEINFO sei{};
	sei.cbSize = sizeof(sei);
	sei.fMask = SEE_MASK_NOCLOSEPROCESS;
	sei.lpFile = lpFile;
	sei.lpVerb = L"runas";
	sei.nShow = SW_SHOW;
	bool ret = ShellExecuteEx(&sei);
	CloseHandle(sei.hProcess);

	return 0;
}
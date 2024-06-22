#include <wchar.h>
#include <Windows.h>

const wchar_t* SHELL_FOLDER = LR"(shell:AppsFolder\)";
const wchar_t* RELEASE_FAMILY_NAME = L"60568DGPStudio.SnapHutao_wbnnev551gwxy";
const wchar_t* APP = L"!App";

int wmain(int argc, wchar_t* argv[])
{
	const wchar_t* pkgFamilyName = argc == 1 ? RELEASE_FAMILY_NAME : argv[1];

	size_t len = wcslen(SHELL_FOLDER) + wcslen(pkgFamilyName) + wcslen(APP) + 1;
	wchar_t* lpFile = new wchar_t[len];

	swprintf(lpFile, len, L"%s%s%s", SHELL_FOLDER, pkgFamilyName, APP);

	SHELLEXECUTEINFO sei{};
	sei.cbSize = sizeof(sei);
	sei.fMask = SEE_MASK_NOCLOSEPROCESS;
	sei.lpFile = lpFile;
	sei.lpVerb = L"runas";
	sei.nShow = SW_SHOW;

	if (ShellExecuteEx(&sei))
	{
		CloseHandle(sei.hProcess);
	}

	return 0;
}
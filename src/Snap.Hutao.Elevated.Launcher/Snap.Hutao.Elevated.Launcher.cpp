#pragma comment(linker, "/SUBSYSTEM:windows /ENTRY:mainCRTStartup")
#include <Windows.h>

int main()
{
	SHELLEXECUTEINFO sei{};
	sei.cbSize = sizeof(SHELLEXECUTEINFO);
	sei.fMask = SEE_MASK_NOCLOSEPROCESS;
	sei.hInstApp = NULL;
	sei.hwnd = NULL;
	sei.lpDirectory = NULL;
	sei.lpFile = L"shell:AppsFolder\\60568DGPStudio.SnapHutao_wbnnev551gwxy!App";
	sei.lpParameters = L"";
	sei.lpVerb = L"runas";
	sei.nShow = SW_SHOW;
	ShellExecuteEx(&sei);
	if (sei.hProcess != 0)
	{
		CloseHandle(sei.hProcess);
	}
}
; Ref: https://github.com/ayaka14732/TinyPE-on-Win10
; .\nasm -f bin -o Snap.Hutao.Elevated.Launcher.exe .\Snap.Hutao.Elevated.Launcher.asm

BITS 64

; DOS Header
    dw 'MZ'                 ; e_magic
    dw 0                    ; [UNUSED] e_cblp
pe_hdr:                                                 ; PE Header
    dw 'PE'                 ; [UNUSED] c_cp             ; Signature
    dw 0                    ; [UNUSED] e_crlc           ; Signature (Cont)
image_hdr:                                              ; Image File Header
    dw 0x8664               ; [UNUSED] e_cparhdr        ; Machine
S_CloseHandle:
    dw 0x01                 ; Function Ordinal[2] <- e_minalloc | NumberOfSections
    db 'CloseHandle', 0     ; Function Name[12]
                            ; e_maxalloc & e_ss         | TimeDateStamp
                            ; e_sp       & e_csum       | PointerToSymbolTable
                            ; e_ip       & e_cs         | NumberOfSymbols
    dw opt_hdr_size         ; [UNUSED] e_lfarlc         ; SizeOfOptionalHeader
    dw 0x22                 ; [UNUSED] e_ovno           ; Characteristics
opt_hdr:                                                ; Optional Header, COFF Standard Fields
    dw 0x020b               ; [UNUSED] e_res            ; Magic (PE32+)
    db 0x22                 ; [UNUSED] e_res (Cont)     ; [UNUSED] MajorLinkerVersion               ; 0
    db 0x33                 ; [UNUSED] e_res (Cont)     ; [UNUSED] MinorLinkerVersion               ; 0
    dd code_size            ; [UNUSED] e_res (Cont)     ; SizeOfCode
    dw 0x100                ; [UNUSED] e_oemid          ; [UNUSED] SizeOfInitializedData            ; 0
    dw 0x175                ; [UNUSED] e_oeminfo        ; [UNUSED] SizeOfInitializedData (Cont)     ; 0
    dd 0x114514             ; [UNUSED] e_res2           ; [UNUSED] SizeOfUninitializedData          ; 0
    dd entry                ; [UNUSED] e_res2 (Cont)    ; AddressOfEntryPoint
    dd code                 ; [UNUSED] e_res2 (Cont)    ; BaseOfCode
                                                        ; Optional Header, NT Additional Fields
    dq 0x000140000000       ; [UNUSED] e_res2 (Cont)    ; ImageBase
    dd pe_hdr               ; e_lfanew                  ; [MODIFIED] SectionAlignment (0x10 -> 0x04)
    dd 0x04                 ; FileAlignment
    dw 0x06                 ; MajorOperatingSystemVersion
    dw 0                    ; MinorOperatingSystemVersion
    dw 0                    ; MajorImageVersion
    dw 0                    ; MinorImageVersion
    dw 0x06                 ; MajorSubsystemVersion
    dw 0                    ; MinorSubsystemVersion
    dd 0x01919810           ; Reserved1                 ; 0
    dd file_size            ; SizeOfImage
    dd hdr_size             ; SizeOfHeaders
    dd 0x23333333           ; CheckSum                  ; 0
    dw 0x02                 ; Subsystem (Windows GUI)
    dw 0x8160               ; DllCharacteristics
    dq 0x100000             ; SizeOfStackReserve
    dq 0x1000               ; SizeOfStackCommit
    dd 0x100000             ; SizeOfHeapReserve[4]
    dw 0                    ; SizeOfHeapReserve[2]
S_ExitProcess:
    dw 0                    ; FunctionOrdinal[2] <- SizeOfHeapReserve[2]
    db 'ExitProcess', 0     ; FunctionName[12] <- SizeOfHeapCommit[8], LoaderFlags[4]
    dd 0x02                 ; NumberOfRvaAndSizes

; Optional Header, Data Directories
    dd 0                    ; Export, RVA
    dd 0                    ; Export, Size
    dd itbl                 ; Import, RVA
    dd itbl_size            ; Import, Size

opt_hdr_size equ $-opt_hdr

; Section Table
    section_name db '.hutao'; Name
    times 8-($-section_name) db 0
    dd sect_size            ; VirtualSize
    dd entry                ; VirtualAddress
    dd code_size            ; SizeOfRawData
    dw entry                ; PointerToRawData[2]
S_ShellExecuteExW:
    dw 0                    ; FunctionOrdinal[2] <- PointerToRawData[2]
    db 'ShellExecuteExW', 0 ; FunctionName[16] <- PointerToRelocations[4], PointerToLinenumbers[4], NumberOfRelocations[2], NumberOfLinenumbers[2], Characteristics[4]

hdr_size equ $-$$

code:

entry:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 70h
    mov     rcx, gs:[60h]        ; NtCurrentPeb()
    mov     rcx, [rcx+20h]       ; ->ProcessParameters
    mov     rcx, [rcx+78h]       ; ->CommandLine.Buffer
    lea     rdx, [rbp-10h]       ; argc
    call    [rel I_CommandLineToArgvW]
    cmp     dword [rbp-10h], 1   ; argc
    jnz     readFromArgs

    mov     r8, LEN_RELEASE_FAMILY_NAME
    lea     rdi, [rel RELEASE_FAMILY_NAME]
    jmp     toFullName

readFromArgs:

    mov     rdi, [rax+8]
    mov     rcx, rdi
    call    [rel I_lstrlenW]
    movzx   r8, ax
    shl     r8, 1
    
toFullName:

    mov     rsi, r8
    add     r8, LEN_SHELL_FOLDER + 2 + LEN_APP_SUFFIX + 2
    mov     rdx, 8               ; HEAP_ZERO_MEMORY
    mov     rcx, gs:[60h]        ; NtCurrentPeb()
    mov     rcx, [rcx+30h]       ; ->ProcessHeap
    call    [rel I_HeapAlloc]

    vmovups  ymm0, [rel SHELL_FOLDER]
    vmovups  [rax], ymm0
    mov     word [rax+32], '\'   ;

    mov     r8,  rsi
    mov     rdx, rdi
    mov     rdi, rax
    lea     rcx, [rdi+LEN_SHELL_FOLDER+2]
    call    [rel I_RtlCopyMemory]
    
    mov     rcx, [rel APP_SUFFIX]
    mov     [rdi+LEN_SHELL_FOLDER+2+rsi], rcx

    vpxor   ymm0, ymm0
    vmovups [rbp-70h], ymm0
    vmovups [rbp-50h], ymm0
    vmovups [rbp-30h], ymm0
    vmovups [rbp-10h], xmm0

    lea     rax, [rel RUNAS]
    mov     dword [rbp-70h], 70h ; sei.cbSize = sizeof(SHELLEXECUTEINFOA)
    mov     dword [rbp-6Ch], 40h ; sei.fMask  = SEE_MASK_NOCLOSEPROCESS
    mov     dword [rbp-40h], 5   ; sei.nShow  = SW_SHOW
    mov     [rbp-58h], rdi       ; sei.lpFile = fullName
    mov     [rbp-60h], rax       ; sei.lpVerb = "runas"
    
    lea     rcx, [rbp-70h]       ; sei
    sub     rsp, 30h
    call    [rel I_ShellExecuteExW]
    add     rsp, 30h
    test    eax, eax
    jz      onExit
    mov     rcx, [rbp-8]         ; sei.hProcess
    call    [rel I_CloseHandle]

onExit:

    xor     ecx, ecx             ; exit code 0
    call    [rel I_ExitProcess]

SHELL_FOLDER:
    dw __utf16__("shell:AppsFolder")
    LEN_SHELL_FOLDER equ $-SHELL_FOLDER
RELEASE_FAMILY_NAME:
    dw __utf16__("60568DGPStudio.SnapHutao_wbnnev551gwxy")
    LEN_RELEASE_FAMILY_NAME equ $-RELEASE_FAMILY_NAME
APP_SUFFIX:
    dw __utf16__("!App")
    LEN_APP_SUFFIX equ $-APP_SUFFIX
RUNAS:
    dw __utf16__("runas"), 0

; Import Directory

itbl:

    dd L_SHELL32            ; Import Name Table
    dd 0x7355608            ; Time Stamp
    dd 0                    ; Forwarder Chain
    dd S_SHELL32            ; DLL Name
    dd A_SHELL32            ; Import Address Table

    dd L_KERNEL32           ; Import Name Table
    dd 0x00010032           ; Time Stamp
    dd 0                    ; Forwarder Chain
    dd S_KERNEL32           ; DLL Name
    dd A_KERNEL32           ; Import Address Table

itbl_size equ $-itbl

; Import Name Table
; Import Address Directory

A_SHELL32:
L_SHELL32:
I_ShellExecuteExW:
    dq S_ShellExecuteExW
I_CommandLineToArgvW:
    dq S_CommandLineToArgvW
    dq 0

A_KERNEL32:
L_KERNEL32:
I_HeapAlloc:
    dq S_HeapAlloc
I_CloseHandle:
    dq S_CloseHandle
I_ExitProcess:
    dq S_ExitProcess
I_lstrlenW:
    dq S_lstrlenW
I_RtlCopyMemory:
    dq S_RtlCopyMemory
    dq 0

; Symbol

S_SHELL32:
    db 'SHELL32.dll'
S_CommandLineToArgvW:
    dw 0                        ; [UNUSED] Function Ordinal
    db 'CommandLineToArgvW'     ; Function Name
    db 0

S_KERNEL32:
    db 'KERNEL32.dll'
S_HeapAlloc:
    dw 0                        ; [UNUSED] Function Ordinal
    db 'HeapAlloc'              ; Function Name
S_lstrlenW:
    dw 0                        ; [UNUSED] Function Ordinal
    db 'lstrlenW'               ; Function Name
S_RtlCopyMemory:
    dw 0                        ; [UNUSED] Function Ordinal
    db 'RtlCopyMemory'          ; Function Name
    db 0

sect_size equ $-code
code_size equ $-code
file_size equ $-$$
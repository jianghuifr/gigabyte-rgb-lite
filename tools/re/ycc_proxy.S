    .intel_syntax noprefix
    .text
    .globl access_io_port
access_io_port:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_access_io_port]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_access_io_port]

    .globl CheckNewSMI_State
CheckNewSMI_State:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_CheckNewSMI_State]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_CheckNewSMI_State]

    .globl fnYccDrv
fnYccDrv:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_fnYccDrv]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_fnYccDrv]

    .globl gb_inp
gb_inp:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_gb_inp]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_gb_inp]

    .globl gb_inpd
gb_inpd:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_gb_inpd]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_gb_inpd]

    .globl gb_inpw
gb_inpw:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_gb_inpw]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_gb_inpw]

    .globl gb_outp
gb_outp:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_gb_outp]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_gb_outp]

    .globl gb_outpd
gb_outpd:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_gb_outpd]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_gb_outpd]

    .globl gb_outpw
gb_outpw:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_gb_outpw]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_gb_outpw]

    .globl MapMem
MapMem:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_MapMem]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_MapMem]

    .globl MapMem_Phys_To_Linear
MapMem_Phys_To_Linear:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_MapMem_Phys_To_Linear]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_MapMem_Phys_To_Linear]

    .globl MapMem_Phys_To_Linear2
MapMem_Phys_To_Linear2:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_MapMem_Phys_To_Linear2]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_MapMem_Phys_To_Linear2]

    .globl MapMemEx
MapMemEx:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_MapMemEx]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_MapMemEx]

    .globl MS_ReadMSR
MS_ReadMSR:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_MS_ReadMSR]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_MS_ReadMSR]

    .globl MS_WriteMSR
MS_WriteMSR:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_MS_WriteMSR]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_MS_WriteMSR]

    .globl nYccDrv
nYccDrv:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_nYccDrv]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_nYccDrv]

    .globl ReadMSR
ReadMSR:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_ReadMSR]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_ReadMSR]

    .globl ReadMSR64
ReadMSR64:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_ReadMSR64]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_ReadMSR64]

    .globl SMICmd
SMICmd:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_SMICmd]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_SMICmd]

    .globl SMICmd64
SMICmd64:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_SMICmd64]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_SMICmd64]

    .globl UnMapMem
UnMapMem:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_UnMapMem]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_UnMapMem]

    .globl UnMapMemEx
UnMapMemEx:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_UnMapMemEx]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_UnMapMemEx]

    .globl WriteMSR
WriteMSR:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_WriteMSR]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_WriteMSR]

    .globl WriteMSR64
WriteMSR64:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_WriteMSR64]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_WriteMSR64]

    .globl YCC_Alloc_Kernel_PhysMem
YCC_Alloc_Kernel_PhysMem:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_YCC_Alloc_Kernel_PhysMem]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_YCC_Alloc_Kernel_PhysMem]

    .globl YCC_Free_Kernel_PhysMem
YCC_Free_Kernel_PhysMem:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_YCC_Free_Kernel_PhysMem]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_YCC_Free_Kernel_PhysMem]

    .globl YCC_MapMem_Copy_Userbuf_To_Phys
YCC_MapMem_Copy_Userbuf_To_Phys:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_YCC_MapMem_Copy_Userbuf_To_Phys]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_YCC_MapMem_Copy_Userbuf_To_Phys]

    .globl YCC_TranslateLinsToPhys
YCC_TranslateLinsToPhys:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_YCC_TranslateLinsToPhys]
    mov rdx, [rsp+0x28]
    mov r8,  [rsp+0x30]
    mov r9,  [rsp+0x38]
    mov rax, [rsp+0x40]
    mov [rsp+0x20], rax
    call log_call
    mov rcx, [rsp+0x28]
    mov rdx, [rsp+0x30]
    mov r8,  [rsp+0x38]
    mov r9,  [rsp+0x40]
    movsd xmm0, [rsp+0x50]
    movsd xmm1, [rsp+0x58]
    movsd xmm2, [rsp+0x60]
    movsd xmm3, [rsp+0x68]
    add rsp, 0x88
    jmp qword ptr [rip+p_YCC_TranslateLinsToPhys]

    .section .rdata
.Lnm_access_io_port: .asciz "access_io_port"
.Lnm_CheckNewSMI_State: .asciz "CheckNewSMI_State"
.Lnm_fnYccDrv: .asciz "fnYccDrv"
.Lnm_gb_inp: .asciz "gb_inp"
.Lnm_gb_inpd: .asciz "gb_inpd"
.Lnm_gb_inpw: .asciz "gb_inpw"
.Lnm_gb_outp: .asciz "gb_outp"
.Lnm_gb_outpd: .asciz "gb_outpd"
.Lnm_gb_outpw: .asciz "gb_outpw"
.Lnm_MapMem: .asciz "MapMem"
.Lnm_MapMem_Phys_To_Linear: .asciz "MapMem_Phys_To_Linear"
.Lnm_MapMem_Phys_To_Linear2: .asciz "MapMem_Phys_To_Linear2"
.Lnm_MapMemEx: .asciz "MapMemEx"
.Lnm_MS_ReadMSR: .asciz "MS_ReadMSR"
.Lnm_MS_WriteMSR: .asciz "MS_WriteMSR"
.Lnm_nYccDrv: .asciz "nYccDrv"
.Lnm_ReadMSR: .asciz "ReadMSR"
.Lnm_ReadMSR64: .asciz "ReadMSR64"
.Lnm_SMICmd: .asciz "SMICmd"
.Lnm_SMICmd64: .asciz "SMICmd64"
.Lnm_UnMapMem: .asciz "UnMapMem"
.Lnm_UnMapMemEx: .asciz "UnMapMemEx"
.Lnm_WriteMSR: .asciz "WriteMSR"
.Lnm_WriteMSR64: .asciz "WriteMSR64"
.Lnm_YCC_Alloc_Kernel_PhysMem: .asciz "YCC_Alloc_Kernel_PhysMem"
.Lnm_YCC_Free_Kernel_PhysMem: .asciz "YCC_Free_Kernel_PhysMem"
.Lnm_YCC_MapMem_Copy_Userbuf_To_Phys: .asciz "YCC_MapMem_Copy_Userbuf_To_Phys"
.Lnm_YCC_TranslateLinsToPhys: .asciz "YCC_TranslateLinsToPhys"


    .intel_syntax noprefix
    .text
    .globl InitializeSMB
InitializeSMB:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_InitializeSMB]
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
    jmp qword ptr [rip+p_InitializeSMB]

    .globl ReadSmbType
ReadSmbType:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_ReadSmbType]
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
    jmp qword ptr [rip+p_ReadSmbType]

    .globl Read_SMB_Byte
Read_SMB_Byte:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_Read_SMB_Byte]
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
    jmp qword ptr [rip+p_Read_SMB_Byte]

    .globl Read_SMB_Quick
Read_SMB_Quick:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_Read_SMB_Quick]
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
    jmp qword ptr [rip+p_Read_SMB_Quick]

    .globl Read_SMB_Word
Read_SMB_Word:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_Read_SMB_Word]
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
    jmp qword ptr [rip+p_Read_SMB_Word]

    .globl SMB_Process_Call
SMB_Process_Call:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_SMB_Process_Call]
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
    jmp qword ptr [rip+p_SMB_Process_Call]

    .globl ShutdownSMB
ShutdownSMB:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_ShutdownSMB]
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
    jmp qword ptr [rip+p_ShutdownSMB]

    .globl Write_SMB_Byte
Write_SMB_Byte:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_Write_SMB_Byte]
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
    jmp qword ptr [rip+p_Write_SMB_Byte]

    .globl Write_SMB_Word
Write_SMB_Word:
    sub rsp, 0x88
    mov [rsp+0x28], rcx
    mov [rsp+0x30], rdx
    mov [rsp+0x38], r8
    mov [rsp+0x40], r9
    movsd [rsp+0x50], xmm0
    movsd [rsp+0x58], xmm1
    movsd [rsp+0x60], xmm2
    movsd [rsp+0x68], xmm3
    lea rcx, [rip+.Lnm_Write_SMB_Word]
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
    jmp qword ptr [rip+p_Write_SMB_Word]

    .section .rdata
.Lnm_InitializeSMB: .asciz "InitializeSMB"
.Lnm_ReadSmbType: .asciz "ReadSmbType"
.Lnm_Read_SMB_Byte: .asciz "Read_SMB_Byte"
.Lnm_Read_SMB_Quick: .asciz "Read_SMB_Quick"
.Lnm_Read_SMB_Word: .asciz "Read_SMB_Word"
.Lnm_SMB_Process_Call: .asciz "SMB_Process_Call"
.Lnm_ShutdownSMB: .asciz "ShutdownSMB"
.Lnm_Write_SMB_Byte: .asciz "Write_SMB_Byte"
.Lnm_Write_SMB_Word: .asciz "Write_SMB_Word"


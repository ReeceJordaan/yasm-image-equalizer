; ==========================
; Group member 01: Shaylin_Govender_u20498952
; Group member 02: Reece_Jordaan_u23547104
; Group member 03: Ayush_Sanjith_u23535424
; Group member 04: Aryan_Mohanlall_u23565536
; Group member 05: Name_Surname_student-nr
; ==========================
section .bss
    w_buf       resb 20
    w_len       resq 1
    h_buf       resb 20
    h_len       resq 1
    head        resq 1
    fd          resq 1

section .data
    p6          db 'P6', 0x0A
    max_colour  db '255', 0x0A
    space       db ' '
    newline     db 0x0A

section .text
    global writePPM
    extern open, write, close

writePPM:
    push rbp
    mov rbp, rsp

    mov [head], rsi

    mov rax, 2
    mov rsi, 0x41
    mov rdx, 600o
    call open

    cmp rax, 0
    js error
    mov [fd], rax

    call findW
    call findH

    mov rdi, r15
    lea rsi, [w_buf]
    call uitoa
    mov [w_len], rax

    mov rdi, r14
    lea rsi, [h_buf]
    call uitoa
    mov [h_len], rax

    mov edi, [fd]
    lea rsi, [p6]
    mov edx, 3
    call write

    mov edi, [fd]
    lea rsi, [w_buf]
    mov rdx, qword [w_len]
    call write

    mov edi, [fd]
    lea rsi, [space]
    mov edx, 1
    call write

    mov edi, [fd]
    lea rsi, [h_buf]
    mov rdx, qword [h_len]
    call write

    mov edi, [fd]
    lea rsi, [newline]
    mov edx, 1
    call write

    mov edi, [fd]
    lea rsi, [max_colour]
    mov edx, 4
    call write

    call writePixel

    mov edi, [fd]
    call close

    leave
    ret

findW:
    xor r15, r15
    mov rdi, [head]
findW_loop:
    cmp rdi, 0
    je findW_end
    inc r15
    mov rdi, [rdi + 32]
    jmp findW_loop
findW_end:
    ret

findH:
    xor r14, r14
    mov rdi, [head]
findH_loop:
    cmp rdi, 0
    je findH_end
    inc r14
    mov rdi, [rdi + 16]
    jmp findH_loop
findH_end:
    ret

uitoa:
    mov rax, rdi
    cmp rax, 0
    jne uitoa_nonzero
    mov byte [rsi], '0'
    mov rax, 1
    ret

uitoa_nonzero:
    mov rbx, rsi
    add rsi, 20
    xor rcx, rcx

uitoa_loop:
    xor rdx, rdx
    mov r10, 10
    div r10
    add rdx, '0'
    dec rsi
    mov byte [rsi], dl
    inc rcx
    test rax, rax
    jne uitoa_loop

    mov rax, rcx
    mov rdi, rbx
    mov rsi, rsi
    rep movsb
    ret

writePixel:
    mov r13, [head]
row_loop:
    cmp r13, 0
    je end_pixel
    mov r12, r13
col_loop:
    cmp r12, 0
    je next_row
    mov edi, [fd]
    lea rsi, [r12 + 0]
    mov edx, 1
    call write
    mov edi, [fd]
    lea rsi, [r12 + 1]
    mov edx, 1
    call write
    mov edi, [fd]
    lea rsi, [r12 + 2]
    mov edx, 1
    call write
    mov r12, [r12 + 32]
    jmp col_loop
next_row:
    mov r13, [r13 + 16]
    jmp row_loop
end_pixel:
    ret

error:
    leave
    ret

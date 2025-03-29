; ==========================
; Group member 01: Shaylin_Govender_u20498952
; Group member 02: Reece_Jordaan_u23547104
; Group member 03: Ayush_Sanjith_u23535424
; Group member 04: Aryan_Mohanlall-u23565536
; Group member 05: Name_Surname_student-nr
; ==========================

section .bss
    histogram               resd 256
    cumulativeHistogram     resd 256
    head_ptr                resq 1
    row_ptr                 resq 1
    col_ptr                 resq 1

section .data
    const_0_299             dd 0.299
    const_0_587             dd 0.587
    const_0_114             dd 0.114
    const_0_5               dd 0.5
    const_255               dq 255.0
    cdfMin                  dd 0x7FFFFFFF
    grayscale               dd 0
    cumulative              dd 0
    totalPixels             dd 0

section .text
    global computeCDFValues

computeCDFValues:
    cmp rdi, 0
    je .return

    mov [head_ptr], rdi

    xor rsi, rsi
    mov rdi, histogram
    call zero_histogram

    xor rsi, rsi
    mov rdi, cumulativeHistogram
    call zero_histogram

    mov rax, [head_ptr]
    mov [row_ptr], rax
    call compute_histogram

    xor rsi, rsi
    mov rdi, histogram
    mov rax, cumulativeHistogram
    call compute_cumulative_histogram

    xor rsi, rsi
    mov rdi, cumulativeHistogram
    call find_cdf_min

    mov rax, [head_ptr]
    mov [row_ptr], rax
    call normalize_cdf

.return:
    ret

zero_histogram:
    mov dword [rdi + rsi * 4], 0
    inc rsi

    cmp rsi, 256
    jl zero_histogram

    ret

compute_histogram:
    mov rax, [row_ptr]
    cmp rax, 0
    je end_rows

    mov [col_ptr], rax

    call loop_histogram

    mov rax, [row_ptr]
    mov rax, [rax + 16]
    mov [row_ptr], rax

    jmp compute_histogram

loop_histogram:
    mov rax, [col_ptr]
    cmp rax, 0
    je end_cols

    mov rbx, [totalPixels]
    inc rbx
    mov [totalPixels], rbx

    ; Load the RGB values as unsigned bytes and zero-extend to 64 bits
    movzx rbx, byte [rax]
    movzx rcx, byte [rax + 1]
    movzx rdx, byte [rax + 2]

    ; Convert and scale the red component
    cvtsi2ss xmm0, rbx
    mulss xmm0, [const_0_299]           ; Multiply by 0.299

    ; Convert and scale the green component
    cvtsi2ss xmm1, rcx
    mulss xmm1, [const_0_587]           ; Multiply by 0.587
    addss xmm0, xmm1                    ; Add to result in xmm0

    ; Convert and scale the blue component
    cvtsi2ss xmm1, rdx
    mulss xmm1, [const_0_114]           ; Multiply by 0.114
    addss xmm0, xmm1                    ; Add to result in xmm0
    
    roundss xmm0, xmm0, 4               ; Round to nearest int
    cvtss2si edi, xmm0
    mov dword [grayscale], edi

    mov ebx, dword [grayscale]
    mov byte [rax + 3], bl

    mov rdi, histogram
    inc dword [rdi + rbx * 4]

    mov rax, [rax + 32]
    mov [col_ptr], rax

    jmp loop_histogram

end_cols:
    ret

end_rows:
    ret

compute_cumulative_histogram:
    mov edx, dword [rdi + rsi * 4]
    add dword [cumulative], edx
    
    mov edx, dword [cumulative]
    mov dword [rax + rsi * 4], edx

    inc rsi
    cmp rsi, 256
    jl compute_cumulative_histogram

    ret

find_cdf_min:
    mov ebx, dword [rdi + rsi * 4]

    cmp ebx, 0
    jle .next

    mov eax, dword [cdfMin]
    cmp ebx, eax
    jge .next

    mov dword [cdfMin], ebx

    .next:
        inc rsi
        cmp rsi, 256
        jl find_cdf_min

        ret

normalize_cdf:
    mov r8, [row_ptr]
    cmp r8, 0
    je end_normalization

    mov [col_ptr], r8
    call loop_normalize

    mov r8, [row_ptr]
    mov r8, [r8 + 16]
    mov [row_ptr], r8

    jmp normalize_cdf

loop_normalize:
    mov r8, [col_ptr]
    cmp r8, 0
    je end_normalization

    mov ebx, dword [r8 + 3]

    mov rdi, cumulativeHistogram
    mov ecx, dword [rdi + rbx * 4]

    mov edx, dword [cdfMin]

    mov esi, dword [totalPixels]

    sub ecx, edx

    sub esi, edx
    jz end_normalization            ; Division by 0

    cvtsi2sd xmm0, ecx
    cvtsi2sd xmm1, esi

    movapd xmm2, xmm0
    movapd xmm3, xmm1

    divpd xmm2, xmm3

    mov rax, const_255
    movsd xmm0, qword [rax]
    mulsd xmm0, xmm2

    cvtsd2si rax, xmm0
    cmp rax, 255
    jg set_max

    cmp rax, 0
    jl set_min

    jmp store_cdf_value

set_max:
    mov rax, 255
    jmp store_cdf_value

set_min:
    xor rax, rax
    jmp store_cdf_value

store_cdf_value:
    mov dword [r8 + 3], eax

    mov r8, [r8 + 32]
    mov [col_ptr], r8

    jmp loop_normalize

end_normalization:
    ret
; ==========================
; Group member 01: Shaylin_Govender_u20498952
; Group member 02: Reece_Jordaan_u23547104
; Group member 03: Ayush_Sanjith_u23535424
; Group member 04: Aryan_Mohanlall_u23565536
; Group member 05: Name_Surname_student-nr
; ==========================

section .data
    READ_ONLY                                   equ 0
    HEADER_BUFFER_SIZE                          equ 512
    newline                                     db 0x0A
    space                                       db 0x20
    comment                                     db '#', 0
    formatP6                                    db 'P6', 0
    headerBuffer times HEADER_BUFFER_SIZE       db 0

section .bss
    width                                       resd 1
    height                                      resd 1
    maxColor                                    resd 1
    fileDescriptor                              resq 1
    headNode                                    resq 1
    totalNodes                                  resd 1
    byteCounter                                 resd 1
    byteAmount                                  resd 1
    bufferPtr                                   resq 1

section .text
    global readPPM
    global _error
    extern malloc

readPPM:
    call openFile
    cmp rax, 0
    jle _error

    call readHeader
    cmp dword [byteAmount], 0
    jle _error
    cmp dword [width], 0
    jle _error
    cmp dword [height], 0
    jle _error
    cmp dword [maxColor], 0
    jle _error
    mov [bufferPtr], rsi

    call createList

    call populateList

    call closeFile

    mov rax, [headNode]
    ret

_error:
    ; Error handler to close the file and return null
    call closeFile
    xor rax, rax
    ret

openFile:
    ; Opens file for reading
    mov rax, 2
    mov rsi, READ_ONLY
    xor rdx, rdx
    syscall
    mov [fileDescriptor], rax
    ret

closeFile:
    ; Close the file if it was opened
    mov rax, 3
    mov rdi, [fileDescriptor]
    syscall
    ret

readFile:
    ; Read the file into the buffer (512 bytes)
    mov rdi, [fileDescriptor]
    mov rax, 0
    mov rsi, headerBuffer
    mov rdx, HEADER_BUFFER_SIZE
    syscall

    mov dword [byteAmount], eax
    mov dword [byteCounter], 0

    mov rsi, headerBuffer

    ret

readHeader:
    ; Reads header and parses PPM format, width, height, max color
    call readFile
    cmp dword [byteAmount], 0
    jle .header_read

    ; Expect 'P6' format
    call skipWhitespaceAndComments
    mov rdi, formatP6
    call checkFormat

    ; Parse width, height, and max color value
    call parseWidth
    call parseHeight
    call parseMaxColor

    .header_read:
        ret

skipWhitespaceAndComments:
    ; Skips whitespace and comments in the buffer
    .skipLoop:
        mov al, [rsi]
        cmp al, [space]
        je .skip
        cmp al, [newline]
        je .skip
        cmp al, [comment]
        je .skipComment
        jmp .done

    .skipComment:
        .commentLoop:
            inc rsi
            inc dword [byteCounter]
            mov al, [rsi]
            cmp al, [newline]
            jne .commentLoop
        jmp .skipLoop

    .skip:
        inc rsi
        inc dword [byteCounter]
        jmp .skipLoop

    .done:
        ret

checkFormat:
    ; Compare the first two bytes to 'P6'
    mov al, byte [rsi]
    cmp al, byte [rdi]
    jne _error
    inc rsi
    inc dword [byteCounter]
    inc rdi
    mov al, byte [rsi]
    cmp al, byte [rdi]
    jne _error

    ; Skips to newline after format check
    .skipFormatLine:
        inc rsi
        inc dword [byteCounter]
        mov al, [rsi]
        cmp al, [newline]
        jne .skipFormatLine
        
    ret

parseWidth:
    ; Parse width value from the buffer
    call skipWhitespaceAndComments
    mov rdi, width
    call parseInteger
    ret

parseHeight:
    ; Parse height value from the buffer
    call skipWhitespaceAndComments
    mov rdi, height
    call parseInteger
    ret

parseMaxColor:
    ; Parse the maximum color value from the buffer
    call skipWhitespaceAndComments
    mov rdi, maxColor
    call parseInteger
    ret

parseInteger:
    ; Converts number in buffer to integer
    xor rcx, rcx
    xor rax, rax
    xor rbx, rbx

    ; Loop to count digits and find end of the number
    .countDigits:
        mov al, [rsi]
        cmp al, '0'
        jl .convertToInt
        cmp al, '9'
        jg .convertToInt
        inc rcx
        inc rsi
        jmp .countDigits

    .convertToInt:
        ; rsi now points to the first non-digit character, and rcx has the number of digits
        sub rsi, rcx

        ; Loop to convert the digits into an integer
        .conversionLoop:
            test rcx, rcx
            jz .done
            mov al, [rsi]
            sub al, '0'
            imul rbx, 10
            add rbx, rax
            inc rsi
            inc dword [byteCounter]
            dec rcx
            jmp .conversionLoop

        .done:
            mov [rdi], ebx
            ret

createList:
    ; Creates 2D linked list for pixel nodes (width x height)
    mov eax, [width]
    mov rdi, rax
    mov eax, [height]
    imul rdi, rax
    mov [totalNodes], edi
    imul rdi, 40
    call malloc

    test rax, rax
    jz .malloc_fail

    mov [headNode], rax

    xor rcx, rcx
    xor rsi, rsi

    .createList_row_loop:
        mov eax, [width]
        mov rdi, rax
        imul rdi, 40
        imul rdi, rcx
        mov rax, [headNode]
        add rdi, rax

        mov rdx, rdi
        xor r8, r8

        .createList_column_loop:
            mov byte [rdx], 0
            mov byte [rdx + 1], 0
            mov byte [rdx + 2], 0
            mov byte [rdx + 3], 0

            .set_up:
                mov qword [rdx+8], 0
                mov eax, [width]
                cmp rsi, rax
                jl .set_down
                mov r9, rdx
                imul rax, 40
                sub r9, rax
                mov qword [rdx+8], r9

            .set_down:
                mov qword [rdx+16], 0
                mov eax, [height]
                mov r9, rax
                mov eax, [width]
                imul r9, rax
                sub r9, rax
                cmp rsi, r9
                jge .set_left
                mov r9, rdx
                imul rax, 40
                add r9, rax
                mov qword [rdx+16], r9

            .set_left:
                mov qword [rdx+24], 0
                cmp r8, 0
                jle .set_right
                mov r9, rdx
                sub r9, 40
                mov qword [rdx+24], r9

            .set_right:
                mov qword [rdx+32], 0
                mov eax, [width]
                dec eax
                cmp r8, rax
                jge .createList_next_column
                mov r9, rdx
                add r9, 40
                mov qword [rdx+32], r9

            .createList_next_column:
                add rdx, 40
                inc rsi
                inc r8
                mov eax, [width]
                cmp r8, rax
                jl .createList_column_loop
            
        inc rcx
        mov eax, [height]
        cmp rcx, rax
        jl .createList_row_loop

        ret

    .malloc_fail:
        mov qword [headNode], 0
        ret

populateList:
    ; Populates the linked list's pointers, connecting all nodes in the list.
    mov rsi, [bufferPtr]
    call skipWhitespaceAndComments
    mov rax, [headNode]
    mov rdi, rax

    .populateList_row_loop:
        mov rdx, rdi

        .populateList_column_loop:
            mov eax, [byteCounter]
            cmp eax, [byteAmount]
            jl .set_red
            
            push rdi
            push rdx
            call readFile
            pop rdx
            pop rdi

            cmp dword [byteAmount], 0
            jle .end_loop

            .set_red:
                mov al, byte [rsi]
                mov byte [rdx], al
                inc rsi
                inc dword [byteCounter]

                mov eax, [byteCounter]
                cmp eax, [byteAmount]
                jl .set_green

                push rdi
                push rdx
                call readFile
                pop rdx
                pop rdi

                cmp dword [byteAmount], 0
                jle .end_loop

            .set_green:
                mov al, byte [rsi]
                mov byte [rdx+1], al
                inc rsi
                inc dword [byteCounter]

                mov eax, [byteCounter]
                cmp eax, [byteAmount]
                jl .set_blue
                
                push rdi
                push rdx
                call readFile
                pop rdx
                pop rdi
                
                cmp dword [byteAmount], 0
                jle .end_loop

            .set_blue:
                mov al, byte [rsi]
                mov byte [rdx+2], al
                inc rsi
                inc dword [byteCounter]

                mov eax, [byteCounter]
                cmp eax, [byteAmount]
                jl .populateList_next_column
                
                push rdi
                push rdx
                call readFile
                pop rdx
                pop rdi

                cmp dword [byteAmount], 0
                jle .end_loop
            
            .populateList_next_column:
                mov rdx, [rdx+32]
                cmp rdx, 0
                jne .populateList_column_loop
                
        mov rdi, [rdi+16]
        cmp rdi, 0
        jne .populateList_row_loop

    .end_loop:
        ret
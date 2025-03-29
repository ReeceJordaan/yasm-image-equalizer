; ==========================
; Group member 01: Shaylin_Govender_u20498952
; Group member 02: Reece_Jordaan_u23547104
; Group member 03: Ayush_Sanjith_u23535424
; Group member 04: Aryan_Mohanlall-u23565536
; Group member 05: Name_Surname_student-nr
; ==========================

section .data
    format db "Hello World",0
    eg dd 50.0
    min dd 0.0
    max dd 255.0
    half dd 0.5
    
section .text
    global applyHistogramEqualisation

applyHistogramEqualisation:
    cmp rdi,0           ;NULL check
    je END

    mov rbx,rdi
    mov rdx,rbx         ;rdx for row
    mov rcx,rdx         ;rcx for col

    jmp TraverseRowRight

CheckAllSides:
    mov r13,[rbx+32]
    cmp r13,0
    jne SetUpRowAndCol

    mov r13,[rbx+16]
    cmp r13,0
    jne SetUpRowAndCol

    mov r13,[rbx+24]
    cmp r13,0
    jne SetUpRowAndCol

    mov r13,[rbx+8]
    cmp r13,0
    jne SetUpRowAndCol

SetUpRowAndCol:
    mov rcx,r13
    mov rdx,r13
    jmp TraverseRowRight

TraverseRowRight:
    cmp rcx,0
    je MoveToNextRow
    jmp FindIntensity

MoveToNextRow:
   mov rdx,[rdx+16]          ;move down
   cmp rdx,0
   je END
   mov rcx,rdx
   jmp TraverseRowRight

FindIntensity:
    movzx r11,BYTE [rcx+3]   ;get CDF
    movzx r12,BYTE [rcx+3]   ;save CDF 

    ;Clamping
    cmp eax,0
    jl Set0

    cmp eax,255
    jg Set255
    jmp UpdateIntensity

Set255:
    mov eax,255
    jmp UpdateIntensity

Set0:
    mov eax,0
    jmp UpdateIntensity

UpdateIntensity:
    mov  BYTE [rcx],r11b
    mov  BYTE [rcx+1],r11b
    mov  BYTE [rcx+2],r11b
    mov  BYTE [rcx+3],r12b

    mov rcx,[rcx+32]
    jmp TraverseRowRight
    ret


END:
    ret
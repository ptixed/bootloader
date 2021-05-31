
print16:
    pusha

print16_loop:
    mov ax, [bx]
    test al, al
    jz print16_end

    mov ah, 0x0e
    int 0x10

    inc bx
    jmp print16_loop

print16_end:
    popa
    ret


print16b:
    pusha
    mov cx, 8

print16b_loop:
    mov al, '0'
    mov ah, 0x0e
    
    test bl, 0x80
    jz print16b_print
    inc al

print16b_print:
    int 0x10

    shl bl, 1
    dec cx
    jnz print16b_loop

print16b_end:
    popa
    ret

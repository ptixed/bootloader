[org 0x7c00]
[bits 16]

jmp main

times 3-($-$$) db 0x90
%include "asm/fdd.asm"

main:
    mov ebp, 0
    mov ds, bp
    mov ebp, 0x2000
    mov esp, ebp

    mov [drive_id], dl

    mov ah, 0x8
    int 0x13
    inc dh
    mov [head_number], dh
    and cl, 00111111b
    mov [sector_number], cl

    mov bx, hello_bios
    call print16

    mov cx, 0
    mov edi, 0x01000000
init_disk:
    push cx 

        ; CHS conversion
        mov ax, cx
        mov cl, 0x80
        mul cl
        add ax, 1

        xor dx, dx
        mov cl, [sector_number]
        div cx
        push dx ; remainder = sector
            xor dx, dx
            mov cl, [head_number]
            div cx
            mov dh, dl ; remainder = head
        pop cx
        inc cx
        mov ch, al

        ; https://en.wikipedia.org/wiki/INT_13H#INT_13h_AH=02h:_Read_Sectors_From_Drive
        mov ax, 0x1000
        mov es, ax
        mov ah, 0x02
        mov al, 0x80
        mov dl, [drive_id]
        mov bx, 0

        int 0x13

        ; ignoring error code for small images
        ; jc panic

        mov esi, 0x10000
        disk_copy:
            mov eax, [esi]
            mov [edi], eax
            add esi, 4
            add edi, 4
            cmp esi, 0x20000
            jl disk_copy

    pop cx
    inc cx
    cmp cx, 0x10
    jne init_disk

    mov bx, hello_disk
    call print16

init_vga:
    ; https://wiki.osdev.org/Drawing_In_Protected_Mode
    mov ah, 0x00
    mov al, 0x13 ; video mode 13 = VGA 320x200
    int 0x10

    xor al, al
init_palette:
    mov dx, 0x3c8
    out dx, al
    inc dx
    out dx, al   
    out dx, al   
    out dx, al   
    
    inc al
    cmp al, 64
    jl init_palette 

init_pit:
    cli
    ; https://wiki.osdev.org/Programmable_Interval_Timer
    ; this should be already set by BIOS
    ; mov al, 00110100b
    ; out 0x43, al 
    ; mov al, 0xff
    ; out 0x40, al
    ; out 0x40, al

init_32:
    lgdt [gdt_descriptor]
    mov eax, cr0
    or eax, 0x01
    mov cr0, eax
    jmp CODE_SEG:init_32_done

panic:
    mov bx, error
    call print16
    jmp $

%include "asm/print16.asm"
%include "asm/gdt.asm"

[bits 32]
init_32_done:
    mov ax, DATA_SEG
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

; only when init_vga is disabled
; mov ebx, hello_32
; call print32

jmp 0x01000000
jmp $

%include "asm/print32.asm"

hello_bios:
    db "Hello from bios", 0x0a, 0x0d, 0
hello_disk:
    db "Hello from disk", 0x0a, 0x0d, 0
hello_32:
    db "Hello from 32 bits", 0
error:
    db "Error", 0x0a, 0x0d, 0
drive_id:
    db 0
head_number:
    db 0
sector_number:
    db 0

times 510-($-$$) db 0
dw 0xaa55


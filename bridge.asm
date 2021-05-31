[bits 32]
[extern main]

IRQ0 equ 0x20
GPF  equ 0x0d

init_pic:

PIC1      equ 0x20
PIC1_DATA equ 0x21
PIC2      equ 0xa0
PIC2_DATA equ 0xa1

    ; https://wiki.osdev.org/8259_PIC
    in al, PIC1_DATA
    push ax
    in al, PIC2_DATA
    push ax

    ; initialization command words ICW1-4
    mov al, 0x11
    out PIC1, al
    out 0x80, al
    out PIC2, al
    out 0x80, al
    
    mov al, IRQ0
    out PIC1_DATA, al
    out 0x80, al
    mov al, IRQ0 + 8
    out PIC2_DATA, al
    out 0x80, al

    mov al, 4 
    out PIC1_DATA, al
    out 0x80, al
    mov al, 2
    out PIC2_DATA, al
    out 0x80, al

    mov al, 1
    out PIC1_DATA, al
    out 0x80, al
    out PIC2_DATA, al
    out 0x80, al

    ; restore masks
    pop ax
    out PIC2_DATA, al
    out 0x80, al
    pop ax
    out PIC1_DATA, al
    out 0x80, al

    ; https://wiki.osdev.org/Interrupt_Descriptor_Table#Structure_IA-32
init_irq0:
    mov eax, irq0_handler
    mov word [idt + IRQ0*8], ax
    mov word [idt + IRQ0*8 + 2], 8 ; aka CODE_SEG
    mov word [idt + IRQ0*8 + 4], 0x8E00
    shr eax, 16
    mov word [idt + IRQ0*8 + 6], ax
init_gpf:
    mov eax, gpf_handler
    mov word [idt + GPF*8], ax
    mov word [idt + GPF*8 + 2], 8 ; aka CODE_SEG
    mov word [idt + GPF*8 + 4], 0x8E00
    shr eax, 16
    mov word [idt + GPF*8 + 6], ax

init_interrupts:
    lidt [idtr]
    sti

call main
jmp $

irq0_handler:
    mov al, 0x20 ; PIC end of interrupt
    out PIC1, al
    iret

gpf_handler:
    add esp, 4
    iret

idt:
    times (IRQ0+0x10)*8 db 0
idtr:
    dw (IRQ0+0x10)*8 - 1
    dd idt


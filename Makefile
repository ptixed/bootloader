all: image
run: all
	qemu-system-x86_64 -drive format=raw,file=image
flash: all
	sudo dd if=image of=/dev/sda
	sudo eject /dev/sda
clean:
	rm -rf *.o *.bin image splash/ splash.c

.PHONY: all run flash clean

%.o: %.c
	gcc -fno-pie -fno-asynchronous-unwind-tables -m32 -ffreestanding -c $< -o $@
bridge.o : bridge.asm
	nasm bridge.asm -f elf -o bridge.o -w+all 
kernel.bin : kernel.o bridge.o splash.o
	ld -m elf_i386 -o kernel.bin -Ttext 0x01000000 bridge.o kernel.o splash.o --oformat binary
boot.bin : boot.asm
	nasm boot.asm -f bin -o boot.bin -w+all
image: boot.bin kernel.bin
	cat boot.bin kernel.bin > image

splash.c: splash.gif
	./splash.sh
	

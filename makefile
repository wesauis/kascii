# env
ARCH ?= x86_64

# x86_64 commands
					LINK_x86_64 = x86_64-elf-ld -n -T targets/x86_64/linker.ld -o
KERNEL_COMPILE_x86_64 = x86_64-elf-gcc -c -I src/interface -ffreestanding -o $@
		 C_COMPILE_x86_64 = x86_64-elf-gcc -c -I src/interface -ffreestanding -o $@
	 ASM_COMPILE_x86_64 = nasm -f elf64 -o $@
					 ISO_x86_64 = grub-mkrescue /usr/lib/grub/i386-pc targets/x86_64/iso -o

# kernel
kernel_src := $(shell find src/kernel -name *.c)
kernel_obj := $(patsubst src/kernel/%.c, build/kernel/%.o, $(kernel_src))

$(kernel_obj): build/kernel/%.o : src/kernel/%.c
	@mkdir -p $(dir $@)
	@$(KERNEL_COMPILE_${ARCH}) $(patsubst build/kernel/%.o, src/kernel/%.c, $@)

# C
c_src := $(shell find src/${ARCH} -name *.c)
c_obj := $(patsubst src/${ARCH}/%.c, build/${ARCH}/%.o, $(c_src))

$(c_obj): build/${ARCH}/%.o : src/${ARCH}/%.c
	@mkdir -p $(dir $@)
	@$(C_COMPILE_${ARCH}) $(patsubst build/${ARCH}/%.o, src/${ARCH}/%.c, $@)

# assembly
asm_src := $(shell find src/${ARCH} -name *.asm)
asm_obj := $(patsubst src/${ARCH}/%.asm, build/${ARCH}/%.o, $(asm_src))

$(asm_obj): build/${ARCH}/%.o : src/${ARCH}/%.asm
	@mkdir -p $(dir $@)
	@$(ASM_COMPILE_${ARCH}) $(patsubst build/${ARCH}/%.o, src/${ARCH}/%.asm, $@)


.PHONY: build clean

build: $(kernel_obj) $(c_obj) $(asm_obj)
	@mkdir -p dist/${ARCH}
	@$(LINK_${ARCH}) dist/${ARCH}/kascii-${ARCH}.bin $(kernel_obj) $(c_obj) $(asm_obj)
	@cp dist/${ARCH}/kascii-${ARCH}.bin targets/${ARCH}/iso/boot/kernel.bin
	@$(ISO_${ARCH}) dist/${ARCH}/kascii-${ARCH}.iso

clean:
	@rm -r build dist || :
	@rm targets/${ARCH}/iso/boot/kernel.bin || :

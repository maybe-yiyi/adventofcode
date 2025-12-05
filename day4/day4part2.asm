section .data
inputfile db "input4.txt", 0x00
charbuf   db 0                ; for input and output
sum       dq 0
string    times 19044 db 0
rowdir    dq 0, 1, 1, 1, 0, -1, -1, -1 
coldir    dq 1, 1, 0, -1, -1, -1, 0, 1

section .text
global  _start

readchar:
  push  rdx
  push  rsi
  push  rdi

  mov   rdx, 1          ; 1 byte
  lea   rsi, [charbuf]  ; to charbuf
  mov   rdi, 3          ; first file opened
  mov   rax, 0x00       ; read
  syscall

  pop   rdi
  pop   rsi
  pop   rdx
  ret

printchar:
  push  rdx
  push  rcx
  push  rsi
  push  rdi
  push  rax

  mov   rdx, 1
  lea   rsi, [charbuf]
  mov   rdi, 1
  mov   rax, 0x01
  syscall

  pop   rax
  pop   rdi
  pop   rsi
  pop   rcx
  pop   rdx
  ret

intlen:
  push  rdx
  push  rsi
  push  rdi

  mov   rdi, 0
lenloop:
  inc   rdi
  xor   rdx, rdx
  mov   rsi, 10
  idiv  rsi
  cmp   rax, 0
  jnz   lenloop

  mov   rax, rdi
  pop   rdi
  pop   rsi
  pop   rdx
  ret

printint:
  push  rdx
  push  rsi
  push  rdi
  push  rax

  mov   rdi, 0
intloop:
  inc   rdi
  xor   rdx, rdx
  mov   rsi, 10
  idiv  rsi
  add   rdx, '0'
  push  rdx
  cmp   rax, 0
  jnz   intloop
print:
  dec   rdi
  pop   rax
  mov   [charbuf], al
  call  printchar
  cmp   rdi, 0
  jne   print
  mov   [charbuf], byte 10
  call  printchar

  pop   rax
  pop   rdi
  pop   rsi
  pop   rdx
  ret

_start:
  ; open file
  mov   rsi, 0          ; readonly
  mov   rdi, inputfile
  mov   rax, 0x02       ; open
  syscall

main_loop:
  xor   rbx, rbx        ; row idx
i_loop:
  inc   rbx
  cmp   rbx, 138
  je    after_input
  xor   rdx, rdx        ; col idx
j_loop:
  inc   rdx
  
  call  readchar

  cmp   rdx, 137
  je    i_loop

  mov   al, [charbuf]
  imul  rcx, rbx, 138   ; rcx = 12 * rbx
  add   rcx, rdx        ; rcx = 12 * rbx + rdx
  cmp   al, 64          ; '@'
  jne   is_empty
  mov   [string + rcx], byte 1
  jmp   j_loop
is_empty:
  mov   [string + rcx], byte 0
  jmp   j_loop

after_input:
  xor   r15, r15        ; roll counter big
  xor   rbx, rbx        ; row idx
i_loop_1:
  inc   rbx
  cmp   rbx, 138
  je    extra_part
  xor   rdx, rdx        ; col idx
j_loop_1:
  inc   rdx
  cmp   rdx, 138
  je    i_loop_1
  
  imul  rcx, rbx, 138   ; rcx = 12 * rbx
  add   rcx, rdx        ; rcx = 12 * rbx + rdx
  cmp   [string + rcx], byte 0
  je    j_loop_1

  xor   rdi, rdi        ; roll counter
  xor   rsi, rsi        ; dir idx
dir_loop:
  mov   r8, [rowdir + 8 * rsi]  ; r8 = rowdir[rsi]
  mov   r9, [coldir + 8 * rsi]  ; r9 = coldir[rsi]
  add   r8, rbx                 ; r8 = rowdir[rsi] + rbx
  add   r9, rdx                 ; r9 = coldir[rsi] + rdx
  imul  r8, r8, 138             ; r8 = 138 * (rowdir[rsi] + rbx)
  add   r8, r9                  ; r8 = 138 * (rowdir[rsi] + rbx) + coldir[rsi] + rdx
  inc   rsi
  cmp   [string + r8], byte 0
  je    after_if
  inc   rdi
after_if:
  cmp   rsi, 8
  jne   dir_loop
  cmp   rdi, 4
  jge   j_loop_1
  imul  rcx, rbx, 138   ; rcx = 12 * rbx
  add   rcx, rdx        ; rcx = 12 * rbx + rdx
  mov   [string + rcx], byte 0
  inc   r15
  jmp   j_loop_1
extra_part:
  cmp   r15, 0
  je    return
  add   [sum], r15
  jmp   after_input

return:
  mov   rax, [sum]
  call  printint

  mov   rdi, 0
  mov   rax, 0x3c
  syscall

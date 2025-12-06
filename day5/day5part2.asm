section .data
inputfile db "input5.txt", 0x00
charbuf   db 0                ; for input and output
arr       times 400 dq 0

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
  xor   r15, r15        ; idx in arr
read_ranges:
  xor   rbx, rbx        ; integer
read_first:
  call  readchar
  
  mov   al, [charbuf]
  cmp   al, 45 ; '-'
  je    after_read_first
  cmp   al, 10 ; '\n'
  je    done_ranges

  sub   al, '0'
  imul  rbx, rbx, 10
  add   rbx, rax
  jmp   read_first
after_read_first:
  shl   rbx, 1
  mov   [arr + 8 * r15], rbx
  inc   r15
  xor   rbx, rbx
read_second:
  call  readchar
  mov   al, [charbuf]
  cmp   al, 10 ; '\n'
  je    after_read_second

  sub   al, '0'
  movzx rax, al
  imul  rbx, rbx, 10
  add   rbx, rax
  jmp   read_second
after_read_second:
  shl   rbx, 1
  inc   rbx
  mov   [arr + 8 * r15], rbx
  inc   r15
  jmp   read_ranges
done_ranges:
  mov   rbx, -1
  mov   [arr + 8 * r15], rbx ; -1 terminated array
  xor   r8, r8      ; count
sort:
  inc   r8
  cmp   r8, r15
  jge   end_sort
  xor   r9, r9      ; j index
  dec   r9
inner_loop:
  inc   r9
  mov   r10, [arr + 8 * r9 + 8]
  cmp   r10, -1
  je    sort
  cmp   r10, [arr + 8 * r9]
  jge   inner_loop
  mov   r11, [arr + 8 * r9]
  mov   [arr + 8 * r9 + 8], r11
  mov   [arr + 8 * r9], r10
  jmp   inner_loop
end_sort:
  xor   r15, r15    ; index
  xor   r14, r14    ; start - end
  mov   r13, [arr]  ; start int
  shr   r13, 1
  xor   r12, r12    ; count
loop:
  mov   rax, [arr + 8 * r15]
  inc   r15
  cmp   rax, -1
  je    return
  shr   rax, 1
  jc    is_end_int
  inc   r14
  jmp   after_if
is_end_int:
  dec   r14
after_if:
  cmp   r14, 0
  jne   loop

  add   r12, rax
  sub   r12, r13
  inc   r12

  mov   rax, [arr + 8 * r15]
  shr   rax, 1
  mov   r13, rax
  jmp   loop
  
return:
  mov   rax, r12
  call  printint

  mov   rdi, 0
  mov   rax, 0x3c
  syscall

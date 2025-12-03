section .data
inputfile db "input2.txt", 0x00
charbuf   db 0                ; for input and output
startint  dq 0                ; start interval
endint    dq 0                ; end interval
intlength dq 0                ; length of the current integer
sum       dq 0                ; total sum

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
  push  rcx

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

  pop   rcx
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
  xor   rbx, rbx
read_until_dash:
  call  readchar
  cmp   rax, 0 ; EOF
  je    return
  
  mov   al, [charbuf]
  cmp   al, 45 ; '-'
  je    after_read_until_dash

  mov   r15b, [charbuf]
  sub   r15b, '0'
  movzx r15, r15b
  imul  rbx, rbx, 10
  add   rbx, r15
  jmp   read_until_dash
after_read_until_dash:
  mov   [startint], rbx

  xor   rbx, rbx
read_until_comma:
  call  readchar
  mov   al, [charbuf]
  cmp   al, 44 ; ','
  je    after_read_until_comma

  mov   r15b, [charbuf]
  sub   r15b, '0'
  movzx r15, r15b
  imul  rbx, rbx, 10
  add   rbx, r15
  jmp   read_until_comma

after_read_until_comma:
  mov   [endint], rbx
 
  mov   r12, [startint]
  dec   r12
loop_through_ints:
  inc   r12
  cmp   [endint], r12
  jl    after_loops
  mov   rax, r12
  call  intlen
  mov   [intlength], rax

  mov   r14, 0            ; start at length = 2
loop_various_lengths:
  inc   r14
  cmp   r14, [intlength]
  jge   loop_through_ints
  ; check if r14 divides length
  xor   rdx, rdx
  mov   rax, [intlength]
  mov   rcx, r14
  idiv  rcx
  cmp   rdx, 0
  jne   loop_various_lengths ; jumps if rem neq 0

  mov   rsi, 10
  mov   rcx, r14
powerloop:
  cmp   rcx, 1
  jle   afterpower
  imul  rsi, rsi, 10
  dec   rcx
  jmp   powerloop
afterpower:
  mov   rax, r12
  xor   rdx, rdx
  idiv  rsi

  mov   r15, rdx
  mov   rbx, rax
testpowers:
  cmp   rbx, 0
  je    after_test

  mov   rax, rbx
  xor   rdx, rdx
  idiv  rsi
  cmp   rdx, r15
  jne   loop_various_lengths
  
  mov   rbx, rax
  jmp   testpowers
after_test:
  add   [sum], r12
  jmp   loop_through_ints
after_loops:
  jmp   main_loop
return:
  mov   rax, [sum]
  call  printint

  mov   rdi, 0          ; code 0
  mov   rax, 0x3c       ; exit
  syscall

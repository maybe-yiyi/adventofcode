section .data
inputfile db "input2.txt", 0x00
charbuf   db 0                ; for input and output
startint  dq 0                ; start interval
endint    dq 0                ; end interval
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

  shr   rax, 1
  jc    loop_through_ints ; jumps if CF is 1 (aka odd)

  mov   rsi, 1
  mov   rcx, rax
powerloop:
  cmp   rcx, 0
  jle   afterpower
  imul  rsi, rsi, 10
  dec   rcx
  jmp   powerloop
afterpower:             ; rsi is now 10^(len/2)
  mov   rax, r12
  xor   rdx, rdx
  idiv  rsi
  cmp   rax, rdx        ; check if top half = bottom half
  jne   loop_through_ints

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

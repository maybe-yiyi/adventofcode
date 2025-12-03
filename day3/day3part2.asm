section .data
inputfile db "input3.txt", 0x00
charbuf   db 0                ; for input and output
sum       dq 0
string    times 100 db 0
stringlen dq 100

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
  xor   rbx, rbx          ; index
read_inputs:
  call  readchar
  cmp   rax, 0            ; EOF
  je    return

  mov   al, [charbuf]
  cmp   al, 10            ; '\n'
  je    after_input
not_bigger:
  mov   [string + rbx], al; store char into string
  inc   rbx
  jmp   read_inputs

after_input:
  xor   r9, r9
  mov   r13, -1
  xor   r15, r15          ; big loop index
big_loop:
  inc   r15
  cmp   r15, 12            ; number of times to loop
  jg    after_big_loop

  mov   rbx, r13
  xor   r14b, r14b        ; largest char
  xor   r13, r13          ; index of char
second_loop:
  inc   rbx
  mov   rax, [stringlen]
  sub   rax, 12
  add   rax, r15
  cmp   rbx, rax
  jge   after_loop

  mov   r12b, [string + rbx]

  cmp   r12b, 0           ; null term basically
  je    after_loop

  cmp   r12b, r14b
  jle   second_loop
  mov   r14b, r12b
  mov   r13, rbx
  jmp   second_loop

after_loop:
  imul  r9, r9, 10
  sub   r14b, 48
  movzx r14, r14b
  add   r9, r14

  jmp   big_loop
after_big_loop:
  add   [sum], r9
  jmp   main_loop

return:
  mov   rax, [sum]
  call  printint

  mov   rdi, 0          ; code 0
  mov   rax, 0x3c       ; exit
  syscall

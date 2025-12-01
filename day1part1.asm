section .data
inputfile db "input1.txt", 0x00
charbuf   db 0

section .text
global  _start

readchar:
  push  rcx
  push  r10

  mov   rdx, 1
  lea   rsi, [charbuf]
  mov   rdi, 3
  mov   rax, 0x00
  syscall

  pop   r10
  pop   rcx
  ret

printchar:
  push  rdi
  push  rcx
  push  r10
  
  mov   rdx, 1
  lea   rsi, [charbuf]
  mov   rdi, 1
  mov   rax, 0x01
  syscall

  pop   r10
  pop   rcx
  pop   rdi
  ret

printint:
  push  rdx

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

  pop   rdx
  ret
 
_start:
  ; open file
  mov   rsi, 0  ; read_only
  mov   rdi, inputfile
  mov   rax, 0x02
  syscall

  ; initialize rbx to 50, this is our dial
  mov   rbx, 10050

  ; initialize r8 to 0, this is our counter (result)
  xor   r12, r12

main_loop:
  ; read sign into r10
  xor   r10, r10
  call  readchar
  mov   r10b, [charbuf]

  ; initialize rcx for movement
  xor   rcx, rcx
read_until_newline:
  call  readchar
  cmp   rax, 0 ; EOF
  je    return
  
  mov   al, [charbuf]
  cmp   al, 10 ; '\n'
  je    after_read_until_newline

  mov   r9b, [charbuf]
  sub   r9b, '0'
  movzx r9, r9b
  imul  rcx, rcx, 10
  add   rcx, r9
  jmp   read_until_newline

after_read_until_newline:
  cmp   r10b, 'L'
  jne   turn_right
turn_left:
  sub   rbx, rcx
  jmp   after_turn
turn_right:
  add   rbx, rcx

after_turn:
while:
  cmp   rbx, 10050
  jg    after_while
  add   rbx, 100
  jmp   while
after_while:
  mov   rax, rbx
  xor   rdx, rdx
  mov   rsi, 100
  div   rsi

  cmp   rdx, 0
  jne   main_loop

  inc   r12
  jmp   main_loop

return:
  mov   rax, r12
  call  printint

  mov   rdi, 0
  mov   rax, 0x3c
  syscall

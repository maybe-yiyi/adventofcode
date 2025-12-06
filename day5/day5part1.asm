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
  movzx rax, al
  imul  rbx, rbx, 10
  add   rbx, rax
  jmp   read_first
after_read_first:
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
  mov   [arr + 8 * r15], rbx
  inc   r15
  jmp   read_ranges
done_ranges:
  xor   r15, r15        ; count
loop_query:
  xor   rbx, rbx        ; query
input_query:
  call  readchar
  cmp   rax, 0 ; EOF
  je    return

  mov   al, [charbuf]
  cmp   al, 10 ; '\n'
  je    after_input_query

  sub   al, '0'
  movzx rax, al
  imul  rbx, rbx, 10
  add   rbx, rax
  jmp   input_query
after_input_query:
  ;mov   rax, rbx
  ;call  printint
  xor   r14, r14        ; idx of array
loop_array:
  mov   r13, [arr + 8 * r14]
  inc   r14
  cmp   rbx, r13
  jge   greater_than_first
  inc   r14
  jmp   loop_array
greater_than_first:
  mov   r13, [arr + 8 * r14]
  ;mov   rax, r13
  ;call  printint
  inc   r14
  cmp   rbx, r13
  jle   less_than_second
  mov   r13, [arr + 8 * r14]
  cmp   r13, 0          ; end of inputs
  je    loop_query
  jmp   loop_array
less_than_second:
  inc   r15             ; add 1 to count
  jmp   loop_query      ; done searching
return:
  mov   rax, r15
  call  printint

  mov   rdi, 0
  mov   rax, 0x3c
  syscall

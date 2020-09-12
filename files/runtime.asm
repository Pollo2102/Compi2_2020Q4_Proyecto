; EasyASM C runtime functions
 
.global print_str
.global print_int
.global print_char
.global read_int
 
start:
    jal main
    
    ; Exit program
    li $v0, 10
    syscall
 
print_str:
    li $v0, 4
    syscall
    jr $ra
 
print_int:
    li $v0, 1
    syscall
    jr $ra
 
print_char:
    li $v0, 11
    syscall
    jr $ra
    
read_int:
    li $v0, 5
    syscall
    jr $ra
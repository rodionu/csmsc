li $a0,1	#Reg1
li $a1,0	#Reg2
li $t0,1	#Track original stack ptr
move $t0, $sp		#Reserve stack pointer
subi $t0,$t0,-40	#Set end condition
LOOP:
	add $s0,$a0,$a1	#Add up fibonacci sequence
	move $a1,$a0		#Cycle numbers
	move $a0, $s0		#Cycle numbers
	sw $a0,($sp)		#Store result to stack
	subi $sp,$sp,-4		#In(dec)rement stack pointer
	blt $sp,$t0,LOOP	#Will stop at desired element in sequence (10)
li $v0,10
syscall
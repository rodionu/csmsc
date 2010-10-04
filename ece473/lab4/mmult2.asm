# Matrix multiplier
# 10/3/10
# Cameron McGary

.data
aMatrix:	.word 1 2 -1 3 0 4
bMatrix:	.word 1 -4 2 5 -3 6
cMatrix	.word 0 0 0 0
aXdim:		.word 3		#Row length
aYdim:		.word 2		#Column length
bXdim:		.word 2
bYdim:		.word 3
cXdim:		.word 0		#Reserving memory space
cYdim:		.word 0

#What all the registers in this program are used for
#a0-a4: 	Storing aX/aY and bX/bY dimensions
#t0:		Column select for A, Row select for B
#t1-t2:	Storing the elements to be multiplied in A and B
#t4:		Temporary multiplication storage
#k0-k1:	Tracking current row in A and column in B (nested loops)
#s0:		Used for saving stack pointer
#t9:		Temporary offset calculation storage
#v0:		Row offset to aMatrix (row-select)
#v1:		Column offset to bMatrix (column-select)
#t8:		A address register
#t9:		B address register

main:
#This section establishes the width and length of the matrices
#in byte amounts, so they can be used as stop-limiters
#All A REGISTERS ARE USED FOR THIS, DO NOT TOUCH
	lw $a0,aXdim
	sll $a0,$a0,2
	lw $a1,aYdim
	sll $a1,$a1,2
	lw $a2,bXdim
	sll $a2,$a2,2
	lw $a3,bYdim
	sll $a3,$a3,2
	li $k0,0	#Used for tracking current row in aMatrix
	li $k1,0	#Used for tracking current column in bMatrix

	lw $s1,aYdim		#Load #rows*4 into s1, so we know how many times to rpt
	li $v0,0			#A-Row select
	li $v1,0			#B-Column select

#This section calculates a single element of the resultant matrix
#one ROW in aMatrix and one COLUMN in bMatrix

ele:		li $t0,0			#Initialization (count = 0)
		la $s0,$sp		#Save stack pointer (will need it later)

mults:	
		add $v0,$v0,$t0		#Select element in aMatrix
		mult $t0,$a2			#Offset of ONE ROW * ele number in bMatrix
		mflo $t4
		add $v1,$v1,$t4		#Determines full offset in bMatrix

		lw $t1,aMatrix($v0)	#Should be Matrix offset by t0 (0 to start)
		lw $t2,bMatrix($v1)
		mult $t1,$t2		#Multiply current element pair.
		mflo $t3			#Store 32 bit result
		sw $t3,$sp		#Hold result on the stack for now
		subi $sp,$sp,4		#Decrement stack pointer
		addi $t0,$t0,4		#Add 4 to $a0
		blt $t0,$a0,mults	#Repeat until you calculate the last element

		lw $t1,$sp			#Load top of stack
stack:	addi $sp,$sp,4		#Increment stack ptr
		lw $t2,$sp			#Load register with next stack element
		add $t1,$t1,$t3		#Add (to eventually get matrix result element)
		blt $sp,$s0,stack	#Make sure we don't go past the starting address

#Now we need to save the resultant number into the c matrix, and restart
#We must check to see if we have used all columns in B before switching
#to a new row in A

	sw $t1,cMatrix($k0)
	addi $k0,$k0,4		#Bump counters by 4 bytes
	addi $k1,$k1,4	
	blt $k1,$a2,ele		#
		

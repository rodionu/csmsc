# Matrix multiplier
# 10/3/10
# Cameron McGary

.data
aMatrix:	.word 1 2 -1 3 0 4
bMatrix:	.word 1 -4 2 5 -3 6
cMatrix:	.word 0 0 0 0
aXdim:		.word 3		#Row length
aYdim:		.word 2		#Column length
bXdim:		.word 2
bYdim:		.word 3
cXdim:		.word 2		#Reserving memory space
cYdim:		.word 2

.text
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

#C code summary Format a[column][row]
#xA and yA are the dimensions of A
#
#for(i=0; i<yA,  i++){		//Index through ROWS of A (column select B) Counter 1
#	for(k1=0; k1<xB; k1++){
#		z=0;	
#		for(k=0; i<xA, k++{		//Index through ROWS of B (column select A) Counter 2
#			z += a[i][k0] * b[k0][k1];
#		}
#		sv = z;				//SAVE z (probably to stack)
#		k = 0;				//Reset nested index counter
#	}
#	k1=0;					//Reset nested (k1) counter
#}
#Then add them up, shouldn't be hard
move $s0,$sp	#Save stack pointer
li $v0,0		#Counter 0 (A ROWS)
li $k0,0		#Counter 1 (B COLUMNS)
li $k1,0		#Counter 2 (A COLUMNS, B ROWS)
la $s1,cMatrix	#Store an address index

	
ROW:
	beqz $v0,BCF		#If first iteration, calculate an element
	addi $v0,$v0,1		#If not first iteration, index to next row and continue
	li $k0,0			#ELSE Reset counter 1
	srl $t0,$a1,2
	bgt $v0,$t0,END


BCF:	beqz $k0,ELE	#Calculate an element (first run)
BCN:addi $k0,$k0,4	#Select next B column
	bgt $k0,$a2,ROW
	li $k1,0		#Clear nested counter

#Calculate one element (for(k) loop)
ELE:	
	mult $v0,$a0		#Determine row offset in aMatrix
	mflo $t0			#Temp storage
	lw $t1,aMatrix($k1)	#Load aMatrix offset by count2
	add $t1,$t1,$t0		#Add aMatrix row offset to column offset

	srl $t0,$k1,2		#Divide by 4 (byte offset -> count)
	mult $t0,$a2		#Calculate byte offset of B ROWS
	mflo $t0			#Temp storage
	add $t0,$t0,$k0	#Add column offset
	lw $t2,bMatrix($t0)	#Load B offset by calc'd value (one row per cycle)

	mult $t1,$t2		#Multiply cross-elements
	mflo $sp			#Save result to stack
	subi $sp,$sp,4		#Increment stack
	addi $k1,$k1,4		#Increase counter 2 by 32 bytes (next element)
	blt $k1,$a1,ELE		#Repeat until out of columns in A matrix
	li $t0,0			#Clear t0 for use

ADD:	move $t1,$sp			#Load stack value
	add $t0,$t0,$t1	#Add value on stack
	addi $sp,$sp,4		#"Decrement" stack ptr
	bge $sp,$s0,ADD	#Repeat until out of elements to sum
	subi $sp,$sp,4		#"Increment" sp, it's pointing BELOW the first ele now.
	sw $t0,($s1)		#Save the value in result matrix
	addi $s1,$s1,4		#Index forward in result matrix
	j BCN			#Finished with this B column, go to next

END:	li $v0, 10
	syscall	













	
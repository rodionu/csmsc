# Matrix multiplier - NEW TEST CASE (3x2 * 2x3)
# 10/3/10
# Cameron McGary

.data
aMatrix:	.word 6 8 15 0 -5 9
bMatrix:	.word 2 0 5 86 1 -9
cMatrix:	.word 0 0 0 0 0 0 0 0 0
aXdim:		.word 2		#Row length
aYdim:		.word 3		#Column length
#It is assumed bXdim = aYdim and bYdim = aXdim. Also, c dimensions
#do not matter for the purpose of calculation, but the appropriate
#number of spaces must be reserved (if you don't want to overwrite random data)

.text
#This section establishes the width and length of the matrices
#in byte amounts, so they can be used as stop-limiters
#All A REGISTERS ARE USED FOR THIS, DO NOT TOUCH
	lw $a0,aXdim	#also bYdim
	lw $a1,aYdim	#also bXdim
	lw $a2,aXdim	
	sll $a2,$a2,2	#MEMORY WIDTH of aXdim/bYdim
	lw $a3,aYdim	
	sll $a3,$a3,2	#MEMORY WIDTH of aYdim/bXdim

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
j START
	
ROW:	addi $v0,$v0,1
START:	li $k0,0		#Clear both counters
	li $k1,0
	beqz $v0,BCF		#If first iteration, calculate an element
	bge $v0,$a1,END


BCF:	beqz $k0,ELE	#Calculate an element (first run)
BCN:	addi $k0,$k0,4	#Select next B column
	bge $k0,$a3,ROW #bXdim = aYdim
	li $k1,0		#Clear nested counter

#Calculate one element (for(k) loop)
ELE:	
	mult $v0,$a2		#Determine row offset in aMatrix (in bytes)
	mflo $t0		#Temp storage
	add $t0,$t0,$k1		#Calculate row + column offset
	lw $t1,aMatrix($t0)	#Load aMatrix corresponding to offset

	mult $k1,$a1		#Row byte length * selected column
	mflo $t0		#Temp storage
	add $t0,$t0,$k0		#Stored + column offset * 4B
	lw $t2,bMatrix($t0)	#Load B offset by calc'd value (one row per cycle)

	mult $t1,$t2		#Multiply cross-elements
	mflo $t0		#Temp storage
	sw $t0,($sp)		#Save result to stack
	subi $sp,$sp,4		#Increment stack
	addi $k1,$k1,4		#Increase counter 2 by 32 bytes (next element)
	blt $k1,$a2,ELE		#Repeat until out of columns in A matrix
	addi $sp,$sp,8		#Reverse last stack increment. Last stacked value still in t0

ADD:	lw $t1,($sp)		#Load stack value
	add $t0,$t0,$t1		#Add value on stack
	addi $sp,$sp,4		#"Decrement" stack ptr
	ble $sp,$s0,ADD		#Repeat until out of elements to sum
	subi $sp,$sp,4		#"Increment" sp, it's pointing BELOW the first ele now.
	sw $t0,($s1)		#Save the value in result matrix
	addi $s1,$s1,4		#Index forward in result matrix
	j BCN			#Finished with this B column, go to next

END:	li $v0, 10
	syscall	













	

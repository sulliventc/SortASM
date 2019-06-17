.data
list: .word 1, 8, 2, 91, 37, 88, 29, 17, 30, 32, 11, 39, 42
lbrk: .asciiz "\n"
.text

la $a0, list			# $a0 = address of list
addi $a1, $zero, 13		# $a1 = list size
jal sort			# jump and link sort
la $a0, list			# $a0 = address of list again
addi $a1, $zero, 13		# $a1 = list size again
j prnt				# jump to prnt

##########
# ------ #
# ------ #
##########
	# swap(array v, index k)
swap: 	sll $t1, $a1, 2 	# $t1 = k * 4
	add $t1, $a0, $t1	# t1 = v+(k*4)
				#    (address of v[k])
	lw $t0, 0($t1)		# $t0 (temp) = v[k]
	lw $t2, 4($t1)		# $t2 = v[k+1]
	sw $t2, 0($t1)		# v[k] = $t2 (v[k+1])
	sw $t0, 4($t1)		# v[k+1] = t0 (temp)
	jr $ra			# return to calling routine
	
	# sort(array v, size n)
sort:	addi $sp,$sp,-20	# make room on stack for 5 registers
	sw $ra, 16($sp)		# save $ra on stack
	sw $s3, 12($sp)		# save $s3 on stack
	sw $s2, 8($sp)		# save $s2 on stack
	sw $s1, 4($sp)		# save $s1 on stack
	sw $s0, 0($sp)		# save $s0 on stack
	
	move $s2, $a0		# save $a0 into $s2
	move $s3, $a1		# save $a1 into $s3
	move $s0, $zero		# i = 0
for1:	slt $t0, $s0, $s3	# $t0 = 0 if $s0 >= $s3 (i >= n)
	beq $t0, $zero, exit1	# go to exit1 if $s0 >= $s3 (i >= n)
	addi $s1, $s0, -1	# j = i - 1
for2:	slti $t0, $s1, 0	# $t0 = 1 if $s1 < 0 (j < 0)
	bne $t0, $zero, exit2	# go to exit 2 if $s1 < 0 (j < 0)
	sll $t1, $s1, 2		# $t1 = j * 4
	add $t2, $s2, $t1	# $t2 = v + (j * 4)
	lw $t3, 0($t2)		# $t3 = v[j]
	lw $t4, 4($t2)		# $t4 = v[j + 1]
	slt $t0, $t4, $t3	# $t0 = 0 if $t4 >= $t3 (v[j + 1] >= v[j])
	beq $t0, $zero, exit2	# go to exit 2 if $t4 >= $t3 (v[j + 1] >= v[j])
	move $a0, $s2		# 1st param of swap is v (old $a0)
	move $a1, $s1		# 2nd param of swap is j
	jal swap		# call swap procedure
	addi $s1, $s1, -1	# j -= 1
	j for2			# jump to test of inner loop
exit2:	addi $s0, $s0, 1	# j += 1
	j for1			# jump to test of outer loop
	
exit1:	lw $s0, 0($sp)		# restore $s0 from stack
	lw $s1, 4($sp)		# restore $s1 from stack
	lw $s2, 8($sp)		# restore $s2 from stack
	lw $s3, 12($sp)		# restore $s3 from stack
	lw $ra, 16($sp)		# restore $ra from stack
	addi $sp,$sp, 20	# restore stack pointer
	jr $ra			# return to calling routine

##########
# ------ #
# ------ #
##########

	# prnt(array v, size n)
prnt:	move $s1, $a0		# save $a0 into $s2
	move $s2, $a1		# save $a1 into $s3
	move $s0, $zero		# i = 0
	la $s3, lbrk		# save lbrk into $s4
for3:	slt $t0, $s0, $s2	# i >= n
	beq $t0, $zero, exit3
	sll $t1, $s0, 2		# $t1 = i * 2^2
	add $t1, $t1, $s1	# $t1 = v[k]
	addi $v0, $zero, 1	# v0 = print integer
	lw $a0, 0($t1)		# set a0 to integer to print
	syscall			
	addi $v0, $zero, 4	# v0 = print string
	move $a0, $s3		# a0 = "\n"
	syscall		
	addi $s0, $s0, 1	# i += 1
	j for3
exit3:	addi $v0, $zero, 10
	syscall
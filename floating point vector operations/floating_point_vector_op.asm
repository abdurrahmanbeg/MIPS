 #########################
 # By: Abdurrahman Beg 
 # Prepared for: Dr. Muhamed F. Mudawar
 # 212-COE 501: Computer Architecture
 #########################
 
 .data    
    prompt1:    	.asciiz    "\n1. Enter a Square Matrix of Single-Precision Floats"
    prompt2:    	.asciiz    "2. Compute and Print ALL the Row Sums"
    prompt3:    	.asciiz    "3. Compute and Print All the Column Sums"
    prompt4:    	.asciiz    "4. Compute and Display the Matrix Transpose"
    prompt5:    	.asciiz    "5. Exit the Program"   
    select:      	.asciiz    ">>Enter selection: "  
    newline: 		.asciiz    "\n"
    spacing: 		.asciiz    " | "
    prompt_n:  		.asciiz    "Enter N: "
    data_prompt:	.asciiz    "Enter the Matrix Elements (row-wise, bottom-up): "
    floating_num: 	.float     0.0
    mdArray: 		.float 0.0:10
	     		.float 0.0:10
	     		.float 0.0:10 
	    		.float 0.0:10 
		   	.float 0.0:10 
		   	.float 0.0:10
		   	.float 0.0:10 
		   	.float 0.0:10 
		   	.float 0.0:10 
		   	.float 0.0:10        
    size: 		.word  10
    			.eqv   DATA_SIZE 4
    
.text
.globl main
main:
menu:
    li $v0, 4     		#this is the command for printing a string
    la $a0, prompt1	 	#this loads the string to print into the argument $a0 for printing
    syscall     
    li $v0, 4     
    la $a0, newline 
    syscall  
    li $v0, 4    
    la $a0, prompt2 
    syscall     
    li $v0, 4    
    la $a0, newline 
    syscall   
    li $v0, 4   
    la $a0, prompt3 
    syscall      
    li $v0, 4    
    la $a0, newline 
    syscall  
    li $v0, 4    
    la $a0, prompt4 
    syscall     
    li $v0, 4     
    la $a0, newline 
    syscall  
    li $v0, 4     
    la $a0, prompt5 
    syscall     
    li $v0, 4     
    la $a0, newline 
    syscall  
    li $v0, 4    
    la $a0, select
    syscall      
    
    li $v0, 5    #command to read the number  provided by the user
    syscall      #executing the command for reading an integer
    move $t0, $v0 
    
    beq $t0, 1, input_matrix
    beq $t0, 2, sum_by_row
    beq $t0, 3, sum_by_col
    beq $t0, 4, transpose_matrix
    bge $t0, 5, exit
    blez $t0, exit
    
input_matrix: 
	# Input matrix row-by-row
    	# Read the value of N
   	la $a0, prompt_n
    	li $v0, 4
	syscall
	li $v0, 5 #command to read the number provided by the user
	syscall
	move $s0, $v0  #save the numbered entered in $s0
	move $a0, $s0
	jal read_matrix
   	move $s1, $v0   # Address of allocated memory from $t2 to $v0 and now to $s1
    	j menu
    
read_matrix:
	la $t2, mdArray
	lw $a3, size
	mul $t1, $a0, $a0			# n*n
	sll $t1, $t1, 2				# n*n*4
	move $a0, $t1	
	la $a0, data_prompt
	li $v0, 4				# Enter element in index
	syscall	
	li $t0, 0				# initilze loop index to zero
		
reading_matrix_elements:
	bge $t0, $t1, end_reading_matrix_elements  # keep all elements
	li $v0, 6				
	syscall					# read float
	addu $t3, $t2, $t0			# base address + loop index
	swc1 $f0, ($t3)				# store the read value
	addiu $t0, $t0, 4				# increment index
	j reading_matrix_elements			# loop

end_reading_matrix_elements:
	move $v0, $t2
	jr $ra
    
sum_by_row:	
	move $a0, $s0    #Save N in $s0
	move $a1, $s1    # address of allocated memory ( 16 bits )
	move $t2, $s2
	jal sum_row	
	j menu	

sum_row:
	move $t2, $a0  # N
	sll $a0, $a0, 2 # $a0 x 4
	li $v0, 9
	syscall        # reserver 8 bits spaces
	move $t4, $v0  # Address of allocated memory moved to $t4 ( 8 bits )
	li $t0, 0      #rowIndex
	mtc1 $zero, $f4
	li $t1, 0
	li $t7, 0
	li $t8, 0

sum_row_outer_loop:
	bge $t0, $t2, return
	mtc1 $zero, $f4
	li $t1, 0	#colIndex

sum_row_inner_loop:
	bge  $t1, $t2, sum_row_end_inner_loop # $t2 is N
	# address of A[i][j]
	mul $t6, $t0, $t2	#t6 = rowIndex	* colSize
	addu $t6, $t6, $t1	#		+ colIndex
	mul $t6, $t6, DATA_SIZE	#  		* DataSize
	addu $t6, $t6, $a1  	# 		+ base addrr
	lwc1 $f6, ($t6)      # Address of the first element is now in $f6
	add.s $f4, $f4, $f6
	
	addiu $t1, $t1, 1
	j sum_row_inner_loop

sum_row_end_inner_loop:
	bge   $t7, $t2, return
	addiu $t7, $t7, 1
	lwc1 $f24, floating_num
	add.s $f12, $f4, $f24
	li $v0, 2
	syscall
	li $v0, 4    
    	la $a0, spacing
   	syscall   
	addiu $t0, $t0, 1	#rowIndex is incremented
	j sum_row_outer_loop	
return:
	jr $ra

sum_by_col:	
	move $a0, $s0    #save the numbered entered in $s0
	move $a1, $s1    # base address of matrix ( 16 bits )
	move $a2, $s2
	jal sum_col
	
	j menu

sum_col:
	move $t2, $s0  	# N is in $a0
	sll $a0, $a0, 2 # $a0 x 4
	li $v0, 9
	syscall        	# reserver 8 bits spaces
	move $t4, $v0  	# Address of allocated memory moved to $t4 ( 8 bits )
	li $t0, 0		#rowIndex
	mtc1 $zero, $f4
	li $t1, 0	#colIndex	
	li $t7, 0
	li $t8, 0
	
sum_col_outer_loop:
	bge  $t0, $t2, return
	mtc1 $zero, $f4	

sum_col_inner_loop:
	bge  $t0, $t2, sum_col_end_inner_loop # $t2 = N
	# address of A[i][j]
	mul $t6, $t0, $t2	#t6 = rowIndex	* colSize
	addu $t6, $t6, $t1	#		+ colIndex
	mul $t6, $t6, DATA_SIZE #  		* DataSize
	addu $t6, $t6, $a1   # 			+ base addrr
	lwc1 $f6, ($t6)      # Address of the first element is now in $f6
	add.s $f4, $f4, $f6
	
	#add $t1, $t1, $t2	
	addiu $t0, $t0, 1
	#addiu $t8, $t8, 1	#inner loop index increment until N
	j sum_col_inner_loop

sum_col_end_inner_loop:
	bge    $t7, $t2, return
	addiu $t7, $t7, 1
	lwc1 $f24, floating_num
	add.s $f12, $f4, $f24
	li $v0, 2
	syscall
 	li $v0, 4    
    	la $a0, spacing
   	syscall   
	li $t0, 0
	addiu $t1, $t1, 1	#colIndex is incremented
	j sum_col_outer_loop
	
transpose_matrix:
	li $t0, 0			#rowIndex
	move $t2, $s0 			#colSize
	
transpose_outer_loop:
	beq $t0, $t2, print_matrix 		
	lwc1 $f1, floating_num
	move $t1, $t0			# colIndex
	
transpose_inner_loop:	
	beq $t1, $t2 , transpose_end_inner_loop
	# address of A[i][j]
	mul $t3, $t1, $t2		# t3 = colIndex * colSize
	add $t3, $t3, $t0		#		+ rowIndex
	mul $t3, $t3, DATA_SIZE		#  		* DataSize
	add $t3, $t3, $a1 		#		+ base addrr		
	mul $t4, $t0, $t2		# t4 = rowIndex * colSize
	add $t4, $t4, $t1		#		+ colIndex
	mul $t4, $t4, DATA_SIZE		#  		* DataSize
	add $t4, $t4, $a1 		#		+ base addrr	
	lwc1 $f2, ($t3)
	lwc1 $f3, ($t4)
	swc1 $f2, ($t4)
	swc1 $f3, ($t3)	
	addi $t1, $t1, 1		#increment colIndex
	j transpose_inner_loop
	
transpose_end_inner_loop:
	addi $t0, $t0, 1		#increment rowIndex
	li $t7, 0
	li $t8, 0
	j transpose_outer_loop

print_matrix:
	li $t0, 0 			#rowIndex = 0
	
print_matrix_outer_loop:
	beq $t0, $t2, return	
	li $v0, 4
	la $a0, newline
	syscall
	lwc1 $f1, floating_num
	li $t1, 0 #colIndex = 0			
	
print_matrix_inner_loop:	
	beq $t1, $t2, print_matrix_end_inner_loop
	mul $t3, $t0, $t2			# t4 = rowIndex * colSize
	add $t3, $t3, $t1			#		+ colIndex		
	mul $t3, $t3, DATA_SIZE			#  		* DataSize
	add $t3, $t3, $a1 			#		+ base addrr	
	lwc1 $f12,($t3)
	li $v0, 2
	syscall
	li $v0, 4
	la $a0, spacing
	syscall	
	addi $t1, $t1 , 1			#increment colIndex
	j print_matrix_inner_loop
	
print_matrix_end_inner_loop:
	addi $t0, $t0, 1			#increment rowIndex
	li $t7, 0
	li $t8, 0
	j print_matrix_outer_loop	
 	
exit:
	li $v0, 10
	syscall

    
    

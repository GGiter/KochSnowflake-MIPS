.eqv BMP_FILE_SIZE 2500000
	.data
fname:	.asciiz "source.bmp"
bitmaparea: .space BMP_FILE_SIZE # Reserve the data section being used by the bitmap display (512 x 256 bytes)	
display1: .asciiz "\nEnter 1 to run the setpixel subroutine "
display2: .asciiz "\nEnter 2 to run the drawline subroutine"
display3: .asciiz "\nEnter 3 to run the drawrectangle subroutine"
display4: .asciiz "\nEnter 4 to run the drawpolygon subroutine"
display5: .asciiz "\nEnter 5 to run the fillrectangle subroutine"
display6: .asciiz "\nEnter 6 to run the drawcircle subroutine"
display7: .asciiz "\nEnter 7 to run the fillcircle subroutine"
display8: .asciiz "\nEnter 8 to run the dashedline subroutine\n"
runagain: .asciiz "\nTo run another drawing primative enter 1, to exit enter 2"
bitmapreset: .asciiz "\nRemember to reset the bitmap display if running again\n"
cos:  .float  0.5  
sin:  .float  0.865
distance: .float 200.0
input: .asciiz "F+F-F"
	.text

main:		
	li $t0, 0
	li $a0, 0			
   	li $a1,	0
	li $a2, 50		
   	li $a3, 1
   	li $k0, 0
   	li $k1, 0
	
	jal inst_loop

inst_loop:
	# iterate through series
    	lb $t1, input($t0)
   	beq $t1, 0, primitiveran
	# change lower case character to '*'
	
	beq $t1,'+',rotate_right
	beq $t1,'-',rotate_left

   	beq $t1,'F',forward
	
   	j case 
    	sb $t1, input($t0)
		
rotate_right:

	
	mtc1 $a2,$f0 # konwersja z int na float
	move $s0,$a2 # move x2 to stack
	sub $s0,$s0,$a0 # x2 - x1
	l.s $f2 cos # save cos
	l.s $f3 sin # save sin
	
	div $s0,$s0,2  # x*cos
	
	mul.s $f0,$f0,$f2 # x*cos
	mtc1 $a3,$f1
	
	move $s1,$a3 # move y2 to stack
	sub $s1,$s1,$a1 # y2 - y1
	
	mul $s1,$s1,7 # y*7
	div $s1,$s1,8 # y/8
	
	mul.s $f1,$f1,$f3 # y*sin
	
	sub.s $f0,$f0,$f1 
	
	sub $s0,$s0,$s1 # x*cos - y*sin

	mfc1 $v0,$f0 # konwersja z float na int
	add $s0, $s0,$a0 # y2 + y1
	move $v0,$s0 # resutl x2
	
	mtc1 $a2,$f0 # konwersja z int na float
	move $s0,$a2  # move x2 to stack
	sub $s0,$s0,$a0 # x2 - x1
	
	mul.s $f0,$f0,$f3 # x*sin
	
	mul $s0,$s0,7	#x*7	
	div $s0,$s0,8 # x/8
	
	mtc1 $a3,$f1
	move $s1,$a3  # move y2 to stack
	sub $s1,$s1,$a1 # y2 - y1

	mul.s $f1,$f1,$f2 # y*cos
	div $s1,$s1,2 #y*cos
	
	add.s $f0,$f0,$f1
	add $s0,$s0,$s1

	mfc1 $v1,$f0 # konwersja z float na int
	add $s0, $s0,$a1 # y2 + y1
	move $v1,$s0 # result y2
		 	 
	move $a3,$v1
	move $a2,$v0
	
	jal case
rotate_left:

	
	mtc1 $a2,$f0 # konwersja z int na float
	move $s0,$a2 # move x2 to stack
	sub $s0,$s0,$a0 # x2 - x1
	l.s $f2 cos # save cos
	l.s $f3 sin # save sin
	
	div $s0,$s0,2  # x*cos
	
	mul.s $f0,$f0,$f2 # x*cos
	mtc1 $a3,$f1
	
	move $s1,$a3 # move y2 to stack
	sub $s1,$s1,$a1 # y2 - y1
	
	mul $s1,$s1,7 # y*7
	div $s1,$s1,8 # y/8
	
	mul.s $f1,$f1,$f3 # y*sin
	
	add.s $f0,$f0,$f1 
	
	add $s0,$s0,$s1 # x*cos + y*sin

	mfc1 $v0,$f0 # konwersja z float na int
	add $s0, $s0,$a0 # x2 + x1

	move $v0,$s0 # resutl x2
	
	mtc1 $a2,$f0 # konwersja z int na float
	move $s0,$a2  # move x2 to stack
	sub $s0,$s0,$a0 # x2 - x1
	
	mul.s $f0,$f0,$f3 # x*sin
	
	mul $s0,$s0,7	#x*7	
	div $s0,$s0,8 # x/8
	
	mtc1 $a3,$f1
	move $s1,$a3  # move y2 to stack
	sub $s1,$s1,$a1 # y2 - y1

	mul.s $f1,$f1,$f2 # y*cos
	div $s1,$s1,2 #y*cos
	
	sub.s $f0,$f1,$f0
	sub $s0,$s1,$s0

	mfc1 $v1,$f0 # konwersja z float na int
	add $s0, $s0,$a1 # y2 + y1
	move $v1,$s0 # result y2
		 	 
	move $a3,$v1
	move $a2,$v0
	
	jal case
case:
#increase index 
    addi $t0, $t0, 1

    j inst_loop 

rotate:
	mtc1 $a0,$f0 # konwersja z int na float
	l.s $f2 cos
	l.s $f3 sin
	mul.s $f0,$f0,$f2 # x*cos
	mtc1 $a1,$f1
	mul.s $f1,$f1,$f3 # y*sin
	sub.s $f0,$f0,$f1
	abs.s $f0,$f0
	mfc1 $v0,$f0 # konwersja z float na int
	
	mtc1 $a0,$f0 # konwersja z int na float
	mul.s $f0,$f0,$f3 # x*sin
	mtc1 $a1,$f1
	mul.s $f1,$f1,$f2 # y*cos
	add.s $f0,$f0,$f1
	mfc1 $v1,$f0 # konwersja z float na int
	
	jr $ra

forward:
	move $a0, $k0							
    	move $a1, $k1
	li $t9, 0x00FF0000

	add $a2,$a2,$a0
    	add $a3,$a3,$a1
	move $v0, $a2							
    	move $v1, $a3
    
    	add $a0,$a0,200		
    	add $a1,$a1,200	
    	add $a2,$a2,200	
    	add $a3,$a3,200	
	addiu $sp, $sp, -4		
	sw $t9, ($sp)
	jal drawline
	
	
	move $a0, $k0
	move $a1, $k1
	
    	move $a2, $v0							
    	move $a3, $v1
    		
    	move $k0, $a2
    	move $k1, $a3
	j case
			
primitiveran:
	add $a0,$a0,200		
    	add $a1,$a1,200	
    	add $a2,$a2,200	
    	add $a3,$a3,200
	li $v0, 10         		# Sets $v0 in preperation for a system call.
      	syscall 			# Exits the program
setpixel:
																									
	# Stores the values of the s registers in the stack so they can be used in the subroutine
												
	addiu $sp, $sp, -24	# Decrement the stack pointer
	sw $ra, 20($sp)		# Save the value of the return address to the stack
	sw $s0, 16($sp)		# Save the original value of $s0 to the stack
	sw $s1, 12($sp)		# Save the original value of $s1 to the stack
	sw $s2, 8($sp)		# Save the original value of $s2 to the stack
	sw $s3, 4($sp)		# Save the original value of $s3 to the stack
	sw $s4, ($sp)		# Save the original value of $s4 to the stack
	
	
	# Copies the values of the parameters passed in into the now free s registers
	
	move $s0, $a0		# Store the x co-ordinate in $s0
	move $s1, $a1		# Store the y co-ordinate in $s1
	move $s2, $a2		# Store the colour in $s2
	li $s3, 0x10010000 	# Load the base address (Top left hand pixel (x = 0, y = 0) address = 0x10010000
		
				
	# The main code for drawing the pixel to the bitmap
			
	sll $s1, $s1, 9		# The shift of 9 turns the y co-ordinate into the bit value of it by raising 
						# the power of the y co-ordinate to 9
	addu $s4, $s0, $s1	# Adds x co-ordinate to the number of bits calculated by the Y co-ordinate and shift
	sll $s4, $s4, 2		# The shift of 2 moves moves the bit value along to put the x co-ordinate 
						# in the correct location
	addu $s3, $s3, $s4	# Adds the value of the of the shift calculated to the base address 
						# to reach the correct XY co-ordinates
	sw $s2, ($s3)		# Load the colour into the specified memory address location		
	
					
	# Restores the original values of the s registers from the stack						
					
	lw $s4, ($sp)		# Restore original value of $s4	from the stack
	lw $s3, 4($sp)		# Restore original value of $s3 from the stack
	lw $s2, 8($sp)		# Restore original value of $s2 from the stack
	lw $s1, 12($sp)		# Restore original value of $s1 from the stack
	lw $s0, 16($sp)		# Restore original value of $s0 from the stack
	lw $ra, 20($sp)		# Restore the value of the return address from the stack
	addiu $sp, $sp, 24	# Increment the stack pointer
	
	jr $ra		# Jump to the return address to exit the subroutine
	nop
	  		
drawline:	
		
	# Stores the values of the s registers in the stack so they can be used in the subroutine
	
	addiu $sp, $sp, -52	# Decrement the stack pointer
	sw $ra, 48($sp)		# Save the value of the return address ($ra) to the stack
	sw $s0, 44($sp)		# Save the original value of $s0 to the stack
	sw $s1, 40($sp)		# Save the original value of $s1 to the stack
	sw $s2, 36($sp)		# Save the original value of $s2 to the stack
	sw $s3, 32($sp)		# Save the original value of $s3 to the stack
	sw $s4, 28($sp)		# Save the original value of $s4 to the stack
	sw $s5, 24($sp)		# Save the original value of $s5 to the stack
	sw $s6, 20($sp)		# Save the original value of $s6 to the stack
	sw $s7, 16($sp)		# Save the original value of $s7 to the stack
	sw $t0, 12($sp)		# Save the original value of $t0 to the stack
	sw $t1, 8($sp)		# Save the original value of $t1 to the stack
	sw $t2, 4($sp)		# Save the original value of $t2 to the stack
	sw $t3, ($sp)		# Save the original value of $t3 to the stack 
	
	# Copies the values of the parameters passed in into the now free s registers
	
	move $s0, $a0		# Store the x co-ordinate of point 1 in $s0
	move $s1, $a1		# Store the y co-ordinate of point 1 in $s1
	move $s2, $a2		# Store the x co-ordinate of point 2 in $s2
	move $s3, $a3		# Store the y co-ordinate of point 2 in $s3
	lw $s4, 52($sp)		# Store the colour (takes form the stack) in $s4
	
	
	# Main code for drawing the line on the bitmap
	
	subu $t3, $s2, $s0 		# Calculates x1 - x0 and store it in $t3
	abs $s5, $t3 			# Sets dx ($s5) to the absolute value of x1 - x0
	subu $t3, $s3, $s1		# Calculates y1 - y0 and stores it in $t3
	abs $s6, $t3			# Sets dy ($s6) to the absolute value of y1 - y0
	sub, $s6, $zero, $s6 	# Sets dy to -dy as dy is needed as a minus value later in calculations
							# it is turned minus via two's complement method
	bgt $s0, $s2, sxelse	# If x0 is greater than x1 then branch to sxelse
	nop
	li $s7, 1				# Set the value of sx ($s7) to 1
	b sxcomplete			# Branch around the sxelse section
	nop
	
	
sxelse:				# Branches to here if x0 is greater than x1
	li $s7, -1		# Sets the value of sx ($s7) to -1	

sxcomplete:					# Branches to here if x1 was greater than x0
	bgt $s1, $s3, syelse	# If y0 is greater than y1 then branch to syelse
	nop
	li $t0, 1				# Sets the value of sy ($t0) to 1 
	b sycomplete			# Branch around the syelse section
	nop
	
syelse:				# Branche shere is y0 is greater than y1
	li $t0, -1		# Sets the value sy ($t0) to -1
	
sycomplete:				# Branches to here if y1 was greater than y0
	addu $t1, $s5, $s6	# err is set to the value of dx - dy
drawpixelloop:
	move $a0, $s0		# Store the x co-ordinate in $a0
	move $a1, $s1		# Store the y co-ordinate in $a1
	move $a2, $s4		# Store the colour in $a2
	
	jal setpixel		# Enter the subroutine "setpixel"
	nop
	
	add $t2, $t1, $t1					# Sets e2 ($t2) to err ($t1) * 2 by calculating err + err   
	bgt $s6, $t2, e2notgreaterthandy	# Branch if -dy is greater than e2
	nop
	add $t1, $t1, $s6					# Calculate err = err - dy: err = $t1 , -dy = $s6
	add $s0, $s0, $s7					# Calculate x0 = x0 + sx: x0 = $s0 , sx = $s7
	
e2notgreaterthandy:	
	bgt $t2, $s5, e2greaterthandx		# Branch if e2 ($t2) is greater than dx ($s5)
	nop 
	add $t1, $t1, $s5					# Calculate err = derr + dx: err = $t1 , dx = $s5
	add $s1, $s1, $t0  					# Caluclate y0 = y0 + sy: y0 = $s1 , sy = $t0
e2greaterthandx:
	
	# To exit the loop x0 must now be equal to x1 and y0 much now be equal to y1
	# The two statements must be true to pass both branches and thus exits the loop
	
	bne $s0, $s2, drawpixelloop	# If x0 ($s0) and x1 ($s2) are not 
	nop							# equal branch to drawpixelloop
	bne $s1, $s3, drawpixelloop	# If y0 ($s1) and y1 ($s3) are not
	nop							# equal branch to drawpixelloop
	
	# Restores the original values of the s registers from the stack
	
	lw $t3, ($sp)		# Restore the original value of $t3 from the stack
	lw $t2, 4($sp)		# Restore the original value of $t2 from the stack
	lw $t1, 8($sp)		# Restore the original value of $t1 from the stack
	lw $t0, 12($sp)		# Restore the original value of $t0 from the stack
	lw $s7, 16($sp)		# Restore the original value of $s7 from the stack 
	lw $s6, 20($sp)		# Restore the original value of $s6 from the stack
	lw $s5, 24($sp)		# Restore the original value of $s5 from the stack
	lw $s4, 28($sp)		# Restore the original value of $s4 from the stack
	lw $s3, 32($sp)		# Restore the original value of $s3 from the stack
	lw $s2, 36($sp)		# Restore the original value of $s2 from the stack
	lw $s1, 40($sp)		# Restore the original value of $s1 from the stack
	lw $s0, 44($sp)		# Restore the original value of $s0 from the stack
	lw $ra, 48($sp)		# Restore the value of the return address ($ra) from the stack
	addiu $sp, $sp, 56	# Increment the stack pointer, taking itnto account the parameter pushed onto the stack
	
	jr $ra 		# Jump to the return address to exit the subroutine
	nop
	




xequalsy:			# Jumps to here if x and y are equal

	# Restores the original values of the s registers from the stack

	lw $s4, ($sp)		# Restore the original value of $s4 from the stack
	lw $s3, 4($sp)		# Restore the original value of $s3 from the stack
	lw $s2, 8($sp)		# Restore the original value of $s2 from the stack
	lw $s1, 12($sp)		# Restore the original value of $s1 from the stack
	lw $s0, 16($sp)		# Restore the original value of $s0 from the stack
	lw $ra, 20($sp)		# Restore the value of the return address ($ra) from the stack
	addiu $sp, $sp, 28	# Increment the stack pointer, taking itnto account the parameter pushed onto the stack

	jr $ra
	nop	
	
	
xiszero:			# Branches here if x equals zero

	sub $s6, $s1, $s3	# Set tempY to cy - y
	
	la $a0, ($s5)		# Load tempX into the $a0 register (cx - x)
	la $a1, ($s6)		# Load tempY into the $a1 register (cy - y)
	la $a2, ($s4)		# Load the colour into the $a2 register
	
	jal setpixel		# Enter the Subroutine "setpixel"
	nop

	beqz $s3, yiszero	# Branch if y is equal to zero
	nop

	add $s5, $s0, $s2	# Set tempX to cx + x
	
	la $a0, ($s5)		# Load tempX into the $a0 register (cx + x)
	la $a1, ($s6)		# Load tempY into the $a1 register (cy - y)
	la $a2, ($s4)		# Load the colour into the $a2 register
	
	jal setpixel		# Enter the Subroutine "setpixel"
	nop

yiszero:			# Branches here if y equals zero
	
	# Restores the original values of the s registers from the stack
	
	lw $s6, ($sp)		# Restore the original value of $s6 from the stack
	lw $s5, 4($sp)		# Restore the original value of $s5 from the stack
	lw $s4, 8($sp)		# Restore the original value of $s4 from the stack
	lw $s3, 12($sp)		# Restore the original value of $s3 from the stack
	lw $s2, 16($sp)		# Restore the original value of $s2 from the stack
	lw $s1, 20($sp)		# Restore the original value of $s1 from the stack
	lw $s0, 24($sp)		# Restore the original value of $s0 from the stack
	lw $ra, 28($sp)		# Restore the value of the return address ($ra) from the stack
	addiu $sp, $sp, 36	# Increment the stack pointer, taking itnto account the parameter pushed onto the stack


	jr $ra			# Jump to the return address to exit the subroutine
	nop	
	
save_bmp:
#description: 
#	saves bmp file stored in memory to a file
#arguments:
#	none
#return value: none
	sub $sp, $sp, 4		#push $ra to the stack
	sw $ra,4($sp)
	sub $sp, $sp, 4		#push $s1
	sw $s1, 4($sp)
#open file
	li $v0, 13
        la $a0, fname		#file name 
        li $a1, 1		#flags: 1-write file
        li $a2, 0		#mode: ignored
        syscall
	move $s1, $v0      # save the file descriptor
	


#save file
	li $v0, 15
	move $a0, $s1
	la $a1, bitmaparea
	li $a2, BMP_FILE_SIZE
	syscall

#close file
	li $v0, 16
	move $a0, $s1
        syscall
	
	lw $s1, 4($sp)		#restore (pop) $s1
	add $sp, $sp, 4
	lw $ra, 4($sp)		#restore (pop) $ra
	add $sp, $sp, 4
	jr $ra


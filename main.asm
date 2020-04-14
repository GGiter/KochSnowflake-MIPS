################################################################################
# Koch Snowflake using simplified L-System and Bresenham algorithm   	       #
# Topic 15								       #
# ARKO project								       #
# Author : Piotr Gêbuœ							       #
################################################################################	
		.data
		.align 4
buff:		.space 4 # buff
offset:		.space 4 # offset
size:		.space 4 # size
width:		.space 4 # width
file_size_buff:	.space 4 # file_size_buff
x1:	.space 4
y1:	.space 4
x2:	.space 4
y2:	.space 4
dy:	.space 4
last_x2:	.space 4
last_y2:	.space 4
last_x1:	.space 4
last_y1:	.space 4
value1:		.space 4 # temporal value
axis:	.space 4
wrongFile: .asciiz "Invalid input file."
fileNameIn:	.asciiz "in.bmp"
fileNameOut:	.asciiz "out.bmp"
input: .asciiz "+F+F--F+F+F+F--F+F--F+F--F+F+F+F--F+F--F+F--F+F+F+F--F+F--F+F--F+F+F+F--F+F--F+F--F+F+F+F--F+F--F+F--F+F+F+F--F+F" # L-system input string
		.text

main:
	la $a0, fileNameIn
	jal openFile
	
	# pass arguments for instruction loop
	li $t8, 0	# index for reading input string
	li $a0, 0	# start.x		
   	li $a1,	0	# start.y
	li $a2, 17	# end.x	
   	li $a3, 0	# end.y
   	sw $a0,last_x1
   	sw $a1,last_y1
	jal instruction_loop
	
	la $a0, fileNameOut	
	j saveFile
openFile:
	# open file 'in.bmp':
	move $s3, $a0 # move file name to s3
	li $a1, 0
	li $a2, 0
	li $v0, 13
	syscall	
	move $t1, $v0 		# move descriptor to $t1
	bltz $t1, fileError # if the file is invalid exit
	# read 'Header(BM)' bytes :
	move $a0, $t1
	la $a1, buff
	li $a2, 2
	li $v0, 14
	syscall
	# read 4 bytes that determine the size
	move $a0, $t1
	la $a1, size
	li $a2, 4
	li $v0, 14
	syscall
	lw $s0, size		# save size $s0
	# allocate memory of the file size :
	move $a0, $s0
	li $v0, 9
	syscall
	move $s1, $v0		
	sw $s1, file_size_buff
	# read 4 reserved bytes:
	move $a0, $t1		
	la $a1, buff
	li $a2, 4
	li $v0, 14
	syscall
	# read offset:
	move $a0, $t1
	la $a1, offset
	li $a2, 4
	li $v0, 14
	syscall
	# read size of data header :
	move $a0, $t1
	la $a1, buff
	li $a2, 4
	li $v0, 14
	syscall
	# read width:
	move $a0, $t1
	la $a1, width
	li $a2, 4
	li $v0, 14
	syscall
	lw $s2, width			
	# read height:
	move $a0, $t1
	la $a1, buff
	li $a2, 4
	li $v0, 14
	syscall
	# close the file
	move $a0, $t1
	li $v0, 16
	syscall
	# read pixel array
	move $a0, $s3
	la $a1, 0
	la $a2, 0
	li $v0, 13
	syscall
	move $t1, $v0
	move $a0, $t1
	la $a1, ($s1)
	la $a2, ($s0)		
	li $v0, 14
	syscall
	lw $s0, size
	move $a0, $t1		# close the file
	li $v0, 16
	syscall
	lw $s5, offset		# load offset to $s5
	li $t7, 0		# counter set to 0
	lw $s2, width
	add $s1, $s1, $s5	# go to the start of pixel array
	li $s6, 4
	div $s2, $s6		# set padding 
	mfhi $s6		# padding
	
	jr $ra
instruction_loop:
	# iterate through series
    	lb $t9, input($t8)
    	# save file if the input ended
   	beq $t9, 0, end_loop		
	beq $t9,'+',rotate_right
	beq $t9,'-',rotate_left
   	beq $t9,'F',forward
   	j case 
    	sb $t9, input($t8)
end_loop:
	jr $ra
rotate:	
	move $s3,$a2 # move x2 to stack
	sub $s3,$s3,$a0 # x2 - x1

	sra $s3,$s3,1 # x2*0.5
		
	move $s4,$a3 # move y2 to stack
	sub $s4,$s4,$a1 # y2 - y1
	
	sll $s4,$s4,3 
	sub $s4,$s4,$a3
	add $s4,$s4,$a1 # y*7
	div $s4,$s4,8 # y/8 no sra as the value might be negative
	
	mul $s4,$s4,$s7 # negate y2 if we are rotating left
	sub $s3,$s3,$s4 # x2*0.5 - y2*7/8

	add $s3, $s3,$a0 # y2 + y1
	move $v0,$s3 # resutl x2

	move $s3,$a2  # move x2 to stack
	sub $s3,$s3,$a0 # x2 - x1

	sll $s3,$s3,3 
	sub $s3,$s3,$a2
	add $s3,$s3,$a0 # x2*7	
	sra $s3,$s3,3  # x2/8 works here because we never get to negative in this case
	
	move $s4,$a3  # move y2 to stack
	sub $s4,$s4,$a1 # y2 - y1

	sra $s4,$s4,1 # y2*0.5
	
	mul $s3,$s3,$s7 # negate x2 if we are rotating left
	add $s3,$s3,$s4 # x2*7/8 + y2*0.5

	add $s3, $s3,$a1 # y2 + y1
	move $v1,$s3 # result y2
	
	# new end.x and end.y 	 
	move $a3,$v1
	move $a2,$v0
	
	jr $ra
# rotate by (60 degrees)	
rotate_right:
	li $s7,1
	sw $ra,4($sp)
	jal rotate
	lw $ra, 4($sp)
	j case
	
#rotate by (-60 degrees)
rotate_left:
	li $s7,-1
	sw $ra,4($sp)
	jal rotate
	lw $ra, 4($sp)
	j case
case:
	# increase index 
    	addi $t8, $t8, 1
	# return to loop
    	j instruction_loop 
# go forward 
forward:
	lw $v0, last_x1							
    	lw $v1, last_y1
    	 	
    	# move  vector (x2,y2) by (x1,y1)
	add $a2,$a2,$v0
    	add $a3,$a3,$v1
    	sub $a2,$a2,$a0
    	sub $a3,$a3,$a1
    	# x2 = x2 + last_x - x1
    	# y2 = y2 + last_y - y1
    	
    	lw $a0, last_x1							
    	lw $a1, last_y1
    	
    	sw $a2, last_x2
	sw $a3, last_y2
    
    	# shift points by vector [60,80] to center the snowflake
    	add $a0,$a0,60		
    	add $a1,$a1,80	
    	add $a2,$a2,60	
    	add $a3,$a3,80
    	
    	sw $ra,4($sp)
	jal drawLine
	lw $ra, 4($sp)
	
	# load last values	
	lw $a0, last_x1							
    	lw $a1, last_y1
	
	lw $a2, last_x2
	lw $a3, last_y2

	# now last end point is the new start point
    	sw $a2 , last_x1
    	sw $a3 , last_y1
    
	j case
# Bresenham algorithm
drawLine:
	# move arguments
	move $t0 , $a0 # x1
	move $t1 , $a1 # y1
	move $t2 , $a2 # x2
	move $t3 , $a3 # y2
	la $t4, ($t0)	# x1 -> t4, 
	la $t5, ($t1)	# y1 -> t5
	bge $t0, $t2, x1greater	# if x1 >= x2 go to x1greater
	li $t6, 1		# xi = 1
	sub $t7, $t2, $t0	# dx = x2 - x1 
	b next		
x1greater:
	li $t6, -1		# xi = -1
	sub $t7, $t0, $t2	# dx = x1 - x2 
next:
	bge $t1, $t3, y2greater	# if (y1<y2) go to y2greater
	li $s0, 1		# yi = 1
	sub $s7, $t3, $t1 	# dy = y2 - y1 
	b ox	
y2greater:
	li $s0, -1		# yi = -1
	sub $s7, $t1, $t3	# dy = y2 - y1
ox:	
	bge $s7, $t7, oy  # if (dy>=dx) go to oy
	# OX
	sub $s2, $s7, $t7	# ai = dy-dx
	sll $s2, $s2, 1		# ai = 2*ai
	sll $s3, $s7, 1		# bi = 2*dy
	sub $s4, $s3, $t7	# d = bi - dx
	li $v0 , 1
	sw $v0 , axis
axis_determiner:
	lw $a0,axis
	blez $a0, oyloop 
oxloop:
	beq $t2, $t4, end_draw_line # while(x!=x2)
	bltz $s4, increase_x		# if(d>=0), go lower
	add $t4, $t6, $t4	# x += xi
	add $t5, $s0, $t5	# y += yi
	add $s4, $s2, $s4	# d +=ai
	b reset
oy:
	# OY
	li $v0 , 0
	sw $v0,axis
	sub $s2, $t7, $s7	# ai = dx - dy
	sll $s2, $s2, 1		# ai = 2*ai
	sll $s3, $t7, 1		# bi = 2*dx
	sub $s4, $s3, $s7	# d = bi - dy
	b axis_determiner
increase_x:
	add $s4, $s3, $s4	# d += bi
	add $t4, $t6, $t4	# x += xi
	b reset
increase_y:
	add $s4, $s3, $s4	# d +=bi
	add $t5, $t5, $s0	# y += yi
reset:
	# reset the values
	sw $t0, x1		
	sw $t1, y1
	sw $t2, x2
	sw $t3, y2
	sw $s7, dy
coloring:			
	lw $s5, width		# width
	move $t1, $t4		# x
	move $t2, $t5		# y
	li $t3, 0		# counter
	subi $t1, $t1, 1	# x--
	blez $t1, xpositive		
xnegative:
	addi $t3, $t3, 3	# counter +3
	subi $t1, $t1, 1	# x-- 
	bgtz $t1, xnegative	# do while x <= 0
xpositive:
	li $t0, 0		# counter
	subi $t2, $t2, 1	# y--
	blez $t2, xpositive	
ynegative:
	add $t0, $t0, $s5	# 3*width  y-1 times
	add $t0, $t0, $s5
	add $t0, $t0, $s5
	add $t0, $t0, $s6	# s6 -> padding, 
	subi $t2, $t2, 1	# y--
	bgtz $t2, ynegative
ypositive:
	add $t3, $t3, $t0	
	add $s1, $s1, $t3	# first bit of pixel x,y
	li $s7, 0		# color value ( black )
	sb $s7, ($s1)
	addi $s1, $s1, 1	# BGR coloring
	sb $s7, ($s1)
	addi $s1, $s1, 1
	sb $s7, ($s1)
	subi $s1, $s1, 2	# black coloring
	sub $s1, $s1, $t3	# reset
	# reset the values
	lw $t0, x1
	lw $t1, y1
	lw $t2, x2
	lw $t3, y2
	lw $s7, dy
	b axis_determiner
oyloop:
	beq $t3, $t5, end_draw_line	# while(y!=y2)
	bltz $s4, increase_y		# if(d>=0), go up
	add $t4, $t6, $t4	# x += xi
	add $t5, $s0, $t5	# y += yi
	add $s4, $s2, $s4	# d +=ai
	b reset
end_draw_line:
	jr $ra
fileError:		# error messege to display when in.bmp is invalid
	li $v0, 4
	la $a0, wrongFile 
	syscall # print error message
	b end
saveFile:
	# open "out.bmp"
	li $a1, 1
	li $a2, 0
	li $v0, 13
	syscall		
	move $t0, $v0
	bltz $t0, fileError # if .bmp is invalid
	lw $s0, size
	lw $s1, file_size_buff
	move $a0, $t0
	la $a1, ($s1)	# buffer to save
	la $a2, ($s0)	# number of symbols
	li $v0, 15
	syscall		# save
	move $a0, $t0
	li $v0, 16
	syscall		# close the file
end:
	# close program:
	li $v0, 10
	syscall

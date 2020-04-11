		.data
		.align 4
buff:		.space 4
offset:		.space 4
size:		.space 4
width:		.space 4
begging:	.space 4
value1:	.space 4
value2:	.space 4
value3:	.space 4
value4:	.space 4
value5:	.space 4
value6:	.space 4
value7:	.space 4
last_x2:	.space 4
last_y2:	.space 4
last_x1:	.space 4
last_y1:	.space 4
axis:	.space 4
wrongFile: .asciiz "Invalid input file."
fileNameIn:	.asciiz "in.bmp"
fileNameOut:	.asciiz "out.bmp"
input: .asciiz "+F+F--F+F+F+F--F+F--F+F--F+F+F+F--F+F--F+F--F+F+F+F--F+F--F+F--F+F+F+F--F+F--F+F--F+F+F+F--F+F--F+F--F+F+F+F--F+F"
buf:		.space 4
		.text
		.globl main

main:
	# open file 'in.bmp':
	la $a0, fileNameIn
	li $a1, 0
	li $a2, 0
	li $v0, 13
	syscall	
	move $t1, $v0 		# move descriptor to $t1
	bltz $t1, fileExc # if the file is invalid exit
	# read 'BM' bytes :
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
	sw $s1, begging
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
	# read information header :
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
	la $a0, fileNameIn
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
	li $t7, 0		#  counter set to 0
	lw $s2, width
	add $s1, $s1, $s5	# go to the start of pixel array
	li $s6, 4
	div $s2, $s6		# set padding 
	mfhi $s6		# padding
	
	
	li $t8, 0	# index for reading input string
	li $a0, 0	# start.x		
   	li $a1,	0	# start.y
	li $a2, 17	# end.x	
   	li $a3, 0	# end.y
   	li $k0, 0	# last start.x
   	li $k1, 0	# last start.y
   	sw $a0,last_x1
   	sw $a1,last_y1

	jal inst_loop
	
inst_loop:
	# iterate through series
    	lb $t9, input($t8)
    	# save file if the input ended
   	beq $t9, 0, saveFile		
	beq $t9,'+',rotate_right
	beq $t9,'-',rotate_left
   	beq $t9,'F',forward
   	jal case 
    	sb $t9, input($t8)	
rotate_right:
	# save values as there are too many variables
	sw $s0, value6
	sw $s1, value7
	
	move $s0,$a2 # move x2 to stack
	sub $s0,$s0,$a0 # x2 - x1

	div $s0,$s0,2  # x*cos
		
	move $s1,$a3 # move y2 to stack
	sub $s1,$s1,$a1 # y2 - y1
	
	mul $s1,$s1,7 # y*7
	div $s1,$s1,8 # y/8
		
	sub $s0,$s0,$s1 # x*cos - y*sin

	add $s0, $s0,$a0 # y2 + y1
	move $v0,$s0 # resutl x2

	move $s0,$a2  # move x2 to stack
	sub $s0,$s0,$a0 # x2 - x1

	mul $s0,$s0,7	#x*7	
	div $s0,$s0,8 # x/8
	
	move $s1,$a3  # move y2 to stack
	sub $s1,$s1,$a1 # y2 - y1

	div $s1,$s1,2 #y*cos
	
	add $s0,$s0,$s1 # x*cos + y*sin

	add $s0, $s0,$a1 # y2 + y1
	move $v1,$s0 # result y2
	
	# new end.x and end.y 	 
	move $a3,$v1
	move $a2,$v0

	# load saved values
	lw $s0, value6
	lw $s1, value7
	
	jal case
rotate_left:
	# save values as there are too many variables
	sw $s0, value6
	sw $s1, value7

	move $s0,$a2 # move x2 to stack
	sub $s0,$s0,$a0 # x2 - x1
	
	div $s0,$s0,2  # x*cos
	
	move $s1,$a3 # move y2 to stack
	sub $s1,$s1,$a1 # y2 - y1
	
	mul $s1,$s1,7 # y*7
	div $s1,$s1,8 # y/8
		
	add $s0,$s0,$s1 # x*cos + y*sin

	add $s0, $s0,$a0 # x2 + x1

	move $v0,$s0 # resutl x2
	
	move $s0,$a2  # move x2 to stack
	sub $s0,$s0,$a0 # x2 - x1
		
	mul $s0,$s0,7	#x*7	
	div $s0,$s0,8 # x/8
	
	move $s1,$a3  # move y2 to stack
	sub $s1,$s1,$a1 # y2 - y1

	div $s1,$s1,2 #y*cos
	
	sub $s0,$s1,$s0 # y*cos - x*sin

	add $s0, $s0,$a1 # y2 + y1
	move $v1,$s0 # result y2
	
	# new end.x and end.y 	 
	move $a3,$v1
	move $a2,$v0

	# load saved values
	lw $s0, value6
	lw $s1, value7
	
	jal case
case:
#increase index 
    addi $t8, $t8, 1
#return to loop
    jal inst_loop 

forward:
	lw $v0, last_x1							
    	lw $v1, last_y1
    		
	add $a2,$a2,$v0
    	add $a3,$a3,$v1
    	sub $a2,$a2,$a0
    	sub $a3,$a3,$a1
    	# x2 = x2 + last_x - x1
    	# y2 = y2 + last_y - y1
    	
    	lw $a0, last_x1							
    	lw $a1, last_y1
    	
	move $v0, $a2							
    	move $v1, $a3
    	
    	sw $a2, last_x2
	sw $a3, last_y2
    
    	# shift points by vector [80,80]
    	add $a0,$a0,80		
    	add $a1,$a1,80	
    	add $a2,$a2,80	
    	add $a3,$a3,80
    	
	jal drawLine
end_forward:	
	lw $a0, last_x1							
    	lw $a1, last_y1
	
	lw $a2, last_x2
	lw $a3, last_y2

    	sw $a2 , last_x1
    	sw $a3 , last_y1
    
	j case
# Bresenham algorithm
drawLine:
	move $t0 , $a0 #x1
	move $t1 , $a1 #y1
	move $t2 , $a2 #x2
	move $t3 , $a3 #y2
	la $t4, ($t0)	
	la $t5, ($t1)	# x -> t4, y,-> t5
	bge $t0, $t2, x1greater		# if x1 >= x2 go to else
	li $t6, 1		#xi = 1
	sub $t7, $t2, $t0	#dx = x2 - x1 , calculate offset
	b next		
x1greater:
	li $t6, -1		#xi = -1
	sub $t7, $t0, $t2	#dx = x1 - x2 , calculate offset
next:
	bge $t1, $t3, y2greater	#if (y1<y2) go to else2
	li $s0, 1		#yi = 1
	sub $s7, $t3, $t1 	#dy = y2 - y1 , calculate offse
	b next3	
y2greater:
	li $s0, -1		#yi = -1
	sub $s7, $t1, $t3	#dy = y2 - y1
	b next3
next3:	
	bge $s7, $t7, else3
	li $a0 , 1
	sw $a0,axis
	# dy < dx, OX
	sub $s2, $s7, $t7	#ai = dy-dx
	sll $s2, $s2, 1		#ai = 2*ai
	sll $s3, $s7, 1		#bi = 2*dy
	sub $s4, $s3, $t7	#d = bi - dx
	b axis_determiner
axis_determiner:
	lw $a0,axis
	blez $a0, loop2
	b loop
loop:
	beq $t2, $t4, back 	# while(x!=x2)
	bltz $s4, else4		# if(d>=0), go lower
	add $t4, $t6, $t4	# x += xi
	add $t5, $s0, $t5	# y += yi
	add $s4, $s2, $s4	# d +=ai
	b next4
else4:
	add $s4, $s3, $s4	#d += bi
	add $t4, $t6, $t4	#x += xi
next4:
	# reset the values
	sw $t0, value1		
	sw $t1, value2
	sw $t2, value3
	sw $t3, value4
	sw $s7, value5
coloring:			
	lw $s5, width		#witdth
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
	add $t3, $t3, $t0	# suma dwoch powyzszych wyrazen
	add $s1, $s1, $t3	# pierwszy bit piksela x,y
	li $s7, 0		# color value ( black )
	sb $s7, ($s1)
	addi $s1, $s1, 1	# BGR coloring
	sb $s7, ($s1)
	addi $s1, $s1, 1
	sb $s7, ($s1)
	subi $s1, $s1, 2	# black coloring
	sub $s1, $s1, $t3	# reset
	# reset the values
	lw $t0, value1
	lw $t1, value2
	lw $t2, value3
	lw $t3, value4
	lw $s7, value5
	b axis_determiner
else3:
	# OY
	li $a0 , 0
	sw $a0,axis
	sub $s2, $t7, $s7	# ai = dx - dy
	sll $s2, $s2, 1		# ai = 2*ai
	sll $s3, $t7, 1		# bi = 2*dx
	sub $s4, $s3, $s7	# d = bi - dy
	b axis_determiner
loop2:
	beq $t3, $t5, back	# while(y!=y2)
	bltz $s4, else5		# if(d>=0), go up
	add $t4, $t6, $t4	# x += xi
	add $t5, $s0, $t5	# y += yi
	add $s4, $s2, $s4	# d +=ai
	b next4
else5:
	add $s4, $s3, $s4	# d +=bi
	add $t5, $t5, $s0	# y += yi
	b next4
fileExc:		# error messege to display when in.bmp is invalid
	li $v0, 4
	la $a0, wrongFile 
	syscall # print error message
	b end
back:
	j end_forward
saveFile:
	# open "out.bmp"
	la $a0, fileNameOut
	li $a1, 1
	li $a2, 0
	li $v0, 13
	syscall		
	move $t0, $v0
	bltz $t0, fileExc
	lw $s0, size
	lw $s1, begging
	move $a0, $t0
	la $a1, ($s1)	# buffer to save
	la $a2, ($s0)	# number of symbols
	li $v0, 15
	syscall		# save
	move $a0, $t0
	li $v0, 16
	syscall		# close the file
end:
	#close program:
	li $v0, 10
	syscall

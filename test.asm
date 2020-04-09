		.data
		.align 4
buff:		.space 4
offset:		.space 4
size:		.space 4
width:		.space 4
poczatek:	.space 4
value1:	.space 4
value2:	.space 4
value3:	.space 4
value4:	.space 4
value5:	.space 4
value6:	.space 4
value7:	.space 4
value8:	.space 4
value9:	.space 4
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
	sw $s1, poczatek
	# odczytanie 4 bajtow zarezerwowanych:
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
	div $s2, $s6		#set padding 
	mfhi $s6		# padding
	
	
	li $t8, 0	# index for reading input string
	li $a0, 0	# start.x		
   	li $a1,	0	# start.y
	li $a2, 20	# end.x	
   	li $a3, 0	# end.y
   	li $k0, 0	# last start.x
   	li $k1, 0	# last start.y

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
	add $a2,$a2,$k0
    	add $a3,$a3,$k1
    	sub $a2,$a2,$a0
    	sub $a3,$a3,$a1
    	move $a0, $k0							
    	move $a1, $k1
    	
	move $v0, $a2							
    	move $v1, $a3
    	
    	sw $v0, value8
	sw $v1, value9
    
    	# shift points by vector [100,100]
    	add $a0,$a0,100		
    	add $a1,$a1,100	
    	add $a2,$a2,100	
    	add $a3,$a3,100
    	
	jal drawLine
end_forward:	
	move $a0, $k0
	move $a1, $k1
	
	lw $a2, value8
	lw $a3, value9

    	move $k0, $a2
    	move $k1, $a3
    
	j case
# Bresenham algorithm
drawLine:
	move $t0 , $a0 #x1
	move $t1 , $a1 #y1
	move $t2 , $a2 #x2
	move $t3 , $a3 #y2
	la $t4, ($t0)	# zmienne x i y na ktorych bedziemy operowac
	la $t5, ($t1)	# tu x to t4, y, to t5
	bge $t0, $t2, else		# jak wieksze lub rowne t0(x1) od t2(x2), to else
	li $t6, 1		#xi = 1
	sub $t7, $t2, $t0	#dx = x2 - x1
	b next		# tu xi to t6 , dx to t7
else:
	li $t6, -1		#xi = -1
	sub $t7, $t0, $t2	#dx = x1 - x2
next:
	bge $t1, $t3, else2	#if(y1<y2)
	li $s0, 1		#yi = 1
	sub $s7, $t3, $t1 	#dy = y2 - y1
	b next2	# tu yi, to s0, a dy to s7
else2:
	li $s0, -1		#yi = -1
	sub $s7, $t1, $t3	#dy = y2 - y1
next2:	#algorytm korzysta z 13 zmiennych, konieczny zapis
	sw $t0, value1	#x1
	sw $t1, value2	#y1
	sw $t2, value3	#x2
	sw $t3, value4	#y2
	sw $s7, value5	#dy
kolorowanie:			# obliczamy (y-1)*(3*szerokosc+padding)+3*(x-1)
	lw $s5, width		#szerokosc
	move $t1, $t4		#x
	move $t2, $t5		#y
	li $t3, 0		#licznik do wyliczania piksela
	subi $t1, $t1, 1	#x--
	blez $t1, paf		#if(x>0) , to wchodzimy w puf
puf:
	addi $t3, $t3, 3	#+3
	subi $t1, $t1, 1	#x-- w petli
	bgtz $t1, puf		#petla az t1(x) <= 0
paf:
	li $t0, 0		#licznik
	subi $t2, $t2, 1	#y--
	blez $t2, pok		#jak t2(y) <= 0 , to omijamy pam
pam:
	add $t0, $t0, $s5	#dodajemy potrojna szerokosc tyle razy ile y-1
	add $t0, $t0, $s5
	add $t0, $t0, $s5
	add $t0, $t0, $s6		## s6 to padding, 
	subi $t2, $t2, 1	#y--
	bgtz $t2, pam
pok:
	add $t3, $t3, $t0	#suma dwoch powyzszych wyrazen
	add $s1, $s1, $t3		#pierwszy bit piksela x,y
	li $s7, 0		# value do kolorowania, 0 0 0 to czarny
	sb $s7, ($s1)
	addi $s1, $s1, 1	#kolorowaine BGR W pikselu
	sb $s7, ($s1)
	addi $s1, $s1, 1
	sb $s7, ($s1)
	subi $s1, $s1, 2			## kolorowanie na czarno
	sub $s1, $s1, $t3	# powrot do poczatku skad zaczynalismy
	lw $t0, value1
	lw $t1, value2
	lw $t2, value3
	lw $t3, value4
	lw $s7, value5
# to wyzej to rysowanie plamki o wspolrzednych t4, t5
next3:	
	bge $s7, $t7, else3
	#tu jestesmy jak s7 < t7, czyli dy < dx, czyli os wiodaca, to OX
	sub $s2, $s7, $t7	#ai = dy-dx
	sll $s2, $s2, 1		#ai = 2*ai
	sll $s3, $s7, 1		#bi = 2*dy
	sub $s4, $s3, $t7	#d = bi - dx
loop:
	beq $t2, $t4, back 	#while(x!=x2)
	bltz $s4, else4		#if(d>=0), to wchodzimy nizej
	add $t4, $t6, $t4	#x += xi
	add $t5, $s0, $t5	#y += yi
	add $s4, $s2, $s4	#d +=ai
	b next4
else4:
	add $s4, $s3, $s4	#d += bi
	add $t4, $t6, $t4	#x += xi
next4:
	sw $t0, value1	#algorytm korzysta z 13 zmiennych, konieczny zapis	
	sw $t1, value2
	sw $t2, value3
	sw $t3, value4
	sw $s7, value5
kolorowanie2:			#analogiczne do wyzej (kolorowanie)
	lw $s5, width		#szerokosc
	move $t1, $t4		#x
	move $t2, $t5		#y
	li $t3, 0		#licznik do wyliczania piksela
	subi $t1, $t1, 1	#x--
	blez $t1, paf2		#if(x>0) , to wchodzimy w puf2
puf2:
	addi $t3, $t3, 3	#+3
	subi $t1, $t1, 1	#x-- w petli
	bgtz $t1, puf2		#petla az t1(x) <= 0
paf2:
	li $t0, 0		#licznik
	subi $t2, $t2, 1	#y--
	blez $t2, pok2		#jak t2(y) <= 0 , to omijamy pam2
pam2:
	add $t0, $t0, $s5	#dodajemy potrojna szerokosc tyle razy ile y-1
	add $t0, $t0, $s5
	add $t0, $t0, $s5
	add $t0, $t0, $s6		## s6 to padding, 
	subi $t2, $t2, 1	#y--
	bgtz $t2, pam2
pok2:
	add $t3, $t3, $t0	#suma dwoch powyzszych wyrazen
	add $s1, $s1, $t3		#pierwszy bit piksela x,y
	li $s7, 0		# value do kolorowania, 0 0 0 to czarny
	sb $s7, ($s1)
	addi $s1, $s1, 1	#kolorowaine BGR W pikselu
	sb $s7, ($s1)
	addi $s1, $s1, 1
	sb $s7, ($s1)
	subi $s1, $s1, 2			## kolorowanie na czarno
	sub $s1, $s1, $t3	# powrot do poczatku skad zaczynalismy
	lw $t0, value1
	lw $t1, value2
	lw $t2, value3
	lw $t3, value4
	lw $s7, value5
	# to wyzej to rysowanie plamki o wspolrzednych t4, t5
	b loop
else3:
	# tu jestesmy jak os wiodaca, to OY
	sub $s2, $t7, $s7	#ai = dx - dy
	sll $s2, $s2, 1		#ai = 2*ai
	sll $s3, $t7, 1		#bi = 2*dx
	sub $s4, $s3, $s7	#d = bi - dy
loop2:
	beq $t3, $t5, back	#while(y!=y2)
	bltz $s4, else5		#if(d>=0), to wchodzi
	add $t4, $t6, $t4	#x += xi
	add $t5, $s0, $t5	#y += yi
	add $s4, $s2, $s4	#d +=ai
	b next5
else5:
	add $s4, $s3, $s4	#d +=bi
	add $t5, $t5, $s0	#y += yi
next5:		
	sw $t0, value1
	sw $t1, value2
	sw $t2, value3
	sw $t3, value4
	sw $s6, value5
kolorowanie3:			# opis wyzej, analogicznie do kolorowanie
	lw $s5, width		#szerokosc
	move $t1, $t4		#x
	move $t2, $t5		#y
	li $t3, 0		#licznik do wyliczania piksela
	subi $t1, $t1, 1	#x--
	blez $t1, paf3		#if(x>0) , to wchodzimy w puf3
puf3:
	addi $t3, $t3, 3	#+3
	subi $t1, $t1, 1	#x-- w petli
	bgtz $t1, puf3		#petla az t1(x) <= 0
paf3:
	li $t0, 0		#licznik
	subi $t2, $t2, 1	#y--
	blez $t2, pok3		#jak t2(y) <= 0 , to omijamy pam
pam3:
	add $t0, $t0, $s5	#dodajemy potrojna szerokosc tyle razy ile y-1
	add $t0, $t0, $s5
	add $t0, $t0, $s5
	add $t0, $t0, $s6		## s6 to padding, 
	subi $t2, $t2, 1	#y--
	bgtz $t2, pam3
pok3:
	add $t3, $t3, $t0	#suma dwoch powyzszych wyrazen
	add $s1, $s1, $t3		#pierwszy bit piksela x,y
	li $s7, 0		# value do kolorowania, 0 0 0 to czarny
	sb $s7, ($s1)
	addi $s1, $s1, 1	#kolorowaine BGR W pikselu
	sb $s7, ($s1)
	addi $s1, $s1, 1
	sb $s7, ($s1)
	subi $s1, $s1, 2			## kolorowanie na czarno
	sub $s1, $s1, $t3	# powrot do poczatku skad zaczynalismy
	lw $t0, value1
	lw $t1, value2
	lw $t2, value3
	lw $t3, value4
	lw $s7, value5
# to wyzej to rysowanie plamki o wspolrzednych t4, t5	
	b loop2	
fileExc:		# ewentualny blad do wyswietlenia w przypadku braku lub blednego pliku in.bmp
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
	lw $s1, poczatek
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

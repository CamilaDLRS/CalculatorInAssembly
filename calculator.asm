.data
	enunciadoEntrada: 	.asciiz "Bem vindo a calculadora \nPara: \n soma: + \n subtração: - \n multiplicação: *\n divisão: /\n primo: p\n fatorial f\n"
	enunciadoResposta:	.asciiz "Resposta: "
	respostaResto:		.asciiz "\nResto: "
	erroEntrada:		.asciiz "Entrada inválida."
	teste:			.asciiz "Primo\n"
	pulaLinha:		.asciiz "\n"
.text

.globl main

main:
	li $v0, 4
	la $a0, enunciadoEntrada
	syscall
	
	li $v0, 5
	syscall
	move $t0, $v0				#guarda o numero digitado em $t0
	
	li $v0, 12
	syscall
	move $s0, $v0				#guarda o caracter digitado em #s0
	
	li $v0, 4					#pula uma linha pois o syscall = 12, le o caracter e executa direto,
	la $a0, pulaLinha			#nao deixando o usuario pular linha
	syscall

	move $a0, $t0				#guardar o numero digita em $a0
	
	beq $s0, 112, casoPrimo		# se o caracter digitado for igual a 'p', chama a função primo
	beq $s0, 102, casoFatorial	# se o caracter digitado for igual a 'f', chama a função fatorial
	j else

casoPrimo:		
	ble $a0, 0, default
	jal primo
	j resposta

casoFatorial:	
	bltz $a0, default
	jal fatorial
	j resposta

else:							#caso a opção difere de primo e fatorial, leia mais um numero
	li $v0, 5
	syscall
	move $a1, $v0				#armazena o segundo numero digitado em $a1
	
	beq $s0, 43, casoSoma
	beq $s0, 45, casoSubtracao
	beq $s0, 42, casoMultiplicacao
	beq $s0, 47, casoDivisao
	j default

casoSoma:
	jal soma
	j resposta

casoSubtracao:
	jal subtracao
	j resposta

casoMultiplicacao:
	jal multiplicacao
	j resposta

casoDivisao:
	jal divisao

resposta:
	move $t0, $v0				# $t0 recebe a resposta
	 		
	li $v0, 4
	la $a0, enunciadoResposta
	syscall
	li $v0, 1
	move $a0, $t0
	syscall
	
	bne $s0, 47, naoEhDivisao	#se a opção escolhida foi a divisão, mostra o resto
	li $v0, 4
	la $a0, respostaResto
	syscall
	li $v0, 1
	move $a0, $v1
	syscall
	
naoEhDivisao:	
	j finalizacao	
	
default:	
	li $v0, 4
	la $a0, erroEntrada
	syscall
	j finalizacao

	###FUNCIONALIDADES####

soma:
	add $v0, $a0, $a1
	jr $ra

subtracao:
	sub $v0, $a0, $a1
	jr $ra

multiplicacao:
	mult $a0, $a1
	mflo $v0
	jr $ra
	
divisao:
	div $a0, $a1
	mflo $v0
	mfhi $v1
	jr $ra
	
primo:
	## PROLOGO ##
	addiu $sp, $sp, -24			# Abre espaco na pilha
	sw $ra, 16($sp)				# Salva o endereco de retorno na pilha
	sw $a0, 0($sp)				# salva o valor do primeiro parametro na pilha
	## PROLOGO ##

	bne $a0, 1, testedois		# Se x != 1 goto testeprimo
		add $t0, $0, $0			# devolve 0
		j epilogop				# va para o epilogo da funcao
		
testedois:
	bne $a0, 2, testepar		# se nao for 2
		addi $t0, $0, 1			# se for 2, devolve 1 (eh primo)
		j epilogop				# va para o epilogo da funcao
		
testepar:
	addiu $a1, $0, 2			# Coloca o 2 no segundo parametro da divisao
	jal  divisao				# x / 2
	lw $a0, 0($sp)				# Recupera da pilha o valor de $a0 anterior
	bne $v1, $0, testesete		# Se o resto nao for zero va para o continuep
		add $t0, $0, $0			# Devolve 0, pois pares nao sao primos, alem do 2
		j epilogop 				# va para o epilogo da funcao primo
	
testesete:
	bgt $a0, 7, preloop			# Se $a0 é maior que 7, go to preloop
		addi $t0, $0, 1			# devolve 1, pois todos os numeros ate 7 sao primos, exceto primos
		j epilogop				# va para o epilogo da funcao primo

preloop:
	addiu $a1, $0, 3			# o divisor comeca em 3, e vai subindo de dois em dois	
primoloop:
	sw $a1, 4($sp)				# salvando o $a1, pois eh resposabilidade do caller
	jal divisao					# va para a funcao de divisao
	lw $a0, 0($sp)				# recupera valor de $a0
	lw $a1, 4($sp)				# recupera o valor de $a1
	
	bne $v1, $0, incrementa		# x % divisor != 0 - se o resto da divisao nao for zero va para o incrementa
		add $t0, $0, $0			# x % divisor == 0 - se o resto da divisao for zero nao eh primo, $t0 recebe 0
		j epilogop				# va para o epilogo
incrementa:	
	addiu $a1, $a1, 2			# incrementa o divisor, pois nao achou divisor
	blt $a1, $a0, primoloop		# se divisor < x va para o loop	
	addiu $t0, $0, 1			# entao o numero eh primo
	j epilogop					# va para o epilogo
			
errop:
	addi $t0, $0, -1			# Se x < 0, a funcao retorna -1, pois nao existe primo de numero negativo
	j epilogop					# Va para o epilogo do fatorial	

epilogop:
	## EPILOGO ##
	add $v0, $t0, $0			# Registrador de retorno recebe $t0
	lw $ra, 16($sp)				# Recupera o endereço de retorno da pilha
	addiu $sp, $sp, 24			# Remove o espaco da pilha
	jr $ra						# Volta pro endereço anterior
	## EPILOGO ##

	
	
	
fatorial:
	## PROLOGO ##
	addiu $sp, $sp, -24			# Abre espaco na pilha
	sw $ra, 16($sp)				# Salva o endereCo de retorno na pilha
	## PROLOGO ##

	bne $a0, $0, testaf			# Se $a0 nao for 0, va para testa2
		addi $t0, $0, 1			# $t0 = 0 + 1
		j epilogof				# Pula para o epilogo
		
testaf:	
	bge $a0, 2, continuef 		# Se $a0 > 2, va para continue # COMENTAR MAIS1!!!!
		add $t0, $a0, $0		# Se nao, adicione o valor de $a0 no temporario de retorno (pode ser 1 ou 2)
		j epilogof				# Va para o epilogo
	
continuef:
	sw $a0, 0($sp) 		 		# Salva o $a0 na pilha
	addi $a0, $a0, -1			# $a0 = $a0 -1
	jal fatorial				# fatorial(x-1), linkou o $ra novamente
	lw $a0, 0($sp)				# Recupera o valor de $a0 da pilha
	add $a1, $v0, $0			# $a1 = $v0 
	jal multiplicacao			# Chama a funcao de multiplicacao que a gente criou para multiplicar
	move $t0, $v0				# $t0 recebe a resposta da multiplicacao
	j epilogof					# va para o epilogo da funcao	

errof:
	addi $t0, $0, -1			# Se x < 0, a funcao retorna -1, pois nao existe fatorial de numero negativo
	j epilogof					# Va para o epilogo do fatorial

epilogof:
	## EPILOGO ##
	add $v0, $t0, $0			# Registrador de retorno recebe $t0
	lw $ra, 16($sp)				# Recupera o endereço de retorno da pilha
	addiu $sp, $sp, 24			# Remove o espaco da pilha
	jr $ra						# Volta pro endereço anterior
	## EPILOGO ##
	
	
	###ENCERA###
finalizacao:
	li $v0, 10
	syscall

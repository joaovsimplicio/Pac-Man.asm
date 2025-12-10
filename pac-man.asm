; --- Jogo PAC-MAN ---
;Desenvolido por:
;    João Vitor Valerio Simplicio
jmp main

; --- Variaveis Globais ---
posPac: var #1        
posAntPac: var #1     
dirPac: var #1        
inputKey: var #1      
delayTime: var #1
randSeed:  var #1 
dotsLeft:  var #1     

; --- Variaveis dos 6 Fantasmas ---
posGhost1: var #1
dirGhost1: var #1
posGhost2: var #1
dirGhost2: var #1
posGhost3: var #1
dirGhost3: var #1
posGhost4: var #1
dirGhost4: var #1
posGhost5: var #1
dirGhost5: var #1
posGhost6: var #1
dirGhost6: var #1

; --- Codigo Principal ---
main:
    ; 1. Tela Inicial
    call TelaInicial_WaitEnter
    
    ; 2. Prepara o Mapa
    call ConverteMapaParaAzul
    
    ; 3. Espalha os 10 Pontos
    call EspalhaPontosPeloMapa

    ; 4. Desenha o mapa
    call DesenhaMapaPrincipal
    
    ; 5. Configura Pacman
    loadn R0, #619      
    store posPac, R0
    store posAntPac, R0
    loadn R0, #0
    store dirPac, R0    
    
    ; 6. Configura Fantasmas
    loadn R0, #42       
    store posGhost1, R0
    loadn R0, #76       
    store posGhost2, R0
    loadn R0, #842      
    store posGhost3, R0
    loadn R0, #876      
    store posGhost4, R0
    loadn R0, #490      
    store posGhost5, R0
    loadn R0, #509      
    store posGhost6, R0

    ; 7. Direcoes Iniciais
    loadn R0, #2 
    store dirGhost1, R0
    loadn R0, #4 
    store dirGhost2, R0
    loadn R0, #1 
    store dirGhost3, R0
    loadn R0, #3 
    store dirGhost4, R0
    loadn R0, #3 
    store dirGhost5, R0
    loadn R0, #3 
    store dirGhost6, R0
    
    ; Velocidade
    loadn R0, #400      
    store delayTime, R0

    ; Desenha Iniciais
    load R2, posPac
    call printPacman 
    call DesenhaTodosFantasmas

Loop:
    load R0, delayTime
    call Delay_Reg
    
    
    load R0, randSeed
    inc R0
    store randSeed, R0

    call LerInput
    call MovePacman
    
    ; Verifica Fim de Jogo
    call Check_Game_Over
    call Check_Win_Condition

    call MoveFantasmas 
    call Check_Game_Over
    
    jmp Loop

; --- TELA INICIAL ---
TelaInicial_WaitEnter:
    call ApagaTela
    
    ; Escreve "PAC-MAN"
    loadn R1, #2816 ; Amarelo
    loadn R0, #456  ; Posicao
    
    loadn R2, #'P'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'A'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'C'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'-'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'M'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'A'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'N'
    add R2, R2, R1
    outchar R2, R0

    ; Escreve "APERTE ENTER"
    loadn R1, #2816 
    loadn R0, #613  
    call Escreve_AperteEnter

    ; Loop Espera + Gera Seed
    loadn R2, #50
Wait_Start_Loop:
    inc R2
    store randSeed, R2 
    
    inchar R0
    loadn R1, #13 ; Enter
    cmp R0, R1
    jeq Sai_Tela_Start
    
    jmp Wait_Start_Loop

Sai_Tela_Start:
    call ApagaTela
    rts

; --- ROTINA DE LIMPEZA E PREPARO DO MAPA ---
ConverteMapaParaAzul:
    push R0
    push R1
    push R2
    push R3
    push R4
    
    loadn R0, #Fundo    
    loadn R1, #1200     
    loadn R2, #0        
    
Converte_Loop:
    loadi R4, R0        
    
    ; 1. Se for chao original (3967), vira espaco
    loadn R3, #3967
    cmp R4, R3          
    jeq Vira_Espaco
    
    ; 2. Se ja for espaco (32), mantem
    loadn R3, #' '
    cmp R4, R3
    jeq Prox_Conversao

    ; 3. Se for PONTO ('.') de partida velha, vira espaco
    loadn R3, #'.'
    cmp R4, R3
    jeq Vira_Espaco

    ; 4. Se ja for parede azul (3107), mantem
    loadn R3, #3107
    cmp R4, R3
    jeq Prox_Conversao
    
    ; 5. Senao, eh parede original -> Pinta de Azul
    loadn R4, #3107      
    storei R0, R4       
    jmp Prox_Conversao

Vira_Espaco:
    loadn R4, #' '      
    storei R0, R4       

Prox_Conversao:
    inc R0
    inc R2
    cmp R2, R1
    jne Converte_Loop
    
    pop R4
    pop R3
    pop R2
    pop R1
    pop R0
    rts

; --- ESPALHAR PONTOS ---
EspalhaPontosPeloMapa:
    push R0
    push R1
    push R2
    push R3
    push R4
    push R5
    
    loadn R1, #10 ; Total de Pontos
    store dotsLeft, R1
    
    loadn R2, #0  ; Contador

Loop_Espalha:
    call GeraRandomMapPos ; Retorna posicao em R0
    
    ; Verifica se eh espaco
    loadn R3, #Fundo
    add R3, R3, R0
    loadi R4, R3
    
    loadn R5, #' '
    cmp R4, R5
    jne Loop_Espalha 
    
    ; Nao pode nascer no Pacman
    loadn R5, #619
    cmp R0, R5
    jeq Loop_Espalha

    ; Coloca o PONTO
    loadn R4, #'.'
    storei R3, R4
    
    inc R2
    cmp R2, R1
    jne Loop_Espalha
    
    pop R5
    pop R4
    pop R3
    pop R2
    pop R1
    pop R0
    rts

; --- MOVIMENTO PACMAN ---
MovePacman:
    push R0
    push R1
    push R2
    push R3
    push R4
    push R5
    
    load R0, posPac
    load R1, dirPac
    
    loadn R2, #0
    cmp R1, R2
    jeq Move_Sai
    
    call Calc_Pos_Generica ; R2 = NextPos

    ; Verifica destino
    loadn R3, #Fundo
    add R3, R3, R2
    loadi R4, R3    
    
    loadn R3, #' '
    cmp R4, R3
    jeq Pac_Move_OK
    
    loadn R3, #'.'
    cmp R4, R3
    jeq Pac_Eat_Point 
    
    jmp Move_Sai ; Parede

Pac_Eat_Point:
    load R5, dotsLeft
    dec R5
    store dotsLeft, R5
    
    ; Limpa ponto
    loadn R3, #Fundo
    add R3, R3, R2
    loadn R4, #' '
    storei R3, R4

Pac_Move_OK:
    store posAntPac, R0
    store posPac, R2
    
    load R2, posAntPac
    call apagarPacman
    
    load R2, posPac
    call printPacman
    jmp Move_Sai

Move_Sai:
    pop R5
    pop R4
    pop R3
    pop R2
    pop R1
    pop R0
    rts

; --- VERIFICACOES DE FIM DE JOGO ---

Check_Win_Condition:
    push R0
    push R1
    load R0, dotsLeft
    loadn R1, #0
    cmp R0, R1
    jeq Tela_Vitoria
    pop R1
    pop R0
    rts

Check_Game_Over:
    push R0
    push R1
    load R0, posPac
    
    load R1, posGhost1
    cmp R0, R1
    jeq Tela_Derrota
    load R1, posGhost2
    cmp R0, R1
    jeq Tela_Derrota
    load R1, posGhost3
    cmp R0, R1
    jeq Tela_Derrota
    load R1, posGhost4
    cmp R0, R1
    jeq Tela_Derrota
    load R1, posGhost5
    cmp R0, R1
    jeq Tela_Derrota
    load R1, posGhost6
    cmp R0, R1
    jeq Tela_Derrota
    
    pop R1
    pop R0
    rts

Tela_Vitoria:
    call ApagaTela
    
    ; Escreve "VOCE VENCEU" 
    loadn R1, #2816 
    loadn R0, #454 
    
    loadn R2, #'V'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'O'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'C'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'E'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    inc R0 
    loadn R2, #'V'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'E'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'N'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'C'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'E'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'U'
    add R2, R2, R1
    outchar R2, R0
    
    ; Escreve "APERTE ENTER"
    loadn R1, #2816 
    loadn R0, #613
    call Escreve_AperteEnter
    
    jmp Wait_Reset

Tela_Derrota:
    call ApagaTela
    
    ; Escreve "VOCE PERDEU" 
    loadn R1, #2304 
    loadn R0, #454 
    
    loadn R2, #'V'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'O'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'C'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'E'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    inc R0
    loadn R2, #'P'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'E'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'R'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'D'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'E'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'U'
    add R2, R2, R1
    outchar R2, R0

    ; Escreve "APERTE ENTER" 
    loadn R1, #2304
    loadn R0, #613
    call Escreve_AperteEnter

    jmp Wait_Reset

Wait_Reset:
    ; Consome input antigo primeiro 
    inchar R0
    
    ; Espera Novo Enter
    inchar R0
    loadn R1, #13
    cmp R0, R1
    jeq main
    jmp Wait_Reset

Escreve_AperteEnter:
    loadn R2, #'A'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'P'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'E'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'R'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'T'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'E'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    inc R0 ; Espaco
    loadn R2, #'E'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'N'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'T'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'E'
    add R2, R2, R1
    outchar R2, R0
    inc R0
    loadn R2, #'R'
    add R2, R2, R1
    outchar R2, R0
    rts

; --- MOVIMENTACAO FANTASMAS ---

MoveFantasmas:
    push R0
    push R1
    push R6 
    push R7 

    loadn R6, #posGhost1
    loadn R7, #dirGhost1
    call Move_Individual_Ghost

    loadn R6, #posGhost2
    loadn R7, #dirGhost2
    call Move_Individual_Ghost

    loadn R6, #posGhost3
    loadn R7, #dirGhost3
    call Move_Individual_Ghost

    loadn R6, #posGhost4
    loadn R7, #dirGhost4
    call Move_Individual_Ghost

    loadn R6, #posGhost5
    loadn R7, #dirGhost5
    call Move_Individual_Ghost

    loadn R6, #posGhost6
    loadn R7, #dirGhost6
    call Move_Individual_Ghost

    pop R7
    pop R6
    pop R1
    pop R0
    rts

Move_Individual_Ghost:
    push R0 ; Pos Atual
    push R1 ; Direcao Atual
    push R2 ; Next Pos
    push R3 ; Aux
    push R4 ; Mapa
    push R5 

    loadi R0, R6  
    loadi R1, R7  

    call Calc_Pos_Generica 

    ; Verifica colisao (Aceita espaco ou ponto)
    loadn R3, #Fundo
    add R3, R3, R2
    loadi R4, R3
    
    loadn R3, #' '
    cmp R4, R3
    jeq Ghost_Try_Move 
    
    loadn R3, #'.'
    cmp R4, R3
    jeq Ghost_Try_Move 

    ; Bateu na parede
    call GeraRandom_Dir
    storei R7, R1
    jmp End_Move_Ghost 

Ghost_Try_Move:
    push R5
    load R5, randSeed
    loadn R4, #3      
    mod R5, R5, R4
    loadn R4, #0
    cmp R5, R4
    pop R5
    
    jeq Change_Dir_Spontaneous
    jmp Execute_Move

Change_Dir_Spontaneous:
    call GeraRandom_Dir
    storei R7, R1
    jmp End_Move_Ghost

Execute_Move:
    push R6
    mov R2, R0 ; Apaga fantasma antigo
    call apagarFantasma
    pop R6

    call Calc_Pos_Generica 
    
    storei R6, R2 ; Salva e desenha novo
    call printFantasma

End_Move_Ghost:
    pop R5
    pop R4
    pop R3
    pop R2
    pop R1
    pop R0
    rts

; --- INPUT ---
LerInput:
    push R0
    push R1
    inchar R0
    loadn R1, #255
    cmp R0, R1
    jeq LerInput_Fim    
    loadn R1, #'w'
    cmp R0, R1
    jeq SetDir_W
    loadn R1, #'d'
    cmp R0, R1
    jeq SetDir_D
    loadn R1, #'s'
    cmp R0, R1
    jeq SetDir_S
    loadn R1, #'a'
    cmp R0, R1
    jeq SetDir_A
    jmp LerInput_Fim
SetDir_W:
    loadn R1, #1
    store dirPac, R1
    jmp LerInput_Fim
SetDir_D:
    loadn R1, #2
    store dirPac, R1
    jmp LerInput_Fim
SetDir_S:
    loadn R1, #3
    store dirPac, R1
    jmp LerInput_Fim
SetDir_A:
    loadn R1, #4
    store dirPac, R1
    jmp LerInput_Fim
LerInput_Fim:
    pop R1
    pop R0
    rts

; --- CALCULOS AUXILIARES ---

Calc_Pos_Generica:
    push R3
    loadn R3, #1
    cmp R1, R3
    jeq C_Up
    loadn R3, #2
    cmp R1, R3
    jeq C_Right
    loadn R3, #3
    cmp R1, R3
    jeq C_Down
    loadn R3, #4
    cmp R1, R3
    jeq C_Left
    mov R2, R0 
    jmp C_End
C_Up:
    loadn R3, #40
    sub R2, R0, R3
    jmp C_End
C_Down:
    loadn R3, #40
    add R2, R0, R3
    jmp C_End
C_Right:
    loadn R3, #1
    add R2, R0, R3
    jmp C_End
C_Left:
    loadn R3, #1
    sub R2, R0, R3
    jmp C_End
C_End:
    pop R3
    rts

GeraRandom_Dir:
    push R0
    push R2
    load R0, randSeed
    load R2, delayTime
    add R0, R0, R2
    loadn R2, #7
    add R0, R0, R2
    loadn R2, #4
    mod R1, R0, R2 
    loadn R2, #1
    add R1, R1, R2 
    store randSeed, R0
    pop R2
    pop R0
    rts

GeraRandomMapPos:
    push R1
    push R2
    load R0, randSeed
    loadn R1, #17
    mul R0, R0, R1
    loadn R1, #41
    add R0, R0, R1
    store randSeed, R0 
    loadn R1, #1200
    mod R0, R0, R1 
    pop R2
    pop R1
    rts

; --- FUNCOES DE DESENHO ---

printPacman:
  push R0
  push R1
  loadn R0, #'C'   
  loadn R1, #2816  
  add R0, R0, R1   
  outchar R0, R2   
  pop R1
  pop R0
  rts

apagarPacman:
  push R0
  push R1
  push R2
  push R3
  loadn R0, #Fundo
  add R0, R0, R2    
  loadi R1, R0      
  outchar R1, R2    
  pop R3
  pop R2
  pop R1
  pop R0
  rts

printFantasma:
  push R0
  push R1
  loadn R0, #'M'   
  loadn R1, #2304  
  add R0, R0, R1
  outchar R0, R2
  pop R1
  pop R0
  rts

apagarFantasma:
  push R0
  push R1
  push R2
  push R3
  loadn R0, #Fundo
  add R0, R0, R2
  loadi R1, R0
  outchar R1, R2
  pop R3
  pop R2
  pop R1
  pop R0
  rts

DesenhaTodosFantasmas:
    push R2
    load R2, posGhost1
    call printFantasma
    load R2, posGhost2
    call printFantasma
    load R2, posGhost3
    call printFantasma
    load R2, posGhost4
    call printFantasma
    load R2, posGhost5
    call printFantasma
    load R2, posGhost6
    call printFantasma
    pop R2
    rts

DesenhaMapaPrincipal:
  push R0
  push R1
  push R2
  push R3
  loadn R0, #Fundo
  loadn R1, #0
  loadn R2, #1200
DesenhaMapaPrincipalLoop:
    add R3,R0,R1
    loadi R3, R3
    outchar R3, R1
    inc R1
    cmp R1, R2
    jne DesenhaMapaPrincipalLoop
  pop R3
  pop R2
  pop R1
  pop R0
  rts

ApagaTela:
    push R0
    push R1
    loadn R0, #1200
    loadn R1, #' '
    ApagaTela_Loop:
        dec R0
        outchar R1, R0
        jnz ApagaTela_Loop
    pop R1
    pop R0
    rts

Delay_Reg:
    push R0
    push R1
    loop_del:
        loadn R1, #3000
        loop_del2:
            dec R1
            jnz loop_del2
        dec R0
        jnz loop_del
    pop R1
    pop R0
    rts
  

  
Fundo : var #1200
  ;Linha 0
  static Fundo + #0, #3074
  static Fundo + #1, #3072
  static Fundo + #2, #3072
  static Fundo + #3, #3072
  static Fundo + #4, #3072
  static Fundo + #5, #3072
  static Fundo + #6, #3072
  static Fundo + #7, #3072
  static Fundo + #8, #3072
  static Fundo + #9, #3072
  static Fundo + #10, #3072
  static Fundo + #11, #3072
  static Fundo + #12, #3072
  static Fundo + #13, #3072
  static Fundo + #14, #3072
  static Fundo + #15, #3072
  static Fundo + #16, #3072
  static Fundo + #17, #3072
  static Fundo + #18, #3072
  static Fundo + #19, #3072
  static Fundo + #20, #3072
  static Fundo + #21, #3072
  static Fundo + #22, #3072
  static Fundo + #23, #3072
  static Fundo + #24, #3072
  static Fundo + #25, #3072
  static Fundo + #26, #3072
  static Fundo + #27, #3072
  static Fundo + #28, #3072
  static Fundo + #29, #3072
  static Fundo + #30, #3072
  static Fundo + #31, #3072
  static Fundo + #32, #3072
  static Fundo + #33, #3072
  static Fundo + #34, #3072
  static Fundo + #35, #3072
  static Fundo + #36, #3072
  static Fundo + #37, #3072
  static Fundo + #38, #3072
  static Fundo + #39, #3075

  ;Linha 1
  static Fundo + #40, #3073
  static Fundo + #41, #3967
  static Fundo + #42, #3967
  static Fundo + #43, #3967
  static Fundo + #44, #3967
  static Fundo + #45, #3967
  static Fundo + #46, #3967
  static Fundo + #47, #3967
  static Fundo + #48, #3967
  static Fundo + #49, #3967
  static Fundo + #50, #3967
  static Fundo + #51, #3967
  static Fundo + #52, #3967
  static Fundo + #53, #3967
  static Fundo + #54, #3967
  static Fundo + #55, #3967
  static Fundo + #56, #3967
  static Fundo + #57, #3967
  static Fundo + #58, #3967
  static Fundo + #59, #3967
  static Fundo + #60, #3967
  static Fundo + #61, #3967
  static Fundo + #62, #3967
  static Fundo + #63, #3967
  static Fundo + #64, #3967
  static Fundo + #65, #3967
  static Fundo + #66, #3967
  static Fundo + #67, #3967
  static Fundo + #68, #3967
  static Fundo + #69, #3967
  static Fundo + #70, #3967
  static Fundo + #71, #3967
  static Fundo + #72, #3967
  static Fundo + #73, #3967
  static Fundo + #74, #3967
  static Fundo + #75, #3967
  static Fundo + #76, #3967
  static Fundo + #77, #3967
  static Fundo + #78, #3967
  static Fundo + #79, #3073

  ;Linha 2
  static Fundo + #80, #3073
  static Fundo + #81, #3967
  static Fundo + #82, #3967
  static Fundo + #83, #3967
  static Fundo + #84, #3967
  static Fundo + #85, #3967
  static Fundo + #86, #3967
  static Fundo + #87, #3967
  static Fundo + #88, #3967
  static Fundo + #89, #3967
  static Fundo + #90, #3967
  static Fundo + #91, #3967
  static Fundo + #92, #3967
  static Fundo + #93, #3967
  static Fundo + #94, #3967
  static Fundo + #95, #3967
  static Fundo + #96, #3967
  static Fundo + #97, #3967
  static Fundo + #98, #3967
  static Fundo + #99, #3967
  static Fundo + #100, #3967
  static Fundo + #101, #3967
  static Fundo + #102, #3967
  static Fundo + #103, #3967
  static Fundo + #104, #3967
  static Fundo + #105, #3967
  static Fundo + #106, #3967
  static Fundo + #107, #3967
  static Fundo + #108, #3967
  static Fundo + #109, #3967
  static Fundo + #110, #3967
  static Fundo + #111, #3967
  static Fundo + #112, #3967
  static Fundo + #113, #3967
  static Fundo + #114, #3967
  static Fundo + #115, #3967
  static Fundo + #116, #3967
  static Fundo + #117, #3967
  static Fundo + #118, #3967
  static Fundo + #119, #3073

  ;Linha 3
  static Fundo + #120, #3073
  static Fundo + #121, #3967
  static Fundo + #122, #3967
  static Fundo + #123, #3967
  static Fundo + #124, #3967
  static Fundo + #125, #3967
  static Fundo + #126, #3967
  static Fundo + #127, #3967
  static Fundo + #128, #3967
  static Fundo + #129, #3967
  static Fundo + #130, #3967
  static Fundo + #131, #3967
  static Fundo + #132, #3967
  static Fundo + #133, #3967
  static Fundo + #134, #3967
  static Fundo + #135, #3967
  static Fundo + #136, #3967
  static Fundo + #137, #3967
  static Fundo + #138, #3967
  static Fundo + #139, #3967
  static Fundo + #140, #3967
  static Fundo + #141, #3967
  static Fundo + #142, #3967
  static Fundo + #143, #3967
  static Fundo + #144, #3967
  static Fundo + #145, #3967
  static Fundo + #146, #3967
  static Fundo + #147, #3967
  static Fundo + #148, #3967
  static Fundo + #149, #3967
  static Fundo + #150, #3967
  static Fundo + #151, #3967
  static Fundo + #152, #3967
  static Fundo + #153, #3967
  static Fundo + #154, #3967
  static Fundo + #155, #3967
  static Fundo + #156, #3967
  static Fundo + #157, #3967
  static Fundo + #158, #3967
  static Fundo + #159, #3073

  ;Linha 4
  static Fundo + #160, #3073
  static Fundo + #161, #3967
  static Fundo + #162, #3967
  static Fundo + #163, #3967
  static Fundo + #164, #3967
  static Fundo + #165, #3967
  static Fundo + #166, #3078
  static Fundo + #167, #3072
  static Fundo + #168, #3072
  static Fundo + #169, #3072
  static Fundo + #170, #3072
  static Fundo + #171, #3072
  static Fundo + #172, #3072
  static Fundo + #173, #3072
  static Fundo + #174, #3079
  static Fundo + #175, #3967
  static Fundo + #176, #3967
  static Fundo + #177, #3967
  static Fundo + #178, #3967
  static Fundo + #179, #3967
  static Fundo + #180, #3967
  static Fundo + #181, #3967
  static Fundo + #182, #3967
  static Fundo + #183, #3967
  static Fundo + #184, #3967
  static Fundo + #185, #3078
  static Fundo + #186, #3072
  static Fundo + #187, #3072
  static Fundo + #188, #3072
  static Fundo + #189, #3072
  static Fundo + #190, #3072
  static Fundo + #191, #3072
  static Fundo + #192, #3072
  static Fundo + #193, #3079
  static Fundo + #194, #3967
  static Fundo + #195, #3967
  static Fundo + #196, #3967
  static Fundo + #197, #3967
  static Fundo + #198, #3967
  static Fundo + #199, #3073

  ;Linha 5
  static Fundo + #200, #3073
  static Fundo + #201, #3967
  static Fundo + #202, #3967
  static Fundo + #203, #3967
  static Fundo + #204, #3967
  static Fundo + #205, #3967
  static Fundo + #206, #3967
  static Fundo + #207, #3967
  static Fundo + #208, #3967
  static Fundo + #209, #3967
  static Fundo + #210, #3967
  static Fundo + #211, #3967
  static Fundo + #212, #3967
  static Fundo + #213, #3967
  static Fundo + #214, #3967
  static Fundo + #215, #3967
  static Fundo + #216, #3967
  static Fundo + #217, #3967
  static Fundo + #218, #3967
  static Fundo + #219, #3967
  static Fundo + #220, #3967
  static Fundo + #221, #3967
  static Fundo + #222, #3967
  static Fundo + #223, #3967
  static Fundo + #224, #3967
  static Fundo + #225, #3967
  static Fundo + #226, #3967
  static Fundo + #227, #3967
  static Fundo + #228, #3967
  static Fundo + #229, #3967
  static Fundo + #230, #3967
  static Fundo + #231, #3967
  static Fundo + #232, #3967
  static Fundo + #233, #3967
  static Fundo + #234, #3967
  static Fundo + #235, #3967
  static Fundo + #236, #3967
  static Fundo + #237, #3967
  static Fundo + #238, #3967
  static Fundo + #239, #3073

  ;Linha 6
  static Fundo + #240, #3073
  static Fundo + #241, #3967
  static Fundo + #242, #3967
  static Fundo + #243, #3967
  static Fundo + #244, #3967
  static Fundo + #245, #3967
  static Fundo + #246, #3967
  static Fundo + #247, #3967
  static Fundo + #248, #3967
  static Fundo + #249, #3967
  static Fundo + #250, #3967
  static Fundo + #251, #3967
  static Fundo + #252, #3967
  static Fundo + #253, #3967
  static Fundo + #254, #3967
  static Fundo + #255, #3967
  static Fundo + #256, #3967
  static Fundo + #257, #3967
  static Fundo + #258, #3967
  static Fundo + #259, #3967
  static Fundo + #260, #3967
  static Fundo + #261, #3967
  static Fundo + #262, #3967
  static Fundo + #263, #3967
  static Fundo + #264, #3967
  static Fundo + #265, #3967
  static Fundo + #266, #3967
  static Fundo + #267, #3967
  static Fundo + #268, #3967
  static Fundo + #269, #3967
  static Fundo + #270, #3967
  static Fundo + #271, #3967
  static Fundo + #272, #3967
  static Fundo + #273, #3967
  static Fundo + #274, #3967
  static Fundo + #275, #3967
  static Fundo + #276, #3967
  static Fundo + #277, #3967
  static Fundo + #278, #3967
  static Fundo + #279, #3073

  ;Linha 7
  static Fundo + #280, #3073
  static Fundo + #281, #3967
  static Fundo + #282, #3967
  static Fundo + #283, #3967
  static Fundo + #284, #3967
  static Fundo + #285, #3967
  static Fundo + #286, #3967
  static Fundo + #287, #3967
  static Fundo + #288, #3967
  static Fundo + #289, #3967
  static Fundo + #290, #3967
  static Fundo + #291, #3967
  static Fundo + #292, #3967
  static Fundo + #293, #3967
  static Fundo + #294, #3967
  static Fundo + #295, #3967
  static Fundo + #296, #3967
  static Fundo + #297, #3967
  static Fundo + #298, #3967
  static Fundo + #299, #3967
  static Fundo + #300, #3967
  static Fundo + #301, #3967
  static Fundo + #302, #3967
  static Fundo + #303, #3967
  static Fundo + #304, #3967
  static Fundo + #305, #3967
  static Fundo + #306, #3967
  static Fundo + #307, #3967
  static Fundo + #308, #3967
  static Fundo + #309, #3967
  static Fundo + #310, #3967
  static Fundo + #311, #3967
  static Fundo + #312, #3967
  static Fundo + #313, #3967
  static Fundo + #314, #3967
  static Fundo + #315, #3967
  static Fundo + #316, #3967
  static Fundo + #317, #3967
  static Fundo + #318, #3967
  static Fundo + #319, #3073

  ;Linha 8
  static Fundo + #320, #3073
  static Fundo + #321, #3967
  static Fundo + #322, #3967
  static Fundo + #323, #3967
  static Fundo + #324, #3967
  static Fundo + #325, #3967
  static Fundo + #326, #3967
  static Fundo + #327, #3967
  static Fundo + #328, #3967
  static Fundo + #329, #3967
  static Fundo + #330, #3967
  static Fundo + #331, #3967
  static Fundo + #332, #3967
  static Fundo + #333, #3967
  static Fundo + #334, #3967
  static Fundo + #335, #3967
  static Fundo + #336, #3967
  static Fundo + #337, #3967
  static Fundo + #338, #3967
  static Fundo + #339, #3967
  static Fundo + #340, #3967
  static Fundo + #341, #3967
  static Fundo + #342, #3967
  static Fundo + #343, #3967
  static Fundo + #344, #3967
  static Fundo + #345, #3967
  static Fundo + #346, #3967
  static Fundo + #347, #3967
  static Fundo + #348, #3967
  static Fundo + #349, #3967
  static Fundo + #350, #3967
  static Fundo + #351, #3967
  static Fundo + #352, #3967
  static Fundo + #353, #3967
  static Fundo + #354, #3967
  static Fundo + #355, #3967
  static Fundo + #356, #3967
  static Fundo + #357, #3967
  static Fundo + #358, #3967
  static Fundo + #359, #3073

  ;Linha 9
  static Fundo + #360, #3073
  static Fundo + #361, #3967
  static Fundo + #362, #3967
  static Fundo + #363, #3967
  static Fundo + #364, #3967
  static Fundo + #365, #3080
  static Fundo + #366, #3967
  static Fundo + #367, #3967
  static Fundo + #368, #3967
  static Fundo + #369, #3074
  static Fundo + #370, #3072
  static Fundo + #371, #3072
  static Fundo + #372, #3072
  static Fundo + #373, #3072
  static Fundo + #374, #3072
  static Fundo + #375, #3967
  static Fundo + #376, #3967
  static Fundo + #377, #3967
  static Fundo + #378, #3074
  static Fundo + #379, #3082
  static Fundo + #380, #3967
  static Fundo + #381, #3967
  static Fundo + #382, #3967
  static Fundo + #383, #3967
  static Fundo + #384, #3967
  static Fundo + #385, #3083
  static Fundo + #386, #3075
  static Fundo + #387, #3967
  static Fundo + #388, #3967
  static Fundo + #389, #3967
  static Fundo + #390, #3074
  static Fundo + #391, #3072
  static Fundo + #392, #3072
  static Fundo + #393, #3072
  static Fundo + #394, #3072
  static Fundo + #395, #3072
  static Fundo + #396, #3967
  static Fundo + #397, #3967
  static Fundo + #398, #3967
  static Fundo + #399, #3073

  ;Linha 10
  static Fundo + #400, #3073
  static Fundo + #401, #3967
  static Fundo + #402, #3967
  static Fundo + #403, #3967
  static Fundo + #404, #3967
  static Fundo + #405, #3073
  static Fundo + #406, #3967
  static Fundo + #407, #3967
  static Fundo + #408, #3967
  static Fundo + #409, #3073
  static Fundo + #410, #3967
  static Fundo + #411, #3967
  static Fundo + #412, #3967
  static Fundo + #413, #3967
  static Fundo + #414, #3967
  static Fundo + #415, #3967
  static Fundo + #416, #3967
  static Fundo + #417, #3967
  static Fundo + #418, #3073
  static Fundo + #419, #3082
  static Fundo + #420, #3082
  static Fundo + #421, #3967
  static Fundo + #422, #3967
  static Fundo + #423, #3967
  static Fundo + #424, #3083
  static Fundo + #425, #3083
  static Fundo + #426, #3073
  static Fundo + #427, #3967
  static Fundo + #428, #3967
  static Fundo + #429, #3967
  static Fundo + #430, #3073
  static Fundo + #431, #3967
  static Fundo + #432, #3967
  static Fundo + #433, #3967
  static Fundo + #434, #3967
  static Fundo + #435, #3967
  static Fundo + #436, #3967
  static Fundo + #437, #3967
  static Fundo + #438, #3967
  static Fundo + #439, #3073

  ;Linha 11
  static Fundo + #440, #3073
  static Fundo + #441, #3967
  static Fundo + #442, #3967
  static Fundo + #443, #3967
  static Fundo + #444, #3967
  static Fundo + #445, #3073
  static Fundo + #446, #3967
  static Fundo + #447, #3967
  static Fundo + #448, #3967
  static Fundo + #449, #3073
  static Fundo + #450, #3967
  static Fundo + #451, #3967
  static Fundo + #452, #3967
  static Fundo + #453, #3967
  static Fundo + #454, #3967
  static Fundo + #455, #3967
  static Fundo + #456, #3967
  static Fundo + #457, #3967
  static Fundo + #458, #3073
  static Fundo + #459, #3967
  static Fundo + #460, #3082
  static Fundo + #461, #3082
  static Fundo + #462, #3967
  static Fundo + #463, #3083
  static Fundo + #464, #3083
  static Fundo + #465, #3967
  static Fundo + #466, #3073
  static Fundo + #467, #3967
  static Fundo + #468, #3967
  static Fundo + #469, #3967
  static Fundo + #470, #3073
  static Fundo + #471, #3967
  static Fundo + #472, #3967
  static Fundo + #473, #3967
  static Fundo + #474, #3967
  static Fundo + #475, #3967
  static Fundo + #476, #3967
  static Fundo + #477, #3967
  static Fundo + #478, #3967
  static Fundo + #479, #3073

  ;Linha 12
  static Fundo + #480, #3073
  static Fundo + #481, #3967
  static Fundo + #482, #3967
  static Fundo + #483, #3967
  static Fundo + #484, #3967
  static Fundo + #485, #3073
  static Fundo + #486, #3967
  static Fundo + #487, #3967
  static Fundo + #488, #3967
  static Fundo + #489, #3073
  static Fundo + #490, #3967
  static Fundo + #491, #3967
  static Fundo + #492, #3967
  static Fundo + #493, #3967
  static Fundo + #494, #3967
  static Fundo + #495, #3967
  static Fundo + #496, #3967
  static Fundo + #497, #3967
  static Fundo + #498, #3073
  static Fundo + #499, #3967
  static Fundo + #500, #3967
  static Fundo + #501, #3082
  static Fundo + #502, #3072
  static Fundo + #503, #3083
  static Fundo + #504, #3967
  static Fundo + #505, #3967
  static Fundo + #506, #3073
  static Fundo + #507, #3967
  static Fundo + #508, #3967
  static Fundo + #509, #3967
  static Fundo + #510, #3073
  static Fundo + #511, #3967
  static Fundo + #512, #3967
  static Fundo + #513, #3967
  static Fundo + #514, #3967
  static Fundo + #515, #3967
  static Fundo + #516, #3967
  static Fundo + #517, #3967
  static Fundo + #518, #3967
  static Fundo + #519, #3073

  ;Linha 13
  static Fundo + #520, #3073
  static Fundo + #521, #3967
  static Fundo + #522, #3967
  static Fundo + #523, #3967
  static Fundo + #524, #3967
  static Fundo + #525, #3073
  static Fundo + #526, #3967
  static Fundo + #527, #3967
  static Fundo + #528, #3967
  static Fundo + #529, #3073
  static Fundo + #530, #3967
  static Fundo + #531, #3967
  static Fundo + #532, #3967
  static Fundo + #533, #3967
  static Fundo + #534, #3967
  static Fundo + #535, #3967
  static Fundo + #536, #3967
  static Fundo + #537, #3967
  static Fundo + #538, #3073
  static Fundo + #539, #3967
  static Fundo + #540, #3967
  static Fundo + #541, #3967
  static Fundo + #542, #3967
  static Fundo + #543, #3967
  static Fundo + #544, #3967
  static Fundo + #545, #3967
  static Fundo + #546, #3073
  static Fundo + #547, #3967
  static Fundo + #548, #3967
  static Fundo + #549, #3967
  static Fundo + #550, #3073
  static Fundo + #551, #3967
  static Fundo + #552, #3967
  static Fundo + #553, #3967
  static Fundo + #554, #3967
  static Fundo + #555, #3967
  static Fundo + #556, #3967
  static Fundo + #557, #3967
  static Fundo + #558, #3967
  static Fundo + #559, #3073

  ;Linha 14
  static Fundo + #560, #3073
  static Fundo + #561, #3967
  static Fundo + #562, #3967
  static Fundo + #563, #3967
  static Fundo + #564, #3967
  static Fundo + #565, #3073
  static Fundo + #566, #3967
  static Fundo + #567, #3967
  static Fundo + #568, #3967
  static Fundo + #569, #3073
  static Fundo + #570, #3967
  static Fundo + #571, #3967
  static Fundo + #572, #3967
  static Fundo + #573, #3967
  static Fundo + #574, #3967
  static Fundo + #575, #3967
  static Fundo + #576, #3967
  static Fundo + #577, #3967
  static Fundo + #578, #3073
  static Fundo + #579, #3967
  static Fundo + #580, #3967
  static Fundo + #581, #3967
  static Fundo + #582, #3967
  static Fundo + #583, #3967
  static Fundo + #584, #3967
  static Fundo + #585, #3967
  static Fundo + #586, #3073
  static Fundo + #587, #3967
  static Fundo + #588, #3967
  static Fundo + #589, #3967
  static Fundo + #590, #3073
  static Fundo + #591, #3967
  static Fundo + #592, #3967
  static Fundo + #593, #3967
  static Fundo + #594, #3967
  static Fundo + #595, #3967
  static Fundo + #596, #3967
  static Fundo + #597, #3967
  static Fundo + #598, #3967
  static Fundo + #599, #3073

  ;Linha 15
  static Fundo + #600, #3073
  static Fundo + #601, #3967
  static Fundo + #602, #3967
  static Fundo + #603, #3967
  static Fundo + #604, #3967
  static Fundo + #605, #3073
  static Fundo + #606, #3967
  static Fundo + #607, #3967
  static Fundo + #608, #3967
  static Fundo + #609, #3073
  static Fundo + #610, #3967
  static Fundo + #611, #3967
  static Fundo + #612, #3967
  static Fundo + #613, #3967
  static Fundo + #614, #3967
  static Fundo + #615, #3967
  static Fundo + #616, #3967
  static Fundo + #617, #3967
  static Fundo + #618, #3073
  static Fundo + #619, #3967
  static Fundo + #620, #3967
  static Fundo + #621, #3967
  static Fundo + #622, #3967
  static Fundo + #623, #3967
  static Fundo + #624, #3967
  static Fundo + #625, #3967
  static Fundo + #626, #3073
  static Fundo + #627, #3967
  static Fundo + #628, #3967
  static Fundo + #629, #3967
  static Fundo + #630, #3073
  static Fundo + #631, #3967
  static Fundo + #632, #3967
  static Fundo + #633, #3967
  static Fundo + #634, #3967
  static Fundo + #635, #3967
  static Fundo + #636, #3967
  static Fundo + #637, #3967
  static Fundo + #638, #3967
  static Fundo + #639, #3073

  ;Linha 16
  static Fundo + #640, #3073
  static Fundo + #641, #3967
  static Fundo + #642, #3967
  static Fundo + #643, #3967
  static Fundo + #644, #3967
  static Fundo + #645, #3073
  static Fundo + #646, #3967
  static Fundo + #647, #3967
  static Fundo + #648, #3967
  static Fundo + #649, #3073
  static Fundo + #650, #3967
  static Fundo + #651, #3967
  static Fundo + #652, #3967
  static Fundo + #653, #3967
  static Fundo + #654, #3967
  static Fundo + #655, #3967
  static Fundo + #656, #3967
  static Fundo + #657, #3967
  static Fundo + #658, #3073
  static Fundo + #659, #3967
  static Fundo + #660, #3967
  static Fundo + #661, #3967
  static Fundo + #662, #3967
  static Fundo + #663, #3967
  static Fundo + #664, #3967
  static Fundo + #665, #3967
  static Fundo + #666, #3073
  static Fundo + #667, #3967
  static Fundo + #668, #3967
  static Fundo + #669, #3967
  static Fundo + #670, #3073
  static Fundo + #671, #3967
  static Fundo + #672, #3967
  static Fundo + #673, #3967
  static Fundo + #674, #3967
  static Fundo + #675, #3967
  static Fundo + #676, #3967
  static Fundo + #677, #3967
  static Fundo + #678, #3967
  static Fundo + #679, #3073

  ;Linha 17
  static Fundo + #680, #3073
  static Fundo + #681, #3967
  static Fundo + #682, #3967
  static Fundo + #683, #3967
  static Fundo + #684, #3967
  static Fundo + #685, #3073
  static Fundo + #686, #3967
  static Fundo + #687, #3967
  static Fundo + #688, #3967
  static Fundo + #689, #3073
  static Fundo + #690, #3967
  static Fundo + #691, #3967
  static Fundo + #692, #3967
  static Fundo + #693, #3967
  static Fundo + #694, #3967
  static Fundo + #695, #3967
  static Fundo + #696, #3967
  static Fundo + #697, #3967
  static Fundo + #698, #3073
  static Fundo + #699, #3967
  static Fundo + #700, #3967
  static Fundo + #701, #3967
  static Fundo + #702, #3967
  static Fundo + #703, #3967
  static Fundo + #704, #3967
  static Fundo + #705, #3967
  static Fundo + #706, #3073
  static Fundo + #707, #3967
  static Fundo + #708, #3967
  static Fundo + #709, #3967
  static Fundo + #710, #3073
  static Fundo + #711, #3967
  static Fundo + #712, #3967
  static Fundo + #713, #3967
  static Fundo + #714, #3967
  static Fundo + #715, #3967
  static Fundo + #716, #3967
  static Fundo + #717, #3967
  static Fundo + #718, #3967
  static Fundo + #719, #3073

  ;Linha 18
  static Fundo + #720, #3073
  static Fundo + #721, #3967
  static Fundo + #722, #3967
  static Fundo + #723, #3967
  static Fundo + #724, #3967
  static Fundo + #725, #3073
  static Fundo + #726, #3967
  static Fundo + #727, #3967
  static Fundo + #728, #3967
  static Fundo + #729, #3073
  static Fundo + #730, #3967
  static Fundo + #731, #3967
  static Fundo + #732, #3967
  static Fundo + #733, #3967
  static Fundo + #734, #3967
  static Fundo + #735, #3967
  static Fundo + #736, #3967
  static Fundo + #737, #3967
  static Fundo + #738, #3073
  static Fundo + #739, #3967
  static Fundo + #740, #3967
  static Fundo + #741, #3967
  static Fundo + #742, #3967
  static Fundo + #743, #3967
  static Fundo + #744, #3967
  static Fundo + #745, #3967
  static Fundo + #746, #3073
  static Fundo + #747, #3967
  static Fundo + #748, #3967
  static Fundo + #749, #3967
  static Fundo + #750, #3073
  static Fundo + #751, #3967
  static Fundo + #752, #3967
  static Fundo + #753, #3967
  static Fundo + #754, #3967
  static Fundo + #755, #3967
  static Fundo + #756, #3967
  static Fundo + #757, #3967
  static Fundo + #758, #3967
  static Fundo + #759, #3073

  ;Linha 19
  static Fundo + #760, #3073
  static Fundo + #761, #3967
  static Fundo + #762, #3967
  static Fundo + #763, #3967
  static Fundo + #764, #3967
  static Fundo + #765, #3073
  static Fundo + #766, #3967
  static Fundo + #767, #3967
  static Fundo + #768, #3967
  static Fundo + #769, #3073
  static Fundo + #770, #3967
  static Fundo + #771, #3967
  static Fundo + #772, #3967
  static Fundo + #773, #3967
  static Fundo + #774, #3967
  static Fundo + #775, #3967
  static Fundo + #776, #3967
  static Fundo + #777, #3967
  static Fundo + #778, #3073
  static Fundo + #779, #3967
  static Fundo + #780, #3967
  static Fundo + #781, #3967
  static Fundo + #782, #3967
  static Fundo + #783, #3967
  static Fundo + #784, #3967
  static Fundo + #785, #3967
  static Fundo + #786, #3073
  static Fundo + #787, #3967
  static Fundo + #788, #3967
  static Fundo + #789, #3967
  static Fundo + #790, #3073
  static Fundo + #791, #3967
  static Fundo + #792, #3967
  static Fundo + #793, #3967
  static Fundo + #794, #3967
  static Fundo + #795, #3967
  static Fundo + #796, #3967
  static Fundo + #797, #3967
  static Fundo + #798, #3967
  static Fundo + #799, #3073

  ;Linha 20
  static Fundo + #800, #3073
  static Fundo + #801, #3967
  static Fundo + #802, #3967
  static Fundo + #803, #3967
  static Fundo + #804, #3967
  static Fundo + #805, #3081
  static Fundo + #806, #3967
  static Fundo + #807, #3967
  static Fundo + #808, #3967
  static Fundo + #809, #3076
  static Fundo + #810, #3072
  static Fundo + #811, #3072
  static Fundo + #812, #3072
  static Fundo + #813, #3072
  static Fundo + #814, #3072
  static Fundo + #815, #3967
  static Fundo + #816, #3967
  static Fundo + #817, #3967
  static Fundo + #818, #3073
  static Fundo + #819, #3967
  static Fundo + #820, #3967
  static Fundo + #821, #3967
  static Fundo + #822, #3967
  static Fundo + #823, #3967
  static Fundo + #824, #3967
  static Fundo + #825, #3967
  static Fundo + #826, #3073
  static Fundo + #827, #3967
  static Fundo + #828, #3967
  static Fundo + #829, #3967
  static Fundo + #830, #3076
  static Fundo + #831, #3072
  static Fundo + #832, #3072
  static Fundo + #833, #3072
  static Fundo + #834, #3072
  static Fundo + #835, #3072
  static Fundo + #836, #3967
  static Fundo + #837, #3967
  static Fundo + #838, #3967
  static Fundo + #839, #3073

  ;Linha 21
  static Fundo + #840, #3073
  static Fundo + #841, #3967
  static Fundo + #842, #3967
  static Fundo + #843, #3967
  static Fundo + #844, #3967
  static Fundo + #845, #3967
  static Fundo + #846, #3967
  static Fundo + #847, #3967
  static Fundo + #848, #3967
  static Fundo + #849, #3967
  static Fundo + #850, #3967
  static Fundo + #851, #3967
  static Fundo + #852, #3967
  static Fundo + #853, #3967
  static Fundo + #854, #3967
  static Fundo + #855, #3967
  static Fundo + #856, #3967
  static Fundo + #857, #3967
  static Fundo + #858, #3967
  static Fundo + #859, #3967
  static Fundo + #860, #3967
  static Fundo + #861, #3967
  static Fundo + #862, #3967
  static Fundo + #863, #3967
  static Fundo + #864, #3967
  static Fundo + #865, #3967
  static Fundo + #866, #3967
  static Fundo + #867, #3967
  static Fundo + #868, #3967
  static Fundo + #869, #3967
  static Fundo + #870, #3967
  static Fundo + #871, #3967
  static Fundo + #872, #3967
  static Fundo + #873, #3967
  static Fundo + #874, #3967
  static Fundo + #875, #3967
  static Fundo + #876, #3967
  static Fundo + #877, #3967
  static Fundo + #878, #3967
  static Fundo + #879, #3073

  ;Linha 22
  static Fundo + #880, #3073
  static Fundo + #881, #3967
  static Fundo + #882, #3967
  static Fundo + #883, #3967
  static Fundo + #884, #3967
  static Fundo + #885, #3967
  static Fundo + #886, #3967
  static Fundo + #887, #3967
  static Fundo + #888, #3967
  static Fundo + #889, #3967
  static Fundo + #890, #3967
  static Fundo + #891, #3967
  static Fundo + #892, #3967
  static Fundo + #893, #3967
  static Fundo + #894, #3967
  static Fundo + #895, #3967
  static Fundo + #896, #3967
  static Fundo + #897, #3967
  static Fundo + #898, #3967
  static Fundo + #899, #3967
  static Fundo + #900, #3967
  static Fundo + #901, #3967
  static Fundo + #902, #3967
  static Fundo + #903, #3967
  static Fundo + #904, #3967
  static Fundo + #905, #3967
  static Fundo + #906, #3967
  static Fundo + #907, #3967
  static Fundo + #908, #3967
  static Fundo + #909, #3967
  static Fundo + #910, #3967
  static Fundo + #911, #3967
  static Fundo + #912, #3967
  static Fundo + #913, #3967
  static Fundo + #914, #3967
  static Fundo + #915, #3967
  static Fundo + #916, #3967
  static Fundo + #917, #3967
  static Fundo + #918, #3967
  static Fundo + #919, #3073

  ;Linha 23
  static Fundo + #920, #3073
  static Fundo + #921, #3967
  static Fundo + #922, #3967
  static Fundo + #923, #3967
  static Fundo + #924, #3967
  static Fundo + #925, #3967
  static Fundo + #926, #3967
  static Fundo + #927, #3967
  static Fundo + #928, #3967
  static Fundo + #929, #3967
  static Fundo + #930, #3967
  static Fundo + #931, #3967
  static Fundo + #932, #3967
  static Fundo + #933, #3967
  static Fundo + #934, #3967
  static Fundo + #935, #3967
  static Fundo + #936, #3967
  static Fundo + #937, #3967
  static Fundo + #938, #3967
  static Fundo + #939, #3967
  static Fundo + #940, #3967
  static Fundo + #941, #3967
  static Fundo + #942, #3967
  static Fundo + #943, #3967
  static Fundo + #944, #3967
  static Fundo + #945, #3967
  static Fundo + #946, #3967
  static Fundo + #947, #3967
  static Fundo + #948, #3967
  static Fundo + #949, #3967
  static Fundo + #950, #3967
  static Fundo + #951, #3967
  static Fundo + #952, #3967
  static Fundo + #953, #3967
  static Fundo + #954, #3967
  static Fundo + #955, #3967
  static Fundo + #956, #3967
  static Fundo + #957, #3967
  static Fundo + #958, #3967
  static Fundo + #959, #3073

  ;Linha 24
  static Fundo + #960, #3073
  static Fundo + #961, #3967
  static Fundo + #962, #3967
  static Fundo + #963, #3967
  static Fundo + #964, #3967
  static Fundo + #965, #3967
  static Fundo + #966, #3967
  static Fundo + #967, #3967
  static Fundo + #968, #3967
  static Fundo + #969, #3967
  static Fundo + #970, #3967
  static Fundo + #971, #3967
  static Fundo + #972, #3967
  static Fundo + #973, #3967
  static Fundo + #974, #3967
  static Fundo + #975, #3967
  static Fundo + #976, #3967
  static Fundo + #977, #3967
  static Fundo + #978, #3967
  static Fundo + #979, #3967
  static Fundo + #980, #3967
  static Fundo + #981, #3967
  static Fundo + #982, #3967
  static Fundo + #983, #3967
  static Fundo + #984, #3967
  static Fundo + #985, #3967
  static Fundo + #986, #3967
  static Fundo + #987, #3967
  static Fundo + #988, #3967
  static Fundo + #989, #3967
  static Fundo + #990, #3967
  static Fundo + #991, #3967
  static Fundo + #992, #3967
  static Fundo + #993, #3967
  static Fundo + #994, #3967
  static Fundo + #995, #3967
  static Fundo + #996, #3967
  static Fundo + #997, #3967
  static Fundo + #998, #3967
  static Fundo + #999, #3073

  ;Linha 25
  static Fundo + #1000, #3073
  static Fundo + #1001, #3967
  static Fundo + #1002, #3967
  static Fundo + #1003, #3967
  static Fundo + #1004, #3967
  static Fundo + #1005, #3967
  static Fundo + #1006, #3967
  static Fundo + #1007, #3967
  static Fundo + #1008, #3967
  static Fundo + #1009, #3967
  static Fundo + #1010, #3967
  static Fundo + #1011, #3967
  static Fundo + #1012, #3967
  static Fundo + #1013, #3078
  static Fundo + #1014, #3072
  static Fundo + #1015, #3072
  static Fundo + #1016, #3072
  static Fundo + #1017, #3072
  static Fundo + #1018, #3072
  static Fundo + #1019, #3072
  static Fundo + #1020, #3072
  static Fundo + #1021, #3072
  static Fundo + #1022, #3072
  static Fundo + #1023, #3072
  static Fundo + #1024, #3072
  static Fundo + #1025, #3072
  static Fundo + #1026, #3072
  static Fundo + #1027, #3079
  static Fundo + #1028, #3967
  static Fundo + #1029, #3967
  static Fundo + #1030, #3967
  static Fundo + #1031, #3967
  static Fundo + #1032, #3967
  static Fundo + #1033, #3967
  static Fundo + #1034, #3967
  static Fundo + #1035, #3967
  static Fundo + #1036, #3967
  static Fundo + #1037, #3967
  static Fundo + #1038, #3967
  static Fundo + #1039, #3073

  ;Linha 26
  static Fundo + #1040, #3073
  static Fundo + #1041, #3967
  static Fundo + #1042, #3967
  static Fundo + #1043, #3967
  static Fundo + #1044, #3967
  static Fundo + #1045, #3967
  static Fundo + #1046, #3967
  static Fundo + #1047, #3967
  static Fundo + #1048, #3967
  static Fundo + #1049, #3967
  static Fundo + #1050, #3967
  static Fundo + #1051, #3967
  static Fundo + #1052, #3967
  static Fundo + #1053, #3967
  static Fundo + #1054, #3967
  static Fundo + #1055, #3967
  static Fundo + #1056, #3967
  static Fundo + #1057, #3967
  static Fundo + #1058, #3967
  static Fundo + #1059, #3967
  static Fundo + #1060, #3967
  static Fundo + #1061, #3967
  static Fundo + #1062, #3967
  static Fundo + #1063, #3967
  static Fundo + #1064, #3967
  static Fundo + #1065, #3967
  static Fundo + #1066, #3967
  static Fundo + #1067, #3967
  static Fundo + #1068, #3967
  static Fundo + #1069, #3967
  static Fundo + #1070, #3967
  static Fundo + #1071, #3967
  static Fundo + #1072, #3967
  static Fundo + #1073, #3967
  static Fundo + #1074, #3967
  static Fundo + #1075, #3967
  static Fundo + #1076, #3967
  static Fundo + #1077, #3967
  static Fundo + #1078, #3967
  static Fundo + #1079, #3073

  ;Linha 27
  static Fundo + #1080, #3073
  static Fundo + #1081, #3967
  static Fundo + #1082, #3967
  static Fundo + #1083, #3967
  static Fundo + #1084, #3967
  static Fundo + #1085, #3967
  static Fundo + #1086, #3967
  static Fundo + #1087, #3967
  static Fundo + #1088, #3967
  static Fundo + #1089, #3967
  static Fundo + #1090, #3967
  static Fundo + #1091, #3967
  static Fundo + #1092, #3967
  static Fundo + #1093, #3967
  static Fundo + #1094, #3967
  static Fundo + #1095, #3967
  static Fundo + #1096, #3967
  static Fundo + #1097, #3967
  static Fundo + #1098, #3967
  static Fundo + #1099, #3967
  static Fundo + #1100, #3967
  static Fundo + #1101, #3967
  static Fundo + #1102, #3967
  static Fundo + #1103, #3967
  static Fundo + #1104, #3967
  static Fundo + #1105, #3967
  static Fundo + #1106, #3967
  static Fundo + #1107, #3967
  static Fundo + #1108, #3967
  static Fundo + #1109, #3967
  static Fundo + #1110, #3967
  static Fundo + #1111, #3967
  static Fundo + #1112, #3967
  static Fundo + #1113, #3967
  static Fundo + #1114, #3967
  static Fundo + #1115, #3967
  static Fundo + #1116, #3967
  static Fundo + #1117, #3967
  static Fundo + #1118, #3967
  static Fundo + #1119, #3073

  ;Linha 28
  static Fundo + #1120, #3073
  static Fundo + #1121, #3967
  static Fundo + #1122, #3967
  static Fundo + #1123, #3967
  static Fundo + #1124, #3967
  static Fundo + #1125, #3967
  static Fundo + #1126, #3967
  static Fundo + #1127, #3967
  static Fundo + #1128, #3967
  static Fundo + #1129, #3967
  static Fundo + #1130, #3967
  static Fundo + #1131, #3967
  static Fundo + #1132, #3967
  static Fundo + #1133, #3967
  static Fundo + #1134, #3967
  static Fundo + #1135, #3967
  static Fundo + #1136, #3967
  static Fundo + #1137, #3967
  static Fundo + #1138, #3967
  static Fundo + #1139, #3967
  static Fundo + #1140, #3967
  static Fundo + #1141, #3967
  static Fundo + #1142, #3967
  static Fundo + #1143, #3967
  static Fundo + #1144, #3967
  static Fundo + #1145, #3967
  static Fundo + #1146, #3967
  static Fundo + #1147, #3967
  static Fundo + #1148, #3967
  static Fundo + #1149, #3967
  static Fundo + #1150, #3967
  static Fundo + #1151, #3967
  static Fundo + #1152, #3967
  static Fundo + #1153, #3967
  static Fundo + #1154, #3967
  static Fundo + #1155, #3967
  static Fundo + #1156, #3967
  static Fundo + #1157, #3967
  static Fundo + #1158, #3967
  static Fundo + #1159, #3073

  ;Linha 29
  static Fundo + #1160, #3076
  static Fundo + #1161, #3072
  static Fundo + #1162, #3072
  static Fundo + #1163, #3072
  static Fundo + #1164, #3072
  static Fundo + #1165, #3072
  static Fundo + #1166, #3072
  static Fundo + #1167, #3072
  static Fundo + #1168, #3072
  static Fundo + #1169, #3072
  static Fundo + #1170, #3072
  static Fundo + #1171, #3072
  static Fundo + #1172, #3072
  static Fundo + #1173, #3967
  static Fundo + #1174, #3072
  static Fundo + #1175, #3072
  static Fundo + #1176, #3072
  static Fundo + #1177, #3072
  static Fundo + #1178, #3072
  static Fundo + #1179, #3072
  static Fundo + #1180, #3072
  static Fundo + #1181, #3072
  static Fundo + #1182, #3072
  static Fundo + #1183, #3072
  static Fundo + #1184, #3072
  static Fundo + #1185, #3072
  static Fundo + #1186, #3072
  static Fundo + #1187, #3072
  static Fundo + #1188, #3072
  static Fundo + #1189, #3072
  static Fundo + #1190, #3967
  static Fundo + #1191, #3072
  static Fundo + #1192, #3072
  static Fundo + #1193, #3072
  static Fundo + #1194, #3072
  static Fundo + #1195, #3072
  static Fundo + #1196, #3072
  static Fundo + #1197, #3072
  static Fundo + #1198, #3072
  static Fundo + #1199, #3077

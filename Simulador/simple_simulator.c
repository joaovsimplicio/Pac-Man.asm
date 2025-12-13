// gcc simple_simulator.c -O3 -march=native -o simple_simulator.exe -Wall
/*
   SIMULADOR ICMC

   Desenvolvido por: João Vitor Valerio Simplicio, Tainá Felinto, Maria Eduarda Iwashita
*/

#define TAMANHO_PALAVRA 16
#define TAMANHO_MEMORIA 32768
#define MAX_VAL 65535

#define STATE_RESET 0
#define STATE_FETCH 1
#define STATE_DECODE 2
#define STATE_EXECUTE 3
#define STATE_EXECUTE2 4
#define STATE_HALTED 5

#define sPC 0
#define sMAR 1
#define sM4 2
#define sSP 3
#define sULA 0
#define sDATA_OUT 1
#define sTECLADO 4
#define sM3 1

#define ARITH 2
#define LOGIC 1

#define LOAD 48
#define STORE 49
#define LOADN 56
#define LOADI 60
#define STOREI 61
#define MOV 51
#define OUTCHAR 50
#define INCHAR 53
#define ADD 32
#define SUB 33
#define MULT 34
#define DIV 35
#define INC 36
#define LMOD 37
#define AVG 38
#define LAND 18
#define LOR 19
#define LXOR 20
#define LNOT 21
#define SHIFT 16
#define CMP 22
#define JMP 2
#define CALL 3
#define RTS 4
#define PUSH 5
#define POP 6
#define NOP 0
#define HALT 15
#define SETC 8
#define BREAKP 14

#define NEGATIVE 9
#define STACK_UNDERFLOW 8
#define STACK_OVERFLOW 7
#define DIV_BY_ZERO 6
#define ARITHMETIC_OVERFLOW 5
#define CARRY 4
#define ZERO 3
#define EQUAL 2
#define LESSER 1
#define GREATER 0

#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>

#if defined(_WIN32) || defined(_WIN64)
#include <conio.h>
#include <windows.h>
int kbhit_linux(void) { return _kbhit(); }
#else
#include <termios.h>
#include <unistd.h>
#include <fcntl.h>
int kbhit_linux(void) {
    struct termios oldt, newt;
    int ch, oldf;
    tcgetattr(STDIN_FILENO, &oldt);
    newt = oldt;
    newt.c_lflag &= ~(ICANON | ECHO);
    tcsetattr(STDIN_FILENO, TCSANOW, &newt);
    oldf = fcntl(STDIN_FILENO, F_GETFL, 0);
    fcntl(STDIN_FILENO, F_SETFL, oldf | O_NONBLOCK);
    ch = getchar();
    tcsetattr(STDIN_FILENO, TCSANOW, &oldt);
    fcntl(STDIN_FILENO, F_SETFL, oldf);
    if (ch != EOF) { ungetc(ch, stdin); return 1; }
    return 0;
}
#endif

unsigned int MEMORY[TAMANHO_MEMORIA];
int reg[8];
int FR[16] = {0};

typedef struct {
    unsigned int result;
    unsigned int auxFR;
} ResultadoUla;

void le_arquivo(void);
int processa_linha(char* linha);
int pega_pedaco(int ir, int a, int b);
unsigned int _rotl_fixed(const unsigned int value, int shift);
unsigned int _rotr_fixed(const unsigned int value, int shift);
ResultadoUla ULA(unsigned int x, unsigned int y, unsigned int OP, int carry);

int teste_avg_executado = 0;

/* Função principal: executa o simulador e controla o ciclo de instruções */
int main() {
    int i = 0, key = 0;
    int PC = 0, IR = 0, SP = 0, MAR = 0, rx = 0, ry = 0, rz = 0, COND = 0, RW = 0, DATA_OUT = 0;
    int LoadPC = 0, IncPC = 0, LoadIR = 0, LoadSP = 0, IncSP = 0, DecSP = 0, LoadMAR = 0, LoadFR = 0;
    int M1 = 0, M2 = 0, M3 = 0, M4 = 0, M5 = 0, M6 = 0;
    int selM1 = 0, selM2 = 0, selM3 = 0, selM4 = 0, selM5 = 0, selM6 = 0;
    int LoadReg[8] = {0};
    int carry = 0, opcode = 0, temp = 0;
    unsigned char state = 0;
    int OP = 0;
    int TECLADO;
    ResultadoUla resultadoUla;

    le_arquivo();

inicio:
    printf("PROCESSADOR ICMC  - Menu:\n");
    printf("                          'r' goto inicio...\n");
    printf("                          'q' goto fim...\n\n");
    printf("Rodando...\n");

    state = STATE_RESET;
    teste_avg_executado = 0;

loop:
    if (LoadIR) IR = DATA_OUT;
    if (LoadPC) PC = DATA_OUT;
    if (IncPC) PC++;
    if (LoadMAR) MAR = DATA_OUT;
    if (LoadSP) SP = M4;
    if (IncSP) SP++;
    if (DecSP) SP--;

    if (LoadFR)
        for (i = 16; i--;) FR[i] = pega_pedaco(M6, i, i);

    rx = pega_pedaco(IR, 9, 7);
    ry = pega_pedaco(IR, 6, 4);
    rz = pega_pedaco(IR, 3, 1);

    if (LoadReg[rx]) reg[rx] = M2;
    if (RW == 1) MEMORY[M1] = M5;

    for (i = 0; i < 8; i++) LoadReg[i] = 0;
    RW = 0;
    LoadIR = LoadMAR = LoadPC = IncPC = 0;
    LoadSP = IncSP = DecSP = LoadFR = 0;

    switch (state) {
        case STATE_RESET:
            for (i = 0; i < 8; i++) reg[i] = 0;
            for (i = 0; i < 16; i++) FR[i] = 0;
            PC = IR = MAR = 0;
            SP = TAMANHO_MEMORIA - 1;
            RW = DATA_OUT = 0;
            selM1 = sPC; selM2 = sDATA_OUT; selM3 = 0; selM4 = 0; selM5 = sM3; selM6 = sULA;
            state = STATE_FETCH;
            break;
        case STATE_FETCH:
            selM1 = sPC; RW = 0; LoadIR = 1; IncPC = 1;
            state = STATE_DECODE;
            break;
        case STATE_DECODE:
            opcode = pega_pedaco(IR, 15, 10);
            switch (opcode) {
                case INCHAR:
                    TECLADO = kbhit_linux() ? getchar() : 255;
                    TECLADO = pega_pedaco(TECLADO, 7, 0);
                    selM2 = sTECLADO; LoadReg[rx] = 1;
                    state = STATE_FETCH;
                    break;
                case OUTCHAR:
                    printf("%c", reg[rx]);
                    state = STATE_FETCH;
                    break;
                case LOADN:
                    selM1 = sPC; RW = 0; selM2 = sDATA_OUT; LoadReg[rx] = 1; IncPC = 1;
                    state = STATE_FETCH;
                    break;
                case LOAD:
                case STORE:
                    selM1 = sPC; RW = 0; LoadMAR = 1; IncPC = 1;
                    state = STATE_EXECUTE;
                    break;
                case LOADI:
                    selM4 = ry; selM1 = sM4; RW = 0; selM2 = sDATA_OUT; LoadReg[rx] = 1;
                    state = STATE_FETCH;
                    break;
                case STOREI:
                    selM4 = rx; selM1 = sM4; RW = 1; selM3 = ry; selM5 = sM3;
                    state = STATE_FETCH;
                    break;
                case MOV:
                    selM4 = ry; selM2 = sM4; LoadReg[rx] = 1;
                    state = STATE_FETCH;
                    break;
                case ADD: case SUB: case MULT: case DIV: case LMOD: case AVG:
                case LAND: case LOR: case LXOR: case LNOT:
                    selM3 = ry; selM4 = rz;
                    if (opcode == AVG) { selM3 = rx; selM4 = ry; }
                    OP = opcode; carry = pega_pedaco(IR, 0, 0);
                    selM2 = sULA; LoadReg[rx] = 1; selM6 = sULA; LoadFR = 1;
                    state = STATE_FETCH;
                    break;
                case INC:
                    selM3 = rx; selM4 = 8;
                    OP = (pega_pedaco(IR, 6, 6) == 0) ? ADD : SUB;
                    carry = 0; selM2 = sULA; LoadReg[rx] = 1; selM6 = sULA; LoadFR = 1;
                    state = STATE_FETCH;
                    break;
                case CMP:
                    selM3 = rx; selM4 = ry; OP = pega_pedaco(IR, 15, 10);
                    carry = 0; selM6 = sULA; LoadFR = 1;
                    state = STATE_FETCH;
                    break;
                case SHIFT:
                    switch (pega_pedaco(IR, 6, 4)) {
                        case 0: reg[rx] <<= pega_pedaco(IR, 3, 0); break;
                        case 1: reg[rx] = ~((~reg[rx]) << pega_pedaco(IR, 3, 0)); break;
                        case 2: reg[rx] >>= pega_pedaco(IR, 3, 0); break;
                        case 3: reg[rx] = ~((~reg[rx]) >> pega_pedaco(IR, 3, 0)); break;
                        default:
                            if (pega_pedaco(IR, 6, 5) == 2)
                                reg[rx] = _rotl_fixed(reg[rx], pega_pedaco(IR, 3, 0));
                            else
                                reg[rx] = _rotr_fixed(reg[rx], pega_pedaco(IR, 3, 0));
                    }
                    FR[3] = (reg[rx] == 0);
                    state = STATE_FETCH;
                    break;
                case JMP:
                case CALL:
                    COND = pega_pedaco(IR, 9, 6);
                    if ((COND == 0) || (FR[0] && COND == 7)) {
                        if (opcode == CALL) {
                            RW = 1; selM1 = sSP; selM5 = sPC; DecSP = 1;
                            state = STATE_EXECUTE;
                        } else {
                            selM1 = sPC; RW = 0; LoadPC = 1;
                            state = STATE_FETCH;
                        }
                    } else {
                        IncPC = 1; state = STATE_FETCH;
                    }
                    break;
                case PUSH:
                    selM1 = sSP; RW = 1;
                    selM3 = (pega_pedaco(IR, 6, 6) == 0) ? rx : 8;
                    selM5 = sM3; DecSP = 1;
                    state = STATE_FETCH;
                    break;
                case POP:
                case RTS:
                    IncSP = 1; state = STATE_EXECUTE;
                    break;
                case SETC:
                    FR[4] = pega_pedaco(IR, 9, 9); state = STATE_FETCH;
                    break;
                case HALT:
                    state = STATE_HALTED;
                    break;
                default:
                    state = STATE_FETCH;
                    break;
            }
            break;
        case STATE_EXECUTE:
            switch (opcode) {
                case LOAD:
                    selM1 = sMAR; RW = 0; selM2 = sDATA_OUT; LoadReg[rx] = 1; state = STATE_FETCH; break;
                case STORE:
                    selM3 = rx; selM5 = sM3; selM1 = sMAR; RW = 1; state = STATE_FETCH; break;
                case CALL:
                    selM1 = sPC; RW = 0; LoadPC = 1; state = STATE_FETCH; break;
                case POP:
                    selM1 = sSP; RW = 0;
                    if (pega_pedaco(IR, 6, 6) == 0) { selM2 = sDATA_OUT; LoadReg[rx] = 1; }
                    else { selM6 = sDATA_OUT; LoadFR = 1; }
                    state = STATE_FETCH; break;
                case RTS:
                    selM1 = sSP; RW = 0; LoadPC = 1; state = STATE_EXECUTE2; break;
            }
            break;
        case STATE_EXECUTE2:
            IncPC = 1; state = STATE_FETCH;
            break;
        case STATE_HALTED:
            if (!teste_avg_executado) {
                reg[0] = 80;
                reg[1] = 82;
                ResultadoUla teste = ULA(reg[0], reg[1], AVG, 0);
                if (teste.result == 81) printf("%c", (char)teste.result);
                teste_avg_executado = 1;
            }
            printf("\n");
            key = getchar();
            if (key == 'r') goto inicio;
            if (key == 'q') goto fim;
            break;
    }

    if (selM4 == 8) M4 = 1; else M4 = reg[selM4];
    if (selM1 == sPC) M1 = PC; else if (selM1 == sMAR) M1 = MAR; else if (selM1 == sM4) M1 = M4; else if (selM1 == sSP) M1 = SP;

    if (M1 > TAMANHO_MEMORIA) { printf("Ultrapassou limite da memoria\n"); exit(1); }

    if (RW == 0) DATA_OUT = MEMORY[M1];

    temp = 0;
    for (i = 16; i--;) if (FR[i]) temp += (1 << i);

    if (selM3 == 8) M3 = temp; else M3 = reg[selM3];
    resultadoUla = ULA(M3, M4, OP, carry);

    if (selM2 == sULA) M2 = resultadoUla.result;
    else if (selM2 == sDATA_OUT) M2 = DATA_OUT;
    else if (selM2 == sM4) M2 = M4;
    else if (selM2 == sSP) M2 = SP;

    if (selM5 == sPC) M5 = PC; else if (selM5 == sM3) M5 = M3;
    if (selM6 == sULA) M6 = resultadoUla.auxFR; else if (selM6 == sDATA_OUT) M6 = DATA_OUT;

    goto loop;

fim:
    return 0;
}

/* Carrega o arquivo cpuram.mif para a memória do simulador */
void le_arquivo(void) {
    FILE *stream;
    int i, j, processando = 0;
    char linha[110];
    if ((stream = fopen("cpuram.mif", "r")) == NULL) exit(1);
    j = 0;
    while (fscanf(stream, "%s", linha) != EOF) {
        char letra[2] = "00";
        if (!processando) {
            i = 0;
            do {
                letra[0] = letra[1]; letra[1] = linha[i];
                if (letra[0] == '0' && letra[1] == ':') { processando = 1; j = 0; }
                i++;
            } while (linha[i] != '\0');
        }
        if (processando && j < TAMANHO_MEMORIA) {
            MEMORY[j++] = processa_linha(linha);
        }
    }
    fclose(stream);
}

/* Converte uma linha binária do arquivo .mif em um valor inteiro */
int processa_linha(char* linha) {
    int i = 0, j, valor = 0;
    while (linha[i] != ':') { if (linha[i] == 0) return -1; i++; }
    for (j = 0; j < 16; j++) { valor <<= 1; valor += linha[i + j + 1] - '0'; }
    return valor;
}

/* Extrai um intervalo de bits de um inteiro */
int pega_pedaco(int ir, int a, int b) {
    int pedaco = ((1 << (a - b + 1)) - 1);
    return pedaco & (ir >> b);
}

/* Realiza rotação de bits à esquerda */
unsigned int _rotl_fixed(const unsigned int value, int shift) {
    if ((shift &= 16 * 8 - 1) == 0) return value;
    return (value << shift) | (value >> (16 * 8 - shift));
}

/* Realiza rotação de bits à direita */
unsigned int _rotr_fixed(const unsigned int value, int shift) {
    if ((shift &= 16 * 8 - 1) == 0) return value;
    return (value >> shift) | (value << (16 * 8 - shift));
}

/* Unidade Lógica e Aritmética: executa operações e atualiza flags */
ResultadoUla ULA(unsigned int x, unsigned int y, unsigned int OP, int carry) {
    unsigned int auxFRbits[16] = {0};
    unsigned int result = 0;
    switch (pega_pedaco(OP, 5, 4)) {
        case ARITH:
            switch (OP) {
                case ADD:
                    result = carry ? x + y + FR[CARRY] : x + y;
                    if (result > MAX_VAL) { auxFRbits[CARRY] = 1; result -= MAX_VAL; }
                    break;
                case SUB:
                    result = x - y;
                    if ((int)result < 0) auxFRbits[NEGATIVE] = 1;
                    break;
                case MULT:
                    result = x * y;
                    if (result > MAX_VAL) auxFRbits[ARITHMETIC_OVERFLOW] = 1;
                    break;
                case DIV:
                    if (y == 0) { result = 0; auxFRbits[DIV_BY_ZERO] = 1; }
                    else result = x / y;
                    break;
                case LMOD:
                    if (y == 0) { result = 0; auxFRbits[DIV_BY_ZERO] = 1; }
                    else result = x % y;
                    break;
                case AVG:
                    //FUNÇÃO NOVA
                    result = (x + y) >> 1;
                    break;
                default:
                    result = x;
            }
            if (result == 0) auxFRbits[ZERO] = 1;
            break;
        case LOGIC:
            if (OP == CMP) {
                result = x;
                if (x > y) auxFRbits[GREATER] = 1;
                else if (x < y) auxFRbits[LESSER] = 1;
                else auxFRbits[EQUAL] = 1;
            } else {
                switch (OP) {
                    case LAND: result = x & y; break;
                    case LXOR: result = x ^ y; break;
                    case LOR: result = x | y; break;
                    case LNOT: result = ~x & MAX_VAL; break;
                    default: result = x;
                }
                if (result == 0) auxFRbits[ZERO] = 1;
            }
            break;
    }
    unsigned int auxFR = 0;
    for (int i = 16; i--;) if (auxFRbits[i]) auxFR += (1 << i);
    ResultadoUla r = { result, auxFR };
    return r;
}

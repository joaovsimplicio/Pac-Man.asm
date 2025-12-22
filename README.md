# Pac-Man.asm
Clone completo do jogo Pac-Man desenvolvido em Assembly para o Simulador do ICMC-USP. Conta com um mecanismo de movimentação dos inimigos, geração de mapas aleatórios e sistema de colisão.

# Pac-Man em Assembly (Simulador ICMC)

Uma recriação funcional do clássico **Pac-Man**, desenvolvida inteiramente em **Assembly** para a arquitetura do processador do Simulador ICMC (USP).

O projeto implementa lógicas de movimentação para inimigos e manipulação de vídeo de baixo nível.


## ✨ Funcionalidades

* **6 Fantasmas:** Os inimigos utilizam um algoritmo de *Busca Gulosa* (Greedy Search) para perseguir o jogador, alternando com movimentos aleatórios e de "fuga" para evitar ficarem presos em cantos.
* **Geração Procedural de Pontos:** A cada nova partida, os 10 pontos de vitória são espalhados aleatoriamente pelo mapa, garantindo que nenhum jogo seja igual ao outro.
* **RNG Baseado em Input:** Sistema de geração de números aleatórios (RNG) baseado no tempo de resposta do jogador na tela inicial.
* **Sistema de Colisão e Física:** Detecção precisa de paredes, limites do mapa e interação entre sprites.
* **Ciclo de Jogo Completo:** Telas de Início, Vitória e Game Over com reinício automático e limpeza de memória.

## 🚀 Como Executar

1.  Abra o **Simulador ICMC**.
2.  Carregue o arquivo `pacman.asm`.
3.  Monte o código (f7) e carregue na memória(Home).
4.  Execute e divirta-se!

## 🎮 Controles

* **W / A / S / D**: Movimentação do Pac-Man.
* **ENTER**: Iniciar ou Reiniciar o jogo.

## 🛠️ Desafios Técnicos Superados

* Implementação de algoritmos de decisão com instruções de Assembly.
* Manipulação direta da memória de vídeo para renderização de sprites e mapas.
* Gerenciamento de pilha (Stack) para chamadas de função recursivas e aninhadas.
* Criação de lógica de *debounce* para leitura de teclado.

## 📷 Screenshots
<img width="810" height="630" alt="Captura de tela 2025-12-09 225751" src="https://github.com/user-attachments/assets/4bd15a95-9812-420a-9198-83f6bddac35f" />

---
Desenvolvido por [João Vitor Valerio Simplicio, Tainá Felinto, Maria Eduarda Iwashita] - Sistemas de Informação (USP)

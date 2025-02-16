# Four Up (Connect 4) - Assembly Implementation

## Introduction
This project is a **two-player Connect 4 game** implemented in **Assembly language**. The objective is to connect **four symbols in a row** either horizontally, vertically, or diagonally on a grid-based board. The game supports **win and draw detection** with efficient memory management.

## Technologies Used
- **Programming Language**: Assembly  
- **Board Representation**: Grid-based memory management  
- **Win/Draw Detection**: Implemented using efficient logical checks  

## Game Rules
1. Two players choose a symbol and take turns.
2. Players drop their selected symbol from the top of any of the **seven columns** by pressing keys `1-7`.
3. The symbol fills the lowest available row in that column.
4. The game continues until:
   - A player **connects four symbols** (Win).
   - The board is **full** with no winner (Draw).

## Implementation Details
- **Grid Representation**: The board is stored as a 2D array in memory.
- **Efficient Checking**: Logical conditions check for four-in-a-row matches.
- **Input Handling**: Player inputs are processed through keyboard interrupts.
- **Optimized Memory Use**: The program efficiently manages board updates.

## How to Run
1. Assemble the code using an **x86 Assembly assembler** (NASM, MASM, etc.).
2. Load and execute the program in a compatible emulator or system.
3. Follow on-screen instructions to play.

## Future Enhancements
- Add a **single-player mode** with an AI opponent.
- Implement **graphical rendering** for a better user experience.
- Optimize logic for **faster execution**.

## Conclusion
This project showcases an **efficient Assembly-based Connect 4 game**, demonstrating **low-level programming techniques** and **memory-efficient game logic**. 

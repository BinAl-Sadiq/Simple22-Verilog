/*Sizes & Counts*/
`define IMEMSIZE 1000/*The count of instructions at the instructions memory*/
`define ISIZE 32/*instruction size*/
`define RAMSIZE 1000/*The count of words at RAM memory*/
`define WSIZE 32/*Word size*/
`define RSIZE 32/*Registers' size*/

/*Opcodes*/
`define ADD 5'b00000/*add GPRn0 GPRn1 GPRn2 >> GPRn0 = GPRn1 + GPRn2*/
`define SUB 5'b00001/*sub GPRn0 GPRn1 GPRn2 >> GPRn0 = GPRn1 - GPRn2*/
`define MUL 5'b00010/*mul GPRn0 GPRn1 GPRn2 >> GPRn0 = GPRn1 * GPRn2*/
`define DIV 5'b00011/*div GPRn0 GPRn1 GPRn2 >> GPRn0 = int(GPRn1 / GPRn2)*/
`define STORE 5'b00100/*store a word into RAM at address sp from a register >> store GPRn*/
`define LOAD 5'b00101/*load a word from RAM at address sp to a register >> load GPRn*/
`define SET 5'b00110/*Set immediate to a register >> set GPRn 289*/
`define INT 5'b00111/*Interrupt >> int 15*/
`define SPECIAL_GET 5'b01000/*special_get GPRn special_register*/
`define SPECIAL_SET 5'b01001/*special_set special_register GPRn*/
`define EXIT 5'b11111

# comp310 Constrained development task

Student number: 1607539

Github repository: https://github.com/Stompyy/THPSDemake

## NES demake of _Tony Hawks Pro Skater_ for the 6502 processor written in assembly language

Controls are shown after the title screen.

FCEUX controls emulated on a keyboard are:
* Start		- Enter
* A		- F key
* B		- G key (Hold down in air to grind the ledge)
* directions 	- arrow keys

Cloud images at the top are randomly generated with decreasing probability going downwards. In stateMachine.asm there is a commented section which instructs the line to amend if you want a full background of 0.5 probability cloud tiles.

Pseudo random number generator is seeded from a title screen timer (used to flash the press start message so 0-10 seed).

I was so close to getting marching squares working! Had to spread my time between this and dissertation work though, else I would have got it definitely.

Traffic cones trip you up. _A_ will jump out of a grind. You will fall if landing while mid trick. Tap right to speed up. If you've played Tony Hawks Pro Skater before then you will know the gameplay aspects to expect.

Works brilliantly on the actual NES hardware with the EverDrive SD cartridge before the NES's chip went a bit loose...

Opposing game background loads in as you look at the other nametable.

In variables you can see a *PlayerState* byte where each bit is a flag, e.g. is_grounded, is_grinding etc. Have chosen to revert back to using individual byte addresses as booleans with a 0-1 flag for readability and maintainability. I had the spare memory to use so in those interests have decided to aim for coherency. You will see how this *playerState* byte would be implemented in the variables.asm, commented section describing implementation, jest below where it is declared.

Konami code was an overscope...

### Compiling if necessary

To compile from source, open a powershell window (shift + mouse right button, halfway down in menu) in the folder where the comp310.asm is found.
Use command:

.\tools\nesasm_win32\nesasm.exe .\comp310.asm

to build a file named comp310.nes which can then be opened as a rom in a NES emulator such as FCEUX.

compiled file is also included in this .zip

VHDL Implementation of the classic game Pong

Works for Altera FPGA Flex10K Device Family
	Specific Device in family: EPF10K70RC240-4

User Interface:
	Display: VGA with 1280x1024 resolution
	Keyboard: PS2
		'Up' and 'Down' arrow keys are Player 1 paddle controls
		'W' and 'S' keys are Player 2 paddle controls when in Multiplayer Mode
	Pushbuttons and FLEX switch on FPGA board:
		PB2 : Resets game to initial state
		PB1 : Resets game and score to initial state
		FLEX switch 0:
			DOWN Position: AI Mode
			UP Position: Multiplayer Mode

Game Play:
	Objective is to avoid letting the ball hit your side of the screen. When the
	ball hits the edge of the screen, the colors invert until you hit either PB1
	or PB2. 

Future Additions/Bug Fixes:
	1. Make AI beatable
	2. Varied speed and projectile of ball depending on the angle it strikes one of the paddles
	3. Fix minor collision issue: collisions at very top and bottom edges of paddles
	4. Implement similar game Brick smash and allow player to pick either Pong or Brick Smash
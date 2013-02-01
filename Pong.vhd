-- Caroline Lichtenberger
-- Date: 1/20/13
-- Description: FPGA Pong main interface

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
LIBRARY WORK;
USE WORK.up1core.ALL;

ENTITY Pong IS
	PORT(
		-- VGA interface signals
		SIGNAL Clock		 					: IN STD_LOGIC; 
        SIGNAL Red,Green,Blue 					: OUT STD_LOGIC;
        SIGNAL Horiz_sync, Vert_sync			: OUT STD_LOGIC;
		-- Keyboard signals
		SIGNAL kb_clk, kb_data					: IN STD_LOGIC;
		SIGNAL RST								: IN STD_LOGIC;
		SIGNAL Score_RST						: IN STD_LOGIC;
		SIGNAL Multiplayer						: IN STD_LOGIC
	);
END Pong;

ARCHITECTURE beh OF Pong IS

COMPONENT keyboard IS
	PORT(
		keyboard_clk, keyboard_data, clock_25Mhz , 
		reset, read		: IN	STD_LOGIC;
		scan_code		: OUT	STD_LOGIC_VECTOR(7 DOWNTO 0);
		scan_ready		: OUT	STD_LOGIC
	);
END COMPONENT;

COMPONENT Seven_Segment_disp IS
	PORT(
		SIGNAL Clock		 				: IN STD_LOGIC;
        SIGNAL MSByte, LSByte				: IN STD_LOGIC_VECTOR(3 DOWNTO 0);             
        SIGNAL Red,Green,Blue 				: OUT STD_LOGIC;
        SIGNAL pixel_row, pixel_column		: IN STD_LOGIC_VECTOR(10 DOWNTO 0)
	);
END COMPONENT;

-- Video Display Signals   
SIGNAL Red_Data, Green_Data, Blue_Data, vert_sync_int,
		main_red,main_blue,main_green									: STD_LOGIC;
SIGNAL Size 															: STD_LOGIC_VECTOR(9 DOWNTO 0);  
SIGNAL Ball_Y_motion, Ball_X_motion 									: STD_LOGIC_VECTOR(9 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(2,10);
SIGNAL Ball_Y_pos														: STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(240, 11);
SIGNAL Ball_X_pos														: STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(320, 11);
SIGNAL Left_PaddleX_pos													: STD_LOGIC_VECTOR(10 DOWNTO 0);
SIGNAL Left_PaddleY_pos													: STD_LOGIC_VECTOR(10 DOWNTO 0) := CONV_STD_LOGIC_VECTOR(240, 11);
SIGNAL pixel_row, pixel_column											: STD_LOGIC_VECTOR(10 DOWNTO 0);
SIGNAL Right_PaddleX_pos, Right_PaddleY_pos								: STD_LOGIC_VECTOR(10 DOWNTO 0);
SIGNAL DirLeftY,DirRightY												: STD_LOGIC_VECTOR(9 DOWNTO 0);

-- Keyboard Signals
SIGNAL sRead, sScan_ready, u_flag, d_flag, multi_d, multi_u				: STD_LOGIC;
SIGNAL sScan_code														: STD_LOGIC_VECTOR(7 DOWNTO 0);

-- Misc. Signals
SIGNAL update_f															: STD_LOGIC;
SIGNAL score_player, score_opp											: STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL red_input, green_input, blue_input								: STD_LOGIC;

-- FSM states
TYPE state IS (initialState, stateOn, stateOff, multi_state_off);
SIGNAL current_state	:	state;

BEGIN           

	SYNC: vga_sync
 		PORT MAP(clock_25Mhz => clock, 
				red => main_red, green => main_green, blue => main_blue,	
    	     	red_out => red, green_out => green, blue_out => blue,
			 	horiz_sync_out => horiz_sync, vert_sync_out => vert_sync_int,
			 	pixel_row => pixel_row, pixel_column => pixel_column);
	KB: keyboard
		PORT MAP(
			keyboard_clk 	=> kb_clk,
			keyboard_data	=> kb_data,
			clock_25Mhz		=> clock,
			reset			=> RST,
			read			=> sRead,
			scan_code		=> sScan_code,
			scan_ready		=> sScan_ready	);
	
	ScoreDisp: Seven_Segment_Disp
		PORT MAP(
			Clock => Clock,
			MSByte => score_player, 
			LSByte => score_opp,             
			Red => Red_input,
			Green => Green_input,
			Blue => Blue_input,
			pixel_row => pixel_row, 
			pixel_column => pixel_column
		);

main_red <= Red_input OR Red_Data;
main_blue <= blue_input OR blue_data;
main_green <= green_input OR green_data;

-- Determines pixel sizing for display components; allows for scalability
Size <= CONV_STD_LOGIC_VECTOR(4,10);

-- need internal copy of vert_sync to read
vert_sync <= vert_sync_int;

-- ************************************************************************************************************************************************

-- Begin Processes

-- ************************************************************************************************************************************************
-- Display Process
-- ************************************************************************************************************************************************
RGB_Display: PROCESS (Ball_X_pos, Ball_Y_pos, Left_PaddleX_pos, Left_PaddleY_pos, Right_PaddleX_pos, Right_PaddleY_pos, pixel_column, pixel_row,
						Size)
						
	VARIABLE Ball_on, Left_Paddle, Right_Paddle : STD_LOGIC := '0'; 

BEGIN
		
	IF (('0' & Ball_X_pos) >= CONV_STD_LOGIC_VECTOR(639,11) - Size OR Ball_X_pos <= Size) THEN
		IF(RST /= '0') THEN
			-- Set Ball_on ='1' to display ball
			IF ('0' & Ball_X_pos <= pixel_column + Size) AND
				(Ball_X_pos + Size >= '0' & pixel_column) AND
				('0' & Ball_Y_pos <= pixel_row + Size) AND
				(Ball_Y_pos + Size >= '0' & pixel_row ) THEN
					Ball_On := '1';
					Red_data <= NOT Ball_On;
					Blue_Data <= NOT Ball_On;
					Green_Data <= NOT Ball_On;
			-- Display left paddle
			ELSIF ('0' & Left_PaddleX_pos <= pixel_column + Size) AND
				(Left_PaddleX_pos + Size >= '0' & pixel_column-size) AND
				('0' & Left_PaddleY_pos <= pixel_row +Size+ size +size+size+size) AND
				(Left_PaddleY_pos + Size >= '0' & pixel_row-size-size-size-size-size) THEN
					Left_Paddle := '1';
					Green_Data <= NOT Left_Paddle;
					Blue_Data <= NOT Left_Paddle;
					Red_Data <= NOT Left_Paddle;
	
			-- Display right paddle
			ELSIF ('0' & Right_PaddleX_pos <= pixel_column + Size) AND
				(Right_PaddleX_pos + Size >= '0' & pixel_column-size) AND
				('0' & Right_PaddleY_pos <= pixel_row +Size+ size +size+size+size) AND
				(Right_PaddleY_pos + Size >= '0' & pixel_row-size-size-size-size-size) THEN
					Right_Paddle := '1';
					Blue_Data <= NOT Right_Paddle;
					Green_Data <= NOT Right_Paddle;
					Red_Data <= NOT Right_Paddle;
			ELSE
				Blue_data <= '1';
				Green_data <= '1';
				Red_data <= '1';
			END IF;
		END IF;
	ELSE
	-- Set Ball_on ='1' to display ball
	IF ('0' & Ball_X_pos <= pixel_column + Size) AND
		(Ball_X_pos + Size >= '0' & pixel_column) AND
		('0' & Ball_Y_pos <= pixel_row + Size) AND
		(Ball_Y_pos + Size >= '0' & pixel_row ) THEN
			Ball_On := '1';
			Red_data <= Ball_On;
			Blue_Data <= NOT Ball_On;
			Green_Data <= NOT Ball_On;
	
	-- Display left paddle
	ELSIF (('0' & Left_PaddleX_pos <= pixel_column + Size) AND
 	(Left_PaddleX_pos + Size >= '0' & pixel_column-size) AND
 	('0' & Left_PaddleY_pos <= pixel_row +Size+ size +size+size+size) AND
 	(Left_PaddleY_pos + Size >= '0' & pixel_row-size-size-size-size-size)) THEN
 		Left_Paddle := '1';
 		Green_Data <= Left_Paddle;
 		Blue_Data <= NOT Left_Paddle;
 		Red_Data <= NOT Left_Paddle;
	
	-- Display right paddle
	ELSIF (('0' & Right_PaddleX_pos <= pixel_column + Size) AND
 	(Right_PaddleX_pos + Size >= '0' & pixel_column-size) AND
 	('0' & Right_PaddleY_pos <= pixel_row +Size+ size +size+size+size) AND
 	(Right_PaddleY_pos + Size >= '0' & pixel_row-size-size-size-size-size)) THEN
 		Right_Paddle := '1';
 		Blue_Data <= Right_Paddle;
 		Green_Data <= NOT Right_Paddle;
 		Red_Data <= NOT Right_Paddle;
 		
 	ELSE
		Blue_data <= '0';
		Red_data <= '0';
		Green_Data <= '0';
	END IF;
END IF;
	
END PROCESS RGB_Display;

-- ************************************************************************************************************************************************
-- Keyboard Process
-- ************************************************************************************************************************************************

KeyScan : PROCESS(current_state, RST, sRead, sScan_ready, sScan_code, clock)
BEGIN
	
	IF (RST = '0') THEN
		-- Reset button pushed; active low
		u_flag <= '0';
		d_flag <= '0';
		sRead <= '0';
		current_state <= initialState;
	ELSE
	 IF(clock'EVENT AND clock = '1') THEN
		IF(sScan_ready = '1') THEN
			sRead <= '1';
		CASE current_state IS
			WHEN initialState =>
				-- Is E0 received?
				IF(sScan_code = "11100000") THEN
					current_state <= stateOn;
				ELSIF (sScan_code = "00011101") THEN
					multi_u <= '1';
					current_state <= initialState;
				ELSIF (sScan_code = "00011011") THEN
					multi_d <= '1';
					current_state <= initialState;
				ELSIF (sScan_code = "11110000") THEN
					current_state <= multi_state_off;
				ELSE
					current_state <= initialState;
				END IF;
			WHEN multi_state_off =>
				IF(sScan_code = "00011101") THEN
					multi_u <= '0';
					current_state <= initialState;
				ELSIF (sScan_code = "00011011") THEN
					multi_d <= '0';
					current_state <= initialState;
				ELSE
					current_state <= initialState;
				END IF;
			WHEN stateOn =>
				-- MSb first
				IF(sScan_code = "01110101") THEN
					-- Up arrow key pressed
					u_flag <= '1';
					current_state <= initialState;
				ELSIF(sScan_code = "01110010") THEN
					-- Down arrow key pressed
					d_flag <= '1';
					current_state <= initialState;
				ELSIF(sScan_code = "11110000") THEN
					-- Break code; go to off state
					current_state <= stateOff;
				ELSE
					-- Irrelevant key pressed; go to initial state
					current_state <= initialState;
				END IF;
			
			WHEN stateOff =>
				IF(sScan_code = "01110101") THEN
					-- Up arrow key released
					u_flag <= '0';
					current_state <= initialState;
				ELSIF(sScan_code = "01110010") THEN
					-- Down arrow key released
					d_flag <= '0';
					current_state <= initialState;
				ELSE
					-- Irrelevant key pressed; go to initial state
					current_state <= initialState;
				END IF;
			END CASE;
		ELSE
			sRead <= '0';
		END IF;
	 END IF;
	END IF;
END PROCESS KeyScan;

-- ************************************************************************************************************************************************
-- Motion Process
-- ************************************************************************************************************************************************
Move_Ball: PROCESS (RST, vert_sync_int)
BEGIN
	-- Move ball once every vertical sync
			
			IF (RST = '0') THEN
				-- Active low reset
				update_f <= '1';
				Ball_X_pos <= CONV_STD_LOGIC_VECTOR(320, 11);
				Ball_Y_pos <= CONV_STD_LOGIC_VECTOR(240, 11);
				Ball_X_motion <= CONV_STD_LOGIC_VECTOR(2,10);
				Ball_Y_motion <= CONV_STD_LOGIC_VECTOR(2,10);
				
			ELSIF (Score_RST = '0') THEN
				score_player <= "0000";
				score_opp <= "0000";
				Ball_X_pos <= CONV_STD_LOGIC_VECTOR(320, 11);
				Ball_Y_pos <= CONV_STD_LOGIC_VECTOR(240, 11);
				Ball_X_motion <= CONV_STD_LOGIC_VECTOR(2,10);
				Ball_Y_motion <= CONV_STD_LOGIC_VECTOR(2,10);
				
			ELSIF (vert_sync_int'EVENT AND vert_sync_int = '1') THEN
				-- Bounce off top or bottom of screen
				-- Horizontal ball movement
				IF (('0' & Ball_X_pos) >= CONV_STD_LOGIC_VECTOR(639,11) - Size AND update_f = '1') THEN
					score_player <= score_player + "0001";
					update_f <= '0';
					IF(RST /= '0') THEN
						Ball_X_motion <= CONV_STD_LOGIC_VECTOR(0,10);
						Ball_Y_motion <= CONV_STD_LOGIC_VECTOR(0,10);
					END IF;
				ELSIF ((Ball_X_pos <= Size) AND update_f = '1') THEN
					score_opp <= score_opp + "0001";
					update_f <= '0';
					IF(RST /= '0') THEN
						Ball_X_motion <= CONV_STD_LOGIC_VECTOR(0,10);
						Ball_Y_motion <= CONV_STD_LOGIC_VECTOR(0,10);
					END IF;
				END IF;
			
				-- Vertical ball movement
				IF(('0' & Ball_Y_pos) >= CONV_STD_LOGIC_VECTOR(479,10) - Size) THEN
					Ball_Y_motion <= - CONV_STD_LOGIC_VECTOR(2,10);
				ELSIF (Ball_Y_pos <= Size) THEN
					Ball_Y_motion <= CONV_STD_LOGIC_VECTOR(2,10);
				END IF;
			
				-- Collision for left paddle
				IF (Ball_X_pos-Size <= Left_PaddleX_pos + Size+size+size) THEN 
					IF(Ball_Y_pos+Size >= Left_PaddleY_pos - Size- Size-size-size AND Ball_Y_pos-Size <= Left_PaddleY_pos+Size+Size+size+size) THEN
						Ball_X_motion <= CONV_STD_LOGIC_VECTOR(2,10);
					END IF;
				END IF;
			
				-- Collision for right paddle
				IF(Ball_X_pos + Size >= Right_PaddleX_pos -size-size) THEN
					IF(Ball_Y_pos - size >= Right_PaddleY_pos - size- size AND Ball_Y_pos+size <= Right_paddleY_pos +size +size+size) THEN
						Ball_X_motion <= - CONV_STD_LOGIC_VECTOR(2,10);
					END IF;
				END IF;
				-- Compute next ball position
				Ball_X_pos <= Ball_X_pos + Ball_X_motion;
				Ball_Y_pos <= Ball_Y_pos + Ball_Y_motion;
			END IF;
			
END PROCESS Move_Ball;

-- Left paddle movement
Move_Left_Paddle: PROCESS
BEGIN
	-- Move left paddle once every vertical sync
	WAIT UNTIL vert_sync_int'EVENT AND vert_sync_int = '1';
	
	IF(u_flag = '1' AND d_flag = '0') THEN
		IF(Left_PaddleY_pos <= Size+size+size+size+size) THEN
			DirLeftY <= CONV_STD_LOGIC_VECTOR(0,10);
		ELSE
			DirLeftY <= -CONV_STD_LOGIC_VECTOR(4,10);
		END IF;
	ELSIF(u_flag = '0' AND d_flag = '1') THEN
		IF(('0'& Left_PaddleY_pos) >= CONV_STD_LOGIC_VECTOR(479,10)-Size-size-size-size-size) THEN
			DirLeftY <= CONV_STD_LOGIC_VECTOR(0,10);
		ELSE
			DirLeftY <= CONV_STD_LOGIC_VECTOR(4,10);
		END IF;
	ELSE
		DirLeftY <= CONV_STD_LOGIC_VECTOR(0,10);
	END IF;
	
	-- Update paddle position
	Left_PaddleY_pos <= Left_PaddleY_pos+DirLeftY;
	Left_PaddleX_pos <= CONV_STD_LOGIC_VECTOR(4,11);
END PROCESS Move_Left_Paddle;

-- Right paddle movement
Move_Right_Paddle: PROCESS
BEGIN
	-- Move right paddle once every vertical sync
	WAIT UNTIL vert_sync_int'event and vert_sync_int = '1';
	IF (Multiplayer = '1') THEN
		IF(multi_u = '1' AND multi_d = '0') THEN
			IF(Right_PaddleY_pos <= Size+size+size+size+size) THEN
				DirRightY <= CONV_STD_LOGIC_VECTOR(0,10);
			ELSE
				DirRightY <= -CONV_STD_LOGIC_VECTOR(4,10);
			END IF;
		ELSIF(multi_u = '0' AND multi_d = '1') THEN
			IF(('0'& Right_PaddleY_pos) >= CONV_STD_LOGIC_VECTOR(479,10)-Size-size-size-size-size) THEN
				DirRightY <= CONV_STD_LOGIC_VECTOR(0,10);
			ELSE
				DirRightY <= CONV_STD_LOGIC_VECTOR(4,10);
			END IF;
		ELSE
			DirRightY <= CONV_STD_LOGIC_VECTOR(0,10);
		END IF;
		Right_PaddleY_pos <= Right_PaddleY_pos + DirRightY;
		Right_PaddleX_pos <= CONV_STD_LOGIC_VECTOR(632,11);
	ELSE
		Right_PaddleX_pos <= CONV_STD_LOGIC_VECTOR(632,11);
		Right_PaddleY_pos <= Ball_Y_pos;
	END IF;
END PROCESS Move_Right_Paddle;

END beh;
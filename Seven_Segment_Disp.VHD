-- Author: Caroline Lichtenberger
-- Date: 01/20/13
-- Description: VGA 7 Segment Display

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;
LIBRARY WORK;
USE WORK.up1core.ALL;

ENTITY Seven_Segment_Disp IS

GENERIC(ADDR_WIDTH: INTEGER := 12; DATA_WIDTH: INTEGER := 1);

   PORT(SIGNAL Clock		 				: IN STD_LOGIC;
        SIGNAL MSByte, LSByte				: IN STD_LOGIC_VECTOR(3 DOWNTO 0);             
        SIGNAL Red,Green,Blue 				: OUT STD_LOGIC; -- VGA colors
        SIGNAL pixel_row, pixel_column		: IN STD_LOGIC_VECTOR(10 DOWNTO 0) 
        );
END Seven_Segment_Disp;

ARCHITECTURE behavior OF Seven_Segment_Disp IS

-- Video Display Signals   
SIGNAL Size 																							: STD_LOGIC_VECTOR(9 DOWNTO 0);  -- Pixel size
SIGNAL SEG_Yma_pos, SEG_Xma_pos,SEG_Ymb_pos, SEG_Xmb_pos,SEG_Ymc_pos, SEG_Xmc_pos,SEG_Ymd_pos, 
	   SEG_Xmd_pos,SEG_Yme_pos, SEG_Xme_pos,SEG_Ymf_pos, SEG_Xmf_pos,SEG_Ymg_pos, SEG_Xmg_pos			: STD_LOGIC_VECTOR(9 DOWNTO 0);
SIGNAL SEG_Yla_pos, SEG_Xla_pos,SEG_Ylb_pos, SEG_Xlb_pos,SEG_Ylc_pos, SEG_Xlc_pos,SEG_Yld_pos, 
	   SEG_Xld_pos,SEG_Yle_pos, SEG_Xle_pos,SEG_Ylf_pos, SEG_Xlf_pos,SEG_Ylg_pos, SEG_Xlg_pos			: STD_LOGIC_VECTOR(9 DOWNTO 0);
--SIGNAL pixel_row, pixel_column																			: STD_LOGIC_VECTOR(10 DOWNTO 0); 

-- Signals for VGA 7 Segment Displays
SIGNAL LSB_sega, LSB_segb, LSB_segc, LSB_segd, LSB_sege, LSB_segf, LSB_segg	: STD_LOGIC;
SIGNAL MSB_sega, MSB_segb, MSB_segc, MSB_segd, MSB_sege, MSB_segf, MSB_segg : STD_LOGIC;

BEGIN           
   MSD: dec_7seg
		PORT MAP(hex_digit =>MSByte, segment_a => MSB_sega, segment_b => MSB_segb, segment_c => MSB_segc, 
				segment_d => MSB_segd,	segment_e => MSB_sege, segment_f => MSB_segf, 
				segment_g => MSB_segg );

   LSD: dec_7seg
		PORT MAP(hex_digit =>LSByte, segment_a => LSB_sega, segment_b => LSB_segb, segment_c => LSB_segc, 
				segment_d => LSB_segd,	segment_e => LSB_sege, segment_f => LSB_segf, 
				segment_g => LSB_segg );

-- pixel sizing is 8x8 bits
Size <= CONV_STD_LOGIC_VECTOR(4,10);

-- ************************************************************************************************************************************************
-- Positioning for score board display
-- ************************************************************************************************************************************************

-- MSD Segment A
SEG_Xma_pos <= CONV_STD_LOGIC_VECTOR(250,10);
SEG_Yma_pos <= CONV_STD_LOGIC_VECTOR(16,10);
-- MSD Segment B
SEG_Xmb_pos <= CONV_STD_LOGIC_VECTOR(270,10);
SEG_Ymb_pos <= CONV_STD_LOGIC_VECTOR(36,10);
-- MSD Segment C
SEG_Xmc_pos <= CONV_STD_LOGIC_VECTOR(270,10);
SEG_Ymc_pos <= CONV_STD_LOGIC_VECTOR(76,10);
-- MSD Segment D
SEG_Xmd_pos <= CONV_STD_LOGIC_VECTOR(250,10);
SEG_Ymd_pos <= CONV_STD_LOGIC_VECTOR(96,10);
-- MSD Segment E
SEG_Xme_pos <= CONV_STD_LOGIC_VECTOR(230,10);
SEG_Yme_pos <= CONV_STD_LOGIC_VECTOR(76,10);
-- MSD Segment F
SEG_Xmf_pos <= CONV_STD_LOGIC_VECTOR(230,10);
SEG_Ymf_pos <= CONV_STD_LOGIC_VECTOR(36,10);
-- MSD Segment G
SEG_Xmg_pos <= CONV_STD_LOGIC_VECTOR(250,10);
SEG_Ymg_pos <= CONV_STD_LOGIC_VECTOR(56,10);
-- LSD Segment A
SEG_Xla_pos <= CONV_STD_LOGIC_VECTOR(322,10);
SEG_Yla_pos <= CONV_STD_LOGIC_VECTOR(16,10);
-- LSD Segment B
SEG_Xlb_pos <= CONV_STD_LOGIC_VECTOR(342,10);
SEG_Ylb_pos <= CONV_STD_LOGIC_VECTOR(36,10);
-- LSD Segment C
SEG_Xlc_pos <= CONV_STD_LOGIC_VECTOR(342,10);
SEG_Ylc_pos <= CONV_STD_LOGIC_VECTOR(76,10);
-- LSD Segment D
SEG_Xld_pos <= CONV_STD_LOGIC_VECTOR(322,10);
SEG_Yld_pos <= CONV_STD_LOGIC_VECTOR(96,10);
-- LSD Segment E
SEG_Xle_pos <= CONV_STD_LOGIC_VECTOR(302,10);
SEG_Yle_pos <= CONV_STD_LOGIC_VECTOR(76,10);
-- LSD Segment F
SEG_Xlf_pos <= CONV_STD_LOGIC_VECTOR(302,10);
SEG_Ylf_pos <= CONV_STD_LOGIC_VECTOR(36,10);
-- LSD Segment G
SEG_Xlg_pos <= CONV_STD_LOGIC_VECTOR(322,10);
SEG_Ylg_pos <= CONV_STD_LOGIC_VECTOR(56,10);


RGB_Display: PROCESS (SEG_Ylg_pos,SEG_Xlg_pos,SEG_Ylf_pos,SEG_Xlf_pos,SEG_Yle_pos,SEG_Xle_pos,SEG_Yld_pos,SEG_Xld_pos,SEG_Ylc_pos,SEG_Xlc_pos,SEG_Ylb_pos,SEG_Xlb_pos,SEG_Yla_pos,SEG_Xla_pos,SEG_Xma_pos,SEG_Yma_pos,SEG_Xmb_pos,SEG_Ymb_pos,SEG_Xmc_pos,SEG_Ymc_pos,SEG_Xmd_pos,SEG_Ymd_pos,SEG_Xme_pos,SEG_Yme_pos, pixel_column, pixel_row, Size)
BEGIN

-- Set SEG_on ='1' or respective segment to display
-- Segment MSD a
 IF ('0' & SEG_Xma_pos <= pixel_column + Size+ size +size+size) AND
 	(SEG_Xma_pos + Size >= '0' & pixel_column-size-size-size-size) AND
 	('0' & SEG_Yma_pos <= pixel_row + Size) AND
 	(SEG_Yma_pos + Size >= '0' & pixel_row-size )AND (MSB_sega = '1')  THEN
 		Red <= '1';
 		Green <= '1';
 		Blue <= '1';
-- Segment MSD b
 ELSIF ('0' & SEG_Xmb_pos <= pixel_column + Size) AND
 	(SEG_Xmb_pos + Size >= '0' & pixel_column-size) AND
 	('0' & SEG_Ymb_pos <= pixel_row + Size+ size +size+size) AND
 	(SEG_Ymb_pos + Size >= '0' & pixel_row-size-size-size-size ) AND (MSB_segb = '1') THEN
 		Red <= '1';
 		Green <= '1';
 		Blue <= '1';
-- Segment MSD c
 ELSIF ('0' & SEG_Xmc_pos <= pixel_column + Size) AND
 	(SEG_Xmc_pos + Size >= '0' & pixel_column-size) AND
 	('0' & SEG_Ymc_pos <= pixel_row + Size+ size +size+size) AND
 	(SEG_Ymc_pos + Size >= '0' & pixel_row-size-size-size-size ) AND (MSB_segc = '1') THEN
 		Red <= '1';
 		Green <= '1';
 		Blue <= '1';
-- Segment MSD d
 ELSIF ('0' & SEG_Xmd_pos <= pixel_column + Size+ size +size+size) AND
 	(SEG_Xmd_pos + Size >= '0' & pixel_column-size-size-size-size) AND
 	('0' & SEG_Ymd_pos <= pixel_row + Size) AND
 	(SEG_Ymd_pos + Size >= '0' & pixel_row-size ) AND (MSB_segd = '1') THEN
 		Red <= '1';
 		Green <= '1';
 		Blue <= '1';
-- Segment MSD e
 ELSIF ('0' & SEG_Xme_pos <= pixel_column + Size) AND
 	(SEG_Xme_pos + Size >= '0' & pixel_column-size) AND
 	('0' & SEG_Yme_pos <= pixel_row + Size+ size +size+size) AND
 	(SEG_Yme_pos + Size >= '0' & pixel_row-size-size-size-size ) AND (MSB_sege = '1') THEN
 		Red <= '1';
 		Green <= '1';
 		Blue <= '1';
-- Segment MSD f
 ELSIF ('0' & SEG_Xmf_pos <= pixel_column + Size) AND
 	(SEG_Xmf_pos + Size >= '0' & pixel_column-size) AND
 	('0' & SEG_Ymf_pos <= pixel_row +Size+ size +size+size) AND
 	(SEG_Ymf_pos + Size >= '0' & pixel_row-size-size-size-size ) AND(MSB_segf = '1') THEN
 		Red <= '1';
 		Green <= '1';
 		Blue <= '1';
-- Segment MSD g
 ELSIF ('0' & SEG_Xmg_pos <= pixel_column + Size+ size +size+size) AND
 	(SEG_Xmg_pos + Size >= '0' & pixel_column-size-size-size-size) AND
 	('0' & SEG_Ymg_pos <= pixel_row + Size) AND
 	(SEG_Ymg_pos + Size >= '0' & pixel_row-size ) AND (MSB_segg = '1') THEN
 		Red <= '1';
 		Green <= '1';
 		Blue <= '1';
-- Segment LSD a
 ELSIF ('0' & SEG_Xla_pos <= pixel_column + Size+ size +size+size) AND
 	(SEG_Xla_pos + Size >= '0' & pixel_column-size-size-size-size) AND
 	('0' & SEG_Yla_pos <= pixel_row + Size) AND
 	(SEG_Yla_pos + Size >= '0' & pixel_row-size ) AND (LSB_sega = '1') THEN
 		Red <= '1';
 		Green <= '1';
 		Blue <= '1';
-- Segment LSD b
 ELSIF ('0' & SEG_Xlb_pos <= pixel_column + Size) AND
 	(SEG_Xlb_pos + Size >= '0' & pixel_column-size) AND
 	('0' & SEG_Ylb_pos <= pixel_row + Size+ size +size+size) AND
 	(SEG_Ylb_pos + Size >= '0' & pixel_row-size-size-size-size ) AND (LSB_segb = '1') THEN
 		Red <= '1';
 		Green <= '1';
 		Blue <= '1';
-- Segment LSD c
 ELSIF ('0' & SEG_Xlc_pos <= pixel_column + Size) AND
 	(SEG_Xlc_pos + Size >= '0' & pixel_column-size) AND
 	('0' & SEG_Ylc_pos <= pixel_row + Size+ size +size+size) AND
 	(SEG_Ylc_pos + Size >= '0' & pixel_row-size-size-size-size ) AND (LSB_segc = '1') THEN
 		Red <= '1';
 		Green <= '1';
 		Blue <= '1';
-- Segment LSD d
 ELSIF ('0' & SEG_Xld_pos <= pixel_column + Size+ size +size+size) AND
 	(SEG_Xld_pos + Size >= '0' & pixel_column-size-size-size-size) AND
 	('0' & SEG_Yld_pos <= pixel_row + Size) AND
 	(SEG_Yld_pos + Size >= '0' & pixel_row-size ) AND (LSB_segd = '1') THEN
 		Red <= '1';
 		Green <= '1';
 		Blue <= '1';		
-- Segment LSD e
 ELSIF ('0' & SEG_Xle_pos <= pixel_column + Size) AND
 	(SEG_Xle_pos + Size >= '0' & pixel_column-size) AND
 	('0' & SEG_Yle_pos <= pixel_row + Size+ size +size+size) AND
 	(SEG_Yle_pos + Size >= '0' & pixel_row-size-size-size-size ) AND (LSB_sege = '1') THEN
 		Red <= '1';
 		Green <= '1';
 		Blue <= '1';
-- Segment LSD f
 ELSIF ('0' & SEG_Xlf_pos <= pixel_column + Size) AND
 	(SEG_Xlf_pos + Size >= '0' & pixel_column-size) AND
 	('0' & SEG_Ylf_pos <= pixel_row + Size+ size +size+size) AND
 	(SEG_Ylf_pos + Size >= '0' & pixel_row-size-size-size-size ) AND (LSB_segf = '1') THEN
 		Red <= '1';
 		Green <= '1';
 		Blue <= '1';
-- Segment LSD g
 ELSIF ('0' & SEG_Xlg_pos <= pixel_column + Size+ size +size+size) AND
 	(SEG_Xlg_pos + Size >= '0' & pixel_column-size-size-size-size) AND
 	('0' & SEG_Ylg_pos <= pixel_row + Size) AND
 	(SEG_Ylg_pos + Size >= '0' & pixel_row-size ) AND (LSB_segg = '1') THEN
 		Red <= '1';
 		Green <= '1';
 		Blue <= '1';
---- Off
ELSE
 		Red <= '0';
 		Green <= '0';
 		Blue <= '0';
END IF;

END PROCESS RGB_Display;

END behavior;


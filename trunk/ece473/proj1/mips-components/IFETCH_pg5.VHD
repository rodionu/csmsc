-- MIPS Processor VHDL Behavioral Model
--
-- Ifetch module (provides the PC and instruction memory) 
-- 

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY Ifetch IS
	PORT(	SIGNAL Instruction 		: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
      		SIGNAL PC_OUT 			: OUT	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			SIGNAL PC_IN			: IN	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
        	SIGNAL clock, reset 	: IN 	STD_LOGIC);
END Ifetch;

ARCHITECTURE behavior OF Ifetch IS
   TYPE INST_MEM IS ARRAY (0 to 31) of STD_LOGIC_VECTOR (31 DOWNTO 0);
   SIGNAL iram : INST_MEM := (
	X"0x3c010000", 
	X"0x3424002a", 
	X"0x3c011001", 
	X"0x34250000", 
	X"0x3c011001", 
	X"0x34260060", 
	X"0x20c6fffc", 
	X"0x0c100008", 
	X"0x23bdfffc", 
	X"0xafbf0004", 
	X"0x00c54023", 
	X"0x15000007", 
	X"0x00051021", 
	X"0x8c480000", 
	X"0x10880010", 
	X"0x3c010000", 
	X"0x34220000", 
	X"0x0810001e", 
	X"0x000840c2", 
	X"0x00084080", 
	X"0x00a81021", 
	X"0x8c480000", 
	X"0x10880008", 
	X"0x0088082a", 
	X"0x14200004", 
	X"0x20450004", 
	X"0x0c100008", 
	X"0x0810001e", 
	X"0x00023021", 
	X"0x0c100008", 
	X"0x8fbf0004", 
	X"0x23bd0004"
   );
    
	SIGNAL PC	  			: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
	SIGNAL Mem_Addr 		: STD_LOGIC_VECTOR( 31 DOWNTO 0 );
BEGIN 				
	--	PC(1 DOWNTO 0) <= "00";		
		PC_OUT <= PC;
  		Instruction <= iram(CONV_INTEGER(PC(31 DOWNTO 2)- X"0100000"));
	PROCESS
		BEGIN
			WAIT UNTIL ( clock'EVENT ) AND ( clock = '1' );
			IF reset = '1' THEN
				   PC( 31 DOWNTO 0) <= X"00400000"-4;
			ELSE 
				   PC( 31 DOWNTO 0 ) <= PC_IN( 31 DOWNTO 2) & "00";
			END IF;
			
	END PROCESS;
END behavior;



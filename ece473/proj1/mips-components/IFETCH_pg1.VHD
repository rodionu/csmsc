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
   TYPE INST_MEM IS ARRAY (0 to 6) of STD_LOGIC_VECTOR (31 DOWNTO 0);
   SIGNAL iram : INST_MEM := (
		X"3C011001",
		X"34280000",
		X"00008020",
		X"8D0A0000",
		X"020A8020",
		X"21080004",
		X"1540FFFD"
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



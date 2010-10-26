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
   TYPE INST_MEM IS ARRAY (0 to 44) of STD_LOGIC_VECTOR (31 DOWNTO 0);
   SIGNAL iram : INST_MEM := (
		X"001f8021",
		X"3c010000",
		X"34310007",
		X"3c011001",
		X"34240000",
		X"02202821",
		X"0c100009",
		X"0200f821",
		X"03e00008",
		X"00a06021",
		X"01804821",
		X"00804021",
		X"8d0a0000",
		X"8d0b0004",
		X"016a082a",
		X"10200004",
		X"00000000",
		X"ad0a0004",
		X"ad0b0000",
		X"21080004",
		X"8d0a0000",
		X"2129ffff",
		X"34010001",
		X"1429fff5",
		X"00000000",
		X"218cffff",
		X"34010001",
		X"142cffef",
		X"00804021",
		X"00a04821",
		X"00094880",
		X"01094820",
		X"8d22fffc",
		X"03e00008",
		X"3c011001",  --la $a0, irray
		X"34240000",
		X"00804021",
		X"8d0a0000",	--0
		X"8d0a0004",	--1
		X"8d0a0008",	--2	
		X"8d0a000C",	--3
		X"8d0a0010",	--4
		X"8d0a0014",	--5
		X"8d0a0018",	--6
		X"8d0a001C"	--7
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



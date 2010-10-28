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
        	SIGNAL PC_plus_4_out 	: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        	SIGNAL Add_result 		: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
        	SIGNAL Branch 			: IN 	STD_LOGIC;
        	SIGNAL Zero 			: IN 	STD_LOGIC;
      		SIGNAL PC_out 			: OUT	STD_LOGIC_VECTOR( 9 DOWNTO 0 );
        	SIGNAL clock, reset 	: IN 	STD_LOGIC);
END Ifetch;

ARCHITECTURE behavior OF Ifetch IS
   TYPE INST_MEM IS ARRAY (0 to 8) of STD_LOGIC_VECTOR (31 DOWNTO 0);
   SIGNAL iram : INST_MEM := (
        X"00000000",   -- nop
        X"3c011001",	--Test Program 1
        X"34280000",
        X"00008020",
        X"8d0a0000", 
        X"020a8020", 
        X"21080004", 
        X"1540fffc",
        X"08100007"
        
--		X"2001000F",
--       X"20020008",
--        X"00411825",
--        X"00411827",
--		X"0C10002C",	--JAL TO PC = 44 (2C)
--        X"2001000F",
--        X"20020008",
--        X"2001000F",
--        X"20020008",
--        X"200500FA",
--        X"00411820",
--		X"03E00008"		--Jump Return

       
       
   );
    
	SIGNAL PC, PC_plus_4 	 : STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL next_PC, Mem_Addr : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
BEGIN 						
					
		PC(1 DOWNTO 0) <= "00";
					-- copy output signals - allows read inside module
		PC_out 			<= PC;
		PC_plus_4_out 	<= PC_plus_4;
						-- send address to inst. memory address register
		Mem_Addr <= Next_PC;
						-- Adder to increment PC by 4        
      	PC_plus_4( 9 DOWNTO 2 )  <= PC( 9 DOWNTO 2 ) + 1;
      	PC_plus_4( 1 DOWNTO 0 )  <= "00";
						
                  	-- Mux to select Branch Address or PC + 4     
		Next_PC  <= Add_result WHEN ( (Branch='1') AND ( Zero='1' ) ) ELSE
            X"00" WHEN Reset = '1' ELSE
			   PC_plus_4( 9 DOWNTO 2 );

	PROCESS
		BEGIN
			WAIT UNTIL ( clock'EVENT ) AND ( clock = '1' );
			IF reset = '1' THEN
				   PC( 9 DOWNTO 2) <= "00000000" ;
				   Instruction <= iram(CONV_INTEGER(0));
			ELSE 
				   PC( 9 DOWNTO 2 ) <= next_PC;
				   Instruction <= iram(CONV_INTEGER(Mem_Addr));
			END IF;
	END PROCESS;
END behavior;



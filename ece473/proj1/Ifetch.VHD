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
        	SIGNAL clock, reset 	: IN 	STD_LOGIC;
        	SIGNAL done				: OUT 	STD_LOGIC_VECTOR (0 DOWNTO 0));
END Ifetch;

ARCHITECTURE behavior OF Ifetch IS
  TYPE INST_MEM IS ARRAY (0 to 26) of STD_LOGIC_VECTOR (31 DOWNTO 0);
   SIGNAL iram : INST_MEM := (

x"3c011001",
x"34250000",
x"3c011001",
x"34260070",
x"20110000",
x"20120000",
x"00a04825",
x"01205025",
x"8d4b0000",
x"11600002",
x"214a0004",
x"08100008",
x"214afffc",
x"0149082a",
x"14200006",
x"8d2b0000",
x"8d4c0000",
x"156c0005",
x"21290004",
x"214afffc",
x"0810000d",
x"20110001",
x"08100019",
x"2011ffff",
x"08100019",
x"20120001",
x"0810001a"

--x"3c010000",
--x"3424002a",
--x"3c011001",
--x"34250000", 
--x"3c011001", 
--x"34260060", 
--x"20c6fffc", 
--x"0c100009", 
--x"08100008",
--x"23bdfffc", 
--x"afbf0004", 
--x"00c54023", 
--x"15000006", 
--x"00051021", 
--x"8c480000", 
--x"1088000f", 
--x"3c010000", 
--x"34220000", 
--x"0810001f", 
--x"000840c2", 
--x"00084080", 
--x"00a81021", 
--x"8c480000", 
--x"10880007", 
--x"0088082a", 
--x"14200003",
--x"20450004", 
--x"0c100009", 
--x"0810001f", 
--x"00023021", 
--x"0c100009", 
--x"8fbf0004", 
--x"23bd0004",
--x"03e00008"

--X"201f0000",  --PROGRAM 3 (0 to 40)
--X"001f8021",
--X"24110007",
--X"3c011001",
--X"34240000",
--X"02202821",
--X"0c100010",
--X"00a04821",
--X"00804021",
--X"8d0d0000",
--X"2129ffff",
--X"21080004",
--X"20010000",
--X"1429fffb",
--X"00000000",
--X"0810000f",
--X"00a06021",
--X"01804821",
--X"00804021",
--X"8d0a0000",
--X"8d0b0004",
--X"016a082a",
--X"10200003",
--X"00000000",
--X"ad0a0004",
--X"ad0b0000",
--X"21080004",
--X"8d0a0000",
--X"2129ffff",
--X"20010001",
--X"1429fff4",
--X"00000000",
--X"218cffff",
--X"20010001",
--X"142cffee",
--X"00804021",
--X"00a04821",
--X"00094880",
--X"01094820",
--X"8d22fffc",
--X"03e00008"

--x"201f0000",
--x"001f8021",
--x"24110007",
--x"3c010000", 
--x"34310007", 
--x"3c011001", 
--x"34240000", 
--x"02202821", 
--x"0c100010", 
--x"00a04821",
--x"00804021",
--x"8d0d0000",
--x"2129ffff",
--x"21080004",
--x"34010000",
--x"1429fffb",
--x"00000000",
--x"0810000f",
--x"00a06021",
--x"01804821", 
--x"00804021",
--x"8d0a0000", 
--x"8d0b0004",
--x"016a082a",
--x"10200003",
--x"00000000",
--x"ad0a0004",
--x"ad0b0000",
--x"21080004",
--x"8d0a0000",
--x"2129ffff",
--x"34010001",
--x"1429fff4",
--x"00000000",
--x"218cffff",
--x"34010001",
--x"142cffee",
--x"00804021",
--x"00a04821",
--x"00094880",
--x"01094820",
--x"8d22fffc",
--x"03e00008"

--X"3c011001", --Test program 1 (0 to 7)
--X"34280000",
--X"00008020",
--X"8d0a0000", 
--X"020a8020", 
--X"21080004", 
--X"1540fffc",
--X"08100007"

--	X"3c011001", --Test program 2 (0 to 19)
--	X"34280000",
--	X"8d090000",
--	X"8d0a0004",
--	X"00001020",
--	X"00006820",
--	X"20030004",
--	X"314c0001",
--	X"34010000",
--	X"102c0002",
--	X"20630001",
--	X"00491020",
--	X"000a5042",
--	X"00094840",
--	X"21ad0001",
--	X"20630008",
--	X"34010010",
--	X"142dfff5",
--	X"20630002",
--	X"08100013"
   );
    
	SIGNAL PC, PC_plus_4 	 : STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	SIGNAL next_PC, Mem_Addr : STD_LOGIC_VECTOR( 7 DOWNTO 0 );
BEGIN 						
					
		PC(1 DOWNTO 0) <= "00";
					-- copy output signals - allows read inside module
		PC_out 			<= PC WHEN reset= '0' ELSE
							"0000000000";
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
	    done 	 <= "1" WHEN Next_PC = PC (9 DOWNTO 2) ELSE "0";
	PROCESS
		BEGIN
			WAIT UNTIL ( clock'EVENT ) AND ( clock = '1' );
			IF reset = '1' THEN
				PC( 9 DOWNTO 2) <= "00000000";
				Instruction <= iram(CONV_INTEGER(0));
			ELSE 
				PC( 9 DOWNTO 2 ) <= next_PC;
				Instruction <= iram(CONV_INTEGER(Mem_Addr));
			END IF;
	END PROCESS;
END behavior;



-- MIPS Processor VHDL Behavioral Model
--						
--  Dmemory module (implements the data
--  memory for the MIPS computer)
--
-- 
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_SIGNED.ALL;

ENTITY dmemory IS
	PORT(	read_data 			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			write_data 			: IN 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			address 			: IN 	STD_LOGIC_VECTOR( 7 DOWNTO 0 );
			Mem_Sel				: IN	STD_LOGIC_VECTOR( 4 DOWNTO 0 );
			MemRead, Memwrite 	: IN 	STD_LOGIC;
			Mem_Data			: OUT 	STD_LOGIC_VECTOR( 31 DOWNTO 0 );
			clock,reset			: IN 	STD_LOGIC );
            
--    SIGNAL addrshift: STD_LOGIC_VECTOR(7 DOWNTO 0);
END dmemory;

ARCHITECTURE behavior OF dmemory IS 
   TYPE DATA_RAM IS ARRAY (0 to 27) OF STD_LOGIC_VECTOR (31 DOWNTO 0);
   SIGNAL ram: DATA_RAM := (

x"00000006", 
x"00000003",
x"00000008",
x"0000000a",
x"00000010",
x"00e00015",
x"00000023",
x"00000024",
x"00000527",
x"00000033",
x"00000001",
x"00000100",
x"00000400",
x"0000002d",
x"00000400",
x"00000100",
x"00000001",
x"00000033",
x"00000027",
x"00000024",
x"00000023",
x"0000f015",
x"00000010",
x"0000000a",
x"00000008",
x"00000003",
x"00000009",
x"00000000"


--x"00000002", --prgtest 4 (0 to 23)
--x"00000003",
--x"00000008",
--x"0000000a",
--x"00000010",
--x"00000015",
--x"00000023",
--x"0000002a",
--x"0000002b",
--x"00000032",
--x"00000040",
--x"00000045",
--x"00000046",
--x"0000004d",
--x"00000052",
--x"00000053",
--x"00000054",
--x"0000005a",
--x"00000060",
--x"00000063",
--x"00000064",
--x"00000069",
--x"0000006f",
--x"00000078"


--x"00000001",	--PROGRAM 3 memory, (0 to 7)
--x"00000009",
--x"00000002",
--x"00000008",
--x"00000005",
--x"00000006",
--x"00000007",
--x"00000000"


--	X"00000033", --RAM for testprog 2 (0 to 1)
--	X"0000002C"

--	X"00000001", --RAM for testprog 1 (0 to 10)
--	X"00000002",
--	X"00000003", 
--	X"00000004",
--	X"00000005",
--	X"00000006",
--	X"00000007",
--	X"00000008",
--	X"00000009",
--	X"0000000A",
--	X"00000000"
   );
   BEGIN
       PROCESS(clock, MemRead, Memwrite, address)
           BEGIN
			Mem_Data (31 DOWNTO 0) <= ram(CONV_INTEGER(Mem_Sel));
             IF (clock = '0' and clock'EVENT) THEN
                   IF (MemRead = '1') THEN
--					  addrshift <= (address AND "11111100");
					    read_data (31 DOWNTO 0) <= ram(CONV_INTEGER(address(7 DOWNTO 2)));
--                      read_data (7 DOWNTO 0) <= ram(CONV_INTEGER(addrshift));
--                      read_data (15 DOWNTO 8) <= ram(CONV_INTEGER(addrshift+1));
--                      read_data (23 DOWNTO 16) <= ram(CONV_INTEGER(addrshift+2));
--                      read_data (31 DOWNTO 24) <= ram(CONV_INTEGER(addrshift+3));
                   ELSIF (Memwrite = '1') THEN
						ram(CONV_INTEGER(address (7 DOWNTO 2))) <= write_data (31 DOWNTO 0);
--                      ram(CONV_INTEGER(address)) <= write_data (7 DOWNTO 0);
--                      ram(CONV_INTEGER(address+1)) <= write_data (15 DOWNTO 8);
--                      ram(CONV_INTEGER(address+2)) <= write_data (23 DOWNTO 16);
--                      ram(CONV_INTEGER(address+3)) <= write_data (31 DOWNTO 24);   
                   END IF;
               END IF;               
       END PROCESS;
   END behavior;
  


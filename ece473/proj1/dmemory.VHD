
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
   TYPE DATA_RAM IS ARRAY (0 to 10) OF STD_LOGIC_VECTOR (31 DOWNTO 0);
   SIGNAL ram: DATA_RAM := (
	X"00000001", --RAM for testprog 1 (0 to 10)
	X"00000002",
	X"00000003", 
	X"00000004",
	X"00000005",
	X"00000006",
	X"00000007",
	X"00000008",
	X"00000009",
	X"0000000A",
	X"00000000"

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
  


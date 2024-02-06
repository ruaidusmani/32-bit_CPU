library ieee;
use ieee.std_logic_1164.all;

entity pc_register is
	port (address_in : in std_logic_vector (31 downto 0);
	      clk	 : in std_logic;
		reset 	: in std_logic;
		pc_reg_out : out std_logic_vector(31 downto 0));
end pc_register;

architecture pc_register_struct of pc_register is
begin
	process (address_in, clk, reset)
	begin
		if (reset = '1') then
			pc_reg_out <= X"00000000";
		else if (rising_edge(clk)) then
			pc_reg_out <= address_in;
		end if;
		end if;
	end process;
end pc_register_struct; 

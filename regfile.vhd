library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity regfile is 
port ( 	din 		: in std_logic_vector(31 downto 0);
	reset 		: in std_logic; 
	clk		: in std_logic;
	write		: in std_logic;
	read_a		: in std_logic_vector(4 downto 0);
	read_b		: in std_logic_vector(4 downto 0);
	write_address	: in std_logic_vector(4 downto 0);
	out_a		: out std_logic_vector(31 downto 0);
	out_b		: out std_logic_vector(31 downto 0));
end regfile;

architecture regfile_struct of regfile is

type registers is array (0 to 31) of std_logic_vector(31 downto 0);
signal R: registers;

begin     
	process (din, reset, clk, write, write_address)
    begin
		if (reset = '1') then
		    reset_registers : for i in 0 to 31 loop
		      	R(i) <= (others => '0');
		    end loop reset_registers;
		elsif (rising_edge(clk)) then
            if (write = '1') then 
                R(to_integer(unsigned(write_address))) <= din;
            end if;
        end if;
     end process;

    out_a <= R(to_integer(unsigned(read_a)));
    out_b <= R(to_integer(unsigned(read_b)));

end regfile_struct;

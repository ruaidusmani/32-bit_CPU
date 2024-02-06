library ieee;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity d_cache is 
port ( 	
    	din 		: in std_logic_vector(31 downto 0);
	reset 		: in std_logic; 
	clk		: in std_logic;
	data_write	: in std_logic;
	address	    	: in std_logic_vector(4 downto 0);
	d_out		: out std_logic_vector(31 downto 0));
end d_cache;

architecture d_cache_struct of d_cache is

type locations is array (0 to 31) of std_logic_vector(31 downto 0);
signal L: locations;

begin     
	process (din, reset, clk, data_write, address)
   	begin
		if (reset = '1') then
		    reset_locations : for i in 0 to 31 loop
		      	L(i) <= (others => '0');
		    end loop reset_locations;
		elsif (rising_edge(clk)) then
            if (data_write = '1') then 
                L(to_integer(unsigned(address))) <= din;
            end if;
        end if;
     end process;
     
    d_out <= L(to_integer(unsigned(address)));
end d_cache_struct;

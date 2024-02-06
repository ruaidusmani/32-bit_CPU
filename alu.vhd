library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity alu is 
	port (x,y        : in std_logic_vector (31 downto 0);
	      add_sub    : in std_logic;
	      logic_func : in std_logic_vector (1 downto 0);
	      func 	 : in std_logic_vector (1 downto 0);
	      output     : out std_logic_vector (31 downto 0);
	      overflow	 : out std_logic;
	      zero 	 : out std_logic);
end alu;

architecture alu_struct of alu is 
signal arith_result, logic_result : std_logic_vector(31 downto 0);
signal msb_x, msb_y, msb_arith_result : std_logic;
constant all_zeros : std_logic_vector (31 downto 0) := (others => '0');

begin
	-- arith block
	msb_x <= x(31);
	msb_y <= y(31);
	
	process (x,y,add_sub) is
	begin
        	if (add_sub = '0') then
			arith_result <= x + y;
       	     	else 
                     	arith_result <= x - y;
		end if;  
    	end process; 
    	
    	msb_arith_result <= arith_result(31);
    	
    	process (arith_result) is
	begin 
		if (arith_result = all_zeros) then
			zero <= '1';
		else
			zero <= '0';
		end if;
	end process; 

	process (msb_x, msb_y, add_sub, msb_arith_result, arith_result)
	begin
		if ((add_sub = '0') and (msb_x = msb_y) and ((msb_x /= msb_arith_result) or (msb_y /= msb_arith_result))) then
			overflow <= '1';
		elsif ((add_sub = '1') and (msb_x /= msb_y) and (msb_x /= msb_arith_result)) then
			overflow <= '1';
		else
			overflow<= '0';
		end if;
	end process; 

	-- logic block
	process (x,y,logic_func) is
	begin 
		case logic_func is
			when "00" => logic_result <= x and y;
			when "01" => logic_result <= x or y;
			when "10" => logic_result <= x xor y;
			when others => logic_result <= x nor y;
		end case;
	end process;

	-- output block
	process (y, msb_arith_result, arith_result, logic_result, func)
	begin 
		case func is
			when "00" => output <= y;
			when "01" => output <= (31 downto 1 => '0') & msb_arith_result;
			when "10" => output <= arith_result;
			when others => output <= logic_result;
		end case;
	end process;

end alu_struct;

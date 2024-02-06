library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity next_address is
port (  rt, rs : in std_logic_vector (31 downto 0);
        pc     : in std_logic_vector (31 downto 0);
        target_address : in std_logic_vector (25 downto 0);
        branch_type    : in std_logic_vector (1 downto 0);
        pc_sel         : in std_logic_vector (1 downto 0);
        next_pc        : out std_logic_vector (31 downto 0));
end next_address;

architecture next_address_struct of next_address is

signal pc_temp : std_logic_vector (31 downto 0);
signal sign_extended_target_address : std_logic_vector (31 downto 0);

begin 

    sign_extended_target_address (31 downto 16) <= (others => target_address(25));
	sign_extended_target_address (15 downto 0) <= target_address(15 downto 0);    

	process (rt, rs, pc, pc_temp, target_address, pc_sel, branch_type) is
	begin

		if (pc_sel = "00") then

			if (branch_type = "00") then 
			     pc_temp <= pc + x"00000001";
			elsif (branch_type = "01") then
				if (rt = rs) then
					pc_temp <= pc + X"00000001" + sign_extended_target_address;
				else 
				    pc_temp <= pc + X"00000001";
				end if;
			elsif (branch_type = "10") then
				if (rt /= rs) then
					pc_temp <= pc + X"00000001" + sign_extended_target_address;
				else 
					pc_temp <= pc + X"00000001";
				end if;
			elsif (branch_type = "11") then
				if (rs < "0") then
				    pc_temp <= pc + X"00000001" + sign_extended_target_address;
				else 
					pc_temp <= pc + X"00000001";
				end if;
			end if;

		elsif (pc_sel = "01") then
			pc_temp <= "000000" & target_address (25 downto 0);
		elsif (pc_sel = "10") then
			pc_temp <= rs;
		else
		end if;
	end process; 
    next_pc <= pc_temp;	
end next_address_struct;

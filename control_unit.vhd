library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity control_unit is
	port (	instruction_in : in std_logic_vector (31 downto 0);
		reg_write_ctrl, reg_dst_ctrl,
		reg_in_src_ctrl, alu_src_ctrl, add_sub_ctrl, data_write_ctrl : out std_logic; 
		logic_func_ctrl, func_ctrl, branch_type_ctrl, pc_sel_ctrl 
		: out std_logic_vector (1 downto 0));
end control_unit;

architecture control_unit_struct of control_unit is 
signal opcode : std_logic_vector (5 downto 0);
signal funct : std_logic_vector (4 downto 0);
signal ctrl_signals : std_logic_vector (13 downto 0);

begin
	process (instruction_in, opcode)
	begin
		opcode <= instruction_in(31 downto 26);
		funct <= instruction_in(4 downto 0);
		
		case (opcode) is
			when "001111" => -- lui
				ctrl_signals <= "10110000000000";
			when "000000" => 
				if (funct = "100000") then -- add
					ctrl_signals <= "11101000110000";
				elsif (funct = "100010") then -- sub
					ctrl_signals <= "11101000100000";
				elsif (funct = "101010") then -- slt
					ctrl_signals <= "11101000010000";
				elsif (funct = "100100") then -- and
					ctrl_signals <= "11101000110000";
				elsif (funct = "100101") then -- or
					ctrl_signals <= "11101001110000";
				elsif (funct = "100110") then -- xor
					ctrl_signals <= "11101010110000";
				elsif (funct = "100111") then -- nor
					ctrl_signals <= "11101011110000";
				elsif (funct = "001000") then -- jr
					ctrl_signals <= "00000000000010";
				else
				end if;
			when "001000" => -- addi
				ctrl_signals <= "10110000100000";
			when "001010" => -- slti
				ctrl_signals <= "10111000010000";
			when "001100" => --andi
				ctrl_signals <= "10111000110000";
			when "001101" => -- ori
				ctrl_signals <= "10111001110000";
			when "001110" => -- xori
				ctrl_signals <= "10111010110000";
			when "100011" => -- lw
				ctrl_signals <= "10010010100000";
			when "101011" => -- sw
				ctrl_signals <= "00010100100000";
			when "000010" => -- j
				ctrl_signals <= "00000000000001";
			when "000001" => -- bltz
				ctrl_signals <= "00000000001100";
			when "000100" => -- beq
				ctrl_signals <= "00000000000100";
			when "000101" =>
				ctrl_signals <= "00000000001000";
			when others => 
				ctrl_signals <= (others => '0');
		end case;
		
		reg_write_ctrl <= ctrl_signals (13);
		reg_dst_ctrl <= ctrl_signals (12);
		reg_in_src_ctrl <= ctrl_signals(11);
		alu_src_ctrl <= ctrl_signals(10);
		add_sub_ctrl <= ctrl_signals(9);
		data_write_ctrl <= ctrl_signals(8);
		logic_func_ctrl <= ctrl_signals(7 downto 6);
		func_ctrl <= ctrl_signals(5 downto 4);
		branch_type_ctrl <= ctrl_signals (3 downto 2);
		pc_sel_ctrl <= ctrl_signals (1 downto 0);
	end process;

end control_unit_struct;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity cpu is 
	port (	reset		: in std_logic;
		clk		: in std_logic;
		rs_out, rt_out	: out std_logic_vector (31 downto 0);
		-- output ports from register file
		pc_out 		: out std_logic_vector (31 downto 0); -- pc reg
		overflow, zero	: out std_logic);
end cpu;

architecture cpu_struct of cpu is
-- pc register
component pc_register
	port (	address_in : in std_logic_vector (31 downto 0);
	     	clk	 : in std_logic;
		reset 	: in std_logic;
		pc_reg_out : out std_logic_vector(31 downto 0));
end component;

-- instructionuction cache
component i_cache 
	port (	input : in std_logic_vector (4 downto 0);
		instruction : out std_logic_vector (31 downto 0));
end component;

-- register file
component regfile
	port ( 	din 		: in std_logic_vector(31 downto 0);
		reset 		: in std_logic; 
		clk		: in std_logic;
		write		: in std_logic;
		read_a		: in std_logic_vector(4 downto 0);
		read_b		: in std_logic_vector(4 downto 0);
		write_address	: in std_logic_vector(4 downto 0);
		out_a		: out std_logic_vector(31 downto 0);
		out_b		: out std_logic_vector(31 downto 0));
end component;

-- data cache
component d_cache 
	port ( 	din 		: in std_logic_vector(31 downto 0);
		reset 		: in std_logic; 
		clk		: in std_logic;
		data_write	: in std_logic;
		address	    	: in std_logic_vector(4 downto 0);
		d_out		: out std_logic_vector(31 downto 0));
end component; 

-- next address unit
component next_address
	port (  rt, rs : in std_logic_vector (31 downto 0);
		pc     : in std_logic_vector (31 downto 0);
		target_address : in std_logic_vector (25 downto 0);
		branch_type    : in std_logic_vector (1 downto 0);
		pc_sel         : in std_logic_vector (1 downto 0);
		next_pc        : out std_logic_vector (31 downto 0));
end component;

-- sign extend unit
component sign_extend 
	port (	data_in     : in std_logic_vector(15 downto 0);
	    	func        : in std_logic_vector(1 downto 0);
	    	data_out    : out std_logic_vector(31 downto 0));
end component;

-- alu 
component alu
	port (x,y        : in std_logic_vector (31 downto 0);
	      add_sub    : in std_logic;
	      logic_func : in std_logic_vector (1 downto 0);
	      func 	 : in std_logic_vector (1 downto 0);
	      output     : out std_logic_vector (31 downto 0);
	      overflow	 : out std_logic;
	      zero 	 : out std_logic);
end component;

-- control unit
component control_unit
	port (	instruction_in : in std_logic_vector (31 downto 0);
		reg_write_ctrl, reg_dst_ctrl,
		reg_in_src_ctrl, alu_src_ctrl, add_sub_ctrl, data_write_ctrl : out std_logic; 
		logic_func_ctrl, func_ctrl, branch_type_ctrl, pc_sel_ctrl 
		: out std_logic_vector (1 downto 0));
end component;

-- signals of control unit
signal reg_write, reg_dst, reg_in_src, alu_src, add_sub, data_write : std_logic;
signal logic_func, func, branch_type, pc_sel : std_logic_vector (1 downto 0);

-- signals of components
signal pc_out_comp, next_pc_out, instruction_out, alu_out, dcache_out, sign_extend_out: std_logic_vector (31 downto 0);
signal a_out, b_out : std_logic_vector(31 downto 0);
signal reg_write_address : std_logic_vector (4 downto 0);
signal alu_src_out : std_logic_vector (31 downto 0);
signal reg_file_din : std_logic_vector (31 downto 0);

-- connect all structs
for pc_reg_block : pc_register use entity WORK.pc_register(pc_register_struct);
for i_cache_block : i_cache use entity WORK.i_cache(i_cache_struct);
for regfile_block : regfile use entity WORK.regfile(regfile_struct);
for d_cache_block : d_cache use entity WORK.d_cache(d_cache_struct);
for next_address_block : next_address use entity WORK.next_address(next_address_struct);
for sign_extend_block : sign_extend use entity WORK.sign_extend(sign_extend_struct);
for alu_block : alu use entity WORK.alu(alu_struct);
for ctrl_unit_block : control_unit use entity WORK.control_unit(control_unit_struct);

begin

-- port mapping
pc_reg_block : pc_register
port map ( address_in => next_pc_out, clk => clk, reset => reset, pc_reg_out => pc_out_comp);

i_cache_block : i_cache
port map ( input => pc_out_comp(4 downto 0), instruction => instruction_out);

regfile_block : regfile 
port map ( din => reg_file_din, reset => reset, clk => clk, write => reg_write, read_a => instruction_out(25 downto 21), read_b => instruction_out(20 downto 16), write_address => reg_write_address, out_a => a_out, out_b => b_out);

d_cache_block: d_cache
port map ( din => b_out, reset => reset, clk => clk, data_write => data_write, address => alu_out(4 downto 0), d_out => dcache_out);

next_address_block : next_address
port map ( rt => b_out, rs => a_out, pc => pc_out_comp, target_address => instruction_out(25 downto 0), branch_type => branch_type, pc_sel => pc_sel, next_pc => next_pc_out);

sign_extend_block : sign_extend
port map ( data_in => instruction_out(15 downto 0), func => func, data_out => sign_extend_out);

alu_block : alu
port map ( x => a_out, y => alu_src_out, add_sub => add_sub, logic_func => logic_func, func => func, output => alu_out, overflow => overflow, zero => zero);

ctrl_unit_block : control_unit
port map (	instruction_in => instruction_out, reg_write_ctrl => reg_write, 
		reg_dst_ctrl => reg_dst, reg_in_src_ctrl => reg_in_src, 
		alu_src_ctrl => alu_src, add_sub_ctrl => add_sub,
		data_write_ctrl => data_write, logic_func_ctrl => logic_func,
		func_ctrl => func, branch_type_ctrl => branch_type, pc_sel_ctrl => pc_sel); 

-- reg_dst mux
	reg_write_address <= instruction_out(20 downto 16) when (reg_dst = '0') else instruction_out (15 downto 11);

-- alu_src mux
	alu_src_out <= b_out when (alu_src = '0') else sign_extend_out;

-- reg_in_src mux
	reg_file_din <= dcache_out when (reg_in_src = '0') else alu_out;

	rs_out <= a_out;
	rt_out <= alu_src_out;
	pc_out <= pc_out_comp;

end cpu_struct;

library ieee;
use ieee.std_logic_1164.all;

entity sign_extend is 
port (
    data_in     : in std_logic_vector(15 downto 0);
    func        : in std_logic_vector(1 downto 0);
    data_out    : out std_logic_vector(31 downto 0)
);
end sign_extend;

architecture sign_extend_struct of sign_extend is
begin 
    process(data_in, func)
    begin
        if (func ="00") then
            data_out <= data_in & X"0000";
        elsif (func = "01" or func = "10") then 
         
            data_out(31 downto 16) <= (others => data_in(15));
            data_out(15 downto 0) <= data_in (15 downto 0);

        elsif (func = "11") then
            data_out <= X"0000" & data_in;
        end if;
    end process;

end sign_extend_struct;
    

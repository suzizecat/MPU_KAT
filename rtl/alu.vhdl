library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity alu is
    generic (
        DATA_SIZE : natural := 16
    );
    port (
        clk   : in std_logic;
        reset : in std_logic;

        -- Multiplication truncated to datasize bits
        operand1 : in std_logic_vector(DATA_SIZE -1 downto 0);
        operand2 : in std_logic_vector(DATA_SIZE -1 downto 0);
        output   : out std_logic_vector(DATA_SIZE -1 downto 0);
        overflow : out std_logic;
        bool_res : out std_logic;
        negative_flag : out std_logic;

        command : in std_logic_vector(7 downto 0)        
    );
end entity;

architecture behav of alu is
    signal inter_operand1, inter_operand2 : std_logic_vector(DATA_SIZE downto 0);
    signal internal : unsigned(DATA_SIZE downto 0);
begin

    inter_operand1 <= '0' & operand1;
    inter_operand2 <= '0' & operand2;
  
    compute:process (command,inter_operand1,inter_operand2, reset)
       -- variable internal : unsigned(DATA_SIZE downto 0);
    begin
        if reset = '0' then
            overflow <= '0';
            negative_flag <= '0';
            internal <= (others => '0') ;
            bool_res <= '0';
        elsif command /= "00000000" then
                overflow <= '0';
                negative_flag <= '0';
                internal <= (others => '0') ;

                case command is 
                    when "0000"&"0001" => -- keep op1
                        internal <= unsigned(inter_operand1);
                    when "0000"&"0010" => -- keep op2
                        internal <= unsigned(inter_operand2);
                    when "0001"&"0000" =>   -- add op1 op2
                        internal <= unsigned(inter_operand1) + unsigned(inter_operand2);
                        overflow <= internal(DATA_SIZE);
                    when "0001"&"0001" =>   -- sub op1 op2
                        internal <= unsigned(inter_operand1) - unsigned(inter_operand2);
                        overflow <= internal(DATA_SIZE);
                    when "0010"&"0000" | "0010"&"0001"=>    -- [n]eq op1 op2
                        bool_res <=  not command(0) when inter_operand1 = inter_operand2 else command(0);
                    when "0010"&"0010" | "0010"&"0011"=>    -- [n]gt op1 op2
                        bool_res <=  not command(0) when inter_operand1 > inter_operand2 else command(0);
                    when "0010"&"0100" | "0010"&"0101"=>    -- [n]ge op1 op2
                        bool_res <=  not command(0) when inter_operand1 >= inter_operand2 else command(0);
                    when others => 
                        null;
                end case;
        end if;
    end process;

    output <=  std_logic_vector(internal(DATA_SIZE - 1 downto 0));

end architecture;
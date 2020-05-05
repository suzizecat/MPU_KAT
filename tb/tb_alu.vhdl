library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity tb_alu is
end entity;

architecture testbench of tb_alu is
    component alu is
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
            negative_flag : out std_logic;
    
            command : in std_logic_vector(7 downto 0)        
        );
    end component;
    
    constant DATA_SIZE : natural := 16;
    
    signal operand1, operand2, output : std_logic_vector(DATA_SIZE - 1 downto 0);
    signal command : std_logic_vector(7 downto 0);
    signal clk, reset : std_logic;

begin

    dut: entity work.alu
    generic map (
        data_size => data_size
    )
    port map (
        clk => clk,
        reset => reset,
        operand1 => operand1,
        operand2 => operand2,
        output => output,
        -- overflow => overflow,
        -- negative_flag => negative_flag,
        command => command
    );

    clkgen:process
    begin
        clk <= '0';
        for i in 0 to 35 loop
            clk <= '0';
            wait for 5 ns ;
            clk <= '1';
            wait for 5 ns;            
        end loop;
        wait;
    end process;

    rstgen:process
    begin
        reset <= '0';
        wait for 20 ns;
        reset <= '1';
        wait for 300 ns;
        reset <= '0';
        wait;
    end process;

    stimuli:process
    begin
        wait for 30 ns;
        operand1 <= "0000"&"0000"&"0000"&"0010";
        operand2 <= "0000"&"0000"&"0000"&"0110";
        wait for 10 ns ;
        command <= "0000"&"0001";
        wait for 10 ns ;
        command <= "0000"&"0010";
        wait for 10 ns ;
        command <= "0001"&"0000";
        wait for 10 ns ;
        operand1 <= "0000000000000100";
        wait for 10 ns ;
        operand2 <= "0000000000000001";
        wait for 10 ns ;
        operand1 <= (others => '1' );
        operand2 <= (others => '1');
        wait for 10 ns ;
        operand2 <= (others => '0');
        operand2(0) <= '1';
        wait for 10 ns ;
        command <= (others => '0');
        operand1 <= (others => '1' );
        operand2 <= (others => '1');
        wait for 10 ns ;
        operand2 <= (others => '0');
        operand2(0) <= '1';
        wait;

        
        wait;
    end process;
end architecture;
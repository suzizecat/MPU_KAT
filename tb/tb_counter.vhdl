library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity tb_counter is
end entity;

architecture testbench of tb_counter is
    component counter is
        generic (
            SIZE : natural := 32;
            MAX : natural := natural'high
        );
        port (
            clk   : in std_logic;
            reset : in std_logic;
    
            in_port: in unsigned (SIZE -1 downto 0);
            out_port: out unsigned (SIZE -1 downto 0);
    
            write : in std_logic      
        );
    end component;
    
    signal clk, reset, write : std_logic;
    signal in_port : unsigned (9 downto 0);
    signal out_port: unsigned (9 downto 0);
begin

    dut: entity work.counter
    generic map (
        size => 10,
        max => 10
    )
      port map (
        clk => clk,
        reset => reset,
        in_port => in_port,
        out_port => out_port,
        write => write
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
        write <= '0';
        in_port <= to_unsigned(0,10);
        wait for 50 ns ;
        in_port <= to_unsigned(5,10);
        write <= '1';
        wait for 20 ns;
        write <= '0';
        wait;
      end process;
end architecture;
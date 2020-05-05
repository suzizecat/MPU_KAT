library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

library std;
entity tb_mpu is
    
end entity;

architecture testbench of tb_mpu is
    component mpu is
        generic (
            ADDR_DATA_SIZE : natural := 16;
            ADDR_CMD_SIZE : natural :=8;
            INST_QTY : natural := 256        -- Amount of stored instruction in the ROM
        );
        port (
            clk   : in std_logic;
            reset : in std_logic;
    
            halt : out std_logic;
            query_bus : out std_logic_vector(ADDR_CMD_SIZE + ADDR_DATA_SIZE -1 downto 0 );
            reply_bus : in  std_logic_vector(ADDR_CMD_SIZE + ADDR_DATA_SIZE -1 downto 0 )
        );
    end component;

    signal cmd_bus : std_logic_vector (15 downto 0);
    signal clk, reset,rw,halt_sig : std_logic;
    
begin

    dut: entity work.mpu
      generic map (
        addr_data_size => 16,
        addr_cmd_size => 8,
        INST_QTY => 256
      )
      port map (
        clk => clk,
        reset => reset,
        -- query_bus
        halt => halt_sig,
        reply_bus => (others => '0')
      );
      
      clkgen:process
      begin
          clk <= '0';
          for i in 0 to 75 loop
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
          wait;
      end process;

    stop_handler:process (halt_sig)
    begin
        if halt_sig = '1' then 
            std.env.stop(0);           
        end if;
    end process;
end architecture;
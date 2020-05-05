library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity tb_rom is
end entity;

architecture testbench of tb_rom is
    component rom is
      generic (
        LENGTH : natural := natural'high;
        BYTE_WIDTH  : natural := 32;
        FILENAME: string := "./rom.bin"
      );
      port (
        clk   : in std_logic;
        
        addr : in natural range 0 to LENGTH;
        data : out std_logic_vector(BYTE_WIDTH*8 -1 downto 0 )
    );
    end component;

    constant rom_lenght : natural := 8;
    constant rom_width : natural := 16;
    

    signal addr : natural range 0 to rom_lenght -1;
    signal data : std_logic_vector(rom_width -1 downto 0);
    signal clk : std_logic;
begin

    dut: entity work.rom
      generic map (
        length => rom_lenght,
        BYTE_WIDTH => rom_width/8,
        filename => "/home/julien/Projets/VHDL/MPU_KAT/hex/rom.hex"
      )
      port map (
        clk => clk,
        addr => addr,
        data => data
      );

      clkgen:process
      begin
        clk <= '0';
        for i in 0 to 50 loop
          clk <= '0';
          wait for 5 ns;
          clk <= '1';
          wait for 5 ns;
        end loop;
        wait;
      end process;


      cntgen:process      
      begin
        addr <= 0;
        wait for 12 ns;
        for j in 0 to rom_lenght-1 loop
          addr <= j;
          wait for 10 ns;
        end loop;
        wait;
      end process;

end architecture;


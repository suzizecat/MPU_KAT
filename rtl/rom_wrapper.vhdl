library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;


entity rom_wrapper is
    generic (
        LENGTH : natural := natural'high;
        BYTE_WIDTH  : natural := 4;
        FILENAME: string := "./rom.bin"
    );
    port (
        clk   : in std_logic;
        
        addr : in natural range 0 to LENGTH;
        lock : in std_logic;
        data : out std_logic_vector(BYTE_WIDTH*8 -1 downto 0 ) := (others => '0')
    );
end entity;

architecture behav of rom_wrapper is
    component rom is
        generic (
            LENGTH : natural := natural'high;
            BYTE_WIDTH  : natural := 4;
            FILENAME: string := "./rom.bin"
        );
        port (
            clk   : in std_logic;
            
            addr : in natural range 0 to LENGTH;
            data : out std_logic_vector(BYTE_WIDTH*8 -1 downto 0 ) := (others => '0')
        );
    end component;

    signal content : std_logic_vector(BYTE_WIDTH*8 -1 downto 0 );

begin
    
    my_inst: entity work.rom
      generic map (
        length => LENGTH,
        byte_width => BYTE_WIDTH,
        filename => FILENAME
      )
      port map (
        clk => clk,
        addr => addr,
        data => content
      );

    
    process (clk)
    begin
        if rising_edge(clk) then
            if lock = '0' then
                data <= content;
            end if;
        end if;
    end process;

end architecture;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;


entity rom_arb is
    generic (
        LENGTH : natural := natural'high;
        WIDTH  : natural := 32;
        FILENAME: string := "./rom.bin"
    );
    port (
        clk   : in std_logic;
        
        addr : in natural range 0 to LENGTH;
        data : out std_logic_vector(WIDTH -1 downto 0 )
    );
end entity;

architecture behav of rom_arb is
    
    subtype WORD_t is std_logic_vector(WIDTH -1 downto 0);
    type ROM_t is array (LENGTH -1 downto 0) of WORD_t;
    
    
    subtype FILE_WORD_t is integer range 2**(WIDTH -1) downto 0;
    type ROM_FILE_t is FILE of FILE_WORD_t;


    impure function init_rom(name : string) return ROM_t is
        FILE file_in : ROM_FILE_t OPEN read_mode IS FILENAME;
        variable buff : FILE_WORD_t;
        variable processed_content : ROM_t := (others => (others => '0') );
    begin
        for i in 0 to LENGTH - 1 loop
            read(file_in,buff);
            processed_content(i) := std_logic_vector(to_unsigned(buff,WIDTH-1));
        end loop;
        return processed_content;
    end function;

    signal content : ROM_t := init_rom(FILENAME);
    
begin
    
    process (clk)
    begin
        if rising_edge(clk) then
            data <= content(addr);
        end if;
    end process;

end architecture;
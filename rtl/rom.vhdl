library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;


entity rom is
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
end entity;

architecture behav of rom is
    constant WIDTH : natural := BYTE_WIDTH*8-1;
    
    subtype WORD_t is std_logic_vector(WIDTH downto 0);
    type ROM_t is array (LENGTH -1 downto 0) of WORD_t;
    
    
    subtype FILE_WORD_t is character;
    type ROM_FILE_t is FILE of FILE_WORD_t;


    impure function init_rom(name : string) return ROM_t is
        FILE file_in : ROM_FILE_t OPEN read_mode IS FILENAME;
        variable buff : FILE_WORD_t;
        variable processed_content : ROM_t := (others => (others => '0') );
    begin
        for i in 0 to LENGTH - 1 loop
            --report "Reading "& natural'image(BYTE_WIDTH*8) & " bits word " & natural'image(i);
            for j in BYTE_WIDTH downto  1 loop 
                read(file_in,buff);
                processed_content(i)(j*8-1 downto (j-1)*8) := std_logic_vector(to_unsigned(character'pos(buff),8));
            end loop;
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
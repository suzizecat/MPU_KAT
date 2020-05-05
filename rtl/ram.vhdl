library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library std;
use std.textio.all;


entity ram is
    generic (
        LENGTH : natural := natural'high;
        BYTE_WIDTH  : natural := 4
    );
    port (
        clk   : in std_logic;
        reset : in std_logic;
        
        addr : in natural range 0 to LENGTH;
        data : inout std_logic_vector(BYTE_WIDTH*8 -1 downto 0 ) := (others => '0');
        rw   : in std_logic; -- 1 for write
        cs   : in std_logic
    );
end entity;

architecture behav of ram is
    constant WIDTH : natural := BYTE_WIDTH*8-1;
    
    subtype WORD_t is std_logic_vector(WIDTH downto 0);
    type ROM_t is array (LENGTH -1 downto 0) of WORD_t;
    
    signal content : ROM_t := (others => (others => '0'));

    signal output_enable, write_enable : std_logic;

    signal internal_databus : WORD_t;
    
begin
    

    output_enable <= (not rw) and cs and reset;
    write_enable <= rw and cs and reset;

    process (clk, reset)
    begin
        if reset = '0' then
            content <= (others => (others => '0') );
            internal_databus <= (others => '0') ;
        elsif rising_edge(clk) then
            if write_enable then
                content(addr) <= data;
            elsif output_enable then
                internal_databus <= content(addr);
            end if;
        end if;
    end process;

    data <= internal_databus when output_enable else (others => 'Z');



end architecture;
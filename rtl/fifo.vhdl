library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity fifo is
    generic (
        WIDTH : natural := 24;
        LENGTH: natural := 16
    );
    port (
        clk   : in std_logic;
        reset : in std_logic;
        
        input : in  std_logic_vector(WIDTH - 1 downto 0 );
        output: out std_logic_vector(WIDTH - 1 downto 0 );
        
        write : in  std_logic;
        read  : in  std_logic; -- 1 to go to next stored value
        full  : out std_logic;
        empty : out std_logic
    );
end entity;

architecture behav of fifo is    
    subtype WORD_t is std_logic_vector(WIDTH -1 downto 0);
    type FIFO_t is array (LENGTH -1 downto 0) of WORD_t;
    
    signal content : FIFO_t := (others => (others => '0'));
    signal r_ptr : natural range 0 to LENGTH - 1 := 0;
    signal w_ptr : natural range 0 to LENGTH - 1 := 0;
begin


    process (clk, reset)
    begin
        if reset = '0' then
            content <= (others => (others => '0'));
            empty <= '1';
            full  <= '0';
            r_ptr <=  0 ;
            w_ptr <=  0 ;

        elsif rising_edge(clk) then
            if write = '1' and full = '0' then
                content(w_ptr) <= input;
                w_ptr <= (w_ptr + 1) when w_ptr < LENGTH - 1 else  0;
                full  <= '1'         when r_ptr = w_ptr      else '0';
                empty <= '0';
            end if;
            if read = '1' and empty = '0' then
                r_ptr <= (r_ptr + 1) when r_ptr < LENGTH - 1 else  0 ;
                empty <= '1'         when r_ptr = w_ptr      else '0';
                full  <= '0';
            end if;
        end if;
    end process;

    output <= content(r_ptr);

end architecture;
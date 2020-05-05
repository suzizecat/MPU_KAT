library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

entity counter is
    generic (
        SIZE : natural := 32;
        MAX : natural := natural'high
    );
    port (
        clk   : in std_logic;
        reset : in std_logic;

        in_port: in unsigned (SIZE -1 downto 0);
        out_port: out unsigned (SIZE -1 downto 0);

        lock : in std_logic;
        write : in std_logic 
    );
end entity;

architecture behav of counter is
    signal cnt : unsigned (SIZE -1 downto 0);
begin

    process (clk, reset)
    begin
        if reset = '0' then
            cnt <= (others => '0');
        elsif rising_edge(clk) then
            if write = '1' then
                cnt <= in_port;
            else
                if lock = '0' then 
                    cnt <= cnt + 1 when cnt < MAX else (others => '0');
                end if ;
            end if;
        end if;
    end process;

    out_port <= cnt;

end architecture;

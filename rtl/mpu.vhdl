library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mpu is
    generic (
        ADDR_DATA_SIZE : natural := 16;
        ADDR_CMD_SIZE : natural :=8;
        INST_QTY : natural := 256        -- Amount of stored instruction in the ROM
    );
    port (
        clk   : in std_logic;
        reset : in std_logic;

        query_bus : out std_logic_vector(ADDR_CMD_SIZE + ADDR_DATA_SIZE -1 downto 0 );
        reply_bus : in  std_logic_vector(ADDR_CMD_SIZE + ADDR_DATA_SIZE -1 downto 0 );

        halt : out std_logic := '0'
    );
end entity;

architecture behav of mpu is

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
    
            lock : in std_logic;
            write : in std_logic      
        );
    end component;

    component rom_wrapper is
        generic (
          LENGTH : natural := natural'high;
          BYTE_WIDTH  : natural := 32;
          FILENAME: string := "./rom.bin"
        );
        port (
          clk   : in std_logic;
          lock : in std_logic;
          addr : in natural range 0 to LENGTH;
          data : out std_logic_vector(BYTE_WIDTH*8 -1 downto 0 )
      );
    end component;

    component ram is
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
    end component;

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
        bool_res : out std_logic;
        negative_flag : out std_logic;

        command : in std_logic_vector(7 downto 0)        
      );
    end component;

    
    signal in_cmd  : std_logic_vector(ADDR_CMD_SIZE - 1 downto 0) := (others => 'Z') ;
    signal in_data : std_logic_vector(ADDR_DATA_SIZE - 1 downto 0) := (others => 'Z');

    signal out_cmd  : std_logic_vector(ADDR_CMD_SIZE - 1 downto 0) ;
    signal out_data : std_logic_vector(ADDR_DATA_SIZE - 1 downto 0);

    constant ADDR_WORD_SIZE : natural := ADDR_DATA_SIZE + ADDR_CMD_SIZE;   

    signal r_instruction_pointer : unsigned(ADDR_DATA_SIZE-1 downto 0);
    signal w_instruction_pointer : unsigned(ADDR_DATA_SIZE-1 downto 0);
    signal force_instruction_pointer : std_logic;
    signal pause_instruction_pointer : std_logic;

    signal pause_instruction_memory : std_logic;

    signal w_cache_addr  : unsigned(ADDR_DATA_SIZE-1 downto 0);
    signal rw_cache_data : std_logic_vector(ADDR_DATA_SIZE-1 downto 0);
    signal w_cache_rw      : std_logic;

    signal r_instruction : std_logic_vector(ADDR_WORD_SIZE-1 downto 0);
    signal r_instruction_cmd : std_logic_vector(ADDR_CMD_SIZE-1 downto 0);
    signal r_instruction_data : std_logic_vector(ADDR_DATA_SIZE-1 downto 0);

    signal w_alu_op1 : std_logic_vector(ADDR_DATA_SIZE - 1 downto 0);
    signal w_alu_op2 : std_logic_vector(ADDR_DATA_SIZE - 1 downto 0);
    signal r_alu_res : std_logic_vector(ADDR_DATA_SIZE - 1 downto 0);
    signal w_alu_cmd  : std_logic_vector(7 downto 0);
    signal r_alu_flags: std_logic_vector(2 downto 0);

    type REG_BANK is array (0 to 15) of std_logic_vector(ADDR_DATA_SIZE - 1 downto 0);
    
    signal registers : REG_BANK;

    signal debug :natural;
    
    signal r_muxed_instruction : std_logic_vector(ADDR_WORD_SIZE - 1 downto 0);
    signal w_skip_instruction  : std_logic;
    
begin

    in_cmd <= reply_bus(ADDR_WORD_SIZE - 1 downto  ADDR_DATA_SIZE);
    in_data <= reply_bus(ADDR_DATA_SIZE - 1 downto 0 );

    query_bus <= out_cmd & out_data;

    r_muxed_instruction <= (others => '0') when w_skip_instruction = '1' else r_instruction;
    r_instruction_cmd <= r_muxed_instruction(ADDR_WORD_SIZE -1 downto ADDR_DATA_SIZE);
    r_instruction_data <= r_muxed_instruction(ADDR_DATA_SIZE -1 downto 0);

    instruction_pointer_counter: entity work.counter
      generic map (
        size => ADDR_DATA_SIZE,
        max => INST_QTY -1
      )
      port map (
        clk => clk,
        reset => reset,
        in_port => w_instruction_pointer,
        out_port => r_instruction_pointer,
        lock => pause_instruction_pointer,
        write => force_instruction_pointer
      );

    -- The ROM memory store full instructions (CMD + DATA)
    instruction_rom: entity work.rom_wrapper
      generic map (
        length => INST_QTY,
        byte_width => ADDR_WORD_SIZE/8,
        filename => "/home/julien/Projets/VHDL/MPU_KAT/hex/rom.hex"
      )
      port map (
        clk => clk,
        lock => pause_instruction_memory,
        addr => to_integer(r_instruction_pointer),
        data => r_instruction
      );

    cache_ram: entity work.ram
      generic map (
        length => 10,
        byte_width => ADDR_DATA_SIZE /8
      )
      port map (
        clk => clk,
        reset => reset,
        addr => to_integer(w_cache_addr),
        data => rw_cache_data,
        rw => w_cache_rw,
        cs => '1'
      );

    alu_inst: entity work.alu
      generic map (
        data_size => ADDR_DATA_SIZE
      )
      port map (
        clk => clk,
        reset => reset,
        operand1 => w_alu_op1,
        operand2 => w_alu_op2,
        output => r_alu_res,
        overflow => r_alu_flags(0),
        bool_res => r_alu_flags(1),
        negative_flag => r_alu_flags(2),
        command => w_alu_cmd
      );

    
    cpu:process (clk, reset)
      variable skip_cycles : natural := 0;
    begin
      -- Not yet actually used
      out_cmd               <= (others => '0');
      out_data              <= (others => '0');

      if reset = '0' then
     
        rw_cache_data         <= (others => 'Z');
        w_cache_addr          <= (others => '0');
        w_instruction_pointer <= (others => '0') ;
        w_alu_cmd             <= (others => '0') ;
        w_alu_op1             <= (others => '0') ;
        w_alu_op2             <= (others => '0') ;

        registers <=  (others => (others => '0') );

        w_skip_instruction        <= '0';
        w_cache_rw                <= '0';
        force_instruction_pointer <= '0';

        halt        <= '0';
        skip_cycles :=  0;

        
        
        
      elsif rising_edge(clk) then
        force_instruction_pointer <= '0';
        --pause_instruction_pointer <= '0';
        rw_cache_data <= (others => 'Z');
        w_cache_rw <= '0';
        w_alu_cmd <= (others => '0');
        w_alu_op1 <= (others => '0');
        w_alu_op2 <= (others => '0');
        
        if skip_cycles = 0 then
          w_skip_instruction <= '0';
          case r_instruction_cmd(7 downto 4) is 
            when "0001" =>
              
              case r_instruction_cmd(3 downto 0) is
                -- jumps
                when "0000" | "1000" => -- jumpto [cond] litteral
                  if r_instruction_cmd(3) = '0' or r_alu_flags(1) = '1' then 
                    w_instruction_pointer <= unsigned(r_instruction_data);
                    force_instruction_pointer <= '1';
                    w_skip_instruction <= '1';
                    skip_cycles := 1;
                    
                  end if;
                when "0001" | "1001" => -- jumpto [cond] cache
                  if r_instruction_cmd(3) = '0' or r_alu_flags(1) = '1' then 
                    w_instruction_pointer <= unsigned(rw_cache_data);
                    force_instruction_pointer <= '1';
                    w_skip_instruction <= '1';
                    skip_cycles := 1;
                    
                  end if;
                when "1010" | "0010" => -- jump [cond] to reg
                  if r_instruction_cmd(3) = '0' or r_alu_flags(1) = '1' then 
                    w_instruction_pointer <= unsigned(registers(to_integer(unsigned(r_instruction_data(3 downto  0)))));
                    force_instruction_pointer <= '1';
                    w_skip_instruction <= '1';
                    skip_cycles := 1;
                  end if;
                when "1111" => -- halt \o/
                  halt <= '1';
                when others =>
                  null;
              end case;
            
            when "0010" => 
              -- cache
              case r_instruction_cmd(3 downto 0) is
                when "0000" => -- setcache addr
                  w_cache_addr <= unsigned(r_instruction_data);
                when "0001" => -- writecache litteral
                  w_cache_rw <= '1';
                  skip_cycles := 1;
                  rw_cache_data <= r_instruction_data;
                  --pause_instruction_pointer <= '1';
                when "0010" => -- writecache reg
                  w_cache_rw <= '1';
                  rw_cache_data <= registers(to_integer(unsigned(r_instruction_data(3 downto  0))));
                when "0011" => -- cache to reg
                  registers(to_integer(unsigned(r_instruction_data(3 downto  0)))) <= rw_cache_data;
                when others => 
                  null;
              end case;
                -- write reg
              
            when "0011" => -- Write litteral in register x
                registers(to_integer(unsigned(r_instruction_cmd(3 downto  0)))) <= r_instruction_data;
              
              -- alu
            when "0100" => 
              case r_instruction_cmd(3 downto 0) is
                when "0010" | "0011" => -- [n]eq reg reg
                  w_alu_cmd <= "0010000" & r_instruction_cmd(0);
                  w_alu_op1 <= registers(to_integer(unsigned(r_instruction_data(11 downto  8))));
                  w_alu_op2 <= registers(to_integer(unsigned(r_instruction_data(3 downto  0))));
                when "0100" | "0101" => --[n]gt reg reg
                  w_alu_cmd <=  "0010"&"001" & r_instruction_cmd(0);
                  w_alu_op1 <= registers(to_integer(unsigned(r_instruction_data(11 downto  8))));
                  w_alu_op2 <= registers(to_integer(unsigned(r_instruction_data(3 downto  0))));
                when "0110" | "0111" => --[n]ge reg reg
                  w_alu_cmd <=  "0010"&"010" & r_instruction_cmd(0);
                  w_alu_op1 <= registers(to_integer(unsigned(r_instruction_data(11 downto  8))));
                  w_alu_op2 <= registers(to_integer(unsigned(r_instruction_data(3 downto  0))));
                when "1000" => -- sum reg reg
                  w_alu_cmd <= "00010000";
                  w_alu_op1 <= registers(to_integer(unsigned(r_instruction_data(11 downto  8))));
                  w_alu_op2 <= registers(to_integer(unsigned(r_instruction_data(3 downto  0))));
                when "1001" => -- sub reg reg
                  w_alu_cmd <= "00010001";
                  w_alu_op1 <= registers(to_integer(unsigned(r_instruction_data(11 downto  8))));
                  w_alu_op2 <= registers(to_integer(unsigned(r_instruction_data(3 downto  0))));
                when "1010" => -- incr reg
                  w_alu_cmd <= "00010000";
                  w_alu_op1(ADDR_DATA_SIZE - 1 downto 1) <= (others => '0') ;
                  w_alu_op1(0) <= '1';
                  w_alu_op2 <= registers(to_integer(unsigned(r_instruction_data(3 downto  0))));
                when "1011" => -- decr reg
                  w_alu_cmd <= "00010001";
                  w_alu_op1 <= registers(to_integer(unsigned(r_instruction_data(3 downto  0))));
                  w_alu_op2(ADDR_DATA_SIZE - 1 downto 1) <= (others => '0') ;
                  w_alu_op2(0) <= '1';
                when "1110" => -- alu to reg
                  registers(to_integer(unsigned(r_instruction_data(3 downto  0)))) <= r_alu_res;
                when "1111" => -- alu to cache
                  w_cache_rw <= '1';
                  skip_cycles := 1;
                  rw_cache_data <= r_alu_res;
                when others =>
                  null;
              end case;
            when others =>
              null;
            end case;
            --if skip_cycles : 0 then 
            --  pause_instruction_pointer <= '1';
            --end if;
          else
            skip_cycles := skip_cycles -1;
        end if;
       
      end if;
      pause_instruction_pointer <= '0' when skip_cycles = 0 else '1';
      pause_instruction_memory <= '0' when skip_cycles = 0 else '1';
      debug <= skip_cycles;
    end process;

    
    --;
end architecture;


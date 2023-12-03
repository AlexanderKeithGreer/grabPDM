library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity outUart is
    port (
        i_clk     : in  std_logic;
        i_reset   : in  std_logic;
        i_strobe  : in  std_logic;
        i_data    : in  std_logic_vector(7 downto 0);
        o_tx      : out std_logic
    );
end entity outUart;

architecture arch of outUart is
    -- Constants
    constant c_CLOCK_FREQ : natural := 12000000; -- 12MHz
    constant c_BAUD_RATE  : natural := 12000000;
    constant c_DIVISOR    : natural := c_CLOCK_FREQ / (c_BAUD_RATE);

    -- Signals
    signal s_baud_tick     : std_logic;
    signal s_counter       : unsigned(9 downto 0) := (others => '0');
    signal s_bit_index     : integer range 0 to 10 := 0; -- 8 data bits + 1 start bit
    signal s_tx_shift_reg  : std_logic_vector(8 downto 0);
    signal s_tx_active     : std_logic := '0';

begin

    -- Baud Rate Generator
    process(i_clk, i_reset)
    begin
	     if i_reset = '1' then
            s_counter <= (others => '0');
            s_baud_tick <= '0';
        elsif rising_edge(i_clk) then    
            if s_counter = c_DIVISOR - 1 then
                s_counter <= (others => '0');
                s_baud_tick <= '1';
            else
                s_counter <= s_counter + 1;
                s_baud_tick <= '0';
            end if;
        end if;
    end process;

    -- Transmitter Logic
    process(i_clk, i_reset)
    begin
		  if i_reset = '1' then
            s_tx_active <= '0';
            o_tx <= '1'; -- Default to high (idle state)
            s_bit_index <= 0;
        elsif rising_edge(i_clk) then
            if s_tx_active = '0' and i_strobe = '1' then
                s_tx_active <= '1';
                s_tx_shift_reg <= i_data & '0'; -- Start bit + data
                s_bit_index <= 0;
            elsif s_baud_tick = '1' and s_tx_active = '1' then
                if s_bit_index < 9 then
                    o_tx <= s_tx_shift_reg(s_bit_index);
                    s_bit_index <= s_bit_index + 1;
                else
                    s_tx_active <= '0';
                    o_tx <= '1'; -- Stop bit
                end if;
				end if;
        end if;
    end process;

end arch;

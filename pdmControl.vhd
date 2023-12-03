library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pdmControl is
    generic (
        g_OUT_WIDTH : integer:=8);
    port(
        i_clk       : in  std_logic;                    -- 12 MHz clock input
        i_rst       : in  std_logic;
        i_pdm_data  : in  std_logic;                    -- PDM microphone data input
        o_mic_clk   : out std_logic;                    -- 3 MHz output clock for PDM microphone
        o_data_vect : out std_logic_vector(g_OUT_WIDTH-1 downto 0); -- data vector output
        o_strobe    : out std_logic);                   -- 19.2KHz strobe signal output
end pdmControl;

architecture Behavioral of pdmControl is
    -- Constants and signals declaration
    constant c_MIC_CLOCK_DIVIDER : integer := 4; -- For generating 3 MHz from 12 MHz
    constant c_STROBE_DIVIDER   : integer := 300; -- Approx. for generating 40 KHz from 12 MHz
    signal s_mic_clock_counter  : integer := 0;
    signal s_strobe_counter     : integer := 0;
    signal s_accumulator        : signed(15 downto 0) := (others => '0');
    signal s_last               : signed(15 downto 0) := (others => '0');
    signal s_accumulator2       : signed(15 downto 0) := (others => '0');
    signal s_last2              : signed(15 downto 0) := (others => '0');
    signal s_sample             : std_logic := '0';
    signal s_data_vect_reg      : signed(15 downto 0) := (others => '0');
    signal s_strobe_reg         : std_logic := '0';
begin
    -- Clock division for PDM microphone clock
    o_mic_clk <= '1' when s_mic_clock_counter < c_MIC_CLOCK_DIVIDER/2 else '0';

    process(i_clk, i_rst)
    begin
        if (i_rst = '1') then
            s_mic_clock_counter <= 0;
            s_strobe_counter    <= 0;
            s_accumulator       <= (others => '0');
            s_data_vect_reg     <= (others => '0');
            s_strobe_reg        <= '0';
        elsif rising_edge(i_clk) then
            -- Mic clock division
            if s_mic_clock_counter = c_MIC_CLOCK_DIVIDER-1 then
                s_mic_clock_counter <= 0;
            else
                s_mic_clock_counter <= s_mic_clock_counter + 1;
            end if;

            -- Strobe signal generation
            if s_strobe_counter = c_STROBE_DIVIDER-1 then
                s_strobe_counter <= 0;
                s_strobe_reg <= '1';
            else
                s_strobe_counter <= s_strobe_counter + 1;
                s_strobe_reg <= '0';
            end if;

            -- Sample PDM data on the falling edge of mic clock
            if s_mic_clock_counter = c_MIC_CLOCK_DIVIDER/2-1 then
                if i_pdm_data = '1' then
                    s_accumulator <= s_accumulator + to_signed(1, 16);
                else
                    s_accumulator <= s_accumulator - to_signed(1, 16);
                end if;
            end if;
            if s_mic_clock_counter = c_MIC_CLOCK_DIVIDER/2-1 then
                    s_accumulator2 <= s_accumulator + s_accumulator2;
            end if;

            -- Decimation and output data
            if s_strobe_reg = '1' then
                s_data_vect_reg <= (s_accumulator2 - s_last) - s_last2;
                s_last <= s_accumulator2;
                s_last2 <= s_accumulator2 - s_last;
            end if;

            o_strobe <= s_strobe_reg;
        end if;
    end process;

    o_data_vect <= std_logic_vector(s_data_vect_reg(g_OUT_WIDTH-1 downto 0));

end Behavioral;

-- ----------------------------------------------------------------
-- AI PDM
-- ----------------------------------------------------------------
-- More mucking around with LLMs to generate HDL
-- This is an extremely simple example intended
--  to interface with a PDM microphone
-- ----------------------------------------------------------------
-- PINS
--  i_clk       M2
--  i_mic       R1 <TBD>
--  i_but       N6      (Active Low)
--  o_led[0]    M6
--  o_led[1]    T4
--  o_led[2]    T3
--  o_led[3]    R3
--  o_led[4]    T2
--  o_led[5]    R4
--  o_led[6]    N5
--  o_led[7]    N3
--  o_mic       P1 <TBD>
--  o_uart      T7

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity aiPdm is
    port (
        i_clk   : in std_logic;
        i_mic   : in std_logic;
        i_but   : in std_logic;
        o_led   : out std_logic_vector(7 downto 0);
        o_mic   : out std_logic;
        o_uart  : out std_logic);
end entity aiPdm;

architecture arch of aiPdm is

    component outUart
        port(
            i_clk     : in  std_logic;
            i_reset   : in  std_logic;
            i_strobe  : in  std_logic;
            i_data    : in  std_logic_vector(7 downto 0);
            o_tx      : out std_logic
        );
    end component;

    component pdmControl is
        generic (
            g_OUT_WIDTH : integer:=8);
        port(
            i_clk       : in  std_logic;                    -- 12 MHz clock input
            i_rst       : in  std_logic;
            i_pdm_data  : in  std_logic;                    -- PDM microphone data input
            o_mic_clk   : out std_logic;                    -- 3 MHz output clock for PDM microphone
            o_data_vect : out std_logic_vector(g_OUT_WIDTH-1 downto 0); -- data vector output
            o_strobe    : out std_logic);                   -- 19.2KHz strobe signal output
    end component;

    constant c_OUT_WIDTH : integer := 8;
    signal s_inv_but : std_logic;
    signal s_audio   : std_logic_vector(c_OUT_WIDTH-1 downto 0);
    signal s_output  : std_logic_vector(7 downto 0);
    signal s_strobe  : std_logic;
begin

    s_inv_but <= not i_but;

    OTX: outUart
        port map (i_clk     => i_clk,
                  i_reset   => '0',
                  i_strobe  => s_strobe,
                  i_data    => s_output,
                  o_tx      => o_uart);

    MIC: pdmControl
        generic map (g_OUT_WIDTH => c_OUT_WIDTH)
        port map (i_clk         => i_clk,
                  i_rst         => '0',
                  i_pdm_data    => i_mic,
                  o_mic_clk     => o_mic,
                  o_data_vect   => s_audio,
                  o_strobe      => s_strobe);

    TEST: process(i_clk)
    begin
        if (rising_edge(i_clk)) then
            if (i_but = '1') then
                s_output <= s_audio(c_OUT_WIDTH-1 downto c_OUT_WIDTH-8);
                if s_audio(c_OUT_WIDTH-1) = '0' then
                    o_led <= s_audio(c_OUT_WIDTH-1 downto c_OUT_WIDTH-8);
                else
                    o_led <= not s_audio(c_OUT_WIDTH-1 downto c_OUT_WIDTH-8);
                end if;
            else
                s_output 	<= x"0F";
                o_led 		<= x"0F";
            end if;
        end if;
    end process;


end arch;

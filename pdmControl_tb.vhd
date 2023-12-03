library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all; -- For file I/O

entity pdmControl_tb is
end pdmControl_tb;

architecture tb of pdmControl_tb is
    -- Component declaration of the pdm_controller
    component pdmControl is
        generic (
            g_OUT_WIDTH : integer:=32);
        port(
            i_clk       : in  std_logic;                    -- 12 MHz clock input
            i_rst       : in  std_logic;
            i_pdm_data  : in  std_logic;                    -- PDM microphone data input
            o_mic_clk   : out std_logic;                    -- 3 MHz output clock for PDM microphone
            o_data_vect : out std_logic_vector(g_OUT_WIDTH-1 downto 0); -- data vector output
            o_strobe    : out std_logic);                   -- 19.2KHz strobe signal output
    end component;

    -- Signals for interfacing with the component
    constant c_OUT_WIDTH : integer := 16;

    signal i_clk       : std_logic := '0';
    signal i_rst       : std_logic := '1';
    signal i_pdm_data  : std_logic;
    signal o_mic_clk   : std_logic;
    signal o_data_vect : std_logic_vector(c_OUT_WIDTH-1 downto 0);
    signal o_strobe    : std_logic;


    -- File I/O
    file pdm_file      : text open read_mode is "C:/Users/Alexander Greer/Documents/aiPdm/pdm_data.csv";
    signal s_compare_val : integer := 0; -- Signal to hold the arbitrary range integer
begin
    -- Instantiate the component
    uut: pdmControl
        generic map (
            g_OUT_WIDTH => c_OUT_WIDTH)
        port map(
            i_clk       => i_clk,
            i_rst       => i_rst,
            i_pdm_data  => i_pdm_data,
            o_mic_clk   => o_mic_clk,
            o_data_vect => o_data_vect,
            o_strobe    => o_strobe);

    -- Clock generation
    clk_process: process
    begin
        i_clk <= '0';
        wait for 41.67 ns; -- 12 MHz clock period is about 83.33 ns
        i_clk <= '1';
        wait for 41.67 ns;
        i_rst <= '0';
    end process clk_process;

    -- PDM data reading process
    pdm_data_process: process
        variable v_file_line    : line;
        variable v_line_data    : string(1 to 32);
        variable v_pdm_val      : bit;
        variable v_comma        : character;
        variable v_compare_val  : integer := 0;
    begin
        wait until rising_edge(o_mic_clk);
        if not endfile(pdm_file) then
            readline(pdm_file, v_file_line);
            read(v_file_line, v_compare_val); -- Read the arbitrary range integer
            read(v_file_line, v_comma); -- Read the comma
            read(v_file_line, v_pdm_val); -- Read the PDM value (0 or 1)

            s_compare_val <= v_compare_val;
            if v_pdm_val = '1' then
                i_pdm_data <= '1';
            else
                i_pdm_data <= '0';
            end if;
        else
            -- Handle end of file or repeat the read process
            wait;
        end if;
    end process pdm_data_process;

end tb;

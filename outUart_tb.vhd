library ieee;
use ieee.std_logic_1164.all;

entity outUart_tb is
    -- Testbench has no ports
end entity outUart_tb;

architecture behavior of outUart_tb is
    -- Component Declaration for the Unit Under Test (UUT)
    component outUart
        port(
            i_clk     : in  std_logic;
            i_reset   : in  std_logic;
            i_strobe  : in  std_logic;
            i_data    : in  std_logic_vector(7 downto 0);
            o_tx      : out std_logic
        );
    end component;

    -- Record type for input set
    type input_record is record
        i_data   : std_logic_vector(7 downto 0);
        i_reset  : std_logic;
        i_strobe : std_logic;
    end record;

    -- Array of test inputs
    type input_array is array (natural range <>) of input_record;
    constant test_inputs : input_array := (
        (i_data => "10101010", i_reset => '0', i_strobe => '1'),
        -- Additional test scenarios can be added here
        (i_data => "11001100", i_reset => '0', i_strobe => '1'),
		  (i_data => "11101111", i_reset => '0', i_strobe => '1')
        -- ... more test cases ...
    );

    -- Inputs
    signal s_clk    : std_logic := '0';
	 signal s_data   : std_logic_vector(7 downto 0);
	 signal s_reset  : std_logic;
	 signal s_strobe : std_logic;
	 
    -- Outputs
    signal o_tx     : std_logic;

    -- Clock period definitions
    constant clk_period : time := 83.333 ns; -- 12 MHz clock

begin
    -- Instantiate the Unit Under Test (UUT)
    uut: outUart
        port map (
            i_clk => s_clk,
            i_reset => s_reset,
            i_strobe => s_strobe,
            i_data => s_data,
            o_tx => o_tx
        );

    -- Clock process definitions
    clk_process: process
    begin
        s_clk <= '0';
        wait for clk_period/2;
        s_clk <= '1';
        wait for clk_period/2;
    end process;

    -- Testbench statements
    stim_proc: process
        variable idx : integer := 1;
    begin
        -- Reset
        wait for clk_period * 10;

        -- Iterating over the test input array
        for i in test_inputs'range loop
            -- Apply each test input set
            s_reset <= test_inputs(i).i_reset;
            s_strobe <= test_inputs(i).i_strobe;
            s_data <= test_inputs(i).i_data;

            wait for clk_period; -- Wait some time for each test case
				s_strobe <= '0';
				
				wait for 86800ns; -- Wait for 1/115200 * 10
            
        end loop;

        --wait; -- Stop the simulation
    end process;

end behavior;

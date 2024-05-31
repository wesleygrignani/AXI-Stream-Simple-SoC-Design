----------------------------------------------------------------------------------
-- Name: Wesley Grignani
-- Laboratory of Embedded and Distributed Systems (LEDS) - UNIVALI
-- Project: Simple AXI-Stream IP design
-- Desc: Datapath design
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity datapath is
  port (
    -- Clock and reset signals 
    s_axis_clk    : in std_logic;
    s_axis_rst    : in std_logic;
    -- Data input 
    s_axis_data   : in std_logic_vector(31 downto 0);
    s_axis_last   : in std_logic;
    -- Control signals
    en_calc_reg_i : in std_logic;
    s_axis_valid  : in std_logic;
    en_data_reg_i : in std_logic;
    -- Data output
    m_axis_last : out std_logic;
    data_o      : out std_logic_vector(31 downto 0)
  );
end entity;

architecture rtl of datapath is

  component reg
    port (
      clk_i  : in std_logic;
      ena_i  : in std_logic;
      rst_i  : in std_logic;
      data_i : in  std_logic_vector(31 downto 0);
      data_o : out std_logic_vector(31 downto 0)
    );
  end component;

  signal data_w : std_logic_vector(31 downto 0) := (others => '0');
  signal calc_w : std_logic_vector(31 downto 0) := (others => '0');
  signal en_reg_input_w : std_logic;

begin

  en_reg_input_w <= s_axis_valid and en_data_reg_i;

  process (all)
  begin
    if (s_axis_rst = '1') then 
      m_axis_last <= '0';
    elsif (rising_edge(s_axis_clk)) then
      if(en_reg_input_w = '1') then 
        m_axis_last <= s_axis_last;
      end if;
    end if; 
  end process; 

  -- Input data register
  input_reg : reg
  port map (
    clk_i  => s_axis_clk,
    ena_i  => en_reg_input_w,
    rst_i  => s_axis_rst,
    data_i => s_axis_data,
    data_o => data_w
  );

  -- Perform your calculation here 
  calc_w <= data_w;

  -- Output data register
  calc_reg : reg
  port map (
    clk_i  => s_axis_clk,
    ena_i  => en_calc_reg_i,
    rst_i  => s_axis_rst,
    data_i => calc_w,
    data_o => data_o
  );



end architecture;
----------------------------------------------------------------------------------
-- Name: Wesley Grignani
-- Laboratory of Embedded and Distributed Systems (LEDS) - UNIVALI
-- Project: Simple AXI-Stream IP design
-- Desc: Top level 
----------------------------------------------------------------------------------
-- Definition of Ports
-- s_axis_clk    : Synchronous clock
-- s_axis_rst    : System reset, active high
---------------------- SLAVE -------------------------
-- s_axis_ready  : Ready to accept data in (Ready bit from IP to DMA)
-- s_axis_data   : Data in (Data from the DMA to the IP)
-- s_axis_last   : Optional data in qualifier (Last Bit from DMA to IP) 
-- s_axis_valid  : Data in is valid (Valid bit from DMA to IP)
---------------------- MASTER ------------------------
-- m_axis_valid  : Data out is valid (Valid bit from IP to DMA)
-- m_axis_data   : Data Out (Data out from IP to DMA)
-- m_axis_last   : Optional data out qualifier (Last Bit from IP to DMA)
-- m_axis_ready  : Connected slave device is ready to accept data out (Ready Bit from DMA to IP)
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity top is
  port (
    -- AXI-Stream clock and reset 
    s_axis_clk  : in std_logic;
    s_axis_rst  : in std_logic;
    -- AXI-Stream Slave interface
    s_axis_valid : in  std_logic;
    s_axis_ready : out std_logic;
    s_axis_last  : in  std_logic;
    s_axis_data  : in  std_logic_vector(31 downto 0); 
    -- AXI-Stream Master interface
    m_axis_valid : out std_logic;
    m_axis_ready : in  std_logic;
    m_axis_last  : out std_logic;
    m_axis_data  : out std_logic_vector(31 downto 0)
  );
end entity;

architecture rtl of top is

  component control
    port (
      s_axis_clk   : in  std_logic;
      s_axis_rst   : in  std_logic;
      s_axis_valid : in  std_logic;
      s_axis_ready : out std_logic;
      m_axis_valid : out std_logic;
      m_axis_ready : in  std_logic;
      en_reg_o     : out std_logic
    );
  end component;

  component datapath
    port (
      s_axis_clk    : in  std_logic;
      s_axis_rst    : in  std_logic;
      s_axis_data   : in  std_logic_vector(31 downto 0);
      s_axis_last   : in  std_logic;
      en_calc_reg_i : in  std_logic;
      s_axis_valid  : in  std_logic;
      en_data_reg_i : in  std_logic;
      m_axis_last   : out std_logic;
      data_o        : out std_logic_vector(31 downto 0)
    );
  end component;

  signal en_calc_reg_w  : std_logic;
  signal s_axis_ready_w : std_logic;

begin
 
  control_inst : control
  port map (
    s_axis_clk   => s_axis_clk,
    s_axis_rst   => s_axis_rst,
    s_axis_valid => s_axis_valid,
    s_axis_ready => s_axis_ready_w,
    m_axis_valid => m_axis_valid,
    m_axis_ready => m_axis_ready,
    en_reg_o     => en_calc_reg_w
  );

  datapath_inst : datapath
  port map (
    s_axis_clk    => s_axis_clk,
    s_axis_rst    => s_axis_rst,
    s_axis_data   => s_axis_data,
    s_axis_last   => s_axis_last,
    en_calc_reg_i => en_calc_reg_w,
    s_axis_valid  => s_axis_valid,
    en_data_reg_i => s_axis_ready_w,
    m_axis_last   => m_axis_last,
    data_o        => m_axis_data
  );

  s_axis_ready <= s_axis_ready_w; 

end architecture;
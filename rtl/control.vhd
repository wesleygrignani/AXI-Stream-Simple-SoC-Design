----------------------------------------------------------------------------------
-- Name: Wesley Grignani
-- Laboratory of Embedded and Distributed Systems (LEDS) - UNIVALI
-- Project: Simple AXI-Stream IP design
-- Desc: Controller design
----------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity control is
  port (
    -- Clock and reset inputs 
    s_axis_clk   : in std_logic;
    s_axis_rst   : in std_logic;
    -- Slave signals 
    s_axis_valid : in  std_logic;
    s_axis_ready : out std_logic;
    -- Master signals 
    m_axis_valid : out std_logic;
    m_axis_ready : in  std_logic;
    -- Internal control signals 
    en_reg_o : out std_logic
  );
end entity;

architecture rtl of control is
  
  type state_t is (wait_s, calc_s, write_s);
  signal next_w  : state_t; -- next state
  signal state_r : state_t; -- current state

begin
  
  -- State register 
  process (all)
  begin
    if (s_axis_rst = '1') then 
      state_r <= wait_s; 
    elsif (rising_edge(s_axis_clk)) then 
      state_r <= next_w;
    end if;
  end process;
  
  -- Next state transitions 
  process (all)
  begin
    case state_r is
      -- Initial State (Wait for DMA to input a valid data)
      when wait_s => 
        if(s_axis_valid = '1') then 
          next_w <= calc_s;
        else
          next_w <= wait_s;
        end if;
      -- State that perform some calculations
      when calc_s => next_w <= write_s;
      -- Final state (Wait for DMA to be ready to read data)
      when write_s => 
        if(m_axis_ready = '1') then 
          next_w <= wait_s;
        else 
          next_w <= write_s;
        end if;

      when others => next_w <= wait_s;
    end case;  
  end process;

  -- Control signals 
  s_axis_ready <= '1' when state_r = wait_s else '0'; -- IP is ready to accept data only in first state
  
  m_axis_valid <= '1' when state_r = write_s else '0'; -- Output value is valid only in last state 
  
  en_reg_o <= '1' when state_r = calc_s else '0'; -- Enable for internal register 
    
end architecture;
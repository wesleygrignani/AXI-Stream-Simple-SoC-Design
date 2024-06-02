library ieee;
use ieee.std_logic_1164.all;

entity reg is
  port (
    clk_i  : in  std_logic;
    ena_i  : in  std_logic;
    rst_i  : in  std_logic;
    data_i : in  std_logic_vector(31 downto 0);
    data_o : out std_logic_vector(31 downto 0)
  );
end entity;

architecture rtl of reg is

begin

  process (rst_i, clk_i, ena_i)
  begin
    if (rst_i = '1') then 
      data_o <= (others => '0');
    elsif (rising_edge(clk_i)) then
      if(ena_i = '1') then 
        data_o <= data_i;
      end if;
    end if; 
  end process;    

end architecture;
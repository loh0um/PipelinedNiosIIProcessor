library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity PC is
    port(
        clk       : in  std_logic;
        reset_n   : in  std_logic;
        sel_a     : in  std_logic;
        sel_imm   : in  std_logic;
        branch    : in  std_logic;
        a         : in  std_logic_vector(15 downto 0);
        d_imm     : in  std_logic_vector(15 downto 0);
        e_imm     : in  std_logic_vector(15 downto 0);
        pc_addr   : in  std_logic_vector(15 downto 0);
        addr      : out std_logic_vector(15 downto 0);
        next_addr : out std_logic_vector(15 downto 0)
    );
end PC;

architecture synth of PC is
	signal s_addressCur, s_addressNext, s_muxTop, s_muxBottom: std_logic_vector(15 downto 0);
	
begin
	
	s_addressCur <= 
		d_imm(13 downto 0) & "00" when (sel_imm = '1' and sel_a = '0')
		else std_logic_vector(unsigned(a) + 4) when (sel_imm = '0' and sel_a = '1')
		else std_logic_vector(unsigned(s_muxTop) + unsigned(s_muxBottom)) when (sel_imm = '0' and sel_a = '0')
		else X"0000"; --Should never happen
	
	s_muxTop <= 
		s_addressNext when branch = '0'
		else pc_addr;
	
	s_muxBottom <= 
		X"0004" when branch = '0'
		else std_logic_vector(unsigned(e_imm) + 4);
	
	counterRegister:process (clk,reset_n) is
	begin
		if (reset_n='0') then 
			s_addressNext<=(others=>'0');
		elsif (rising_edge(clk)) then
			s_addressNext <= s_addressCur;
		end if;
			
	end process counterRegister;
	
	addr<= s_addressCur(15 downto 2) & "00";
	next_addr <= s_addressNext(15 downto 2) & "00";
	
end synth;

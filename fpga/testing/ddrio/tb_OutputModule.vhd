library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.math_real.all;

entity tb_OutputModule is
end entity tb_OutputModule;

architecture Behavior of tb_OutputModule is
	component ClockGenerator is
		generic (
			f : real
		);
		port (
			clk: out std_logic
		);
	end component;

	component OutputModule is
		generic (
			-- Number of sysclk cycles to delay output DQS
			DQS_DELAY: natural
		);
		port (
			sysclk	: in std_logic;				-- System clock
			en		: in std_logic;				-- Enable registers
			rst		: in std_logic;				-- Synchronous reset
			oe		: in std_logic;

			D		: in signed(8 downto 0);	-- Data
			mask	: in std_logic;				-- Data mask
			DDR_D	: out signed(8 downto 0);	-- Output data	(TriState)
			DDR_mask: out std_logic;			-- Output data mask


			DQS		: in std_logic;				-- DQS
			DDR_DQS : out std_logic				-- Output DQS (TriState)
		);
	end component OutputModule;

	constant ddrclk_freq : real := 100e6;	-- 100 MHz DDR clock
	constant ddrclk_T	 : time := 1.0/ddrclk_freq * 1.0 sec;
	constant sysclk_freq : real := 400e6;	-- 400 MHz system clock
	constant sysclk_T 	 : time := 1.0/sysclk_freq * 1.0 sec
	constant DQS_DELAY : natural := 1;

	-- Clocks
	signal sysclk, ddrclk: std_logic;
	-- Controls
	signal en, rst, oe: std_logic;
	-- data
	signal D	 : signed(7 downto 0) := "00000000";
	signal DDR_D : signed(7 downto 0);
	signal mask, DQS, DDR_mask, DDR_DQS : std_logic;
begin
	-- Generate clocks
	cmp_clkgen_sysclk: ClockGenerator
		generic map (sysclk_freq)
		port map (sysclk);
	cmp_clkgen_ddrclk: ClockGenerator
		generic map (ddrclk_freq)
		port map (ddrclk);

	-- DUT
	cmp_dut: OutputModule
		generic map(DQS_DELAY);
		port map(sysclk, en, rst, oe, D, mask, DDR_D, DDR_mask,
			DQS, DDR_DQS);

	-- Data generation process
	proc_dgen: process(ddrclk)
	begin
		if rising_edge(clk) then
			D <= D + 1;
		end if;
	end process proc_dgen;

	-- Testbench process
	proc_tb: process
	begin
		rst <= '1';
		en <= '0';
		mask <= '0';
		oe <= '0';
		wait for 1.0 * sysclk_T;
		wait until rising_edge(sysclk);
		rst <= '0';
		en <= '1';
		oe <= '1';
		wait until rising_edge(sysclk);
		wait;
	end process proc_tb;
end architecture Behavior;

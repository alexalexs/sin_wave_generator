library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sin_osc is
	generic (
		M : integer := 16; -- array length
		N : integer := 8 --bit width
	);
	port (
		clk, reset : in std_logic;
		y : out std_logic_vector(N - 1 downto 0)
	);
end entity;

architecture arch of sin_osc is
	signal complete_tick : std_logic;
	signal count_uut0_s_uut3,
	count_uut1_i0_uut3,
	count_rev_uut1_i1_uut3,
	count_uut2_s_uut5,
	y_uut3_addr_uut4,
	data_uut4_i0_uut5,
	data_sig_uut4_i1_uut5,
	count_rev,
	z_del : std_logic_vector(N - 1 downto 0);

	component read_rom_tb is
		generic (
			rom_depth : natural := 8;
			rom_width : natural := 8;
			sim_rom_file : string := "sin_rom.mif"
		);
		port (
			clk, reset : in std_logic;
			addr : in std_logic_vector(rom_width - 1 downto 0);
			data : out std_logic_vector(rom_width - 1 downto 0);
			data_sig : out std_logic_vector(rom_width - 1 downto 0)
		);
	end component;

	component multiplexer is
		generic (
			N : integer := 8;
			M : integer := 7
		);
		port (
			s : in std_logic_vector(N - 1 downto 0);
			i0 : in std_logic_vector(N - 1 downto 0);
			i1 : in std_logic_vector(N - 1 downto 0);
			y : out std_logic_vector(N - 1 downto 0)
		);
	end component;

	component modMCounter is
		generic (
			M : integer := 5; -- count from 0 to M-1
			N : integer := 4 -- N bits required to count upto M i.e. 2**N >= M
		);

		port (
			clk, reset : in std_logic;
			complete_tick : out std_logic;
			count : out std_logic_vector(N - 1 downto 0);
			count_rev : out std_logic_vector(N - 1 downto 0)
		);
	end component;

begin

	uut0 : modMCounter generic map(M => 2 * M, N => N)
	port map(
		clk => clk, reset => reset,
		complete_tick => complete_tick,
		count => count_uut0_s_uut3,
		count_rev => count_rev
	);

	uut1 : modMCounter generic map(M => M, N => N)
	port map(
		clk => clk, reset => reset,
		complete_tick => complete_tick,
		count => count_uut1_i0_uut3,
		count_rev => count_rev_uut1_i1_uut3
	);

	uut2 : modMCounter generic map(M => 4 * M, N => N)
	port map(
		clk => clk, reset => reset,
		complete_tick => complete_tick,
		count => count_uut2_s_uut5,
		count_rev => count_rev
	);

	uut3 : multiplexer generic map(M => M, N => N)
	port map(
		s => count_uut0_s_uut3,
		i0 => count_uut1_i0_uut3,
		i1 => count_rev_uut1_i1_uut3,
		y => y_uut3_addr_uut4
	);

	uut4 : read_rom_tb generic map(
		rom_depth => M,
		rom_width => N,
		sim_rom_file => "sin_rom.mif")
	port map(
		clk => clk, reset => reset,
		addr => y_uut3_addr_uut4,
		data => data_uut4_i0_uut5,
		data_sig => data_sig_uut4_i1_uut5
	);

	uut5 : multiplexer generic map(M => 2 * M, N => N)
	port map(
		s => z_del,
		i0 => data_uut4_i0_uut5,
		i1 => data_sig_uut4_i1_uut5,
		y => y
	);

	-- latch
	process (clk)
	begin
		if (clk'event and clk = '1') then
			z_del <= count_uut2_s_uut5;
		end if;
	end process;
end arch;
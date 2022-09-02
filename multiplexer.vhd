library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplexer is
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
end multiplexer;

architecture arch of multiplexer is
begin

	y <= i0 when unsigned(s) < to_unsigned(M, N) else
		i1 when unsigned(s) > to_unsigned(M, N);

end arch;
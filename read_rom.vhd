library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use ieee.std_logic_textio.all;

entity read_rom_tb is
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
end entity;

architecture arch of read_rom_tb is

	type rom_arr is array(0 to rom_depth - 1) of std_logic_vector(rom_width - 1 downto 0);

	impure function init_mem(mif_file_name : in string) return rom_arr is
		file mif_file : text open read_mode is mif_file_name;
		variable mif_line : line;
		variable temp_bv : bit_vector(rom_width - 1 downto 0);
		variable temp_mem : rom_arr;

	begin
		for i in rom_arr'range loop
			readline(mif_file, mif_line);
			read(mif_line, temp_bv);
			temp_mem(i) := to_stdlogicvector(temp_bv);
		end loop;
		return temp_mem;
	end function;

	signal rom_block : rom_arr := init_mem(sim_rom_file);

begin

	process (clk)
	begin
		if (clk'event and clk = '1') then
			data <= rom_block(to_integer(unsigned(addr)));
			data_sig <= std_logic_vector(0 - signed(unsigned(rom_block(to_integer(unsigned(addr))))));
		end if;
	end process;

end arch;
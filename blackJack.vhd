library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

-- LEDR(0) indicates losing the game
-- LEDG(0) indicates winning the game
-- KEY(0) is game clock
-- KEY(1) is reset
-- KEY(2) is "stay"
-- KEY(3) is "hit"
entity blackJack is
	port (KEY: in std_logic_vector(3 downto 0);
			LEDR: out std_logic_vector(0 downto 0);
			LEDG: out std_logic_vector(0 downto 0) );
end blackJack;

architecture log of blackJack is
	signal count: integer range 0 to 51 := 0;
	signal myHand, dealHand: integer range 0 to 50 := 0;
	signal win, lose: std_logic := '0';
	signal winLED, loseLED: std_logic := '0';
	
	type deck is array (0 to 51) of integer range 2 to 11;
	signal myDeck: deck := (7, 11, 5, 6, 9, 11, 8, 7, 4, 6, 6, 2, 5, 6, 4, 11, 8, 7, 4, 6,
									6, 2, 5, 6, 4, 11, 8, 7, 4, 6, 6, 2, 5, 6, 4, 11, 8, 7, 4, 6,
									6, 2, 5, 6, 4, 11, 8, 7, 4, 6, 5, 3 );
begin

	-- Assign indicator lights
	LEDG(0) <= winLED;
	LEDR(0) <= loseLED;
	
	-- Lose Light Register
	process(KEY(1), lose) begin
		if KEY(1) = '0' then
			loseLED <= '0';
		elsif rising_edge(lose) then
			loseLED <= '1';
		end if;
	end process;
	
	-- Win Light Register
	process(KEY(1), win) begin
		if KEY(1) = '0' then
			winLED <= '0';
		elsif rising_edge(win) then
			winLED <= '1';
		end if;
	end process;
	
	-- deck counter
	process(KEY(0)) begin
		if rising_edge(KEY(0)) then
			count <= count + 1;
		end if;
	end process;
	
	-- dealer hand generation
	process(KEY(0), count, KEY(1)) begin
		if KEY(1) = '0' then
			dealHand <= 0;
		elsif rising_edge(KEY(0)) and (count < 2) then
			dealHand <= dealHand + myDeck(count);
		end if;
	end process;
	
	-- player hand generation
	process(KEY(0), KEY(1), KEY(3), count) begin
		if KEY(1) = '0' then
			myHand <= 0;
		elsif rising_edge(KEY(0)) and (count >= 2) and (KEY(3) = '0') then
			myHand <= myHand + myDeck(count);
		end if;
	end process;
	
	-- output led generation
	process(KEY(0), count, KEY(2)) begin
		if (rising_edge(KEY(0)) and (KEY(2) = '0') and (count > 2)) then
			if (myHand < 22) and (myHand > dealHand) then
				win <= '1';
			elsif (myHand > 21) or (myHand <= dealHand) then 
				lose <= '1';
			end if;
		end if;
	end process;
	

end log;


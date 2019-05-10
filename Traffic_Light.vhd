-- LAMPU LALU LINTAS 4 ARAH
-- @2019
-- AUTHOR:
--	1. ANANDA RIZKY DUTO PAMUNGKAS (TEKNIK KOMPUTER) - 1706985905
--	2. GERALDY CHRISTANTO (TEKNIK KOMPUTER) - 1706043001
--	3. HANSAKA WIJAYA (TEKNIK KOMPUTER) - 1706985962
--	4. MUHAMMAD ILHAM AKBAR(TEKNIK KOMPUTER) - 1706042970
--------------------------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

entity traffic_light is
    port(clr: in std_logic;	-- Clear output
         clock: in std_logic;
         mode: in std_logic;	-- Mode:= 0 auto, mode:=1 manual
         switch: in std_logic_vector(3 downto 0);	-- Digunakan untuk mengatur lampu lalu lintas dalam mode manual
         hijau: inout std_logic_vector(3 downto 0);	-- hijau, kuning, merah: lampu dengan urutan dengan arah T-B-U-S
         kuning: inout std_logic_vector(3 downto 0);
         merah: inout std_logic_vector(3 downto 0);
         zcMerah: inout std_logic_vector(1 downto 0);	-- zcMerah, zcHijau: lampu zebra cross dengan urutan TB-US 
         zcHijau: inout std_logic_vector(1 downto 0));
end traffic_light;

architecture arch of traffic_light is
	-- digunakan untuk generate delay pada timer
    	constant longCount : integer := 30; -- 30 clock pulses 
    	constant shortCount : integer := 10; -- 10 clock pulses
	 
	-- RAM block 32x4
	type mem is array(0 to 31) of std_logic_vector(3 downto 0);
	signal memory_array : mem;
	signal address: integer range 0 to 31;
	 
	-- Signal FSM
	signal state: integer range 0 to 11;
    
	signal timeout: std_logic := '0'; -- Timeout := '1' jika current state telah timeout
	-- signals untuk mentrigger timer
	signal Tl, Ts: std_logic := '0';  -- Tl - long timer, Ts - short timer

begin

    -- Proses sekuensial untuk menentukan present state
    sequential: process (clr, mode, timeout, clock)
    begin
    	-- Mode otomatis
	if mode = '0' then
            if clr = '1' then
                state <= 0;
            elsif timeout = '1' and rising_edge(clock) then
                state <= (state + 1) mod 12;
            end if;
        -- Mode manual
        elsif mode = '1' then
            if switch(3) = '1' then
                state <= 4;
            elsif switch(2) = '1' then
                state <= 2;
            elsif switch(1) = '1' then
                state <= 10;
            elsif switch(0) = '1' then
                state <= 8;
            end if;
        end if;
    end process;

    combinational: process (state)
    begin
        Tl <= '0'; Ts <= '0';
        case state is
            when 0 =>
                -- Timur dan Barat HIJAU dan Zebra cross utara selatan HIJAU, selain itu MERAH
                hijau(3 downto 2) <= "11"; 
		merah(3 downto 2) <= "00"; -- TB
                hijau(1 downto 0) <= "00"; 
		merah(1 downto 0) <= "11"; -- US
                kuning(3 downto 0) <= "0000";
                zcHijau(1) <= '0'; zcMerah(1) <= '1'; -- TB
                zcHijau(0) <= '1'; zcMerah(0) <= '0'; -- US
                -- mulai long timer
                Tl <= '1'; 
            when 1 =>
                -- Timur -> kuning, hijau mati
                kuning(3) <= '1'; 
		hijau(3) <= '0';
                -- Mulai short timer
                Ts <= '1';
            when 2 =>
                -- Timur -> merah, kuning mati
                merah(3) <= '1'; 
		kuning(3) <= '0';
                -- Zebra cross -> US merah, hijau mati
                zcMerah(0) <= '1'; 
		zcHijau(0) <= '0';
                -- Mulai long timer
                Tl <= '1';
            when 3 =>
                -- Barat -> kuning, hijau mati
                kuning(2) <= '1'; 
		hijau(2) <= '0';
                -- Mulai short timer
                Ts <= '1';
            when 4 =>
                -- Barat -> merah, kuning mati
                merah(2) <= '1'; 
		kuning(2) <= '0';
                -- Barat -> hijau, merah mati
                hijau(3) <= '1'; 
		merah(3) <= '0';
                -- Mulai long timer
                Tl <= '1';
            when 5 =>
                -- Timur -> kuning, hijau mati
                kuning(3) <= '1'; 
		hijau(3) <= '0';
                -- Mulai short timer
                Ts <= '1';
            when 6 =>
                -- Timur -> merah, kuning mati
                merah(3) <= '1'; 
		kuning(3) <= '0';
                -- US -> hijau, merah mati
                hijau(1 downto 0) <= "11"; 
		merah(1 downto 0) <= "00";
                -- Zebra-TB -> hijau, merah mati
                zcHijau(1) <= '1'; 
		zcMerah(1) <= '0';
                -- Mulai timer
                Tl <= '1';
            when 7 =>
                -- Utara -> kuning, hijau mati
                kuning(1) <= '1'; 
		hijau(1) <= '0';
                -- Mulai timer
                Ts <= '1';
            when 8 =>
                -- Utara -> merah, kuning mati
                merah(1) <= '1';
		kuning(1) <= '0';
                -- Zebra TB -> merah, hija mati
                zcMerah(1) <= '1'; 
		zcHijau(1) <= '0';
                -- Mulai timer
                Tl <= '1';
            when 9 =>
                -- Selatan -> Kuning, hijau mati
                kuning(0) <= '1'; 
		hijau(0) <= '0';
                -- Mulai timer
                Ts <= '1';
            when 10 =>
                -- Selatan -> merah, kuning mati
                merah(0) <= '1'; 
		kuning(0) <= '0';
                -- Utara -> hijau, merah mati
                hijau(1) <= '1'; 
		merah(1) <= '1';
                -- Mulai timer
                Tl <= '1';
            when 11 =>
                -- Utara -> kuning, hijau mati
                kuning(1) <= '1'; 
		hijau(1) <= '0';
                -- Mulai timer
                Ts <= '1';
        end case;
	-- Output Hijau disimpan ke memory array 0
	-- Output Kuning disimpan ke dalam memory array 1
	-- Output Merah disimpan ke dalam memory array 2
	-- Output zebraCross disimpan dalam memory array 31
		  memory_array(0) <= hijau;
		  memory_array(1) <= kuning;
		  memory_array(2) <= merah;
		  memory_array(31) <= zcMerah & zcHijau;
    end process;

    -- Proses timer
    timer: process(Tl, Ts, clock)
    variable count : integer;
    begin
        timeout <= '0';
        count := 0;
        if Tl = '1' then
            for i in 1 to longCount loop
                if rising_edge(clock) and count <= longCount then
                    count := count + 1;
                end if;
            end loop;
	timeout <= '1';
        elsif Ts = '1' then
           for i in 1 to shortCount loop
                if rising_edge(clock) and count <= shortCount then
                    count := count +1;
                end if;
	   end loop;
	timeout <= '1';
        end if;
    end process;
end architecture ;
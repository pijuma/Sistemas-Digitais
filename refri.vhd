LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE ieee.numeric_std.all ; 

--o processo é chamado sempre que uma das variáveis definidas nele mudam 
--vulgo usaremos na mudança de cloc e checaremos com clck'event = 1 quer dizer que ele foi de 0 pra 1 
-- nao pode usar saida no codigo 

-- os valores 1, 2, 3, 4 que valem 10 25, 50, 100 foram convertidos para 2 5 10 20 
-- ou seja queremos alcançar 100 (20)

ENTITY refri IS -- declarando nossas entradas 
	PORT(
		clk, clk_placa: in std_logic ; 
		reset: in bit ;
		rst_db: in std_logic ;
	
		req: in bit;
		money_add: in bit_vector(2 downto 0) := (others =>'0') ; 
		rico: out bit := '0'; 
		refri: out bit := '0' ;
		estorno: out bit := '0'
	 );

END refri; 

-- é como se o states fosse uma struct 
-- delcara uma variavel do tipo states 

ARCHITECTURE behaviour OF refri IS
	
	TYPE st IS (money, no_money); 
	SIGNAL estado: st ; 
	SIGNAL var_money_atual: unsigned (4 downto 0) := (others => '0') ;
	SIGNAL clock: std_logic ; -- clock da saida do debouncer 
   
	 component Debouncing_Button_VHDL is
        port(
            button: in std_logic;
            clk: in std_logic;
            debounced_button: out std_logic
        );
    end component; 
	 
	 function valor( entrada : in bit_vector(2 downto 0))
		return unsigned is 
		variable saida : unsigned (4 downto 0) := (others => '0') ; 
	begin 
		case entrada is 
			when "001" => saida := saida + 2 ; 
			when "010" => saida := saida + 5 ; 
			when "011" => saida := saida + 10 ; 
			when "100" => saida := saida + 20 ; 
			when others => saida := saida ; 
		end case ; 
		return saida ; 
	end function valor ; 
	
BEGIN
		
		instance_debouncer: Debouncing_Button_VHDL
        port map (
            button => clk, clk => clk_placa,
            debounced_button => clock
        );
		
		PROCESS (clock, reset)
		
		BEGIN 
		
			if(reset = '1') then
				estado <= no_money ; 
				var_money_atual <= "00000";
				refri <= '0';
				estorno <= '0';
				rico <= '0';
			
			elsif (clock'event) and (clock = '1') then 
				
				case estado is
				
					WHEN money =>
					
						if(req = '1' and var_money_atual + valor(money_add) = 20) then
							estado <= no_money ; 
							rico <= '0' ; 
							var_money_atual <= "00000" ; 
							refri <= '1' ;
							estorno <= '0' ; 
							
						elsif((var_money_atual + valor(money_add) > 20) or (req = '1' and var_money_atual + valor(money_add) < 20)) then
							estado <= no_money ; 
							refri <= '0' ; 
							estorno <= '1' ; 
							rico <= '0' ; 
							var_money_atual <= "00000" ; 
						else 
							refri <= '0' ; 
							estorno <= '0' ;
							rico <= '1' ; 
							var_money_atual <= var_money_atual + valor(money_add) ; 
						end if ; 
						
					WHEN no_money => 
						
						if(money_add /= "000" and req = '1') then
							if(valor(money_add)=20)then
							rico <= '0' ; 
							refri <= '1' ; 
							estorno <= '0' ;
							else
							rico <= '0';
							refri<= '0';
							estorno<= '1';
							var_money_atual <= "00000" ;
							end if ;
						
						elsif(money_add /= "000") then 
							estado <= money ; 
							rico <= '1';
							var_money_atual <= var_money_atual + valor(money_add) ; 
							estorno <= '0' ; 
							refri <= '0' ; 
						
						else 
							refri <= '0' ; 
							estorno <= '0' ; 
							rico <= '0' ; 
							
						end if ; 
						
						
				END CASE ; 
				
			END IF ;
			
END PROCESS ; 
END behaviour ; 
LIBRARY ieee ;
USE ieee.std_logic_1164.all ;
USE ieee.numeric_std.all ; 

ENTITY projeto2 IS 
	
	PORT(
		clk, clk_placa: in std_logic ; 
		reset: in bit ;
		rst_db: in std_logic ; 
		andar_chamado: in unsigned (3 downto 0) := (others =>'0') ; -- bits de 3 a 0 - 3 mais significativo 
		andar_atual: out unsigned (3 downto 0) := (others => '0') ;
		movimento: out bit_vector (1 downto 0) := (others => '0') -- vetor de dois bits que representa os estados que sao definidos na arq
	 );

END projeto2; 

ARCHITECTURE behaviour OF projeto2 IS
	
	TYPE st IS (parado, subindo, descendo); 
	SIGNAL estado: st ; 
	SIGNAL var_andar_atual: unsigned (3 downto 0) := (others => '0') ; -- variavel interna que guarda o estado atual
	SIGNAL clock: std_logic ; -- clock da saida do debouncer 
   
	 component Debouncing_Button_VHDL is
        port(
            button: in std_logic;
            clk: in std_logic;
            debounced_button: out std_logic
        );
    end component; 

BEGIN
		
	instance_debouncer: Debouncing_Button_VHDL
        port map (
            button => clk, clk => clk_placa,
            debounced_button => clock
        );
		
		PROCESS (clock, reset)
		
		BEGIN 
		
			if(reset = '1') then
				estado <= parado ; 
				movimento <= "00" ; 
				var_andar_atual <= "0000" ; 
			
			elsif (clock'event) and (clock = '1') then 
				
				case estado is
				
					WHEN parado => 
					
						IF (andar_chamado /= var_andar_atual) then 
							IF(andar_chamado > var_andar_atual) then 
								movimento <= "01" ;
								estado <= subindo ;
								var_andar_atual <= var_andar_atual + 1 ; 
								andar_atual <= var_andar_atual + 1; 
							ELSE 
								movimento <= "10" ; 
								estado <= descendo ;
								var_andar_atual <= var_andar_atual - 1 ;
								andar_atual <= var_andar_atual - 1 ; 
							END IF ; 
						END IF ; 
					
					WHEN subindo => 
						
						IF (andar_chamado = var_andar_atual) then
							movimento <= "00" ;
							estado <= parado ;	
						ELSIF (andar_chamado > var_andar_atual) then 
							var_andar_atual <= var_andar_atual + 1 ; 
							andar_atual <= var_andar_atual+1;
						ELSE 
							movimento <= "10" ; 
							estado <= descendo ;
							var_andar_atual <= var_andar_atual - 1 ; 
							andar_atual <= var_andar_atual - 1 ; 
						END IF ; 
						
					WHEN descendo => 
					
						IF(andar_chamado = var_andar_atual) then 
							movimento <= "00" ;
							estado <= parado ;	
						ELSIF(andar_chamado > var_andar_atual) then 
							movimento <= "01" ;
							estado <= subindo ;
							var_andar_atual <= var_andar_atual + 1 ; 
							andar_atual <= var_andar_atual+1 ;
						ELSE 
							var_andar_atual <= var_andar_atual - 1 ; 
							andar_atual <= var_andar_atual-1 ;
						END IF ;
						
				END CASE ; 
				
			END IF ;
			
END PROCESS ; 
END behaviour ; 

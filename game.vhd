library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.conv_std_logic_vector;
use IEEE.numeric_std.all;

entity topmodule is
  Port (
       clk: in STD_LOGIC;    
       sw: in STD_LOGIC_VECTOR (15 downto 0);
       led: out STD_LOGIC_VECTOR (15 downto 0);
       seg: out STD_LOGIC_VECTOR (6 downto 0);
       an: out STD_LOGIC_VECTOR (3 downto 0);
       
       btnL: in STD_LOGIC;
       btnU: in STD_LOGIC;
       btnR: in STD_LOGIC;
       btnD: in STD_LOGIC;
       btnC: in STD_LOGIC
       );
end topmodule;

architecture Behavioral of topmodule is

signal an_strobe: integer := 0;
signal reset: STD_LOGIC;
signal count: integer := 0;
signal slow_clk: STD_LOGIC;

signal button_pressedL: STD_LOGIC;
signal buttonL: STD_LOGIC;
signal button_pressedU: STD_LOGIC;
signal buttonU: STD_LOGIC;
signal button_pressedR: STD_LOGIC;
signal buttonR: STD_LOGIC;
signal button_pressedD: STD_LOGIC;
signal buttonD: STD_LOGIC;
signal button_pressedC: STD_LOGIC;
signal buttonC: STD_LOGIC;

signal Ai : STD_LOGIC_VECTOR (15 downto 0);
signal Ei : STD_LOGIC_VECTOR (15 downto 0);

signal led_strobe: integer := 0;
signal CLK_1Hz: std_logic_vector(15 downto 0);
signal trigger_led: std_logic;

signal digit: STD_LOGIC_VECTOR(3 downto 0);
signal int_to_seg: integer;


TYPE State_type IS (A, B, C, Cp, D, Dp, E);  -- Define the states
	SIGNAL State : State_Type;    
	
BEGIN
button_pressedL <= btnL; -- connect btnL to signal button_pressedL
button_pressedU <= btnU;
button_pressedR <= btnR;
button_pressedD <= btnD;
button_pressedC <= btnC; 

process (clk,reset) begin 
  if reset = '1' then 
    count <= 0; 
    slow_clk <= '0'; 
  elsif(clk'event and clk = '1') then 
    count <= count + 1;
    if (count = 10000) then 
        slow_clk <= NOT slow_clk; 
        count <= 0; 
    end if;
  end if;
end process;

PROCESS (clk, slow_clk, reset)
    variable UAi : integer;
    variable UEi : integer;
    variable number_of_guesses1 : integer := 0;
    variable number_of_guesses2 : integer := 0;
BEGIN 

    if (rising_edge(button_pressedC)) then      --when a button is pressed, set signal buttonC to high (alternate each time)
      buttonC <= NOT buttonC;
    end if;
    if (rising_edge(button_pressedL)) then
      buttonL <= NOT buttonL;
    end if;
    if (rising_edge(button_pressedU)) then
      buttonU <= NOT buttonU;
    end if;
    if (rising_edge(button_pressedR)) then
      buttonR <= NOT buttonR;
    end if;
    if (rising_edge(button_pressedD)) then
      buttonD <= NOT buttonD;
    end if;
    

    IF (reset = '1') THEN   -- Upon reset, set the state to A to start again
	State <= A;
    
    ELSIF rising_edge(slow_clk) THEN    -- if there is a rising edge of the clock, then begin 
 
	CASE State IS
 
		-- First State is A. Start by displaying PL 1 and wait for input
		WHEN A => 
		    case an_strobe is         --display PL 1 on 7-seg
                when 0 => an <= "1110" ;
                          digit <= "0001" ;
                          an_strobe <= an_strobe + 1;
                when 1 => an <= "1101" ;
                          digit <= "1111" ;                      
                          an_strobe <= an_strobe + 1;
                when 2 => an <= "1011" ;
                          digit <= "1011" ;                   
                          an_strobe <= an_strobe + 1;
                when 3 => an <= "0111" ;
                          digit <= "1010" ;                     
                          an_strobe <= 0;
                when others => an_strobe <= 0;
            end case;
		    
		    -- When buttonL is triggered, set Ei to follow switches 3 to 0
			IF (buttonL = '1') THEN      
			    if (sw(3) = '1') then Ei(15) <= '1'; end if;
                if (sw(2) = '1') then Ei(14) <= '1'; end if;
                if (sw(1) = '1') then Ei(13) <= '1'; end if;
                if (sw(0) = '1') then Ei(12) <= '1'; end if;
            END IF;
             
            IF (buttonU = '1') THEN         
                if (sw(3) = '1') then Ei(11) <= '1'; end if;
                if (sw(2) = '1') then Ei(10) <= '1'; end if;
                if (sw(1) = '1') then Ei(9) <= '1'; end if;
                if (sw(0) = '1') then Ei(8) <= '1'; end if;
           END IF;
                     
           IF (buttonD = '1') THEN
                if (sw(3) = '1') then Ei(7) <= '1'; end if;
                if (sw(2) = '1') then Ei(6) <= '1'; end if;
                if (sw(1) = '1') then Ei(5) <= '1'; end if;
                if (sw(0) = '1') then Ei(4) <= '1'; end if;
           END IF;     
                  
           IF (buttonR = '1') THEN         
                if (sw(3) = '1') then Ei(3) <= '1'; end if;
                if (sw(2) = '1') then Ei(2) <= '1'; end if;
                if (sw(1) = '1') then Ei(1) <= '1'; end if;
                if (sw(0) = '1') then Ei(0) <= '1'; end if;		    
		    END IF;
		    
			IF (buttonC = '1') THEN      -- when buttonC is triggered, default values of array = 0 if other buttons are not pressed
			    UEi := to_integer(unsigned(Ei));     --convert std_logic_vector to integer (easier to do comparison)
				State <= B; 
			END IF; 
 
		-- Second state is B. Display PL 2, wait for input, check input.
		WHEN B =>
		    case an_strobe is     -- display PL 2
                when 0 => an <= "1110" ;
                          digit <= "0010" ;
                          an_strobe <= an_strobe + 1;
                when 1 => an <= "1101" ;
                          digit <= "1111" ;                    
                          an_strobe <= an_strobe + 1;
                when 2 => an <= "1011" ;
                          digit <= "1011" ;                     
                          an_strobe <= an_strobe + 1;
                when 3 => an <= "0111" ;
                          digit <= "1010" ;              
                          an_strobe <= 0;
                when others => an_strobe <= 0;
            end case; 
                            
            
            IF (buttonL = '0') THEN                       
                if (sw(3) = '1') then Ai(15) <= '1'; end if;
                if (sw(2) = '1') then Ai(14) <= '1'; end if;
                if (sw(1) = '1') then Ai(13) <= '1'; end if;
                if (sw(0) = '1') then Ai(12) <= '1'; end if;
            END IF;
                                         
            IF (buttonU = '0') THEN         
                if (sw(3) = '1') then Ai(11) <= '1'; end if;
                if (sw(2) = '1') then Ai(10) <= '1'; end if;
                if (sw(1) = '1') then Ai(9) <= '1'; end if;
                if (sw(0) = '1') then Ai(8) <= '1'; end if;
            END IF;
                                                 
            IF (buttonD = '0') THEN
                if (sw(3) = '1') then Ai(7) <= '1'; end if;
                if (sw(2) = '1') then Ai(6) <= '1'; end if;
                if (sw(1) = '1') then Ai(5) <= '1'; end if;
                if (sw(0) = '1') then Ai(4) <= '1'; end if;
            END IF;     
                                              
            IF (buttonR = '0') THEN         
                if (sw(3) = '1') then Ai(3) <= '1'; end if;
                if (sw(2) = '1') then Ai(2) <= '1'; end if;
                if (sw(1) = '1') then Ai(1) <= '1'; end if;
                if (sw(0) = '1') then Ai(0) <= '1'; end if;
            END IF;
                
            
            IF (buttonC = '0') THEN 
                UAi := to_integer(unsigned(Ai));
                if (UEi = UAi) then     -- compare if PL 1 integer and PL 2 integer are the same. If they are the same, go to the last state
                    trigger_led <= '1';
                    State <= E;
                elsif (UEi > UAi) then  -- else, increment number of guesses, guess the number again
                    number_of_guesses1 := number_of_guesses1 + 1;
                    if (number_of_guesses1 >= 10) then
                        number_of_guesses2 := number_of_guesses2 + 1;
                        number_of_guesses2 := 0;
                    end if;
                    Ai <= "0000000000000000";
                    State <= D;     --2 HI
                elsif (UEi < UAi) then
                    number_of_guesses1 := number_of_guesses1 + 1;
                    if (number_of_guesses1 >= 10) then
                        number_of_guesses2 := number_of_guesses2 + 1;
                        number_of_guesses2 := 0;
                    end if;
                    Ai <= "0000000000000000";
                    State <= C;     --2 LO
                end if;
                
            END IF;   
 
		
		WHEN C =>
		    case an_strobe is 
                when 0 => an <= "1110" ;
                          digit <= "1101" ;    --I
                          an_strobe <= an_strobe + 1;
                when 1 => an <= "1101" ;
                          digit <= "1100" ;    --H                    
                          an_strobe <= an_strobe + 1;
                when 2 => an <= "1011" ;
                          digit <= "1111" ;                     
                          an_strobe <= an_strobe + 1;
                when 3 => an <= "0111" ;
                          digit <= "0010" ;      --2              
                          an_strobe <= 0;
                when others => an_strobe <= 0;
            end case;
              
            IF (buttonL = '1') THEN                       
                if (sw(3) = '1') then Ai(15) <= '1'; end if;
                if (sw(2) = '1') then Ai(14) <= '1'; end if;
                if (sw(1) = '1') then Ai(13) <= '1'; end if;
                if (sw(0) = '1') then Ai(12) <= '1'; end if;
            END IF;
                                                             
            IF (buttonU = '1') THEN         
                if (sw(3) = '1') then Ai(11) <= '1'; end if;
                if (sw(2) = '1') then Ai(10) <= '1'; end if;
                if (sw(1) = '1') then Ai(9) <= '1'; end if;
                if (sw(0) = '1') then Ai(8) <= '1'; end if;
            END IF;
                                                                     
            IF (buttonD = '1') THEN
                if (sw(3) = '1') then Ai(7) <= '1'; end if;
                if (sw(2) = '1') then Ai(6) <= '1'; end if;
                if (sw(1) = '1') then Ai(5) <= '1'; end if;
                if (sw(0) = '1') then Ai(4) <= '1'; end if;
            END IF;     
                                                                  
            IF (buttonR = '1') THEN         
                if (sw(3) = '1') then Ai(3) <= '1'; end if;
                if (sw(2) = '1') then Ai(2) <= '1'; end if;
                if (sw(1) = '1') then Ai(1) <= '1'; end if;
                if (sw(0) = '1') then Ai(0) <= '1'; end if;
            END IF;
                          
            IF (buttonC = '1') THEN
                UAi := to_integer(unsigned(Ai));         
                if (UEi = UAi) then
                    trigger_led <= '1';
                    State <= E;
                elsif (UEi > UAi) then
                    number_of_guesses1 := number_of_guesses1 + 1;
                    if (number_of_guesses1 >= 10) then
                        number_of_guesses2 := number_of_guesses2 + 1;
                        number_of_guesses1 := 0;
                   end if;
                    Ai <= "0000000000000000";
                    State <= Dp;     --2 HI
                elsif (UEi < UAi) then
                    number_of_guesses1 := number_of_guesses1 + 1;
                    if (number_of_guesses1 >= 10) then
                        number_of_guesses2 := number_of_guesses2 + 1;
                        number_of_guesses1 := 0;
                   end if;
                    Ai <= "0000000000000000";
                    State <= Cp;     --2 LO
                end if;
            END IF;
                          
        WHEN Cp =>      --this is to account for the alternate "<= NOT buttonC" states
            case an_strobe is 
                when 0 => an <= "1110" ;
                          digit <= "1101" ;    --I
                          an_strobe <= an_strobe + 1;
                when 1 => an <= "1101" ;
                          digit <= "1100" ;    --H                    
                          an_strobe <= an_strobe + 1;
                when 2 => an <= "1011" ;
                          digit <= "1111" ;                   
                          an_strobe <= an_strobe + 1;
                when 3 => an <= "0111" ;
                          digit <= "0010" ;      --2             
                          an_strobe <= 0;
                when others => an_strobe <= 0;
            end case;
                                        
            IF (buttonL = '0') THEN                       
                if (sw(3) = '1') then Ai(15) <= '1'; end if;
                if (sw(2) = '1') then Ai(14) <= '1'; end if;
                if (sw(1) = '1') then Ai(13) <= '1'; end if;
                if (sw(0) = '1') then Ai(12) <= '1'; end if;
            END IF;
                                                                                 
            IF (buttonU = '0') THEN         
                if (sw(3) = '1') then Ai(11) <= '1'; end if;
                if (sw(2) = '1') then Ai(10) <= '1'; end if;
                if (sw(1) = '1') then Ai(9) <= '1'; end if;
                if (sw(0) = '1') then Ai(8) <= '1'; end if;
            END IF;
                                                                                         
            IF (buttonD = '0') THEN
                if (sw(3) = '1') then Ai(7) <= '1'; end if;
                if (sw(2) = '1') then Ai(6) <= '1'; end if;
                if (sw(1) = '1') then Ai(5) <= '1'; end if;
                if (sw(0) = '1') then Ai(4) <= '1'; end if;
            END IF;     
                                                                                      
            IF (buttonR = '0') THEN         
                if (sw(3) = '1') then Ai(3) <= '1'; end if;
                if (sw(2) = '1') then Ai(2) <= '1'; end if;
                if (sw(1) = '1') then Ai(1) <= '1'; end if;
                if (sw(0) = '1') then Ai(0) <= '1'; end if;
            END IF;
                                              
            IF (buttonC = '0') THEN 
                UAi := to_integer(unsigned(Ai));        
                if (UEi = UAi) then
                    trigger_led <= '1';
                    State <= E;
                elsif (UEi > UAi) then
                    number_of_guesses1 := number_of_guesses1 + 1;
                    if (number_of_guesses1 >= 10) then
                        number_of_guesses2 := number_of_guesses2 + 1;
                        number_of_guesses1 := 0;
                    end if;
                    Ai <= "0000000000000000";
                    State <= D;     --2 HI
                elsif (UEi < UAi) then
                    number_of_guesses1 := number_of_guesses1 + 1;
                    if (number_of_guesses1 >= 10) then
                        number_of_guesses2 := number_of_guesses2 + 1;
                        number_of_guesses1 := 0;
                    end if;
                    Ai <= "0000000000000000";
                    State <= C;     --2 LO
                end if;
            END IF;
                                                                                         
        WHEN D =>
            case an_strobe is 
                when 0 => an <= "1110" ;
                          digit <= "0000" ;    --O
                          an_strobe <= an_strobe + 1;
                when 1 => an <= "1101" ;
                          digit <= "1011" ;    --L                    
                          an_strobe <= an_strobe + 1;
                when 2 => an <= "1011" ;
                          digit <= "1111" ;                     
                          an_strobe <= an_strobe + 1;
                when 3 => an <= "0111" ;
                          digit <= "0010" ;      --2              
                          an_strobe <= 0;
                when others => an_strobe <= 0;
            end case;
            
            IF (buttonL = '1') THEN                       
                if (sw(3) = '1') then Ai(15) <= '1'; end if;
                if (sw(2) = '1') then Ai(14) <= '1'; end if;
                if (sw(1) = '1') then Ai(13) <= '1'; end if;
                if (sw(0) = '1') then Ai(12) <= '1'; end if;
            END IF;
                                                                                                     
            IF (buttonU = '1') THEN         
                if (sw(3) = '1') then Ai(11) <= '1'; end if;
                if (sw(2) = '1') then Ai(10) <= '1'; end if;
                if (sw(1) = '1') then Ai(9) <= '1'; end if;
                if (sw(0) = '1') then Ai(8) <= '1'; end if;
            END IF;
                                                                                                             
            IF (buttonD = '1') THEN
                if (sw(3) = '1') then Ai(7) <= '1'; end if;
                if (sw(2) = '1') then Ai(6) <= '1'; end if;
                if (sw(1) = '1') then Ai(5) <= '1'; end if;
                if (sw(0) = '1') then Ai(4) <= '1'; end if;
            END IF;     
                                                                                                          
            IF (buttonR = '1') THEN         
                if (sw(3) = '1') then Ai(3) <= '1'; end if;
                if (sw(2) = '1') then Ai(2) <= '1'; end if;
                if (sw(1) = '1') then Ai(1) <= '1'; end if;
                if (sw(0) = '1') then Ai(0) <= '1'; end if;
            END IF;
                                                                  
            IF (buttonC = '1') THEN
                UAi := to_integer(unsigned(Ai));         
                if (UEi = UAi) then
                    trigger_led <= '1';
                    State <= E;
                elsif (UEi > UAi) then
                    number_of_guesses1 := number_of_guesses1 + 1;
                    if (number_of_guesses1 >= 10) then
                        number_of_guesses2 := number_of_guesses2 + 1;
                        number_of_guesses1 := 0;
                    end if;
                    Ai <= "0000000000000000";
                    State <= Dp;     --2 HI
                elsif (UEi < UAi) then
                    number_of_guesses1 := number_of_guesses1 + 1;
                    if (number_of_guesses1 >= 10) then
                        number_of_guesses2 := number_of_guesses2 + 1;
                        number_of_guesses1 := 0;
                    end if;
                    Ai <= "0000000000000000";
                    State <= Cp;     --2 LO
                end if;
            END IF;
           
        WHEN Dp =>
            case an_strobe is 
                when 0 => an <= "1110" ;
                          digit <= "0000" ;    --O
                          an_strobe <= an_strobe + 1;
                when 1 => an <= "1101" ;
                          digit <= "1011" ;    --L                    
                          an_strobe <= an_strobe + 1;
                when 2 => an <= "1011" ;
                          digit <= "1111" ;                     
                          an_strobe <= an_strobe + 1;
                when 3 => an <= "0111" ;
                          digit <= "0010" ;      --2              
                          an_strobe <= 0;
                when others => an_strobe <= 0;
            end case;
                       
            IF (buttonL = '0') THEN                       
                if (sw(3) = '1') then Ai(15) <= '1'; end if;
                if (sw(2) = '1') then Ai(14) <= '1'; end if;
                if (sw(1) = '1') then Ai(13) <= '1'; end if;
                if (sw(0) = '1') then Ai(12) <= '1'; end if;
            END IF;
                                                                                                     
            IF (buttonU = '0') THEN         
                if (sw(3) = '1') then Ai(11) <= '1'; end if;
                if (sw(2) = '1') then Ai(10) <= '1'; end if;
                if (sw(1) = '1') then Ai(9) <= '1'; end if;
                if (sw(0) = '1') then Ai(8) <= '1'; end if;
            END IF;
                                                                                                             
            IF (buttonD = '0') THEN
                if (sw(3) = '1') then Ai(7) <= '1'; end if;
                if (sw(2) = '1') then Ai(6) <= '1'; end if;
                if (sw(1) = '1') then Ai(5) <= '1'; end if;
                if (sw(0) = '1') then Ai(4) <= '1'; end if;
            END IF;     
                                                                                                          
            IF (buttonR = '0') THEN         
                if (sw(3) = '1') then Ai(3) <= '1'; end if;
                if (sw(2) = '1') then Ai(2) <= '1'; end if;
                if (sw(1) = '1') then Ai(1) <= '1'; end if;
                if (sw(0) = '1') then Ai(0) <= '1'; end if;
            END IF;
                                                                  
            IF (buttonC = '0') THEN
                UAi := to_integer(unsigned(Ai));         
                if (UEi = UAi) then
                    trigger_led <= '1';
                    State <= E;
                elsif (UEi > UAi) then
                    number_of_guesses1 := number_of_guesses1 + 1;
                    if (number_of_guesses1 >= 10) then
                        number_of_guesses2 := number_of_guesses2 + 1;
                        number_of_guesses1 := 0;
                    end if;
                    Ai <= "0000000000000000";
                    State <= D;     --2 HI
                elsif (UEi < UAi) then
                    number_of_guesses1 := number_of_guesses1 + 1;
                    if (number_of_guesses1 >= 10) then
                        number_of_guesses2 := number_of_guesses2 + 1;
                        number_of_guesses1 := 0;
                    end if;
                    Ai <= "0000000000000000";
                    State <= C;     --2 LO
                end if;
            END IF;

        WHEN E =>
            case an_strobe is       -- display number of guesses up to 99 guesses
                when 0 => an <= "1110" ;
                          digit <= conv_std_logic_vector(number_of_guesses1,digit'length) ;      
                          an_strobe <= an_strobe + 1;
                when 1 => an <= "1101" ;
                          digit <= conv_std_logic_vector(number_of_guesses2,digit'length) ;                          
                          an_strobe <= an_strobe + 1;            
                          an_strobe <= 0;
                when others => an_strobe <= 0;
            end case;
            
            case led_strobe is         -- display led blinks
                when 0    => led <= "1010101010101010";
                             led_strobe <= led_strobe + 1;
                when 1000 => led <= "1111000000000000";
                             led_strobe <= led_strobe + 1;                                          
                when 2000 => led <= "0000111100000000";           
                             led_strobe <= led_strobe + 1;
                when 3000 => led <= "0000000011110000";            
                             led_strobe <= led_strobe + 1;
                when 4000 => led <= "0000000000001111";
                             led_strobe <= led_strobe + 1;
                when 5000 => led_strobe <= 0;
                when others => led_strobe <= led_strobe + 1;
            end case;

		WHEN others =>
			State <= A;      -- default to state A
	END CASE; 
    END IF;
    
  END PROCESS;
  
process(digit)
begin 
  case digit is 
      when "0000" => seg <= "1000000"; --0
      when "0001" => seg <= "1111001"; --1
      when "0010" => seg <= "0100100"; --2
      when "0011" => seg <= "0110000"; --3
      when "0100" => seg <= "0011001"; --4
      when "0101" => seg <= "0010010"; --5
      when "0110" => seg <= "0000010"; --6
      when "0111" => seg <= "1111000"; --7
      when "1000" => seg <= "0000000"; --8
      when "1001" => seg <= "0010000"; --9
      
      when "1010" => seg <= "0001100"; --P
      when "1011" => seg <= "1000111"; --L
      when "1100" => seg <= "0001001"; --H
      when "1101" => seg <= "1001111"; --I
      when "1110" => seg <= "0111111"; ---
      when "1111" => seg <= "1111111"; -- nothing
 
      when others => seg <= "0111111"; ---
    
    end case;
end process;
    
END Behavioral;
            


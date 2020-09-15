library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity project_reti_logiche is
    Port ( i_clk : in STD_LOGIC;
           i_start : in STD_LOGIC;
           i_rst : in STD_LOGIC;
           i_data : in STD_LOGIC_VECTOR (7 downto 0);
           o_address : out STD_LOGIC_VECTOR (15 downto 0);
           o_done : out STD_LOGIC;
           o_en : out STD_LOGIC;
           o_we : out STD_LOGIC;
           o_data : out STD_LOGIC_VECTOR (7 downto 0));
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is

    type states is  (IDLE, leggo_indirizzo,salvo_indirizzo, confronto_indirizzo, leggo_wz, scrivo_indirizzo, concludo);
    signal present_state, next_state : states;
    signal contatore, next_contatore : STD_LOGIC_VECTOR (3 downto 0);
    signal next_o_address : STD_LOGIC_VECTOR (15 downto 0) := "0000000000000000";
    signal next_o_data : STD_LOGIC_VECTOR (7 downto 0) := "00000000";
    signal next_o_en, next_o_we, next_o_done : STD_LOGIC;
    signal change, next_change : STD_LOGIC;
    signal one_hot, next_one_hot : STD_LOGIC_VECTOR (3 downto 0);
    signal ind, next_ind : STD_LOGIC_VECTOR (7 downto 0);

begin
     
     
     
    registri : process (i_rst, i_clk)
    begin
        if i_rst = '1' then

            present_state <= IDLE;
            

        
        elsif (i_clk'event and i_clk = '1') then   --transition on clock
            present_state <= next_state; 
            contatore <= next_contatore;
            o_address <= next_o_address;
            o_done <= next_o_done;
            o_en <= next_o_en;
            o_we <= next_o_we;
            o_data <= next_o_data;
            change <= next_change;
            one_hot <= next_one_hot;
           
            ind <= next_ind;
        end if;
    end process;
    
    
    
    
    transizioni: process (present_state, i_start, i_data) 
     
        
    begin
    
        
        
        next_o_done <= '0';
        next_o_en <= '0';
        next_o_we <= '0';
        next_o_data <="00000000";
        next_contatore <= "0000";
        next_o_address <= "0000000000000000";
        next_change <= '0';
        next_one_hot <= "0000";
        
        next_ind <= "00000000";

        case present_state is
            
            when IDLE =>


                if (i_start = '1') then

                    next_state <= leggo_indirizzo;
                    next_o_address <= std_logic_vector(to_unsigned(8, 16));
                    next_o_en <= '1';
                    next_o_we <= '0';

                else
                    next_state <= IDLE;
                                   
                end if;

            when leggo_indirizzo =>
                
            
                next_state <= salvo_indirizzo;
                next_o_en <= '0';
                next_o_we <= '0';

            when salvo_indirizzo =>

                

                next_ind <= i_data;
                

                next_state <= leggo_wz;
                next_o_address <= "000000000000"&contatore;
                next_o_en <= '1';
                next_o_we <= '0';

                


            when leggo_wz =>
                
                
            
                next_state <= confronto_indirizzo;
                next_contatore <= std_logic_vector(to_unsigned(to_integer(unsigned( contatore )) +1, 4));
                
                next_ind <= ind;   
                
            
            
                    
                

            when confronto_indirizzo =>
                
                
                if("11111111"=(ind xnor i_data )) then
                
                   
                    next_contatore <= contatore;
                    next_state <= scrivo_indirizzo;
                    next_o_en <= '1';
                    next_o_we <= '1';
                    next_o_address <= std_logic_vector(to_unsigned(9, 16));
                    
                    next_o_data <= '1' & std_logic_vector(to_unsigned(to_integer(unsigned( contatore )) -1, 3)) & "0001";   
                   
                    
                elsif("11111111"=(ind xnor std_logic_vector(to_unsigned(to_integer(unsigned( i_data )) + 1, 8)))) then
                        

                   
                    next_contatore <= contatore;
                    next_state <= scrivo_indirizzo;
                    next_o_en <= '1';
                    next_o_we <= '1';
                    next_o_address <= std_logic_vector(to_unsigned(9, 16));
                    
                    next_o_data <= '1' & std_logic_vector(to_unsigned(to_integer(unsigned( contatore )) -1, 3)) & "0010"; 
             

                elsif("11111111"=(ind xnor std_logic_vector(to_unsigned(to_integer(unsigned( i_data )) + 2, 8))) ) then
                
                    next_contatore <= contatore;
                    next_state <= scrivo_indirizzo;
                    next_o_en <= '1';
                    next_o_we <= '1';
                    next_o_address <= std_logic_vector(to_unsigned(9, 16));
                    
                    next_o_data <= '1' & std_logic_vector(to_unsigned(to_integer(unsigned( contatore )) -1, 3)) &  "0100";
                 
                elsif("11111111"=(ind xnor std_logic_vector(to_unsigned(to_integer(unsigned( i_data )) + 3, 8)))) then
                    
                    
                    next_contatore <= contatore;
                    next_state <= scrivo_indirizzo;
                    next_o_en <= '1';
                    next_o_we <= '1';
                    next_o_address <= std_logic_vector(to_unsigned(9, 16));
                    
                    next_o_data <= '1' & std_logic_vector(to_unsigned(to_integer(unsigned( contatore )) -1, 3)) & "1000";
                        
                elsif (contatore = "1000") then
                    next_contatore <= contatore;
                    next_state <= scrivo_indirizzo;
                    next_o_en <= '1';
                    next_o_we <= '1';
                    next_o_address <= std_logic_vector(to_unsigned(9, 16));
                    next_o_data <= ind;
                    

                else
                    next_contatore <= contatore;
                    next_state <= leggo_wz;
                    next_o_en <= '1';
                    next_o_we <= '0';
                    next_o_address <= "000000000000"&contatore;
                    next_ind <= ind;
                
                end if;
                   
                
                

            when scrivo_indirizzo =>
                
                
                next_state <= concludo;
                next_o_done <= '1';
                next_o_en <= '0';
                next_o_we <= '0';
                    
               

            when concludo=>
                

                if(i_start = '0') then
                    next_state <= IDLE;
                    next_o_done <='0';
                    
                elsif (i_start = '1') then
                    next_state <= concludo;
                    next_o_done <= '1';
                    
                end if;


            when others=>
            
            --NON DEVE ARRIVARCI MAI
                
            
            


    
        end case;
    end process;
end Behavioral;
class i2cmb_coverage extends ncsu_component#(.T(wb_transaction));
    
    i2cmb_env_configuration     configuration;
  
    bit [1:0] wb_addr_temp;
    bit     cmdr_err_flag;
    bit   wb_enb_temp;


    we_type_t we_type;
    cmdr_cmd_type_t cmdr_cmd_type;
    fsm_byte_level_type_t fsm_byte_level_type;
    fsm_bit_level_type_t fsm_bit_level_type;
    bit [7:0] reset_data;
    bit [31:0] ValidAddress;
    bit [31:0] InvalidAddress;
    reg_type_t default_registers;
    reg_type_t reg_access;
    reg_type_t RegFile_type;
    we_type_t WriteEnable_type;
    bit [1:0] wb_addr;
    bit [7:0] wb_data;
    bit wb_we;
    


    //for byte level FSM
    fsm_byte_level_type_t byte_fsm_type;
    cmdr_cmd_type_t cmdr_cmds;


  //*********************************** Covergroup for Register Block testing ***************************************
    covergroup reg_block;
    option.per_instance = 1;
    option.name = get_full_name();

     //for valid address check
     ValidAddress : coverpoint ValidAddress
	{
           bins Valid_address = {['d0:'d3]};
           // illegal_bins INVAILD_ADDR = {['h4:$]};

	}
     
     //to check working of error flag of CMDR
     cmdr_err_flag: coverpoint cmdr_err_flag
        {
            bins ERR_CMDR_FLAG  = {'b1};
        }

      //To check whether all the registers are accessed or not
      reg_access : coverpoint reg_access
        {
           bins CSR = {CSR};
           bins DPR = {DPR};
           bins CMDR = {CMDR};
           bins FSMR = {FSMR};  
        }

      // To verify default va;ues of registers
       default_registers: coverpoint default_registers
        {
            bins RESET_CSR = {'b11000000};
            bins RESET_DPR = {'b00000000};
            bins RESET_CMDR = {'b10000000};
            bins RESET_FSMR = {'b00000000};
        }

     //To ensure both read and write are occcuring
      we_type: coverpoint we_type
       {
           bins WB_READ_ENB = {WB_READ_ENB};
           bins WB_WRITE_ENB = {WB_WRITE_ENB}; 
       }

    
    wb_data: coverpoint wb_data
    {
      // regs checks by wb_data
      bins CSR_ALIAS  = {'hC0,'hC0,'h0}; 
      bins DPR_ALIAS  = {'hFF,'hFF,'hFF}; 
      bins CMDR_ALIAS = {'h04,'h04,'h04}; 
      bins FSMR_ALIAS = {'h0,'hFF,'h0}; 

    }
	
    wb_addr: coverpoint wb_addr 
    {
      // regs check by wb_addr
      bins CSR_ADDR_ALIAS  = {'b00}; 
      bins DPR_ADDR_ALIAS  = {'b01}; 
      bins CMDR_ADDR_ALIAS = {'b10};  
      bins FSMR_ADDR_ALIAS = {'b11}; 
    }

    wb_we: coverpoint wb_we 
    {
      // regs check by wb_we
      bins CSR_WE_AL  = {'d1,'d0}; 
      bins DPR_WE_AL  = {'d1,'d0};
      bins CMDR_WE_AL = {'d1,'d0};
      bins FSMR_WE_AL = {'d1,'d0};

    }

    bit_access_aliasing: cross wb_addr,wb_data,wb_we; 


    endgroup


  /************************************** Covergroup for Byte Level FSM *****************************************/
  
    covergroup byte_fsm_cg; 
        option.per_instance = 1;
        option.name = get_full_name();
	
        wb_cmds: coverpoint cmdr_cmds
         {
            bins INVALID   = {ST_INVALID};
 	       }
 	
        //To check what states are covered by the tests
	fsmr_states: coverpoint byte_fsm_type
         {
		        bins START_STATE         = {BYTE_FSM_START};
		        bins STOP_STATE          = {BYTE_FSM_STOP};
		        bins RWACK_STATE         = {BYTE_FSM_READ};
		        bins IDLE_STATE          = {BYTE_FSM_IDLE};
		        bins WRITE_CMD_STATE     = {BYTE_FSM_WRITE};
		        bins SET_BUS_STATE       = {BYTE_FSM_BUS_TAKEN};
		        bins WAIT_STATE          = {BYTE_FSM_WAIT};
		        bins START_PENDING_STARE = {BYTE_FSM_START_PENDING};
	        }
	
	fsm_start_state: coverpoint byte_fsm_type
         {            
		        bins DONE_START    = (BYTE_FSM_START => BYTE_FSM_BUS_TAKEN);
		        illegal_bins INVALID_START = (BYTE_FSM_START => BYTE_FSM_STOP, BYTE_FSM_START => BYTE_FSM_START_PENDING, BYTE_FSM_START => BYTE_FSM_READ, BYTE_FSM_START => BYTE_FSM_WRITE, BYTE_FSM_START => BYTE_FSM_WAIT);
	       }

	fsm_idle_state: coverpoint byte_fsm_type
         {             
		        bins WAIT_IDLE = (BYTE_FSM_IDLE => BYTE_FSM_WAIT);
		        bins START_IDLE  = (BYTE_FSM_IDLE => BYTE_FSM_START_PENDING);
		        illegal_bins INVALID_IDLE = (BYTE_FSM_IDLE => BYTE_FSM_STOP, BYTE_FSM_IDLE => BYTE_FSM_START, BYTE_FSM_IDLE => BYTE_FSM_READ, BYTE_FSM_IDLE => BYTE_FSM_WRITE, BYTE_FSM_IDLE => BYTE_FSM_BUS_TAKEN);
	        }

	fsm_stop_state: coverpoint byte_fsm_type
         {             
		        bins DONE_STOP = (BYTE_FSM_STOP => BYTE_FSM_IDLE);
	 	        illegal_bins INVALID_STOP = (BYTE_FSM_STOP => BYTE_FSM_START, BYTE_FSM_STOP => BYTE_FSM_START_PENDING, BYTE_FSM_STOP => BYTE_FSM_READ, BYTE_FSM_STOP => BYTE_FSM_WRITE, BYTE_FSM_STOP => BYTE_FSM_WAIT, BYTE_FSM_STOP => BYTE_FSM_BUS_TAKEN);
	       }

	fsm_wait_state: coverpoint byte_fsm_type
         {			  
		        bins DONE_WAIT = (BYTE_FSM_WAIT => BYTE_FSM_IDLE);
		        illegal_bins INVALID_WAIT = (BYTE_FSM_WAIT => BYTE_FSM_STOP, BYTE_FSM_WAIT => BYTE_FSM_START_PENDING, BYTE_FSM_WAIT => BYTE_FSM_READ, BYTE_FSM_WAIT => BYTE_FSM_WRITE, BYTE_FSM_WAIT => BYTE_FSM_START, BYTE_FSM_WAIT => BYTE_FSM_BUS_TAKEN);
	       }

	fsm_bus_taken_state: coverpoint byte_fsm_type
         {        
		        bins WRITE_BUS_TAKEN = (BYTE_FSM_BUS_TAKEN => BYTE_FSM_WRITE);
		        bins READ_BUS_TAKEN   = (BYTE_FSM_BUS_TAKEN => BYTE_FSM_READ);
		        bins START_BUS_TAKEN  = (BYTE_FSM_BUS_TAKEN => BYTE_FSM_START);
		        bins STOP_BUS_TAKEN   = (BYTE_FSM_BUS_TAKEN => BYTE_FSM_STOP);
	     }

	fsm_write_state : coverpoint byte_fsm_type
         {          
		        bins DONE_WITH_ACK   = (BYTE_FSM_WRITE => BYTE_FSM_BUS_TAKEN);
		       	       }

	fsm_read_state : coverpoint byte_fsm_type
         {           
		        bins NACK_READ   = (BYTE_FSM_READ => BYTE_FSM_BUS_TAKEN);
		      	       }
    endgroup

   //***************************** Covergroup for Bit Level FSM *****************************
   
    covergroup bit_fsm_cg;
        option.per_instance = 1;
        option.name = get_full_name();

        //To check what states are covered by the states
 
       cmdr_cmd_invalid: coverpoint cmdr_cmd_type
       {
          bins ST_START_CMD    = {ST_START_CMD};
          bins ST_STOP_CMD     = {ST_STOP_CMD};
          bins ST_READ_ACK_CMD = {ST_READ_ACK_CMD};
          bins ST_READ_NAK_CMD = {ST_READ_NAK_CMD};
          bins ST_WRITE_CMD    = {ST_WRITE_CMD};
          bins ST_SET_BUS_CMD  = {ST_SET_BUS_CMD};
          bins ST_WAIT_CMD     = {ST_WAIT_CMD};
          bins INVALID_CMDR = default;
       }

 
      //To check valid states 
      fsm_bit_level_valid: coverpoint fsm_bit_level_type
       {
          bins BIT_FSM_STATE_IDLE   ={BIT_FSM_STATE_IDLE};  
          bins BIT_FSM_START_A      ={BIT_FSM_START_A};   
          bins BIT_FSM_START_B      ={BIT_FSM_START_B};   
          bins BIT_FSM_START_C      ={BIT_FSM_START_C};   
          bins BIT_FSM_RW_A         ={BIT_FSM_RW_A};   
          bins BIT_FSM_RW_B         ={BIT_FSM_RW_B};  
          bins BIT_FSM_RW_C         ={BIT_FSM_RW_C};   
          bins BIT_FSM_RW_D         ={BIT_FSM_RW_D};   
          bins BIT_FSM_RW_E         ={BIT_FSM_RW_E};   
          bins BIT_FSM_STOP_A       ={BIT_FSM_STOP_A};   
          bins BIT_FSM_STOP_B       ={BIT_FSM_STOP_B};   
          bins BIT_FSM_STOP_C       ={BIT_FSM_STOP_C};  
          bins BIT_FSM_RSTART_A     ={BIT_FSM_RSTART_A};   
          bins BIT_FSM_RSTART_B     ={BIT_FSM_RSTART_B};   
          bins BIT_FSM_RSTART_C     ={BIT_FSM_RSTART_C};
       }

      fsm_bit_level_invalid: coverpoint fsm_bit_level_type
       {
         //illegal_bins INVAILD_FSM_BIT = default;
       }

      //to check the transition of address signal
      fsm_addr_bit: coverpoint wb_addr_temp
      {
        bins ADDR_TRANS = {2'b11,2'b10};
      }

      //to check the transitions of enable signal     
      fsm_we_bit: coverpoint wb_enb_temp
      {
        bins WRITE_ENB_TRANS  = {1'b1,1'b0};
      }
      
      fsm_valid_bit: cross fsm_we_bit, fsm_addr_bit;

  endgroup
    
   
//************************************All Covergroups END Here *****************************
   function new(string name = "", ncsu_component #(T) parent = null); 
      super.new(name,parent);
      //to create object of the covergroups
      reg_block = new;  
      byte_fsm_cg = new;
      bit_fsm_cg = new;
    endfunction
  
    function void set_configuration(i2cmb_env_configuration cfg);
      configuration = cfg;
    endfunction


    virtual function void nb_put(T trans);


      if(trans.wb_addr == 'h2) 
         begin
            cmdr_cmd_type       = cmdr_cmd_type_t'(trans.wb_data[2:0]);
   	    cmdr_err_flag       = (trans.wb_data[4]);
	    cmdr_cmds           = cmdr_cmd_type_t'(trans.wb_data);
        end

      if(trans.wb_addr == 'h3) 
	  begin
            byte_fsm_type   = fsm_byte_level_type_t'(trans.wb_data[7:4]);
            fsm_bit_level_type    = fsm_bit_level_type_t'(trans.wb_data[3:0]);
          end
      
      //some other temp vars assigned with wishbone signals
      we_type = we_type_t'(trans.wb_we);
      wb_addr_temp = trans.wb_addr;
      reg_access = reg_type_t'(trans.wb_addr);
      RegFile_type = reg_type_t'(trans.wb_addr);
      WriteEnable_type = we_type_t'(trans.wb_we);
      ValidAddress = trans.wb_addr;
      InvalidAddress = trans.wb_addr;
      byte_fsm_type   = fsm_byte_level_type_t'(trans.wb_data[7:4]);
      fsm_bit_level_type    = fsm_bit_level_type_t'(trans.wb_data[3:0]);
      wb_addr = trans.wb_addr;
      wb_data = trans.wb_data;
      wb_we = trans.wb_we;


      reg_block.sample();
      byte_fsm_cg.sample();
      bit_fsm_cg.sample();
    endfunction
 endclass

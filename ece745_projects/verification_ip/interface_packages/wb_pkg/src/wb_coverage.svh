class wb_coverage extends ncsu_component#(.T(wb_transaction));

    wb_configuration configuration;

    bit [1:0] wb_addr;
    bit [7:0] wb_data;
    bit [31:0] addr_valid;
    bit wb_we;


    covergroup reg_block;

    option.per_instance = 1;

    option.name = get_full_name();

  
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

    //bit_access_aliasing: cross wb_addr,wb_data,wb_we; 

   endgroup


  function new(string name = "", ncsu_component #(T) parent = null); 
    super.new(name,parent);
    reg_block = new;
  endfunction

  function void set_configuration(wb_configuration cfg);
    configuration = cfg;
  endfunction

  virtual function void nb_put(T trans);
    //assignments to all the local variables here
    addr_valid = trans.wb_addr;
    wb_addr = trans.wb_addr;
    wb_data = trans.wb_data;
    wb_we = trans.wb_we;
    reg_block.sample();
  endfunction



endclass

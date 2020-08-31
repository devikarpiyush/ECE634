class wb_driver extends ncsu_component #(.T(wb_transaction));

    
    //calling new function of parent class 
    function new(string name = "", ncsu_component_base parent = null);
        super.new(name,parent);
    endfunction


    virtual wb_if bus;  // declaring virtual interface if WB 
    wb_configuration configuration;  // handle of WB config class
    wb_transaction trans;  //handle of transaction class

    bit [1:0] wb_read_addr;
    bit [7:0] wb_read_data;

    //user defined function to set configuration
    function void set_configuration(wb_configuration cfg);
        configuration = cfg;
    endfunction

    //blocking put task that drives the WB interface with transaction
    virtual task bl_put(T trans);
	bus.wait_for_reset();
        if(trans.wb_wait_for_irq == 'b1)     // wait for interrupt signal becomes high
            begin
                bus.wait_for_interrupt();  //wait for interrupt
        	bus.master_read(trans.wb_addr,trans.wb_data);  //then read from the bus
    	    end

   	else
      	    begin
                if (trans.wb_we == 'b1) //if write enable is high
   		    begin
                        bus.master_write(trans.wb_addr,trans.wb_data);  //write operation
                    end
        	else
		    begin
          		bus.master_read(trans.wb_addr,trans.wb_data);  //read operation
        	    end
            end
  endtask

endclass

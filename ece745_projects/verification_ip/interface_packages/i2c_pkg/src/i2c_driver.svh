class i2c_driver extends ncsu_component#(.T(i2c_transaction));

    //calling new function of the parent class
    function new(string name = "", ncsu_component_base parent = null);
      super.new(name,parent);
    endfunction

    virtual i2c_if bus;  //declaring I2C interface as virtual
    i2c_configuration configuration;  //handle of I2C config class
    i2c_transaction i2c_trans;  //handle of I2C transaction class

    bit [7:0] i2c_read_data_arr [], i=0, j=0, single_or_alternate_read=0;

    //functiom to set config
    function void set_configuration(i2c_configuration cfg);
        configuration = cfg;
    endfunction

    //blocking put method to put I2C transactions in the I2C interface
    virtual task bl_put(T trans);
        $display({get_full_name()," ",trans.convert2string()});
        forever
            begin
                bus.wait_for_i2c_transfer(trans.i2c_Operation,trans.i2c_Data);

    		if(trans.i2c_Operation == READ) //if Read operation
    		    begin
	                i2c_read_data_arr = new [1];

      			if(single_or_alternate_read < 32 ) 
			    begin
      			        i2c_read_data_arr [0] = (100+i);
      			        i++;
      				bus.provide_read_data(i2c_read_data_arr);
      				single_or_alternate_read++;
      		    	    end

      		else if(single_or_alternate_read>=32)
        	    begin 
                        i2c_read_data_arr [0] = (63-j); 
                        bus.provide_read_data(i2c_read_data_arr);
		        j++;
                    end
    	        end
           end
    endtask

endclass

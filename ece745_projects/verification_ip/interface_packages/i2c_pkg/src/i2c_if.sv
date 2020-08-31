//typedef enum bit {WRITE, READ} i2c_op_t;
interface i2c_if		#(
		int I2C_DATA_WIDTH = 8,
		int I2C_ADDR_WIDTH = 8
		)
(

	//************* I2C Signals *****************
	input tri SCL,
	inout tri SDA_O
	);
	import i2c_pkg::*;
	bit sda = 1'b1;
	assign SDA_O = sda ? 'bz : 'b0;
	
	bit [I2C_ADDR_WIDTH-1:0] slave_addr = 8'h22;             //Setting a fix slave address
	int check = 0;
	int check_for_monitor = 0;
	i2c_op_t op; 
	int data_iterator= 0;
	int data_iterator_for_monitor= 0;
	int restart_flag = 0;
	int restart_flag_for_monitor =0;
  	bit [I2C_DATA_WIDTH-1:0] data_for_monitor;
	int monitor_index = 0;


// *******************************Wait for I2C Transfer*********************************************//
	task wait_for_i2c_transfer(output i2c_op_t op, output bit [I2C_DATA_WIDTH-1:0] write_data[]);
	int i;
	
	bit [I2C_DATA_WIDTH-1:0] address; 
	bit [I2C_DATA_WIDTH-1:0] data_i2c;

		if (!restart_flag)
			begin
				do
				@(negedge SDA_O);
				while(!SCL);	
			end
		restart_flag = 0;


	//******************************START Detected**************************************************//		

		check = 1;	

	//Transfer the device address bits one by one from the SDA_O line//
		@(posedge SCL)
			address[6] = SDA_O;
		@(posedge SCL)
			address[5] = SDA_O;
		@(posedge SCL)
			address[4] = SDA_O;
		@(posedge SCL)
			address[3] = SDA_O;
		@(posedge SCL)
			address[2] = SDA_O;
		@(posedge SCL)
			address[1] = SDA_O;
		@(posedge SCL)
			address[0] = SDA_O;
		
		@(posedge SCL);

	//Check for the set slave address to be equal to the address recieved on the SDA_O line//
		if(slave_addr == address)
		@(negedge SCL)
		begin
			sda =0;                            // pull the Sda line low if the address is right - ACK//
			if(!SDA_O)
			begin
				op = WRITE;
			end                                 //check for the last bit in the address and set the operation type on that basis//
			else if(SDA_O)
			begin
				op = READ;
			end
		 
		end 
		
		if(check == 1 && op == WRITE)
		begin			
		i = 0;
			forever
			begin
				@(negedge SCL);
				sda = 1;						// release the SDA line to 1 again//

				@(posedge SCL);
				@(SDA_O or negedge SCL);
				if (!SCL)						// Data transfer only possible if SCL is kept low//
					begin
			//Transfer the 8 data bits from the SDA_O line to the local data array//
							data_i2c [7] = SDA_O;
	                        @ (posedge SCL);
	                        data_i2c [6] = SDA_O;
	                        
	                        @ (posedge SCL);
	                        data_i2c [5] = SDA_O;
	                        
	                        @ (posedge SCL);
	                        data_i2c [4] = SDA_O;
	                        
	                        @ (posedge SCL);
	                        data_i2c [3] = SDA_O;
	                        
	                        @ (posedge SCL);
	                        data_i2c [2] = SDA_O;
	                        
	                        @ (posedge SCL);
	                        data_i2c [1] = SDA_O;
	                        
	                        @ (posedge SCL);
	                        data_i2c [0] = SDA_O;	
				
					data_iterator++;

					write_data = new[data_iterator](write_data); //Copy the data addresses into a new data array in case of bursts of addresses//
					write_data[i] = data_i2c;					// Transfer the address from local array to the argument//
					i++;

				
					@(negedge SCL);
                    			sda = 0;
                    			data_i2c = 0;

                    @(posedge SCL);

				end
				else if(!SDA_O) 
				begin
					restart_flag = 1;    // Repeated Start detected , set restart flag as 1 and check 0 so as to re - enter into start //
					check = 0;
					break; 
				end 
				else if(SDA_O) 
				begin	
					break;              // If SDA_0 goes from low to high then Stop Detected //
				end
			end
		end
	endtask
	
//***********************************************************************************************//

// *******************************Provide READ Data*********************************************//	
	task provide_read_data(input bit [I2C_DATA_WIDTH-1:0] read_data[]);

		 int i,size;
		 i=0; 
		 size = read_data.size();      // Getting the size of the input read argument so that it could later be checked for ACK or NACK//
		 @(posedge SCL);
    		if (SDA_O)
    		begin
									    //wait for restart or stop
          		
    		end

		else if (!SDA_O)
		begin
		forever
		begin 
			//READ the contents of an argument array onto the sda line bit by bit//
			@(negedge SCL);			
			sda = read_data[i][7];				
			@(negedge SCL);
			sda = read_data[i][6];
			@(negedge SCL);
			sda = read_data[i][5];
			@(negedge SCL);
			sda = read_data[i][4];
			@(negedge SCL);
			sda = read_data[i][3];
			@(negedge SCL);
			sda = read_data[i][2];
			@(negedge SCL);
			sda = read_data[i][1];
			@(negedge SCL);
			sda = read_data[i][0];
			i++;

			@(negedge SCL);
			
			if(i < size)
			begin 
				sda = 0;                      // pull the sda line low - ACK until the total capacity of reading data has been fulfilled//
			end
			else if (i == size )
			begin
				sda = 1; 					 // Keep the Sda line high for NACK to indicate this amount of data can only be read//
			end 


			@(posedge SCL);

			if(SDA_O)  
			@(posedge SCL)
        		begin
											//wait for restart or stop;
            			
            			restart_flag = 1;	//If SDA_0 goes from low to high then Stop Detected, Set Restart flag as 1 //
           			break;
        		end
			
		end
 
		end 

	endtask
	
//***********************************************************************************************//

// *******************************Monitor I2C operation*********************************************//	
	
	task monitor(output bit [I2C_ADDR_WIDTH-1:0] addr, output i2c_op_t op, output bit [I2C_DATA_WIDTH-1:0] data[]);
	int i,j;
	
		data.delete();                              // delete the previous data so as to not accumulate it //
				
		if (!restart_flag_for_monitor)
			begin
				do
				@(negedge SDA_O);
				while(!SCL);	
			end
		restart_flag_for_monitor = 0;

		//**************************** START detected in monitor_task ****************************************//
		
		if(check_for_monitor == 0)
		begin
		//Transfer the device address bits one by one from the SDA_O line//	
			@(posedge SCL)
			addr[6] = SDA_O;
			@(posedge SCL)
			addr[5] = SDA_O;
			@(posedge SCL)
			addr[4] = SDA_O;
			@(posedge SCL)
			addr[3] = SDA_O;
			@(posedge SCL)
			addr[2] = SDA_O;
			@(posedge SCL)
			addr[1] = SDA_O;
			@(posedge SCL)
			addr[0] = SDA_O;
		

			@(posedge SCL);

			check_for_monitor =1;
		//Check for the set slave address to be equal to the address recieved on the SDA_O line//
		
			if(slave_addr == addr)
			@(negedge SCL)
			begin
				if(!SDA_O)
				begin
					op = WRITE;
				end 						//check for the last bit in the address and set the operation type on that basis//
				else if(SDA_O)
				begin
					op = READ;
				end
		 
			end 
			 @(posedge SCL);
		end

		if(check_for_monitor == 1)			
		begin 
			forever 
				begin
					@(negedge SCL);

					@(posedge SCL);
					
					data_iterator_for_monitor++;
					@(SDA_O or negedge SCL);
                			if(!SCL)                       // Data transfer only possible if SCL is kept low//
					begin
						//Transfer the 8 data bits from the SDA_O line to the local data array//
						data_for_monitor[7] = SDA_O;
						@(posedge SCL)
						data_for_monitor[6] = SDA_O;
						@(posedge SCL)
						data_for_monitor[5] = SDA_O;
						@(posedge SCL)
						data_for_monitor[4] = SDA_O;
						@(posedge SCL)
						data_for_monitor[3] = SDA_O;
						@(posedge SCL)
						data_for_monitor[2] = SDA_O;
						@(posedge SCL)
						data_for_monitor[1] = SDA_O;
						@(posedge SCL)
						data_for_monitor[0] = SDA_O;

						data = new[data_iterator_for_monitor](data);  //Copy the data addresses into a new data array in case of bursts of addresses//

						data [monitor_index] = data_for_monitor;     // Transfer the address from local array to the argument//
                    				monitor_index++;

						@(negedge SCL);

								@ (posedge SCL);
                   				if(SDA_O)  
						@(posedge SCL)
                    				begin	
										check_for_monitor = 0;
                      					restart_flag_for_monitor = 1;
                      					data_iterator_for_monitor = 0;
                      					monitor_index = 0;
                      					break;
                    				end
					end


					else if (SDA_O)								// Stop Condition // 
                			begin
                      				check_for_monitor = 0;
                      				data_iterator_for_monitor = 0;
                      				monitor_index = 0;
                      				break;
                			end



					else if  (!SDA_O)                          // Start Detection/Restart//
			                begin
								restart_flag_for_monitor = 1;
				                check_for_monitor = 0;
                  				data_iterator_for_monitor = 0;
                  				monitor_index = 0;
                  				break;
              				end
				
				end
			end
	endtask
//***********************************************************************************************//	
endinterface

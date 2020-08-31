`timescale 1ns / 10ps

// `include "../ece7454_projects/verification_ip/interface_packages/i2c_packages/i2c_pkg/src/i2c_if.sv"

module top();

	parameter int WB_ADDR_WIDTH = 2;
	parameter int WB_DATA_WIDTH = 8;
	parameter int I2C_ADDR_WIDTH = 8;
	parameter int I2C_DATA_WIDTH = 8;
	parameter int NUM_I2C_SLAVES = 1;
	parameter int cycle = 10;
	parameter int simulation_time = 200000;
	parameter int rst_time = 113;

	bit  clk;
	bit  rst = 1'b1;
	wire cyc;
	wire stb;
	wire we;
	tri1 ack;
	wire [WB_ADDR_WIDTH-1:0] adr;
	wire [WB_DATA_WIDTH-1:0] dat_wr_o;
	wire [WB_DATA_WIDTH-1:0] dat_rd_i;
	wire irq;
	triand  [NUM_I2C_SLAVES-1:0] scl;
	triand  [NUM_I2C_SLAVES-1:0] sda;

	bit op;
	bit [I2C_DATA_WIDTH-1:0] write_data_top [];
	bit [I2C_DATA_WIDTH-1:0] read_data_top [];

	// Declaring master_monitor registers

	bit [WB_ADDR_WIDTH-1:0] address = 'b0;
	bit [WB_DATA_WIDTH-1:0] data = 'b0;
	bit [I2C_ADDR_WIDTH-1:0] i2c_addr;
	bit [I2C_DATA_WIDTH-1:0] i2c_data [];
	bit we_wb_if = 'b0;

	// declaring for master_write

	bit [WB_DATA_WIDTH-1:0] iic_en = 'b11xxxxxx;
	bit [WB_DATA_WIDTH-1:0] iic_id = 'h05;
	bit intr = 'b0;
	int i2c_r_task = 1, i2c_w_task = 1, alternate_read = 63;

	// ****************************************************************************
	// Clock generator

	initial
	begin : clk_gen
		clk = 0;
		forever #(cycle/2) clk = ~clk;
		//#simulation_time $finish;
	end :clk_gen



	// ****************************************************************************
	// Reset generator
	initial
		begin : rst_gen
			#rst_time rst = 0;
		end :rst_gen


	// ****************************************************************************
	// Monitor Wishbone bus and display transfers in the transcript

	initial
		begin : wb_monitoring
	 	//wb_bus.master_monitor (address, data, we_wb_if);
	 		#1
	  		forever 
	  			begin
					wb_bus.master_monitor (address, data, we_wb_if);
					$display ("ADDRESS  :0x%h, 	DATA  :0x%h, 	WE 	:0x%h", address,data,we_wb_if);
				end
		end : wb_monitoring

	// ****************************************************************************
	// Monitor I2C bus and display transfers in the transcript

	initial
		begin :	i2c_monitor
		// #1
	  		forever 
	  			begin
	  			// #1
					i2c_bus.monitor (i2c_addr, op, i2c_data);
					if (op == 0) 
						begin
							$display("\n/************* I2C_BUS WRITE Transfer *************/\n//\n");
							$display ("ADDRESS  :0x%h  DATA  :%p", i2c_addr,i2c_data);
							$display("\n/**************** I2C_BUS WRITE TRANSFER ENDS *******************/\n");
						end
					else
						begin
							$display("\n/************* I2C_BUS READ Transfer *************/\n//\n");
							$display ("ADDRESS  :0x%h  DATA  :%p", i2c_addr,i2c_data);
							$display("\n/**************** I2C_BUS READ TRANSFER ENDS *******************/\n");
						end
				end
		end   :	i2c_monitor

	// ****************************************************************************

	// Define the flow of the simulation

	initial
		begin : test_flow
			bit [7:0]  wb_data;
			bit [I2C_DATA_WIDTH-1:0]  read_output;
			/********** TASK 1: 32 bytes WRITE (0-31) **********/
			$display("************************ START OF SIMULATION ************************\n");
			$display("/************* TASK 1: 32 bytes WRITE (0-31) *************/\n");
			write_32transfers_to_I2C_bus('h22, 'h00,'h00);		//task wb_commands(input bit [7:0] slave_addr, input bit [7:0] i2c_bus, input bit wb_op, inout bit [7:0]  wb_data);
			/***************************************************/
			/******** TASK 2: 32 bytes READ (100-131) **********/
			$display("/*********** TASK 2: 32 bytes READ (100-131) *************/\n");
			read_32transfers_from_I2C_bus('h22, 'h00, read_output);
			/***************************************************/
			/********** TASK 3: Alternate WRITE (64-127) and READ (63-0) **********/
			$display("/************* TASK 3: Alternate WRITE (64-127) and READ (63-0) *************/\n");
			$display("\n /***** 2 bytes of WRITE command followed by 2 bytes of READ command alternatively *****/ \n",);

			for (int i = 64; i < 128; i = i + 2) 
				begin
					write_2_bytes_to_I2C('h22, 'h00, i);	// Increment write data from 64	to 127
					read_2_bytes_from_I2C('h22, 'h00, read_output); // Decrement read data from	63 to 0
				end
			$display("************************ SIMULATION ENDS HERE ************************\n");
			#simulation_time $finish;

		end : test_flow

	// ****************************************************************************

	// Define the flow of the simulation

	initial
	begin : i2c_if_test_flow
		forever
			begin
				i2c_bus.wait_for_i2c_transfer(op, write_data_top);
				if(op == 'b0 ) 
					begin
						// $display("WRITE DATA @ TOP = %p",write_data_top);
					end
			
				else if(op == 'b1)
					begin
						/**************** READ TASK 1: 32 Bytes READ (100 - 131) **************/
						if( i2c_r_task == 1) 						
							begin
								read_data_top = new [32];
								for (int i = 0; i < 32 ; i++) 
									begin
										read_data_top [i] = 100 + i;
									end
								i2c_r_task ++;
								i2c_bus.provide_read_data(read_data_top);
							end

				/**************** READ TASK 2: 2 bytes (63-0) ********************/
						else if (i2c_r_task > 1)
							begin 
								read_data_top.delete();
								read_data_top = new [2];
								read_data_top[0] = alternate_read --;
								read_data_top[1] = alternate_read --;
								i2c_bus.provide_read_data(read_data_top);
							end

				/*****************************************************************/
					end
			end
	end : i2c_if_test_flow
	// ****************************************************************************

	// Instantiate the Wishbone master Bus Functional Model
	wb_if       #(
      .ADDR_WIDTH(WB_ADDR_WIDTH),
      .DATA_WIDTH(WB_DATA_WIDTH)
      )
	wb_bus (
  	// System sigals
  	.clk_i(clk),
  	.rst_i(rst),
  	// Master signals
  	.cyc_o(cyc),
  	.stb_o(stb),
  	.ack_i(ack),
  	.adr_o(adr),
  	.we_o(we),
  	// Slave signals
  	.cyc_i(),
  	.stb_i(),
  	.ack_o(),
  	.adr_i(),
  	.we_i(),
  	// Shred signals
  	.dat_o(dat_wr_o),
  	.dat_i(dat_rd_i)
  	);

	// ****************************************************************************

	// ****************************************************************************
	// Instantiate the I2C master Bus Functional Model
	i2c_if       #(
      .I2C_ADDR_WIDTH(I2C_ADDR_WIDTH),
      .I2C_DATA_WIDTH(I2C_DATA_WIDTH)
      )
	i2c_bus (

  	.i2c_scl_i(scl),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Clock inputs
  	.i2c_sda_io(sda)         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Data inputs
  	);

	// ****************************************************************************

	// Instantiate the DUT - I2C Multi-Bus Controller
	\work.iicmb_m_wb(str) #(.g_bus_num(NUM_I2C_SLAVES)) DUT
 	 (
    // ------------------------------------
    // -- Wishbone signals:
    .clk_i(clk),         // in    std_logic;                            -- Clock
    .rst_i(rst),         // in    std_logic;                            -- Synchronous reset (active high)
    // -------------
    .cyc_i(cyc),         // in    std_logic;                            -- Valid bus cycle indication
    .stb_i(stb),         // in    std_logic;                            -- Slave selection
    .ack_o(ack),         //   out std_logic;                            -- Acknowledge output
    .adr_i(adr),         // in    std_logic_vector(1 downto 0);         -- Low bits of Wishbone address
    .we_i(we),           // in    std_logic;                            -- Write enable
    .dat_i(dat_wr_o),    // in    std_logic_vector(7 downto 0);         -- Data input
    .dat_o(dat_rd_i),    //   out std_logic_vector(7 downto 0);         -- Data output
    // ------------------------------------
    // ------------------------------------
    // -- Interrupt request:
    .irq(irq),           //   out std_logic;                            -- Interrupt request
    // ------------------------------------
    // ------------------------------------
    // -- I2C interfaces:
    .scl_i(scl),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Clock inputs
    .sda_i(sda),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Data inputs
    .scl_o(scl),         //   out std_logic_vector(0 to g_bus_num - 1); -- I2C Clock outputs
    .sda_o(sda)          //   out std_logic_vector(0 to g_bus_num - 1)  -- I2C Data outputs
    // ------------------------------------
  	);

	//************************************************************************//

	// ************************** 32 bytes Write******************************//

	task write_32transfers_to_I2C_bus(input bit [I2C_DATA_WIDTH-1:0] slave_addr, input bit [I2C_DATA_WIDTH-1:0] i2c_bus, input bit [I2C_DATA_WIDTH-1:0]  wb_data);

		#1100
		address = 'b00;
		data = 'b11000000;			// Enabling the I2C core by setting CSR to 'b11xxxxxx
		wb_bus.master_write (address, data);

		data = i2c_bus;				// Setting the I2C ID = 0x01
	  	address = 'b01;
	  	wb_bus.master_write (address, data);

	  	data = 'bxxxxx110;			//Setting CMDR to 'bxxxxx110
	  	address = 'b10;
	  	wb_bus.master_write (address, data);

		while (!irq) @(posedge clk);

		wb_bus.master_read (address,data);
		// $display("Interrupt 1");
		address = 'b10;
		data = 'bxxxxx100;			//Setting CMDR to 'bxxxxx100
		wb_bus.master_write (address, data);

		while (!irq) @(posedge clk);   		//Checking Interrupt bit of CMDR

		wb_bus.master_read (address,data);
		// $display("Interrupt 2 :");

		address = 'b01;
		data = (slave_addr << 1);
		wb_bus.master_write (address, data);	//Writing 0x44 to DPR to shift slave address by 1 bit

		address = 'b10;
		data = 'bxxxxx001;
		wb_bus.master_write (address, data);	//Writing 0xx1 to CMDR

	// ************************** 32 bytes Write******************************//
		for (int write_loop = wb_data; write_loop < wb_data+32; write_loop++)
			begin
				while (!irq) @(posedge clk);   		//Checking Interrupt bit of CMDR

				wb_bus.master_read (address, data);
				// $display("Interrupt 3 :");


				address = 'b01;
				data = write_loop;
				wb_bus.master_write (address, data);	//Writing 0x78 data to DPR, 0x22 address of the slave I2C# 5
				// $display("Data write to slave");

				address = 'b10;
				data = 'bxxxxx001;
				wb_bus.master_write (address, data);	//Writing 0xx1 data to CMDR,Write command

			end
	//************************************************************************//
		
		while (!irq) @(posedge clk);
		wb_bus.master_read (address, data);
		// $display("Interrupt 4 :");

		address = 'b10;
		data = 'bxxxxx101;
		wb_bus.master_write (address,data);	//Writing 0xx5 data to CMDR,STOP command

		while (!irq) @(posedge clk);
		wb_bus.master_read (address, data);
		// $display("Interupt 5");


	endtask

	//************************************************************************//

	// ************************** 2 bytes Write with REPEATED START ******************************//

	task write_2_bytes_to_I2C(input bit [I2C_DATA_WIDTH-1:0] slave_addr, input bit [I2C_DATA_WIDTH-1:0] i2c_bus, input bit [I2C_DATA_WIDTH-1:0]  wb_data);

		#1100
		address = 'b00;
		data = 'b11000000;			// Enabling the I2C core by setting CSR to 'b11xxxxxx
		wb_bus.master_write (address, data);

		data = i2c_bus;				// Setting the I2C ID = 0x05
	  	address = 'b01;
	  	wb_bus.master_write (address, data);

	  	data = 'bxxxxx110;			//Setting CMDR to 'bxxxxx110
	  	address = 'b10;
	  	wb_bus.master_write (address, data);

		while (!irq) @(posedge clk);

		wb_bus.master_read (address,data);
		// $display("Interrupt 1");
		address = 'b10;
		data = 'bxxxxx100;			//Setting CMDR to 'bxxxxx100
		wb_bus.master_write (address, data);

		while (!irq) @(posedge clk);   		//Checking Interrupt bit of CMDR

		wb_bus.master_read (address,data);
		// $display("Interrupt 2 :");

		address = 'b01;
		data = (slave_addr << 1);
		wb_bus.master_write (address, data);	//Writing 0x44 to DPR to shift slave address by 1 bit

		address = 'b10;
		data = 'bxxxxx001;
		wb_bus.master_write (address, data);	//Writing 0xx1 to CMDR

		while (!irq) @(posedge clk);   		//Checking Interrupt bit of CMDR

		wb_bus.master_read (address, data);
		// $display("Interrupt 3 :");


		wb_bus.master_write ('b01, wb_data);	//Writing wb_data data to DPR, 0x22 address of the slave I2C# 5
		// $display("Data write to slave");

		address = 'b10;
		data = 'bxxxxx001;
		wb_bus.master_write (address, data);	//Writing 0xx1 data to CMDR,Write command


	// ************************** REPEATED START CONDITION ******************************//

		while (!irq) @(posedge clk);

		wb_bus.master_read (address,data);
		// $display("Interrupt 1");
		address = 'b10;
		data = 'bxxxxx100;			//Setting CMDR to 'bxxxxx100
		wb_bus.master_write (address, data);

		while (!irq) @(posedge clk);   		//Checking Interrupt bit of CMDR

		wb_bus.master_read (address,data);
		// $display("Interrupt 2 :");

		address = 'b01;
		data = (slave_addr << 1);
		wb_bus.master_write (address, data);	//Writing 0x44 to DPR to shift slave address by 1 bit

		address = 'b10;
		data = 'bxxxxx001;
		wb_bus.master_write (address, data);	//Writing 0xx1 to CMDR

		while (!irq) @(posedge clk);   		//Checking Interrupt bit of CMDR

		wb_bus.master_read (address, data);
		// $display("Interrupt 3 :");


		wb_bus.master_write ('b01, wb_data+1);	//Writing wb_data data to DPR, 0x22 address of the slave I2C# 5
		// $display("Data write to slave");

		address = 'b10;
		data = 'bxxxxx001;
		wb_bus.master_write (address, data);	//Writing 0xx1 data to CMDR,Write command
		while (!irq) @(posedge clk);
		wb_bus.master_read (address, data);
		// $display("Interrupt 4 :");

		address = 'b10;
		data = 'bxxxxx101;
		wb_bus.master_write (address,data);	//Writing 0xx5 data to CMDR,STOP command

		while (!irq) @(posedge clk);
		wb_bus.master_read (address, data);
		// $display("Interupt 5");


	endtask

	//************************************************************************//

	// ************************** 32 bytes READ ******************************//

	task read_32transfers_from_I2C_bus(input bit [7:0] slave_addr, input bit [7:0] i2c_bus, output bit [7:0]  wb_read_data);
		#1100
	// 0 // Enabling the I2C core by setting CSR to 'b11xxxxxx
		wb_bus.master_write ('b00, 'b11000000);

	// 1 // Setting the I2C ID = 0x01
	  	wb_bus.master_write ('b01, i2c_bus);


	// 2 // Setting CMDR to 'bxxxxx110 SET command
	  	wb_bus.master_write ('b10,'bxxxxx110);

	// 3 // Waiting for Interrupt
		while (!irq) @(posedge clk);
		wb_bus.master_read (address,data);
		// $display("Interrupt 1");

	// 4 // Setting CMDR to 'bxxxxx100 START command
		wb_bus.master_write ( 'b10,'bxxxxx100);

	// 5 // Checking Interrupt bit of CMDR
		while (!irq) @(posedge clk);
		wb_bus.master_read (address,data);
		// $display("Interrupt 2 :");

		wb_bus.master_write ('b01, 'b01000101);	// 14 // Writing 0x45 to DPR to shift slave address by 1 bit + 1 to the rightmost bit meaning READ

		wb_bus.master_write ('b10, 'b001);	// 15 // WRITE command for the

		while (!irq) @(posedge clk);   		// 16 // Checking Interrupt bit of CMDR
		wb_bus.master_read (address,data);

	// ************************** 32 bytes READ loop ******************************//

		for (int read_loop = 0; read_loop < 31; read_loop++)
		begin

			wb_bus.master_write ('b10,'b010);		// 17 // "READ with ACK" command

			while (!irq) @(posedge clk);   		// 18 // Checking Interrupt bit of CMDR
			wb_bus.master_read (address,data);

			wb_bus.master_read ('b01, wb_read_data);		// 19 // "READ" DPR commad to get received byte

			// $display("********************");
			// $display("READ Data @ DPR = %d or %b",wb_read_data,wb_read_data);
			// $display("********************");
		end

		wb_bus.master_write ('b10,'b011);		// 17 // "READ with NACK" command

		while (!irq) @(posedge clk);   		// 18 // Checking Interrupt bit of CMDR
		wb_bus.master_read (address,data);

		wb_bus.master_read ('b01, wb_read_data);		// 19 // "READ" DPR commad to get received byte
		//
		// $display("********************");
		// $display("READ Data @ DPR = %d or %b",wb_read_data,wb_read_data);
		// $display("********************");

		wb_bus.master_write ('b10,'bxxxxx101);	// 20 // Writing 0xx5 data to CMDR,STOP command

		while (!irq) @(posedge clk);		// 21 // Checking Interrupt bit of CMDR
		wb_bus.master_read (address, data);
		// $display("Interupt 5");

	endtask

	//************************************************************************//

	// ************************** 2 bytes READ ******************************//

	task read_2_bytes_from_I2C(input bit [7:0] slave_addr, input bit [7:0] i2c_bus, output bit [7:0]  wb_read_data);
		#1100
		// 0 // Enabling the I2C core by setting CSR to 'b11xxxxxx
		wb_bus.master_write ('b00, 'b11000000);

		// 1 // Setting the I2C ID = 0x01
	  	wb_bus.master_write ('b01, i2c_bus);


		// 2 // Setting CMDR to 'bxxxxx110 SET command
	  	wb_bus.master_write ('b10,'bxxxxx110);

		// 3 // Waiting for Interrupt
		while (!irq) @(posedge clk);
		wb_bus.master_read (address,data);
		// $display("Interrupt 1");

		// 4 // Setting CMDR to 'bxxxxx100 START command
		wb_bus.master_write ( 'b10,'bxxxxx100);

		// 5 // Checking Interrupt bit of CMDR
		while (!irq) @(posedge clk);
		wb_bus.master_read (address,data);
		// $display("Interrupt 2 :");

		wb_bus.master_write ('b01, 'b01000101);	// 14 // Writing 0x45 to DPR to shift slave address by 1 bit + 1 to the rightmost bit meaning READ

		wb_bus.master_write ('b10, 'b001);	// 15 // WRITE command for the

		while (!irq) @(posedge clk);   		// 16 // Checking Interrupt bit of CMDR
		wb_bus.master_read (address,data);

		wb_bus.master_write ('b10,'b010);		// 17 // "READ with ACK" command

		while (!irq) @(posedge clk);   		// 18 // Checking Interrupt bit of CMDR
		wb_bus.master_read (address,data);

		wb_bus.master_read ('b01, wb_read_data);		// 19 // "READ" DPR commad to get received byte

		// $display("********************");
		// $display("READ Data @ DPR = %d or %b",wb_read_data,wb_read_data);
		// $display("********************");

		wb_bus.master_write ('b10,'b011);		// 17 // "READ with NACK" command

		while (!irq) @(posedge clk);   		// 18 // Checking Interrupt bit of CMDR
		wb_bus.master_read (address,data);

		wb_bus.master_read ('b01, wb_read_data);		// 19 // "READ" DPR commad to get received byte
		//
		// $display("********************");
		// $display("READ Data @ DPR = %d or %b",wb_read_data,wb_read_data);
		// $display("********************");

		wb_bus.master_write ('b10,'bxxxxx101);	// 20 // Writing 0xx5 data to CMDR,STOP command

		while (!irq) @(posedge clk);		// 21 // Checking Interrupt bit of CMDR
		wb_bus.master_read (address, data);
		// $display("Interupt 5");

	endtask

endmodule

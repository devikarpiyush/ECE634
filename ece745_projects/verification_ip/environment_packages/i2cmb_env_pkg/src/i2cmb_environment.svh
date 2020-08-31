class i2cmb_environment extends ncsu_component#(.T(wb_transaction));

    i2cmb_env_configuration configuration;  // handle of env config class
    i2c_agent         p0_i2c_agent;  //handle of I2C agent class
    wb_agent          p1_wb_agent;  // handle of WB agent handle
    i2cmb_predictor   pred;   //handle of predictor class
    i2cmb_scoreboard  scbd;   //handle of scoreboard class
    i2cmb_coverage coverage; //handle of environment coverage class


    //calling new function of parent class
    function new(string name = "", ncsu_component_base parent = null);
        super.new(name,parent);
    endfunction

   //user defined function to set configuration
    function void set_configuration(i2cmb_env_configuration cfg);
        configuration = cfg;
    endfunction

    //build function contains creating objects of the agents, predictor and scoreboards and call to their build methods
    virtual function void build();
        p1_wb_agent = new("p1_wb_agent",this);
        p1_wb_agent.set_configuration(configuration.p1_wb_agent_config);
        p1_wb_agent.build();
        p0_i2c_agent = new("p0_i2c_agent",this);
        p0_i2c_agent.set_configuration(configuration.p0_i2c_agent_config);
        p0_i2c_agent.build();
        pred  = new("pred", this);
        pred.set_configuration(configuration);
        pred.build();
        scbd  = new("scbd", this);
        scbd.build();
        coverage = new("coverage", this);
        coverage.set_configuration(configuration);
        coverage.build();
        p1_wb_agent.connect_subscriber(coverage);
	
        //connection predictor to scoreboard
        p1_wb_agent.connect_subscriber(pred);
        pred.set_scoreboard(scbd);
        p0_i2c_agent.connect_subscriber(scbd);
    endfunction

    //function returns the handle of I2C agent
    function ncsu_component #(i2c_transaction) get_i2c_agent();
        return p0_i2c_agent;
    endfunction

    //function returns the handle of WB agent
    function ncsu_component #(wb_transaction) get_wb_agent();
        return p1_wb_agent;
    endfunction

   //run task calls run function present in both the agents
    virtual task run();
        p0_i2c_agent.run();
        p1_wb_agent.run();
    endtask

endclass

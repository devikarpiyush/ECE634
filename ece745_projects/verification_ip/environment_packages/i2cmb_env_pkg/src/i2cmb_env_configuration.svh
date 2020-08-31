class i2cmb_env_configuration extends ncsu_configuration;

    i2c_configuration p0_i2c_agent_config;  //handle of I2C agent config
    wb_configuration p1_wb_agent_config;   //handle of WB agent config


    bit       loopback;
    bit       invert;
    bit [3:0] port_delay;

    covergroup i2cmb_env_configuration_cg;
  	option.per_instance = 1;
        option.name = name;
  	coverpoint loopback;
  	coverpoint invert;
  	coverpoint port_delay;
    endgroup

    //calling new function of the parent class
    function new(string name="");
        super.new(name);
        p0_i2c_agent_config = new("p0_i2c_agent_config");  //creating object of I2C agent config
        p1_wb_agent_config = new("p1_wb_agent_config");  //creating object of WB agent config
       // p1_wb_agent_config.collect_coverage=0;

       // p0_i2c_agent_config.sample_coverage();
       // p1_wb_agent_config.sample_coverage();
        endfunction

  function void sample_coverage();
  	i2cmb_env_configuration_cg.sample();
  endfunction
endclass

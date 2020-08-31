class i2c_transaction extends ncsu_transaction;

    `ncsu_register_object(i2c_transaction)  //factory registratiobn of i2c_transaction class

     bit [7:0] i2c_Data[];  // dyanmic array to store data
     bit [7:0] i2c_Address;  // I2C address
     i2c_op_t i2c_Operation;  //enum for READ or WRITE operations
       
     //calling new function in parent class
     function new(string name="");
         super.new(name);
     endfunction

   //function to convert to string that is useful for displaying messages on the console
    virtual function string convert2string();
        return {super.convert2string(),$sformatf("\n I2C Address: 0x%h\n I2C Data: 0x%p\n I2C Operation: %s\n", i2c_Address, i2c_Data, i2c_Operation)};
    endfunction

    // compare function to compare the trasactions to be used in the scoreboard
    function bit compare(i2c_transaction rhs);
        return ((this.i2c_Address  == rhs.i2c_Address ) &&
                (this.i2c_Operation == rhs.i2c_Operation) &&
                (this.i2c_Data == rhs.i2c_Data) );
    endfunction
endclass

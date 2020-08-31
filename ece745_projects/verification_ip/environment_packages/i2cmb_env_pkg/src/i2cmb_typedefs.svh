  
   typedef enum bit [1:0] {CSR='b00, DPR='b01, CMDR='b10, FSMR='b11} reg_type_t;


   typedef enum bit [2:0] { ST_START_CMD='b100, ST_STOP_CMD='b101, ST_READ_ACK_CMD='b010, ST_READ_NAK_CMD='b011, ST_WRITE_CMD='b001, ST_SET_BUS_CMD='b110, ST_WAIT_CMD='b000, ST_INVALID='b111 } cmdr_cmd_type_t;

   typedef enum bit [3:0] {ST_DON_CMDR_BIT='b1000, ST_NAK_CMDR_BIT='b0100, ST_AL_CMDR_BIT='b0010, ST_ERR_CMDR_BIT='b0001} cmdr_func_type_t;
 
   typedef enum bit {WB_READ_ENB='b0, WB_WRITE_ENB='b1} we_type_t;

   typedef enum bit [3:0] {   BIT_FSM_STATE_IDLE  = 4'b0000,
                            BIT_FSM_START_A     = 4'b0001, 
                            BIT_FSM_START_B     = 4'b0010, 
                            BIT_FSM_START_C     = 4'b0011, 
                            BIT_FSM_RW_A        = 4'b0100, 
                            BIT_FSM_RW_B        = 4'b0101, 
                            BIT_FSM_RW_C        = 4'b0110, 
                            BIT_FSM_RW_D        = 4'b0111, 
                            BIT_FSM_RW_E        = 4'b1000, 
                            BIT_FSM_STOP_A      = 4'b1001, 
                            BIT_FSM_STOP_B      = 4'b1010, 
                            BIT_FSM_STOP_C      = 4'b1011, 
                            BIT_FSM_RSTART_A    = 4'b1100, 
                            BIT_FSM_RSTART_B    = 4'b1101,
                            BIT_FSM_RSTART_C    = 4'b1110 
  } fsm_bit_level_type_t;

  typedef enum bit [3:0] {  BYTE_FSM_IDLE         = 'b0000,
                            BYTE_FSM_BUS_TAKEN    = 'b0001,
                            BYTE_FSM_START_PENDING   = 'b0010,
                            BYTE_FSM_START        = 'b0011,
                            BYTE_FSM_STOP         = 'b0100,
                            BYTE_FSM_WRITE        = 'b0101,
                            BYTE_FSM_READ         = 'b0110,
                            BYTE_FSM_WAIT         = 'b0111

  } fsm_byte_level_type_t;

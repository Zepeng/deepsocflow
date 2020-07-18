/*//////////////////////////////////////////////////////////////////////////////////
Group : ABruTECH
Engineer: Abarajithan G.

Create Date: 11/07/2020
Design Name: AXIS Shift buffer
Tool Versions: Vivado 2018.2
Description: * Pipelined module that takes in AXIS of padded rows and releases kernel_h 
               shifted versions of them in kernel_h clocks as AXIS.
             * kernel_h is dynamically configurable.
             * Eg: If KERNEL_H_MAX == 7:
                    - (7,*) , (5,*), (3,*), (1,*) convolutions are possible
                    - * denotes that kernel can be non-square: (7*4) for example
                    - Input number of words are CONV_UNITS + (7-1) = 8 + 7 - 1 = 14
                    - Then if kernel_h == 3 (dynamically):
                        - kernel_h_1_in is given as 2 (actual-1)
                        - 14 pixels will be shifted down 3 times
                        - First 10 (=8+2) words of 14 (=8+6) should be the valid 
                            padded inputs for 3x3

            * Asserts tlast (registered) at the last data beat of each cin
            * Asserts blocks_2 (registered) for the entire cin at the block before last
            * Samples config bits with "start" pulse and holds them until next "start"
            * Asserts done after the last tlast, until next start.

Dependencies: * axis_register_slice_data_buffer 
                    - Type: IP (axis_register_slice) configured
                    - Data width = {(KERNEL_H_MAX-1) * (DATA_WIDTH/8)} bytes

Revision:
Revision: 2.0
Additional Comments: 

//////////////////////////////////////////////////////////////////////////////////*/

module axis_shift_buffer#(
    parameter DATA_WIDTH                = 16,
    parameter CONV_UNITS                = 8,
    parameter KERNEL_H_MAX              = 3,
    parameter KERNEL_W_MAX              = 3,

    parameter CIN_COUNTER_WIDTH         = 10,
    parameter BLOCKS_COUNTER_WIDTH      = 10,
    parameter ONE                       = 15360,

    parameter TUSER_WIDTH           = 4,
    parameter INDEX_IS_1x1          = 0,
    parameter INDEX_IS_MAX          = 1,
    parameter INDEX_IS_RELU         = 2,
    parameter INDEX_IS_BLOCKS_2     = 3
)(
    aclk,
    aresetn,
    start,
    done,

    kernel_h_1_in,         // = (kernel_h  - 1)
    kernel_w_1_in,         // = (kernel_h  - 1)
    is_max,
    is_relu,
    blocks_1,           // = (blocks    - 1)
    cin_1,              // = (cin       - 1)

    S_AXIS_tdata,
    S_AXIS_tvalid,
    S_AXIS_tready,

    M_AXIS_tdata,
    M_AXIS_tvalid,
    M_AXIS_tready,
    M_AXIS_tlast,
    M_AXIS_tuser,
    
    kernel_h_1_out,
    kernel_w_1_out
);
    localparam KERNEL_H_WIDTH    = $clog2(KERNEL_H_MAX   + 1);
    localparam KERNEL_W_WIDTH    = $clog2(KERNEL_W_MAX   + 1);

    input   wire    aclk;
    input   wire    aresetn;
    input   wire    start;
    output  wire    done;
    
    input   wire    [KERNEL_H_WIDTH         -1       : 0]   kernel_h_1_in;
    input   wire    [KERNEL_W_WIDTH         -1       : 0]   kernel_w_1_in;
    input   wire                                            is_max;
    input   wire                                            is_relu;
    input   wire    [CIN_COUNTER_WIDTH      -1       : 0]   cin_1;
    input   wire    [BLOCKS_COUNTER_WIDTH   -1       : 0]   blocks_1;
    

    input   wire    [DATA_WIDTH * (CONV_UNITS + (KERNEL_H_MAX-1)) - 1 : 0]   S_AXIS_tdata;
    input   wire                                            S_AXIS_tvalid;
    output  wire                                            S_AXIS_tready;

    output  wire    [DATA_WIDTH * (CONV_UNITS) - 1 : 0]     M_AXIS_tdata;
    output  wire                                            M_AXIS_tvalid;
    input   wire                                            M_AXIS_tready;
    output  wire                                            M_AXIS_tlast;
    output  wire    [TUSER_WIDTH-1:0]                       M_AXIS_tuser;

    output  wire    [KERNEL_H_WIDTH         -1     : 0]     kernel_h_1_out;
    output  wire    [KERNEL_W_WIDTH         -1     : 0]     kernel_w_1_out;


    /* 
    CONFIGURATION BITS

    * Registered at "start"
    */

    wire                                    is_max_reg_out       ;
    wire                                    is_relu_reg_out      ;
    wire    [CIN_COUNTER_WIDTH -1 : 0]      cin_1_reg_out        ;
    wire    [BLOCKS_COUNTER_WIDTH-1 : 0]    blocks_1_reg_out     ;

    register
    #(
        .WORD_WIDTH     (KERNEL_H_WIDTH),
        .RESET_VALUE    (1)         
    )
    KERNEL_H_1_REG
    (
        .clock          (aclk),
        .clock_enable   (start),
        .resetn         (aresetn),
        .data_in        (kernel_h_1_in),
        .data_out       (kernel_h_1_out)
    );

    register
    #(
        .WORD_WIDTH     (KERNEL_W_WIDTH),
        .RESET_VALUE    (1)         
    )
    KERNEL_W_1_REG
    (
        .clock          (aclk),
        .clock_enable   (start),
        .resetn         (aresetn),
        .data_in        (kernel_w_1_in),
        .data_out       (kernel_w_1_out)
    );

    register
    #(
        .WORD_WIDTH     (1),
        .RESET_VALUE    (0) 
    )
    IS_MAX_REG
    (
        .clock          (aclk),
        .clock_enable   (start),
        .resetn         (aresetn),
        .data_in        (is_max),
        .data_out       (is_max_reg_out)
    );

    register
    #(
        .WORD_WIDTH     (1),
        .RESET_VALUE    (0) 
    )
    IS_RELU_REG
    (
        .clock          (aclk),
        .clock_enable   (start),
        .resetn         (aresetn),
        .data_in        (is_relu),
        .data_out       (is_relu_reg_out)
    );

    register
    #(
        .WORD_WIDTH     (CIN_COUNTER_WIDTH),
        .RESET_VALUE    (1'b0)
    )
    CIN_1_REG
    (
        .clock          (aclk),
        .clock_enable   (start),
        .resetn         (aresetn),
        .data_in        (cin_1),
        .data_out       (cin_1_reg_out)
    );

    register
    #(
        .WORD_WIDTH     (BLOCKS_COUNTER_WIDTH),
        .RESET_VALUE    (0) 
    )
    BLOCKS_1_REG
    (
        .clock          (aclk),
        .clock_enable   (start),
        .resetn         (aresetn),
        .data_in        (blocks_1),
        .data_out       (blocks_1_reg_out)
    );

    /*
    HANDSHAKES
    */

    wire slice_M_AXIS_tvalid;
        
    wire insert = slice_M_AXIS_tvalid && M_AXIS_tready;
    wire remove = M_AXIS_tvalid       && M_AXIS_tready;

    // STATE
    /*
    "state_data_in" register's current value denotes the positioning of data that is 
    "going into" the data_out registers in this clock cycle (will be available
    in m_data in the next clock). 

    eg: state_data_in == 0 means, first 8 is going into the regs now and those will be
    available in m_data in next clock cycle.

    state_next is combinational fed into the state_data_in reg in this clock.

    state_data_in = 0       :   state_next = 0 + insert
    state_data_in = 1       :   state_next = 1 + remove
    state_data_in = 2       :   state_next = 2 + remove
    state_data_in = last    :   state_next = 0

    if m_ready goes down at state_data_in=last, state_next is changed, but state_reg 
    is not updated (update_state = insert || remove). Hence it is safe.

    */


    wire [CIN_COUNTER_WIDTH-1 : 0] selected_count;
    /*
    * CELLOTAPES
    
    * Found "cin_count" works for 3x3 and "cin_count_next" works mostly for 1x1
    * Cannot unify them, because they are held for different periods
    * In 1x1, they are held for one clock, so gotta use "cin_count_next" to predict next clock
    * In 3x3, both are held for 3 clocks, so gotta use "cin_count" to predict next clock
    * Cellotape solution of just muxing them

    * Then found "cin_count_next" breaks for 1x1 when s_valid goes down for some time
    * It prematuredly switches (because more than a clock elapsed)
    * Another cellotape of using cin_count + 1 to solve it. It works
    */


    assign selected_count = (kernel_h_1_out == 0) ? cin_count+1 : cin_count;        
    wire tlast_in = (state_data_in == kernel_h_1_out) && (selected_count == cin_1_reg_out);


    wire [KERNEL_H_WIDTH-1:0]  state_data_in;
    reg  [KERNEL_H_WIDTH-1:0]  state_next;
    wire update_state;
    
    assign update_state = insert || remove;

    always @ (*) begin
        if (tlast_in)
            state_next <= -KERNEL_H_WIDTH'('d1);
        else if (state_data_in == kernel_h_1_out)
            state_next <= 0;
        else if (state_data_in == 0)
            state_next <= insert;
        else 
            state_next <= state_data_in + remove;
    end


    register
    #(
        .WORD_WIDTH     (KERNEL_H_WIDTH),
        .RESET_VALUE    (-KERNEL_H_WIDTH'('d1))         // Initial state_data_in
    )
    STATE_REG
    (
        .clock          (aclk),
        .clock_enable   (update_state),
        .resetn         (aresetn),
        .data_in        (state_next),
        .data_out       (state_data_in)
    );
    
    /*
    REG SLICE
    
    * Skids the input AXI stream if m_ready goes down in same cycle as the insert handshake
    * M_ready is AND'ed with (state_data_in=0) => last shift data is being accepted downstream in this clock, 
        next is first data (zero shift).
    * If skid_m_valid stays high in this clock, they together form a "remove" handshake, data gets copied
        from reg slice into data_out at, at next rising edge and will be available throughout next clock

    */

    wire [DATA_WIDTH * (CONV_UNITS + (KERNEL_H_MAX-1)) - 1 : 0]  slice_M_AXIS_tdata;

    wire slice_M_AXIS_tready = (state_data_in==0) && M_AXIS_tready;
    
    axis_register_slice_data_buffer reg_slice (
      .aclk(aclk),                    
      .aresetn(aresetn),              
      .s_axis_tvalid(S_AXIS_tvalid),  
      .s_axis_tready(S_AXIS_tready),  
      .s_axis_tdata(S_AXIS_tdata),    
      .m_axis_tvalid(slice_M_AXIS_tvalid),  
      .m_axis_tready(slice_M_AXIS_tready), 
      .m_axis_tdata(slice_M_AXIS_tdata)    
    );

    /*
    MASTER_VALID

    * Tied to master_data
    */
    reg m_valid_next;    
    wire data_clken = ((state_data_in == 0) && insert) || remove;

    /*
    * Problem At the start: 
        - data_out is kept at "ones"
        - state_data_in, state_next and state_data are kept at -1
        - M_valid kept at 1
        - As "M_ready" goes high, "remove" goes up, starting the above state_data_in machine,
            state_data_in increments to 0.
        - Now, this situation is indistinguatable from "d_out = ones" situation in middle of operation
        - So "M_valid" is kept high for one clock, like in middle
        - This results in "ones" being handshaked twice

    * Solution:
        - Start situation   : both "data_in" and "data_out" are "ones" during remove handshake
                            - deassert valid
                ***** CHECK M_ready starts after S_valid
        - Middle situation  : only "data_in" is "ones"
                            - Keep valid high (next clock, ones are gonna come out)
    */

    always @(*) begin
        if (state_data_in == -KERNEL_H_WIDTH'('d1) && (state_data_out == -KERNEL_H_WIDTH'('d1)))
            m_valid_next <= 0;
        else if (state_data_in == -KERNEL_H_WIDTH'('d1))
            m_valid_next <= 1;
        else if (state_data_in ==  0)
            m_valid_next <= slice_M_AXIS_tvalid;
        else 
            m_valid_next <= M_AXIS_tvalid;
    end

    register
    #(
        .WORD_WIDTH     (1),
        .RESET_VALUE    (1)
    )
    M_VALID_REG
    (
        .clock          (aclk),
        .clock_enable   (data_clken),
        .resetn         (aresetn),
        .data_in        (m_valid_next),
        .data_out       (M_AXIS_tvalid)
    );

    /*
    STATE_DATA_OUT

    * Tied to m_data
    * State of data beat available on the output side
    */

    wire [KERNEL_H_WIDTH-1  :0]     state_data_out;

    register
    #(
        .WORD_WIDTH     (KERNEL_H_WIDTH),
        .RESET_VALUE    (-KERNEL_H_WIDTH'('d1))
    )
    STATE_OUT
    (
        .clock          (aclk),
        .clock_enable   (data_clken),
        .resetn         (aresetn),
        .data_in        (state_data_in),
        .data_out       (state_data_out)
    );
    

    /*
    DATA REGISTERS

    * There are 10 (= CONV_UNITS + (KERNEL_H_MAX-1)) data registers
    * First CONV_UNITS (=8) are connected to m_data
    * selected_data[-1] is only from d_in[-1]
    * all other selected_data[i] are muxed between data[i+1] and d_in[i]

    */


    wire    [DATA_WIDTH-1:0]    slice_m_data    [CONV_UNITS + (KERNEL_H_MAX-1)-1:0];
    wire    [DATA_WIDTH-1:0]    selected_data   [CONV_UNITS + (KERNEL_H_MAX-1)-1:0];
    wire    [DATA_WIDTH-1:0]    data_out        [CONV_UNITS + (KERNEL_H_MAX-1)-1:0];
    wire    [DATA_WIDTH-1:0]    m_data          [CONV_UNITS  -1:0];

    assign shift = remove;
    wire resetn_data;
    assign reset_data = !aresetn || (state_data_in==-KERNEL_H_WIDTH'('d1) && remove);

    genvar i;
    generate

        // 10 slice_m_data mapped
        for (i=0; i < CONV_UNITS  + (KERNEL_H_MAX-1); i=i+1) begin: s_data_gen
            assign slice_m_data[i] = slice_M_AXIS_tdata[(i+1)*DATA_WIDTH-1: i*DATA_WIDTH];
        end
        
        // First 8 data_out registers (of 10) connected to m_data
        for (i=0; i < CONV_UNITS; i=i+1) begin: m_data_gen
            assign M_AXIS_tdata[(i+1)*DATA_WIDTH-1: i*DATA_WIDTH] = data_out[i];
        end

        // selected_data[9](1)     is from  slice_m_data[9](1)
        // selected_data[0..8](9) are muxed between data_out[1..9](9) and slice_m_data[0..8](9)
        assign selected_data[CONV_UNITS + (KERNEL_H_MAX-1)-1] = slice_m_data[CONV_UNITS + (KERNEL_H_MAX-1)-1];

        for (i=0; i < CONV_UNITS  + (KERNEL_H_MAX-1)-1; i=i+1) begin: selected_data_gen
            assign selected_data[i] = (state_data_in == 0) ? slice_m_data[i] : data_out[i+1];
        end

        // 10 data_out registers
        for (i=0; i < CONV_UNITS  + (KERNEL_H_MAX-1); i=i+1) begin: data_out_reg_gen
            register
            #(
                .WORD_WIDTH     (DATA_WIDTH),
                .RESET_VALUE    (ONE)
            )
            M_DATA_REG
            (
                .clock          (aclk),
                .clock_enable   (data_clken),
                .resetn         (!reset_data),
                .data_in        (selected_data[i]),
                .data_out       (data_out[i])
            );
        end

    endgenerate

    /*
    Counter

    * Starts at 0, counts upto (=) IM_CH_IN_1 and resets to zero
    * clken:
        - remove & (particular state_data_in) rises for one clock only for an input data beat. Hence "counting"
        - (state_data_in = 0) ensures count_out stays tied to d_out in all (0,1,2..) shifts of same input data beat
        - count_out points to the ch_in of the data available at M_AXIS_tdata at this clock
    */

    wire [CIN_COUNTER_WIDTH-1 : 0]   cin_count, cin_count_next;
    wire                             counter_clken;

    assign counter_clken = remove && (state_data_in == 0);
    assign cin_count_next    = (cin_count == cin_1_reg_out) ? 0 : cin_count + 1;

    register
    #(
        .WORD_WIDTH     (CIN_COUNTER_WIDTH),
        .RESET_VALUE    (0) 
    )
    CH_IN_COUNTER_REG
    (
        .clock          (aclk),
        .clock_enable   (counter_clken),
        .resetn         (aresetn),
        .data_in        (cin_count_next),
        .data_out       (cin_count)
    );

    /*
    TLAST GENERATON ---------------------------------------------------------------------

    * For every IM_CH_IN groups of input data beats, passes a single tlast bit at the
      last shifted data beat (every IM_CH_IN * KERNEL_H_MAX beats).
    * IM_CH_IN is not given, but (IM_CH_IN_1 = IM_CH_IN-1) is given.

    */

    register
    #(
        .WORD_WIDTH     (CIN_COUNTER_WIDTH),
        .RESET_VALUE    (0) 
    )
    TLAST_REG
    (
        .clock          (aclk),
        .clock_enable   (remove),
        .resetn         (aresetn),
        .data_in        (tlast_in),
        .data_out       (M_AXIS_tlast)
    );

    /*
    BLOCKS-2 GENERATION

    * blocks_count = block cin_count of the currnet data beat available in master 
    * blocks_2     = blocks_count == BLOCKS - 2
    */

    wire [BLOCKS_COUNTER_WIDTH-1 : 0] blocks_in;
    wire [BLOCKS_COUNTER_WIDTH-1 : 0] blocks_count ;

    assign blocks_in = (blocks_count == blocks_1) ? 0 : blocks_count + 1;
    wire blocks_clken = M_AXIS_tlast && remove;

    register
    #(
        .WORD_WIDTH     (BLOCKS_COUNTER_WIDTH),
        .RESET_VALUE    (0) 
    )
    BLOCKS_COUNTER_REG
    (
        .clock          (aclk),
        .clock_enable   (blocks_clken),
        .resetn         (aresetn),
        .data_in        (blocks_in),
        .data_out       (blocks_count)
    );

    wire    is_blocks_2_in = blocks_count == (blocks_1 - kernel_w_1_out/2);
    wire    is_blocks_2_out;

    register
    #(
        .WORD_WIDTH     (1),
        .RESET_VALUE    (0) 
    )
    BLOCKS_2_REG
    (
        .clock          (aclk),
        .clock_enable   (blocks_clken),
        .resetn         (aresetn),
        .data_in        (is_blocks_2_in),
        .data_out       (is_blocks_2_out)
    );

    /*
    TUSER GENERATION

    * Tied to data
    */
    wire [TUSER_WIDTH-1:0] tuser_in;
    
    assign tuser_in [INDEX_IS_1x1       ] = (kernel_h_1_out == KERNEL_H_WIDTH'('d0));
    assign tuser_in [INDEX_IS_MAX       ] = is_max_reg_out;
    assign tuser_in [INDEX_IS_RELU      ] = is_relu_reg_out;
    assign tuser_in [INDEX_IS_BLOCKS_2  ] = is_blocks_2_out;

    register
    #(
        .WORD_WIDTH     (TUSER_WIDTH),
        .RESET_VALUE    (0) 
    )
    TUSER_REG
    (
        .clock          (aclk),
        .clock_enable   (data_clken),
        .resetn         (aresetn),
        .data_in        (tuser_in),
        .data_out       (M_AXIS_tuser)
    );

    /*
    DONE GENERATION

    * done = (blocks == 0 & cin == 0 & state_data_in = 0)
    * sampled at last (tlast & remove)

    */

    wire done_in    = (blocks_count == blocks_1);
    wire done_clken = M_AXIS_tlast && remove;
    wire done_reset = !aresetn || start;

    register
    #(
        .WORD_WIDTH     (1),
        .RESET_VALUE    (0) 
    )
    DONE_REG
    (
        .clock          (aclk),
        .clock_enable   (done_clken),
        .resetn         (!done_reset),
        .data_in        (done_in),
        .data_out       (done)
    );


endmodule
`timescale 1ns / 1ps

module axis_shift_buffer_tb();
    parameter CLK_PERIOD            = 10;
    parameter DATA_WIDTH            = 16;
    parameter CONV_UNITS            = 8;
    parameter KERNEL_H_MAX          = 5;
    parameter KERNEL_W_MAX          = 5;
    parameter CIN_COUNTER_WIDTH     = 5;
    parameter TUSER_WIDTH           = 4;

    parameter KERNEL_H_1            = 0;
    parameter KERNEL_W_1            = 0;
    parameter CIN_1                 = 5'd5 - 5'd1;
    parameter BLOCKS_1              = 4-1;
    
    localparam KERNEL_H_WIDTH       = $clog2(KERNEL_H_MAX + 1);
    localparam KERNEL_W_WIDTH       = $clog2(KERNEL_W_MAX + 1);


    reg                                         aclk                    = 0;
    reg                                         aresetn                 = 1;
    reg                                         start                   = 0;
    wire                                        done                       ;
    wire [DATA_WIDTH * (CONV_UNITS+(KERNEL_H_MAX-1)) - 1 : 0]  S_AXIS_tdata;
    reg                                         S_AXIS_tvalid           = 0;
    reg                                         M_AXIS_tready           = 0;

    wire                                        S_AXIS_tready;
    wire [DATA_WIDTH * (CONV_UNITS) - 1 : 0]    M_AXIS_tdata;
    wire                                        M_AXIS_tvalid;
    wire                                        M_AXIS_tlast;
    wire [TUSER_WIDTH     -1     : 0]           M_AXIS_tuser;
    wire [KERNEL_H_WIDTH  -1     : 0]           kernel_h_1_out;
    wire [KERNEL_W_WIDTH  -1     : 0]           kernel_w_1_out;

    reg  [DATA_WIDTH-1 : 0] s_data [CONV_UNITS+(KERNEL_H_MAX-1)-1:0] = '{default:0};
    wire [DATA_WIDTH-1 : 0] m_data [CONV_UNITS-1:0];

axis_shift_buffer
#(
    .DATA_WIDTH         (DATA_WIDTH),
    .CONV_UNITS         (CONV_UNITS),
    .KERNEL_H_MAX       (KERNEL_H_MAX),
    .KERNEL_W_MAX       (KERNEL_W_MAX),
    .CIN_COUNTER_WIDTH  (5)
)
axis_shift_buffer_dut
(
    .aclk               (aclk),
    .aresetn            (aresetn),
    .start              (start),
    .done               (done),
    .kernel_h_1_in      (KERNEL_H_1),
    .kernel_w_1_in      (KERNEL_W_1),
    .is_max             (1),
    .is_relu            (1),
    .blocks_1           (BLOCKS_1),
    .cin_1              (CIN_1),
    .S_AXIS_tdata       (S_AXIS_tdata),
    .S_AXIS_tvalid      (S_AXIS_tvalid),
    .S_AXIS_tready      (S_AXIS_tready),
    .M_AXIS_tdata       (M_AXIS_tdata),
    .M_AXIS_tvalid      (M_AXIS_tvalid),
    .M_AXIS_tready      (M_AXIS_tready),
    .M_AXIS_tlast       (M_AXIS_tlast),
    .M_AXIS_tuser       (M_AXIS_tuser),
    .kernel_h_1_out     (kernel_h_1_out),
    .kernel_w_1_out     (kernel_w_1_out)
);

    genvar i;
    generate
        // 10 s_data mapped
        for (i=0; i < CONV_UNITS +(KERNEL_H_MAX-1); i=i+1) begin: s_data_gen
            assign S_AXIS_tdata[(i+1)*DATA_WIDTH-1: i*DATA_WIDTH] = s_data[i];
        end

        // 8 m_data mapped
        for (i=0; i < CONV_UNITS; i=i+1) begin: m_data_gen
            assign m_data[i] = M_AXIS_tdata[(i+1)*DATA_WIDTH-1: i*DATA_WIDTH];
        end
    endgenerate

    always begin
        #(CLK_PERIOD/2);
        aclk <= ~aclk;
    end

    integer k = 0;
    integer m = 0;
    integer n = 0;

    initial begin
        @(posedge aclk);
        #(CLK_PERIOD*3)

        @(posedge aclk);
        start             <= 1;
        @(posedge aclk);
        start             <= 0;

        @(posedge aclk);
        #(CLK_PERIOD*3)

        // @(posedge aclk);
        // M_AXIS_tready     <= 1;
        // @(posedge aclk);
        // M_AXIS_tready     <= 0;

        for (m=0;   m < CONV_UNITS+(KERNEL_H_MAX-1);    m=m+1) begin
            s_data[m] <= m*100 + k;
        end

        for (n=0; n < 1000; n=n+1) begin
            @(posedge aclk);

            // Turn off ready in this region
            if (n > 24 && n < 29)
                M_AXIS_tready <= 0;
            else if (n < 10)
                M_AXIS_tready <= 0;
            else
                M_AXIS_tready <= 1;


            // Turn off valid in this reigion
            if(n > 30 && n < 40) begin
               S_AXIS_tvalid <= 0;
               continue; 
            end
            else
                S_AXIS_tvalid <= 1;


            if (S_AXIS_tready && S_AXIS_tvalid) begin
                k = k + 1;

                for (m=0; m<CONV_UNITS+(KERNEL_H_MAX-1); m=m+1) begin
                    s_data[m] <= m*100 + k;
                end

            end
                
            
    end

    end

endmodule
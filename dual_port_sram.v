module dual_port_sram #(
    parameter DATA_WIDTH = 8,
    parameter ADDR_WIDTH = 4
) (
    input clk,
    input en,
    input we,
    input re,
    input [ADDR_WIDTH-1:0] waddr,
    input [ADDR_WIDTH-1:0] raddr,
    input [DATA_WIDTH-1:0] din,
    output reg [DATA_WIDTH-1:0] dout
);

    // Depth is 2**ADDR_WIDTH locations, each DATA_WIDTH bits wide.
    reg [DATA_WIDTH-1:0] mem [0:(1 << ADDR_WIDTH)-1];

    // Synchronous write and synchronous read.
    // When en is low, neither memory nor dout is updated.
    always @(posedge clk) begin
        if (en) begin
            if (we)
                mem[waddr] <= din;

            if (re)
                dout <= mem[raddr];
        end
    end

endmodule

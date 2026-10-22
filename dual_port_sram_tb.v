`timescale 1ns/1ps

module dual_port_sram_tb;

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;

    reg clk;
    reg en, we, re;
    reg [ADDR_WIDTH-1:0] waddr, raddr;
    reg [DATA_WIDTH-1:0] din;
    wire [DATA_WIDTH-1:0] dout;

    integer errors;

    dual_port_sram #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) dut (
        .clk(clk), .en(en), .we(we), .re(re),
        .waddr(waddr), .raddr(raddr), .din(din), .dout(dout)
    );

    // 10 ns clock period.
    initial clk = 1'b0;
    always #5 clk = ~clk;

    task check_output;
        input [DATA_WIDTH-1:0] expected;
        input [8*80-1:0] test_name;
        begin
            if (dout !== expected) begin
                $display("FAIL: %0s | expected=%h, got=%h", test_name, expected, dout);
                errors = errors + 1;
            end else begin
                $display("PASS: %0s | dout=%h", test_name, dout);
            end
        end
    endtask

    initial begin
        errors = 0;
        en = 0; we = 0; re = 0;
        waddr = 0; raddr = 0; din = 0;

        // Write A5 to address 3.
        @(negedge clk);
        en = 1; we = 1; re = 0; waddr = 3; din = 8'hA5;

        // Write 3C to address 5.
        @(negedge clk);
        waddr = 5; din = 8'h3C;

        // Read address 3.
        @(negedge clk);
        we = 0; re = 1; raddr = 3;
        @(posedge clk); #1;
        check_output(8'hA5, "Read address 3");

        // Read address 5.
        @(negedge clk);
        raddr = 5;
        @(posedge clk); #1;
        check_output(8'h3C, "Read address 5");

        // Read address 3 while writing a different address (7).
        @(negedge clk);
        we = 1; re = 1; waddr = 7; din = 8'hF0; raddr = 3;
        @(posedge clk); #1;
        check_output(8'hA5, "Simultaneous read address 3 / write address 7");

        // Read back address 7.
        @(negedge clk);
        we = 0; re = 1; raddr = 7;
        @(posedge clk); #1;
        check_output(8'hF0, "Read address 7");

        // With en low, dout should hold its previous value.
        @(negedge clk);
        en = 0; we = 0; re = 1; raddr = 3;
        @(posedge clk); #1;
        check_output(8'hF0, "Output holds while RAM is disabled");

        if (errors == 0)
            $display("\nALL TESTS PASSED");
        else
            $display("\nTESTS FAILED: %0d error(s)", errors);

        $finish;
    end

endmodule

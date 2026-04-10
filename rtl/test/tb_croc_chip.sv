// Copyright 2024 ETH Zurich and University of Bologna.
// Solderpad Hardware License, Version 0.51, see LICENSE for details.
// SPDX-License-Identifier: SHL-0.51
//
// Authors:
// - Philippe Sauter <phsauter@iis.ee.ethz.ch>
// - Enrico Zelioli <ezelioli@iis.ee.ethz.ch>

`define TRACE_WAVE

module tb_croc_chip #(
  parameter int unsigned GpioCount = 32
);

  import tb_croc_pkg::*;

  // Signals fully controlled by the VIP
  // use VIP functions/tasks to manipulate these signals
  logic rst_n;
  logic sys_clk;
  logic ref_clk;

  logic jtag_tck;
  logic jtag_trst_n;
  logic jtag_tms;
  logic jtag_tdi;
  logic jtag_tdo;

  logic uart_rx;
  logic uart_tx;

  // Signals partially controlled by the VIP
  logic [GpioCount-1:0] gpio_in;
  logic [GpioCount-1:0] gpio_out;
  logic [GpioCount-1:0] gpio_out_en;
  wire  [GpioCount-1:0] gpio;

  // Signals controlled by the testbench

  /////////////////////////////
  //  Command Line Arguments //
  /////////////////////////////

  string binary_path;

  initial begin
    // $value$plusargs defines what to look for (here +binary=...)
    if ($value$plusargs("binary=%s", binary_path)) begin
      $display("Running program: %s", binary_path);
    end else begin
      $display("No binary path provided. Running helloworld.");
      binary_path = "../sw/bin/helloworld.hex";
    end
  end

  ////////////
  //  VIP   //
  ////////////
  // Verification IP
  // - drives clocks and resets
  // - provides helper tasks and functions for JTAG, namely:
  //   - jtag_load_hex: loads a hex file into the DUT's memory
  //   - jtag_write_reg32: write 32-bit value to DUT
  //   - jtag_read_reg32: read 32-bit value from DUT
  //   - jtag_halt / jtag_resume: control core execution
  //   - jtag_wait_for_eoc: wait for end of code execution (core writes non-zero to status register)
  // - prints UART output to console (you can also write via uart_write_byte)
  // - internal GPIO loopback for helloworld test

  croc_vip #(
    .GpioCount ( GpioCount )
  ) i_vip (
    .rst_no        ( rst_n       ),
    .sys_clk_o     ( sys_clk     ),
    .ref_clk_o     ( ref_clk     ),
    .jtag_tck_o    ( jtag_tck    ),
    .jtag_trst_no  ( jtag_trst_n ),
    .jtag_tms_o    ( jtag_tms    ),
    .jtag_tdi_o    ( jtag_tdi    ),
    .jtag_tdo_i    ( jtag_tdo    ),
    .uart_rx_o     ( uart_rx     ),
    .uart_tx_i     ( uart_tx     ),
    .gpio_out_en_i ( gpio_out_en ),
    .gpio_out_i    ( gpio_out    ),
    .gpio_in_o     ( gpio_in     )
  );

  ////////////
  //  GPIO  //
  ////////////

  generate
    for(genvar i=0; i<=3; i++) begin
      pulldown(gpio[i]);
    end
    // loop back
    assign gpio[7:4] = gpio[3:0];
    for(genvar i=8; i<GpioCount; i++) begin
      pulldown(gpio[i]);
    end
  endgenerate

  ////////////
  //  DUT   //
  ////////////

  `ifdef TARGET_NETLIST_YOSYS
  croc_chip
  `else
  croc_chip
  `endif
  i_croc_chip (
    .clk_i         ( sys_clk     ),
    .rst_ni        ( rst_n       ),
    .ref_clk_i     ( ref_clk     ),
    .testmode_i    ( 1'b0        ),
    .status_o      (             ),
    .jtag_tck_i    ( jtag_tck    ),
    .jtag_tdi_i    ( jtag_tdi    ),
    .jtag_tdo_o    ( jtag_tdo    ),
    .jtag_tms_i    ( jtag_tms    ),
    .jtag_trst_ni  ( jtag_trst_n ),
    .uart_rx_i     ( uart_rx     ),
    .uart_tx_o     ( uart_tx     ),
    .gpio0_io      (gpio[ 0]),
    .gpio1_io      (gpio[ 1]),
    .gpio2_io      (gpio[ 2]),
    .gpio3_io      (gpio[ 3]),
    .gpio4_io      (gpio[ 4]),
    .gpio5_io      (gpio[ 5]),
    .gpio6_io      (gpio[ 6]),
    .gpio7_io      (gpio[ 7]),
    .gpio8_io      (gpio[ 8]),
    .gpio9_io      (gpio[ 9]),
    .gpio10_io     (gpio[10]),
    .gpio11_io     (gpio[11]),
    .gpio12_io     (gpio[12]),
    .gpio13_io     (gpio[13]),
    .gpio14_io     (gpio[14]),
    .gpio15_io     (gpio[15]),
    .gpio16_io     (gpio[16]),
    .gpio17_io     (gpio[17]),
    .gpio18_io     (gpio[18]),
    .gpio19_io     (gpio[19]),
    .gpio20_io     (gpio[20]),
    .gpio21_io     (gpio[21]),
    .gpio22_io     (gpio[22]),
    .gpio23_io     (gpio[23]),
    .gpio24_io     (gpio[24]),
    .gpio25_io     (gpio[25]),
    .gpio26_io     (gpio[26]),
    .gpio27_io     (gpio[27]),
    .gpio28_io     (gpio[28]),
    .gpio29_io     (gpio[29]),
    .gpio30_io     (gpio[30]),
    .gpio31_io     (gpio[31]),
    .unused0_o     (),
    .unused1_o     (),
    .unused2_o     (),
    .unused3_o     ()
//    .VDD           (1'b1),
//    .VSS           (1'b0),
//    .VDDIO         (1'b1),
//    .VSSIO         (1'b0)
  );

  /////////////////
  //  Testbench  //
  /////////////////

  logic [31:0] tb_data;

  initial begin
    $timeformat(-9, 0, "ns", 12); // 1: scale (ns=-9), 2: decimals, 3: suffix, 4: print-field width

    // wait for reset
    #ClkPeriodSys;

    // init jtag
    i_vip.jtag_init();

    // write test value to sram
    i_vip.jtag_write_reg32(SramBaseAddr, 32'h1234_5678, 1'b1);

    // load binary to sram
    i_vip.jtag_load_hex(binary_path);

    // wake core from WFI by writing to CLINT msip
    $display("@%t | [CORE] Waking core via CLINT msip", $time);
    i_vip.jtag_write_reg32(ClintBaseAddr, 32'h1);

    // halt core
    i_vip.jtag_halt();

    // resume core
    i_vip.jtag_resume();

    // wait for non-zero return value (written into core status register)
    $display("@%t | [CORE] Wait for end of code...", $time);
    i_vip.jtag_wait_for_eoc(tb_data);

    // finish simulation
    repeat(50) @(posedge sys_clk);
    $finish();
  end

  ////////////////
  //  Waveform  //
  ////////////////

  // start waveform dump at time 0, independent of stimuli
  initial begin
    `ifdef TRACE_WAVE
      `ifdef VERILATOR
        $dumpfile("croc.fst");
        $dumpvars(1, i_croc_chip);
      `else
        $dumpfile("croc.vcd");
        $dumpvars(1, i_croc_chip);
      `endif
    `endif
  end

  // flush waveform dump when simulation ends
  final begin
    `ifdef TRACE_WAVE
      $dumpflush;
    `endif
  end

endmodule

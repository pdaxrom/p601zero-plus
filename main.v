module motherboard (
	input	clk_ext,

	input	[3:0] switches,
	input	[3:0] keys,
	output	[8:0] seg_led_h,
	output	[8:0] seg_led_l,
	output	[7:0] leds,
	output	[2:0] rgb1,
	output	[2:0] rgb2,

	input	ps2dat,
	input	ps2clk,

	input	rxd,
	output	txd,

	output	[7:0] tvout,

	input	[1:0] irq,

	output	extresn,

	output	[2:0] sa,
	
	output	clk1,
	output	cd,

	output	sdcs,
	output	sck,
	input	miso,
	output	mosi,

	output	[1:0] mcs,
	output	[1:0] msck,
	inout	[1:0] msio0,
	inout	[1:0] msio1,
	inout	[1:0] msio2,
	inout	[1:0] msio3
);

	parameter OSC_CLOCK = 24000000;
	parameter CPU_CLOCK = 6000000;
	parameter CLK_DIV_PERIOD = (OSC_CLOCK / CPU_CLOCK) / 2;
	parameter LED_REFRESH_CLOCK = 50;
	parameter LED_DIV_PERIOD = (OSC_CLOCK / LED_REFRESH_CLOCK) / 2;

	reg sys_res = 1;
	reg [3:0] sys_res_delay = 4'b1000;

	wire clk_in;
	wire sys_clk;


	reg [24:0] led_cnt;
	reg [1:0] led_anode;
	wire [7:0] seg_byte;

	always @ (posedge clk_in)
	begin
		if (sys_res) led_anode <= 2'b01;
		else begin
			if (led_cnt == (LED_DIV_PERIOD - 1)) begin
				led_anode <= ~led_anode;
				led_cnt <= 0;
			end else led_cnt <= led_cnt + 1'b1;
		end
	end

	always @ (posedge sys_clk or negedge keys[3])
	begin
		if (!keys[3]) begin
			sys_res <= 1;
			sys_res_delay = 4'b1000;
		end else begin
			if (sys_res_delay == 4'b0000) begin
				sys_res <= 0;
			end else sys_res_delay <= sys_res_delay - 4'b0001;
		end
	end

	assign seg_led_h[8] = led_anode[1];
	assign seg_led_l[8] = led_anode[0];

endmodule

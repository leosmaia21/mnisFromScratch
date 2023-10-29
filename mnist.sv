`timescale 1ns / 1ps
`include "parameters.v"


module matrixmul 
#(parameter m1, parameter n1)
(input clk, input matrix, input signed [31:0]image[m1 - 1:0], output signed [31:0] ret_out[n1 -1:0]);

    reg signed [31:0] l1[m1 -1:0][n1 - 1:0];

	reg signed [31:0]temp;

	reg signed [31:0] ret[n1 - 1:0];

    integer i, f, m, n, out;

    initial
    begin 
        
	for (i = 0; i < n1; i = i+1)
		ret[i] = 0;
	if (matrix == 1) begin
        f = $fopen("/home/leonardo/fun/MLnotebooks/l1.txt", "r");
        
        for (i = 0; i < `l1numberWeights; i = i + 1)
        begin
			m = i / n1;
			n = i % n1;
            out = $fscanf(f,"%d,", temp);
			l1[m][n] = temp;
            // #20;  
        end
        $fclose(f);

	end	else begin
        f = $fopen("/home/leonardo/fun/MLnotebooks/l2.txt", "r");
        for (i = 0; i < `l2numberWeights; i = i + 1)
        begin
			m = i / n1;
			n = i % n1;
            out = $fscanf(f,"%d,", temp);
			l1[m][n] = temp;
            // #20;  
        end
        $fclose(f);
	end
	
	end
integer k , j;
always @(image) begin

	for(j=0;j < n1;j=j+1) begin
		for(k=0;k < m1;k=k+1) begin
			ret[j] = ret[j] + (l1[k][j] * image[k]);
		end
	end
//	#1 $finish(1);	
end

assign ret_out = ret;
endmodule


module relu
#(parameter m1 = 128)
(input signed [31:0]data[m1 -1 :0], output signed [31:0]out[m1 -1 :0]);

genvar i;

generate
for (i = 0; i < m1; i = i+1) begin
	assign out[i] = (data[i] > 0) ? data[i] : 0;
end
endgenerate
endmodule

module finalLayer
#(parameter m1)
(input clk, input signed [31:0] data[m1 - 1: 0]);

reg signed [31:0] ret;

integer index;

initial ret = 0;


always @(posedge clk) begin
	for (int i = 0; i < m1; i = i+1) begin
		if (data[i] > ret) begin
			ret = data[i];
			index = i;
		end
	end

	$display("acho que e um: ", index);

end


endmodule

module mnist();
    reg  [31:0] imagesource[`imageSize - 1:0];
	reg clk;
    integer i, f, j;
	wire finished;
	wire [31: 0]l1_out[127:0];
	wire [31: 0]relu_out[127:0];
	wire [31: 0]l2_out[9:0];

	always #5 clk = ~clk;
	
	initial begin
		clk = 0;
		f = $fopen("/home/leonardo/fun/MLnotebooks/image", "r");
		
		for (i = 0; i < `imageSize; i = i + 1)
			j = $fscanf(f,"%d,", imagesource[i]);

		$fclose(f);
	end


matrixmul #(.m1(784), .n1(128)) matrix1(.clk(clk), .matrix(1), .image(imagesource), .ret_out(l1_out));
relu #(.m1(128)) relu1(.data(l1_out), .out(relu_out));
matrixmul #(.m1(128), .n1(10)) matrix2(.clk(clk), .matrix(0), .image(relu_out), .ret_out(l2_out));
finalLayer #(.m1(10)) classification(.clk(clk), .data(l2_out));
endmodule

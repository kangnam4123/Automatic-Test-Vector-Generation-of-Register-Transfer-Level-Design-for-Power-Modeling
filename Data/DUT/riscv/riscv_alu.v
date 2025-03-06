`timescale 1ns / 1ps

`define ALU_ADD   4'd0		
`define ALU_SUB   4'd1		
`define ALU_AND   4'd2			
`define ALU_OR    4'd3		
`define ALU_XOR   4'd4		
`define ALU_SLT   4'd5		
`define ALU_SLTU  4'd6		
`define ALU_SLL   4'd7		
`define ALU_SRL   4'd8		
`define ALU_SRA   4'd9		
`define ALU_MULL  4'd10		
`define ALU_MULH  4'd11		
`define ALU_DIV   4'd12		
`define ALU_REM   4'd13		
`define ALU_AUIPC 4'd14		
`define ALU_IDLE  4'd15


`define  BR_NONE   3'd0
`define  BR_JUMP   3'd1
`define  BR_EQ     3'd2
`define  BR_NE     3'd3
`define  BR_LT     3'd4
`define  BR_GE     3'd5
`define  BR_LTU    3'd6
`define  BR_GEU    3'd7

`define  SIZE_BYTE 2'd0
`define  SIZE_HALF 2'd1
`define  SIZE_WORD 2'd2


module riscv_alu(
input  [3:0]  alu_op_i,   
input  [31:0]  alu_a_i,  
input  [31:0]  alu_b_i,   
output [31:0]  alu_p_o,
output [4:0]  flcnz
);

reg [31:0] result_r;
reg [4:0]  flcnz_1;
reg [31:16] shift_right_fill_r;

reg [31:0] shift_right_1_r;
reg [31:0] shift_right_2_r;
reg [31:0] shift_right_4_r;
reg [31:0] shift_right_8_r;

reg [31:0] shift_left_1_r;
reg [31:0] shift_left_2_r;
reg [31:0] shift_left_4_r;
reg [31:0] shift_left_8_r;
    
wire [31:0]     sub_res_w; 
wire [31:0] sum;
wire 		carry;

assign {carry,sum} = alu_a_i + alu_b_i;
assign sub_res_w = alu_a_i - alu_b_i;

always @ (alu_op_i or alu_a_i or alu_b_i or sub_res_w)
begin
	flcnz_1 = 5'b0;
end


always @ (alu_op_i or alu_a_i or alu_b_i or sub_res_w)
begin
    shift_right_fill_r = 16'b0;
    shift_right_1_r = 32'b0;
    shift_right_2_r = 32'b0;
    shift_right_4_r = 32'b0;
    shift_right_8_r = 32'b0;

    shift_left_1_r = 32'b0;
    shift_left_2_r = 32'b0;
    shift_left_4_r = 32'b0;
    shift_left_8_r = 32'b0;

case (alu_op_i)  		
       `ALU_SLL :
       begin
            if (alu_b_i[0] == 1'b1)
                shift_left_1_r = {alu_a_i[30:0],1'b0};
            else
                shift_left_1_r = alu_a_i;

            if (alu_b_i[1] == 1'b1)
                shift_left_2_r = {shift_left_1_r[29:0],2'b00};
            else
                shift_left_2_r = shift_left_1_r;

            if (alu_b_i[2] == 1'b1)
                shift_left_4_r = {shift_left_2_r[27:0],4'b0000};
            else
                shift_left_4_r = shift_left_2_r;

            if (alu_b_i[3] == 1'b1)
                shift_left_8_r = {shift_left_4_r[23:0],8'b00000000};
            else
                shift_left_8_r = shift_left_4_r;

            if (alu_b_i[4] == 1'b1)
                result_r = {shift_left_8_r[15:0],16'b0000000000000000};
            else
                result_r = shift_left_8_r;
       end

       `ALU_SRL,`ALU_SRA :       
       // shift right operation by 32bit operand b cases (shift right 1 to 31)
       begin											
            // Arithmetic shift? Fill with 1's if MSB set
            if (alu_a_i[31] == 1'b1 && alu_op_i == `ALU_SRA)
                shift_right_fill_r = 16'b1111111111111111;
            else
                shift_right_fill_r = 16'b0000000000000000;

            if (alu_b_i[0] == 1'b1)
                shift_right_1_r = {shift_right_fill_r[31], alu_a_i[31:1]};
            else
                shift_right_1_r = alu_a_i;

            if (alu_b_i[1] == 1'b1)
                shift_right_2_r = {shift_right_fill_r[31:30], shift_right_1_r[31:2]};
            else
                shift_right_2_r = shift_right_1_r;

            if (alu_b_i[2] == 1'b1)
                shift_right_4_r = {shift_right_fill_r[31:28], shift_right_2_r[31:4]};
            else
                shift_right_4_r = shift_right_2_r;

            if (alu_b_i[3] == 1'b1)
                shift_right_8_r = {shift_right_fill_r[31:24], shift_right_4_r[31:8]};
            else
                shift_right_8_r = shift_right_4_r;

            if (alu_b_i[4] == 1'b1)
                result_r = {shift_right_fill_r[31:16], shift_right_8_r[31:16]};
            else
                result_r = shift_right_8_r;
       end       
    
       `ALU_ADD : 
       begin
            result_r      = sum;
       end
       `ALU_SUB : 
       begin
            result_r      = sub_res_w;
       end
  
       `ALU_AND : 
       begin
            result_r      = (alu_a_i & alu_b_i);
       end
       
       `ALU_OR  : 
       begin
            result_r      = (alu_a_i | alu_b_i);
       end
       
       `ALU_XOR : 
       begin
            result_r      = (alu_a_i ^ alu_b_i);
       end

       `ALU_SLTU : 
       begin
            result_r      = (alu_a_i < alu_b_i) ? 32'h1 : 32'h0;
       end
       `ALU_SLT : 
       begin
            if (alu_a_i[31] != alu_b_i[31])
                result_r  = alu_a_i[31] ? 32'h1 : 32'h0;
            else
                result_r  = sub_res_w[31] ? 32'h1 : 32'h0;    
       end       

       default  : 
       begin
            result_r      = alu_a_i;
       end
    endcase
end //always

assign alu_p_o    = result_r;
assign flcnz    = flcnz_1;

endmodule


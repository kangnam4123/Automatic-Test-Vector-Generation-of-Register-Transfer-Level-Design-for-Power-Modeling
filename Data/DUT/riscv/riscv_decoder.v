`timescale 1ns / 1ps
module riscv_decoder(
input  [31:0] if_opcode_w,    			
output [31:0] id_imm_w,		  
output [4:0] id_rd_index_w,	  
output [4:0] id_ra_index_w,	  
output [4:0] id_rb_index_w,	  
output [3:0] id_alu_op_w,	 
output [2:0] id_branch_w,	 
output [1:0] id_mem_size_w,	  
output mulh_w,
output mulhsu_w,
output div_w,
output rem_w,
output sra_w,
output srai_w,
output alu_imm_w,
output jal_w,
output load_w,
output store_w,
output lbu_w,
output lhu_w,
output jalr_w,
output id_illegal_w
);

wire [6:0] op_w;
wire [4:0] rd_w;
wire [2:0] f3_w;
wire [4:0] ra_w;
wire [4:0] rb_w;
wire [6:0] f7_w;

wire op_branch_w  ;
wire op_load_w    ;
wire op_store_w   ;
wire op_alu_imm_w ;
wire op_alu_reg_w ;

wire op_f7_main_w ;
wire op_f7_alt_w  ;
wire op_f7_mul_w  ;

wire lui_w    ;
wire auipc_w  ;

wire beq_w    ;
wire bne_w    ;
wire blt_w    ;
wire bge_w    ;
wire bltu_w   ;
wire bgeu_w   ;

wire lb_w;
wire lh_w;
wire lw_w;

wire sb_w;
wire sh_w;
wire sw_w;

wire addi_w ;
wire slti_w ;
wire sltiu_w;
wire xori_w ;
wire ori_w  ;
wire andi_w ;
wire slli_w ;
wire srli_w ;

wire add_w ;
wire sub_w ;
wire slt_w ;
wire sltu_w;
wire xor_w ;
wire or_w  ;
wire and_w ;
wire sll_w ;
wire srl_w ;

wire mul_w  ;
wire mulhu_w;
wire divu_w ;
wire remu_w ;

wire jump_w;
wire alu_reg_w;
wire branch_w;

assign op_w = if_opcode_w[6:0];
assign rd_w = if_opcode_w[11:7];
assign f3_w = if_opcode_w[14:12];
assign ra_w = if_opcode_w[19:15];
assign rb_w = if_opcode_w[24:20];
assign f7_w = if_opcode_w[31:25];

assign op_branch_w  = (7'b1100011 == op_w);
assign op_load_w    = (7'b0000011 == op_w);
assign op_store_w   = (7'b0100011 == op_w);
assign op_alu_imm_w = (7'b0010011 == op_w);
assign op_alu_reg_w = (7'b0110011 == op_w);

assign op_f7_main_w = (7'b0000000 == f7_w);
assign op_f7_alt_w  = (7'b0100000 == f7_w);
assign op_f7_mul_w  = (7'b0000001 == f7_w);

assign lui_w    = (7'b0110111 == op_w);
assign auipc_w  = (7'b0010111 == op_w);
assign jal_w    = (7'b1101111 == op_w);
assign jalr_w   = (7'b1100111 == op_w) && (3'b000 == f3_w);

assign beq_w    = op_branch_w  && (3'b000 == f3_w);
assign bne_w    = op_branch_w  && (3'b001 == f3_w);
assign blt_w    = op_branch_w  && (3'b100 == f3_w);
assign bge_w    = op_branch_w  && (3'b101 == f3_w);
assign bltu_w   = op_branch_w  && (3'b110 == f3_w);
assign bgeu_w   = op_branch_w  && (3'b111 == f3_w);

assign lb_w     = op_load_w    && (3'b000 == f3_w);
assign lh_w     = op_load_w    && (3'b001 == f3_w);
assign lw_w     = op_load_w    && (3'b010 == f3_w);
assign lbu_w    = op_load_w    && (3'b100 == f3_w);
assign lhu_w    = op_load_w    && (3'b101 == f3_w);

assign sb_w     = op_store_w   && (3'b000 == f3_w);
assign sh_w     = op_store_w   && (3'b001 == f3_w);
assign sw_w     = op_store_w   && (3'b010 == f3_w);

//**** ALU flags assign from f3 field and alu flag
assign addi_w   = op_alu_imm_w && (3'b000 == f3_w);
assign slti_w   = op_alu_imm_w && (3'b010 == f3_w);
assign sltiu_w  = op_alu_imm_w && (3'b011 == f3_w);
assign xori_w   = op_alu_imm_w && (3'b100 == f3_w);
assign ori_w    = op_alu_imm_w && (3'b110 == f3_w);
assign andi_w   = op_alu_imm_w && (3'b111 == f3_w);
assign slli_w   = op_alu_imm_w && (3'b001 == f3_w) && op_f7_main_w;
assign srli_w   = op_alu_imm_w && (3'b101 == f3_w) && op_f7_main_w;
assign srai_w   = op_alu_imm_w && (3'b101 == f3_w) && op_f7_alt_w;  

assign add_w    = op_alu_reg_w && (3'b000 == f3_w) && op_f7_main_w;
assign sub_w    = op_alu_reg_w && (3'b000 == f3_w) && op_f7_alt_w;
assign slt_w    = op_alu_reg_w && (3'b010 == f3_w) && op_f7_main_w;
assign sltu_w   = op_alu_reg_w && (3'b011 == f3_w) && op_f7_main_w;
assign xor_w    = op_alu_reg_w && (3'b100 == f3_w) && op_f7_main_w;
assign or_w     = op_alu_reg_w && (3'b110 == f3_w) && op_f7_main_w;
assign and_w    = op_alu_reg_w && (3'b111 == f3_w) && op_f7_main_w;
assign sll_w    = op_alu_reg_w && (3'b001 == f3_w) && op_f7_main_w;
assign srl_w    = op_alu_reg_w && (3'b101 == f3_w) && op_f7_main_w;
assign sra_w    = op_alu_reg_w && (3'b101 == f3_w) && op_f7_alt_w;	 

assign mul_w    = op_alu_reg_w && (3'b000 == f3_w) && op_f7_mul_w;
assign mulh_w   = op_alu_reg_w && (3'b001 == f3_w) && op_f7_mul_w;	
assign mulhsu_w = op_alu_reg_w && (3'b010 == f3_w) && op_f7_mul_w;   
assign mulhu_w  = op_alu_reg_w && (3'b011 == f3_w) && op_f7_mul_w;
assign div_w    = op_alu_reg_w && (3'b100 == f3_w) && op_f7_mul_w;	
assign divu_w   = op_alu_reg_w && (3'b101 == f3_w) && op_f7_mul_w;
assign rem_w    = op_alu_reg_w && (3'b110 == f3_w) && op_f7_mul_w;	
assign remu_w   = op_alu_reg_w && (3'b111 == f3_w) && op_f7_mul_w;

assign load_w    = lb_w || lh_w || lw_w || lbu_w || lhu_w;
assign store_w   = sb_w || sh_w || sw_w;

assign alu_imm_w = addi_w || slti_w || sltiu_w || xori_w || ori_w || andi_w || slli_w || srli_w || srai_w || lui_w || auipc_w;
assign alu_reg_w = add_w || sub_w || slt_w || sltu_w || xor_w || or_w || and_w || sll_w || srl_w || sra_w || mul_w || mulh_w || mulhsu_w || mulhu_w || div_w || divu_w || rem_w || remu_w;

assign branch_w  = beq_w || bne_w || blt_w || bge_w || bltu_w || bgeu_w;
assign jump_w    = jal_w || jalr_w;

assign id_illegal_w = !(load_w || store_w || alu_imm_w || alu_reg_w || jump_w || branch_w);

wire [31:0] id_i_imm_w = { {20{if_opcode_w[31]}}, if_opcode_w[31:20] };
wire [31:0] id_s_imm_w = { {20{if_opcode_w[31]}}, if_opcode_w[31:25], if_opcode_w[11:7] };
wire [31:0] id_b_imm_w = { {19{if_opcode_w[31]}}, if_opcode_w[31], if_opcode_w[7], if_opcode_w[30:25], if_opcode_w[11:8], 1'b0 };
wire [31:0] id_u_imm_w = { if_opcode_w[31:12], 12'h0 };
wire [31:0] id_j_imm_w = { {11{if_opcode_w[31]}}, if_opcode_w[31], if_opcode_w[19:12], if_opcode_w[20], if_opcode_w[30:21], 1'b0 };

assign id_imm_w =
    (lui_w || auipc_w)              ? id_u_imm_w :
    (branch_w)                      ? id_b_imm_w :
    (load_w || jalr_w || alu_imm_w) ? id_i_imm_w :
    (store_w)                       ? id_s_imm_w :
    (jal_w)                         ? id_j_imm_w : 32'h0;

assign id_rd_index_w = (branch_w || store_w)           ? 5'd0 : rd_w;
assign id_ra_index_w = (lui_w || auipc_w || jal_w)     ? 5'd0 : ra_w;
assign id_rb_index_w = (load_w || jump_w || alu_imm_w) ? 5'd0 : rb_w;

assign id_alu_op_w =
    (add_w || addi_w || lui_w || load_w || store_w) ? 4'd0 :
    (andi_w || and_w)   			? 4'd2 :
    (ori_w || or_w)     			? 4'd3 :
    (xori_w || xor_w)   			? 4'd4 :
    (slti_w || slt_w)   			? 4'd5 :
    (sltiu_w || sltu_w) 			? 4'd6 :
    (sll_w || slli_w)   			? 4'd7 :
    (srl_w || srli_w) 				? 4'd8 :
	(sra_w || srai_w) 				? 4'd9 :
    (mulh_w || mulhsu_w || mulhu_w) ? 4'd11 :
    (mul_w)                         ? 4'd10 :
    (div_w || divu_w)               ? 4'd12 :
    (rem_w || remu_w)               ? 4'd13 :
    (jal_w || jalr_w)               ? 4'd14 :
    (auipc_w)                       ? 4'd14 : 4'd1;

assign id_branch_w =
    beq_w  ? 3'd2 :
    bne_w  ? 3'd3 :
    blt_w  ? 3'd4 :
    bge_w  ? 3'd5 :
    bltu_w ? 3'd6 :
    bgeu_w ? 3'd7 :
    jump_w ? 3'd1 : 3'd0;

assign id_mem_size_w =			
    (lb_w || lbu_w || sb_w) ? 2'd0 :
    (lh_w || lhu_w || sh_w) ? 2'd1 : 2'd2;
	
endmodule


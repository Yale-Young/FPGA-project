`ifndef MY_MODEL__SV
`define MY_MODEL__SV

class my_model extends uvm_component;
   
   uvm_blocking_get_port #(my_transaction)  port;
   uvm_analysis_port #(my_transaction)  ap;

   extern function new(string name, uvm_component parent);
   extern function void build_phase(uvm_phase phase);
   extern virtual  task main_phase(uvm_phase phase);

   `uvm_component_utils(my_model)
endclass 

function my_model::new(string name, uvm_component parent);
   super.new(name, parent);
endfunction 

function void my_model::build_phase(uvm_phase phase);
   super.build_phase(phase);
   port = new("port", this);
   ap = new("ap", this);
endfunction

task my_model::main_phase(uvm_phase phase);
   my_transaction tr;
   my_transaction new_tr;
   logic [31:0]inst;
   logic [6:0] opcode;
   logic [6:0] func7;
   logic [2:0] func3;
   logic [4:0] rs1;
   logic [4:0] rs2;
   logic [4:0] rd;
   logic [31:0] imm;
   logic [31:0] X[0:31];
   logic [31:0] csr[0:31];
   
   logic [31:0] pc;
   logic [31:0] datai,datao,addr;
   logic [1:0] rw;
   int data_size;
   super.main_phase(phase);
   while(1) begin
      port.get(tr);
      pc=32'h8;
      new_tr = new("new_tr");
      new_tr = tr;
      data_size = tr.pc.size();
      for(int i = 0;i < data_size;i++)begin
        inst   = tr.pc[i];
        datai   = tr.data[i];
        opcode = inst[6:0];
        func7  = inst[31:25];
        rd     = inst[11:7];
        rs1    = inst[19:15];
        rs2    = inst[24:20];
        func3  = inst[14:12];
        datao  = 32'b0;
        rw     = 2'b0;
        addr   = 32'b0;
        case(opcode)
        7'b1100111:begin//jalr
          imm[11:0] = inst[31:21];
          X[rd] = pc+32'd4;
          pc = (X[rs1] + imm);
        end
        7'b0110011:begin//R
          case(func7)
          7'b0:begin
            case(func3)
            3'b000:begin//add
            X[rd] = X[rs1] + X[rs2];
            end
            3'b001:begin//sll
            X[rd] = X[rs1] << X[rs2];
            end
            3'b010:begin//slt
            X[rd] = $signed(X[rs1]) < $signed(X[rs2]);
            end
            3'b011:begin//sltu
            X[rd] = X[rs1] < X[rs2];
            end
            3'b100:begin//xor
            X[rd] = X[rs1] ^ X[rs2];
            end
            3'b101:begin//srl
            X[rd] = X[rs1] >> X[rs2];
            end
            3'b110:begin//or
            X[rd] = X[rs1] | X[rs2];
            end
            3'b111:begin//and
            X[rd] = X[rs1] & X[rs2];
            end
            
            endcase
          end
          7'b1:begin
            case(func3)
            3'b000:begin//mul
            X[rd] = X[rs1] * X[rs2];
            end
            3'b001:begin//mulh
            X[rd] = ($signed(X[rs1]) * $signed(X[rs2]))>>32;
            end
            3'b010:begin//mulhsu
            X[rd] = ($signed(X[rs1]) * X[rs2])>>32;
            end
            3'b011:begin//mulhu
            X[rd] = (X[rs1] * X[rs2])>>32;
            end
            3'b100:begin//div
            X[rd] = $signed(X[rs1]) / $signed(X[rs2]);
            end
            3'b101:begin//divu
            X[rd] = X[rs1] /X[rs2];
            end
            3'b110:begin//rem
            X[rd] = $signed(X[rs1]) % $signed(X[rs2]);
            end
            3'b111:begin//remu
            X[rd] = X[rs1]%X[rs2];
            end
            
            endcase
          end
          7'b0100000:begin
            case(func3)
            3'b000:begin//sub
            X[rd] = X[rs1] - X[rs2];
            end
            3'b101:begin//sra
            X[rd] = X[rs1] >> $signed(X[rs2]);
            end
            endcase
          end
          endcase
        end
        7'b0000011:begin//l
          imm[11:0] = inst[31:20];
          case(func3)
            3'b000:begin//lb
            rw = 2'b10;
            addr = X[rs1] + imm;
            X[rd] = datai[7:0];
            end
            3'b001:begin//lh
            rw = 2'b10;
            addr = X[rs1] + imm;
            X[rd] = datai[15:0];
            end
            3'b010:begin//lw
            rw = 2'b10;
            addr = X[rs1] + imm;
            X[rd] = datai[31:0];
            end
            3'b100:begin//lbu
            rw = 2'b10;
            addr = X[rs1] + imm;
            X[rd] = datai[7:0];
            end
            3'b101:begin//lhu
            rw = 2'b10;
            addr = X[rs1] + imm;
            X[rd] = datai[15:0];
            end
            endcase
        end
        7'b0010011:begin//i
          case(func3)
            3'b000:begin//addi
            X[rd] = X[rs1] + imm;
            end
            3'b001:begin//slli
            X[rd] = X[rs1] << rs2;
            end
            3'b010:begin//slti
            X[rd] = X[rs1] < imm;
            end
            3'b011:begin//sltui
            X[rd] = X[rs1] < imm;
            end
            3'b100:begin//xori
            X[rd] = X[rs1] ^ imm;
            end
            3'b101:begin//srli or srai
              if(inst[31:25]==7'b0)begin//srli
              X[rd] = X[rs1] >> rs2;
              end
              else begin//srai
              X[rd] = $signed(X[rs1]) >> $signed(rs2);
              end
            end
            3'b110:begin//ori
            X[rd] = X[rs1] | imm;
            end
            3'b111:begin//andi
            X[rd] = X[rs1] & imm;
            end
            
            endcase
        end
        7'b0001111:begin//fence
          if(func3==3'b0) begin//fenc
          
          end else begin//fencei
          
          end
        end
        7'b1110011:begin//csr
          imm[11:0] = {func7,rs2};
          case(func3)
            3'b000:begin//ecall
            
            end
            3'b001:begin//rw
             X[rd] =csr[imm]; 
             csr[imm] = X[rs1];
            end
            3'b010:begin//rs
            X[rd] =csr[imm]; 
            csr[imm] =X[rd] | X[rs1];
            end
            3'b011:begin//rc
            X[rd] =csr[imm]; 
            csr[imm] =X[rd] & ~X[rs1];
            end
            3'b101:begin//rwi
            X[rd] =csr[imm]; 
            csr[imm] =rs1;
            end
            3'b110:begin//rsi
            X[rd] =csr[imm]; 
            csr[imm] =X[rd] | rs1;
            end
            3'b111:begin//rci
            X[rd] =csr[imm]; 
            csr[imm] =X[rd]& ~rs1;
            end
            
            endcase
        end
        7'b0100011:begin//s
          {imm[11:5],imm[4:0]}={func7,rd};
           case(func3)
            3'b000:begin//sb
            rw = 2'b11;
            addr = X[rs1] + imm;
            datao = X[rs2][7:0];
            end
            3'b001:begin//sh
            rw = 2'b11;
            addr = X[rs1] + imm;
            datao = X[rs2][15:0];
            end
            3'b010:begin//sw
            rw = 2'b11;
            addr = X[rs1] + imm;
            datao = X[rs2][31:0];
            end
          endcase
        end
        7'b1100011:begin//b
          {imm[12],imm[10:5],imm[4:0],imm[11]}={func7,rd};
          case(func3)
            3'b000:begin//beq
            if ($signed(X[rs1]) == $signed(X[rs2])) pc =pc+ imm;
            end
            3'b001:begin//bne
            if ($signed(X[rs1]) !== $signed(X[rs2])) pc =pc+ imm;
            end
            3'b100:begin//blt
            if ($signed(X[rs1]) < $signed(X[rs2])) pc =pc+ imm;
            end
            3'b101:begin//bge
            if ($signed(X[rs1]) >= $signed(X[rs2])) pc =pc+ imm;
            end
            3'b110:begin//bltu
            if (X[rs1] < X[rs2]) pc = pc +imm; 
            end
            3'b111:begin//bgeu
            if (X[rs1] >= X[rs2]) pc =pc+ imm;
            end
            endcase
        end
        7'b0110111:begin//lui
          imm[19:0] = inst[31:12];
          X[rd] =imm;
        end
        7'b0010111:begin//aui
          imm[19:0] = inst[31:12];
          X[rd] = pc + imm;
        end
        7'b1101111:begin//jal
          X[rd] = pc + 32'd4;
          {imm[20],imm[10:1],imm[11],imm[19:12]}= inst[31:12];
          pc = pc + imm;
        end
        
        endcase
        
        if(opcode !=7'b1100011 && opcode != 7'b1101111 && opcode != 7'b1100111) pc = pc+32'd4;
        new_tr.pc[i] = pc;
        new_tr.data[i] = datao;
        new_tr.addr[i] = addr;
        new_tr.rw[i] = rw;
      end
      ap.write(new_tr);
      `uvm_info("my_model", "model has send a pakage", UVM_LOW)
   end
endtask
`endif

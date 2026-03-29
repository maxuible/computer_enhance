// -vet -strict-style -vet-tabs -disallow-do -warnings-as-errors
package main

import "core:fmt"
import "core:os"
main :: proc() {

	Op_Code :: enum {
		Unknown,
		Register_to_register,
	}

	
	// bytes, err := os.read_entire_file_from_path("./listing_0037_single_register_mov", context.allocator)
	bytes, err := os.read_entire_file_from_path("./listing_0038_many_register_mov", context.allocator)

	if err != os.ERROR_NONE {
		fmt.println("could not read file")
	}

	fmt.println("bits 16")

	c := 0 //consumed bytes
	for c < len(bytes){
		
		opcode := get_opcode(bytes[c]>>2)

		if opcode == Op_Code.Register_to_register {
			//d := bytes[c] & 0b00000010
			w := bytes[c] & 0b00000001
			
			c += 1
			
			mod := bytes[c] & 0b11000000 >> 6
			
			reg := bytes[c] & 0b00111000 >> 3
			
			r_m := bytes[c] & 0b00000111
			
			
			reg_code := decode_reg(reg, w)
			r_m_code : string
			if mod == 0b11 {
				r_m_code = decode_reg(r_m, w)
			} 
			fmt.printfln("mov %v, %v", r_m_code, reg_code)


			c += 1
			
			
			continue
		}

			

		fmt.println("\ncould not parse this byte")
		fmt.printfln("%#b", bytes[c])
		c +=1
	}
	


	get_opcode :: proc(opcode: byte) -> (Op_Code) {
		if opcode == 0b100010 {
			return Op_Code.Register_to_register
		}
		return Op_Code.Unknown
	}

	decode_reg :: proc(reg: byte, w:byte) -> string {

		table := [8][2]string{
			{"al","ax"},
			{"cl","cx"},
			{"dl","dx"},
			{"bl","bx"},
			{"ah","sp"},
			{"ch","bp"},
			{"dh","si"},
			{"bh","di"},
		}
		return table[reg][w]

	}
}


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

	// for b in bytes {
	// 	fmt.printfln("%#b",b)
	// }

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
			
			
			// fmt.printfln("d:     %#b", d)
			// fmt.printfln("w:     %#b", w)
			
			// fmt.printfln("bytes: %#b", bytes[c])
			// fmt.printfln("mod:   %#b", mod)
			// fmt.printfln("reg:   %#b", reg)
			// fmt.printfln("r_m:   %#b", r_m)

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
		if reg == 0 {
			if w == 1 {
				return "ax"
			} else {
				return "al"
			}
		} else if reg == 1 {
			if w == 1 {
				return "cx"
			} else {
				return "cl"
			}
		} else if reg == 2 {
			if w == 1 {
				return "dx"
			} else {
				return "dl"
			}
		} else if reg == 3 {
			if w == 1 {
				return "bx"
			} else {
				return "bl"
			}
		} else if reg == 4 {
			if w == 1 {
				return "sp"
			} else {
				return "ah"
			}
		} else if reg == 5 {
			if w == 1 {
				return "bp"
			} else {
				return "ch"
			}
		} else if reg == 6 {
			if w == 1 {
				return "si"
			} else {
				return "dh"
			}
		} else if reg == 7 {
			if w == 1 {
				return "di"
			} else {
				return "bh"
			}
		}
		return "error"
	}
}


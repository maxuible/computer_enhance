// -vet -strict-style -vet-tabs -disallow-do -warnings-as-errors
package main

import "core:fmt"
import "core:os"
import "core:encoding/endian"


main :: proc() {

	Op_Code :: enum {
		Unknown,
		Register_to_register,
		Immediate_to_register,
	}

	
	// bytes, err := os.read_entire_file_from_path("./listing_0037_single_register_mov", context.allocator)
	bytes, err := os.read_entire_file_from_path("./listing_0039_more_movs", context.allocator)

	if err != os.ERROR_NONE {
		fmt.println("could not read file")
	}

	fmt.println("bits 16")

	c := 0 //consumed bytes
	for c < len(bytes){
		
		opcode := get_opcode(bytes[c]>>2)

		if opcode == Op_Code.Register_to_register {
			d := bytes[c] & 0b00000010 >> 1
			w := bytes[c] & 0b00000001
			
			c += 1
			
			mod := bytes[c] & 0b11000000 >> 6
			
			reg := bytes[c] & 0b00111000 >> 3
			
			r_m := bytes[c] & 0b00000111
			
			
			if mod == 0b11 {
				reg_code := decode_reg(reg, w)
				r_m_code := decode_reg(r_m, w)
				fmt.printfln("mov %v, %v", r_m_code, reg_code)
			} else if mod == 0b00{
				reg_code := decode_reg(reg, w)
				r_m_code := decode_r_m(r_m, w)

				if d == 0b1 {
					fmt.printfln("mov %v, [%v]", reg_code, r_m_code)
				} else{
					fmt.printfln("mov [%v], %v", r_m_code, reg_code)
				}

			} else if mod == 0b01 {
				c += 1

				numba := bytes[c]

				reg_code := decode_reg(reg, w)
				r_m_code := decode_r_m(r_m, w)
				
				if d == 0b1 {
					fmt.printfln("mov %v, [%v + %v]", reg_code, r_m_code, numba)
				} else{
					fmt.printfln("mov [%v + %v], %v", r_m_code, numba, reg_code)

				}

			} else if mod == 0b10 {
				c += 1
				numba, _ := endian.get_u16(bytes[c:c+2], .Little) // or .Big
				c += 1

				reg_code := decode_reg(reg, w)
				r_m_code := decode_r_m(r_m, w)
				fmt.printfln("mov %v, [%v + %v]", reg_code, r_m_code, numba)

			}


			
			
			c += 1
			continue
		} else if opcode == Op_Code.Immediate_to_register {
			w := bytes[c]   & 0b00001000 >> 3
			reg := bytes[c] & 0b00000111
			reg_code := decode_reg(reg, w)
			c += 1
			if w == 0b1 {
				numba, _ := endian.get_u16(bytes[c:c+2], .Little) // or .Big
				fmt.printfln("mov %v, %v", reg_code, numba)

			} else {
				numba := bytes[c]
				fmt.printfln("mov %v, %v", reg_code, numba)

			}
			

		}

		

		// fmt.println("\ncould not parse this byte")
		// fmt.printfln("%#b", bytes[c])
		c +=1
	}
	


	get_opcode :: proc(opcode: byte) -> (Op_Code) {
		if opcode == 0b100010 {
			return Op_Code.Register_to_register
		} else if opcode >> 2 == 0b1011 {
			return Op_Code.Immediate_to_register
		}



		return Op_Code.Unknown
	}

	decode_reg :: proc(reg: byte, w: byte) -> string {

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


	decode_r_m :: proc(r_m: byte, w: byte) -> string {
		table := [8]string{
			"bx + si",
			"bx + di", 
			"bp + si", 
			"bp + di", 
			"si"     ,
			"di"     , 
			"bp"     , 
			"bx"     , 
		}

		return table[r_m]
	}
}


#!/usr/bin/env bash

compile_proc () {
	echo "compile: $1"
	iverilog -I src -D VCD='"obj/'$1'.vcd"' -g2012 -o obj/top_$1 src/top.sv src/$2 > obj/log 2>&1
	if [ $? -ne 0 ]; then
		echo "error while compiling $1, log:"
		cat obj/log | sed 's/^/  >> /'
		exit 1
	fi
}

execute_proc () {
	echo "execute: $1"
	vvp -n ./obj/top_$1 > obj/$1.txt
	if [ $? -ne 0 ]; then
		echo "error while executing $1"
		exit 1
	fi
}

display_trace () {
	echo "to display trace for $1: gtkwave obj/$1.vcd waveform.gtkw"
}


rm -rf obj 2>/dev/null
mkdir obj

./scr/generate_code.py > obj/code.txt
./scr/generate_data.py > obj/data.txt

echo
compile_proc none cache_none.sv
compile_proc direct cache_direct.sv
compile_proc assoc cache_assoc.sv

echo
execute_proc none
execute_proc direct
execute_proc assoc

echo
echo stats:
for x in none direct assoc; do
	echo "  $x:"
	cat obj/$x.txt | grep regs | sed 's/^/    /'
done

for x in none direct assoc; do
	echo "  $x:"
	cat obj/$x.txt | grep called | sed 's/^/    /'
done

echo
display_trace none
display_trace direct
display_trace assoc

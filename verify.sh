#!/bin/sh

function check {
	depth=$1
	ip=$2
	occ="c++ -I/opt/AMDAPP/include -L/opt/AMDAPP/lib/x86_64 -lOpenCL"

	printf "DEPTH = %s : input = %s " $depth $ip

	cc -std=c99 -ansi -pedantic -Wall -DMAX_DEPTH=$depth draughts_ser.c -o draughts_ser 2> _warn
	if [ ! -s draughts_ser ]; then
		echo Compilation error for draughts_ser.c
		exit 1
	fi

	$occ -DMAX_DEPTH=$depth draughts_par.cpp -o draughts_par 2>> _warn
	if [ ! -s draughts_par ]; then
		echo Compilation error for draughts_par.cpp
		exit 1
	fi

	./draughts_ser < $ip > _ser
	./draughts_par < $ip > _cl

	ix=`echo $ip | sed 's/input.//' | sed 's/.ip//'`
	diff _ser _cl > /dev/null

	if [ $? -ne 0 ]; then
		echo "DIFFERENT"
	else
		echo "SAME"
	fi
	mv _cl log/"$ix"."d""$depth".cl
	mv _ser log/"$ix"."d""$depth".ser
}

	clear
	rm -f draughts_ser draughts_par _warn _cl
	rm -rf log
	mkdir log

	for file in `ls input/*.ip | cut -d. -f 1 | sort | uniq`
	do
		f0=`echo "$file".0.ip`
		f1=`echo "$file".1.ip`

		i=0
		while [ $i -le 0 ];
		do
			check $i $f0
			check $i $f1
			i=`expr $i + 1`
		done

		if [ -s _warn ]; then
			echo
			echo "Compiler WARNINGS exist!!! Check and fix complier warnings."
		fi
	done

	rm -f _cl _ser _warn

exit 0


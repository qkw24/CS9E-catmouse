#!/bin/bash
# Bash Calculator Framework
# CS9E - Assignment 4.1
#
# Framework by Jeremy Huddleston <jeremyhu@cs.berkeley.edu>
# $LastChangedDate: 2007-10-11 15:49:54 -0700 (Thu, 11 Oct 2007) $
# $Id: bashcalc-fw.sh 88 2007-10-11 22:49:54Z selfpace $

## Floating Point Math Functions ##

# bashcalc <expression>
# This function simply passes in the given expressions to 'bc -l' and prints the result
function bashcalc {
	echo $1 | bc -l
}


# sine <expression>
# This function prints the cosine of the given expression
function sine {
	# ADD CODE HERE FOR PART 3
	echo 's('$1')' | bc -l
}

# cosine <expression>
# This function prints the cosine of the given expression
function cosine {
	# ADD CODE HERE FOR PART 3
	echo 'c('$1')' | bc -l
}

# angle_reduce <angle>
# Prints the angle given expressed as a value between 0 and 2pi
function angle_reduce {
	# ADD CODE HERE FOR PART 3
	tester=$1
	twopi=$(echo '8*a(1)' | bc -l)
	zero='0'
	less=$(echo $1'<'$zero | bc)
	greater=$(echo $1'>'$twopi | bc)
	while [ $less -eq 1 ]
	do
		tester=$(echo $tester'+'$twopi | bc)
		less=$(echo $tester'<'$zero | bc)
	done
	while [ $greater -eq 1 ]
	do
		tester=$(echo $tester'-'$twopi | bc)
		greater=$(echo $tester'>'$twopi | bc)
	done
	echo $tester

}

# float_{lt,lte,eq} <expr 1> <expr 2>
# These functions returns true (exit code 0) if the first value is less than the second (lt),
# less than or equal to the second (lte), or equal to the second (eq).
# Note: We can't just use BASH's builtin [[ ... < ... ]] operator because that is
#       for integer math.
function float_lt {
	# ADD CODE HERE FOR PART 3
	if [ $(echo $1'<'$2 | bc -l) -eq 1 ]
	then
		return 0
	fi
	return 2
}

function float_eq {
	# ADD CODE HERE FOR PART 3
	if [ $(echo $1'=='$2 | bc -l) -eq 1 ]
	then
		return 0
	fi
	return 2
}

function float_lte {
	# ADD CODE HERE FOR PART 3
	if [ $(echo $1'<='$2 | bc -l) -eq 1 ]
	then
		return 0
	fi
	return 2
}

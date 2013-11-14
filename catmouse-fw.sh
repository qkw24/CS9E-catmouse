#!/bin/bash
# Cat & Mouse Framework
# CS9E - Assignment 4.2
#
# Framework by qkw24
# $LastChangedDate: 2007-10-11 15:49:54 -0700 (Thu, 11 Oct 2007) $
# $Id: catmouse-fw.sh 88 2007-10-11 22:49:54Z selfpace $

# Source the file containing your calculator functions:
. bashcalc-fw.sh

# Additional math functions:

# angle_between <A> <B> <C>
# Returns true (exit code 0) if angle B is between angles A and C and false otherwise
function angle_between {
	local A=$1
	local B=$2
	local C=$3

	# ADD CODE HERE FOR PART 1
	B_A=$(cosine $(bashcalc $B'-('$A')'))
	C_B=$(cosine $(bashcalc $C'-('$B')'))
	C_A=$(cosine $(bashcalc $C'-('$A')'))

	if [ $(float_lt $C_A $B_A; echo $?) -eq 0 ] && [ $(float_lt $C_A $C_B; echo $?) -eq 0 ]
	then
		return 0
	else
		return 2
	fi
}

### Simulation Functions ###
# Variables for the state
RUNNING=0
GIVEUP=1
CAUGHT=2

# does_cat_see_mouse <cat angle> <cat radius> <mouse angle>
#
# Returns true (exit code 0) if the kat can see the mouse, false otherwise.
#
# The kat sees the mouse if
# (kat radius) * cos (kat angle - mouse angle)
# is at least 1.0.
function does_cat_see_mouse {
	local cat_angle=$1
	local cat_radius=$2
	local mouse_angle=$3

	# ADD CODE HERE FOR PART 1
	local left=1
	local right=$( bashcalc $cat_radius'*c('$cat_angle'-'$mouse_angle')' )

	local test_result=$(float_lte $left $right; echo $?)

	if [ $test_result -eq 0 ] 
	then
		return 0
	else
		return 2
	fi
}

# next_step <current state> <current step #> <cat angle> <cat radius> <mouse angle> <max steps>
# returns string output similar to the input, but for the next step:
# <state at next step> <next step #> <cat angle> <cat radius> <mouse angle> <max steps>
#
# exit code of this function (return value) should be the state at the next step.  This allows for easy
# integration into a while loop.
function next_step {
	local state=$1
	local -i step=$2
	local old_cat_angle=$3
	local old_cat_radius=$4
	local old_mouse_angle=$5
	local -i max_steps=$6
    local -i qkw_cat

	local new_cat_angle=${old_cat_angle}
	local new_cat_radius=${old_cat_radius}
	local new_mouse_angle=${old_mouse_angle}

	if [ $(float_eq $old_cat_angle $old_mouse_angle; echo $?) -eq 0 ] && [ $(float_eq $old_cat_radius 1; echo $?) -eq 0 ]; then
		state=${CAUGHT}
	fi

	# First, make sure we are still running
	if (( ${state} != ${RUNNING} )) ; then
		echo ${state} ${step} ${old_cat_angle} ${old_cat_radius} ${old_mouse_angle} ${max_steps}
		return ${state}
	fi

	# ADD CODE HERE FOR PART 2
	# Move the cat first
	if [ $(does_cat_see_mouse $old_cat_angle $old_cat_radius $old_mouse_angle; echo $?) -eq 0 ] && [ $(float_lt 1 $old_cat_radius; echo $?) -eq 0 ]; then
		# Move the cat in if it's not at the statue and it can see the mouse
		new_cat_radius=$( bashcalc $old_cat_radius'-1' )
		if [ $(float_lt $new_cat_radius 1; echo $?) -eq 0 ]; then
			new_cat_radius=1
		fi
	else
		# Move the cat around if it's at the statue or it can't see the mouse
		new_cat_angle=$( angle_reduce $(bashcalc $old_cat_angle'+(1.25/'$old_cat_radius')') )
		
		# Check if the cat caught the mouse
		if [ $(angle_between $old_cat_angle $old_mouse_angle $new_cat_angle; echo $?) -eq 0 ] && (( $step < $max_steps)); then
			state=${CAUGHT}
		fi
	fi

	# Now move the mouse if it wasn't kaught
	if (( ${state} != ${CAUGHT} )); then
		# Move the mouse
		new_mouse_angle=$( angle_reduce $(bashcalc "$old_mouse_angle+1") )

		# Give up if we're at the last step and haven't caught the mouse
		if (( $max_steps <= $step )); then
			state=${GIVEUP}
			echo ${state} ${step} ${old_cat_angle} ${old_cat_radius} ${old_mouse_angle} ${max_steps}
			return ${state}
		fi
	fi
	step=$( bashcalc "$step+1" )

	echo ${state} ${step} ${new_cat_angle} ${new_cat_radius} ${new_mouse_angle} ${max_steps}
	return ${state}
}

function print_status {
	local state=$1
	local -i step=$2
	local old_cat_angle=$3
	local old_cat_radius=$4
	local old_mouse_angle=$5
	local -i max_steps=$6

	if (( ${state} == ${RUNNING} )); then
		state='RUNNING'
	elif (( ${state} == ${CAUGHT} )); then
		state='CAUGHT'
	elif (( ${state} == ${GIVEUP} )); then
		state='GIVEUP'
	else
		state='ERROR'
	fi

	printf "$state / steps: $step / cat_angle: %.3f / Qcat_radius: $old_cat_radius / mouse_angle: %.3f / max_steps: $max_steps\n" "$old_cat_angle" "$old_mouse_angle"
}

### Main Script ###

if [[ ${#} != 4 ]] ; then
	echo "$0: usage" >&2
	echo "$0 <cat angle> <cat radius> <mouse angle> <max steps>" >&2
	exit 1
fi

# ADD CODE HERE FOR PART 3
cat_angle=$1
cat_radius=$2
mouse_angle=$3
max_steps=$4
by_qkw=$5
step=0
state=${RUNNING}

#this prints the first step
print_status $state $step $cat_angle $cat_radius $mouse_angle $max_steps

next_variables=$(next_step $state $step $cat_angle $cat_radius $mouse_angle $max_steps)

is_done=$(echo $?)
#this prints the second step
print_status $next_variables

until (( ${is_done} != ${RUNNING} )); do
	next_variables=$(next_step $next_variables)
	is_done=$(echo $?)

	print_status $next_variables
done
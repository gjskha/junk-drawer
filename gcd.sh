#/usr/bin/env bash

# Euclid's algorithm for the finding the greatest common denominator 

function gcd {
	
	n=$1
	m=$2

	while [ $m -ne $n ]; do
		if [ $n -ge $m ]; then

			if [ $DEBUG -eq 1 ]; then
				echo -n "$n (n) - $m (m) "
			fi

			n=$(( $n - $m ))

			if [ $DEBUG -eq 1 ]; then
				echo is $n
			fi
		else
			if [ $DEBUG -eq 1 ]; then
				echo -n "$m (m) - $n (n) "
			fi

			m=$(( $m - $n ))
			if [ $DEBUG -eq 1 ]; then
				echo is $m
			fi
		fi
	done
	echo $n
}

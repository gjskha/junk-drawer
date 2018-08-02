echo "Bubble Sort"

declare -a the_array=(8 4 2 1 7 11 )

echo -n "Starting with the array:"
for elem in "${the_array[@]}" ; do
     echo -n "$elem "
done
echo 

function bubblesort() {

    # weird hacky stuff to pass array in bash
    name=$1[@]
    the_array=("${!name}")
    n=$2

    #echo "Iteration $n"

    # subshell only
    if [ $n -eq 1 ]; then
        echo -n "Round $n, final ordering: "
 
        for elem in "${the_array[@]}" ; do
            echo -n "$elem "
        done
        echo

        return
    fi

    this_iteration=0
    while [ $this_iteration -lt ${#the_array[@]} ]; do
        next_cell_up=$(($this_iteration+1))
        echo -n "Round $n, iteration $this_iteration. Is ${the_array[$this_iteration]} less than ${the_array[$next_cell_up]}?"

        if [[ ${the_array[$this_iteration]} -lt ${the_array[$next_cell_up]} ]]; then
            echo " Yes. Switching places"
            tmp=${the_array[$this_iteration]}
            the_array[$this_iteration]=${the_array[$next_cell_up]} 
            the_array[$next_cell_up]=$tmp 

        else
       
          echo " No, keeping them in place."

      fi
  
        this_iteration=$(( $this_iteration + 1))
    done 

    echo -n "Result: "
    for elem in "${the_array[@]}" ; do
        echo -n "$elem "
    done
    echo

    n=$(( $n - 1 ))
    bubblesort the_array $n
}

bubblesort the_array 6

echo
echo "Insertion Sort"

declare -a the_array=(11 42 2 55 6 13 1 22)

echo -n "Starting with the array:"
for elem in "${the_array[@]}" ; do
     echo -n "$elem "
done
echo 

function insertionsort() {

    # weird hacky stuff to pass array in bash
    name=$1[@]
    the_array=("${!name}")
    array_length=$2
    
    this_iteration=1; 
    next_cell_down=0; 
    #this_iterations_value=0;

    while [ $this_iteration -lt $array_length ]; do
    
        this_iterations_value=${the_array[$this_iteration]};
	next_cell_down=$(($this_iteration - 1));

        echo "Iteration $this_iteration of $array_length. Value of $this_iterations_value"

	# move elements of array less than this_iteration that are greater than this_iterations_value 
	# one position ahead of their current position
        # convert to if/else for clarity
	while [ $next_cell_down -ge 0 ] && [ ${the_array[$next_cell_down]} -lt $this_iterations_value ] ; do
	#while [ $next_cell_down -ge 0 ] && [ ${the_array[$next_cell_down]} -lt ${the_array[$this_iteration]} ] ; do
      
            echo "at outer iteration $this_iteration and inner iteration $next_cell_down : $this_iterations_value is greater than ${the_array[$next_cell_down]}"

            k=$(($next_cell_down + 1))
	    tmp=${the_array[$k]}
	    
	    the_array[$k]=${the_array[$next_cell_down]}
	    the_array[$next_cell_down]=$tmp

	    next_cell_down=$(($next_cell_down - 1))  
	done

        this_iteration=$(( $this_iteration + 1 ))	
    done

    echo -n "After sorting the array:"
    for elem in "${the_array[@]}" ; do
        echo -n "$elem "
    done
    echo 

}

insertionsort the_array 8

declare -a the_array=(10 9 8 7 6 5 4 3 2 1 11)

echo -n "Starting with the array:"
for elem in "${the_array[@]}" ; do
     echo -n "$elem "
done
echo 

insertionsort the_array 11

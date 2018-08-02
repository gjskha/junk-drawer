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
    n=$2
    
    i=1; 
    j=0; 
    key=0;

    while [ $i -lt $n ]; do
    
        key=${the_array[$i]};
	j=$(($i - 1));

	# move elements of array less than i that are greater than key 
	# one position ahead of their current position
	while [ $j -ge 0 ] && [ ${the_array[$j]} -gt $key ] ; do
      
            k=$(($j + 1))
	    tmp=${the_array[$k]}
	    
	    the_array[$k]=${the_array[$j]}
	    the_array[$j]=$tmp

	    j=$(($j - 1))  
	done

        i=$(( $i + 1 ))	
    done

echo -n "After sorting the array:"
for elem in "${the_array[@]}" ; do
     echo -n "$elem "
done
echo 


}

insertionsort the_array 8

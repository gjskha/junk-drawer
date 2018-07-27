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

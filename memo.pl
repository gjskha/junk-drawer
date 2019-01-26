#!perl
# memoization example

our %memo;
	
sub fib {
	my $n = shift;
	my $f;
	if (exists($memo{$n})) { return $memo{$n} }
	if ($n <= 2) { 
		$f = 1 
	} else {
		$f = fib($n-1) + fib($n-2);
	}	
	
	$memo{$n} = $f;
	return $f;
}


while (1) {
	print "enter a value for n: ";
	my $n = <STDIN>; 
	chomp $n;
	my $f = fib($n); 
	print " -> $f\n"

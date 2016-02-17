function ll() {
    echo @ is $@
    while getopts alQ opt; do
        case $opt in
            Q)
                do_stuff=1 # else pass through
            ;;
            a)
                af="-a"
            ;;
            l)
                lp=true
            ;;
        esac
        shift "$((OPTIND - 1))" 
    done
    
    echo
    echo @ is $@
    if [ -z $@ ] ; then
    #if  $@ ) ; then
        echo "Contents of $(pwd):"
    else
        echo "Contents of ${@}:"
    fi
    echo
    
    case $(uname) in
        NetBSD)
            lsflags="-lT"
            os="netbsd" 
        ;;
        FreeBSD)
            lsflags="-l -D %m-%d-%Y"
            os="freebsd"
        ;;
        SunOS)
            lsflags="-le"
            os="sunos"
        ;;
        Linux) 
            lsflags='-l --time-style +%m-%d-%Y'
            os="linux"
        ;;
        CYGWIN*)
            lsflags='--time-style +%m-%d-%Y -l'
            os="cygwin"
        ;;
        *) # presume something GNUish and hope for the best
            lsflags='--time-style +%m-%d-%Y -l'
            os="linux"
        ;;
    esac
 


    # run ls through the args, then filter? or just switch if not custom
   
    if [ ! -z $af ]; then
        lsflags=$lsflags" -a" 
    fi
    
    # long or short permissions style
    ls $lsflags "$@" | awk -v os="$os" -v lp="$lp" '
    
    function format_date(rawdate) {
        ("date -d \""rawdate"\" +%m/%d/%Y") | getline readable_date; 
        return readable_date;
    }
    
    function format_size(bytes) {
        line = sprintf ("%.0fB", bytes)
        for ( i=1; i<=n; ++i ) {
            rounded = int ( (bytes + 512) / 1024)
            bytes = int (bytes / 1024)
            if (bytes > 0 ) line = sprintf ("%.0f%s", rounded+0, om[i])
        }
        return line
    }
    
    function calculate_p(rawp) {
    
        a = b = c = d = 0
        split(rawp, bits, "")
     
        if (bits[2] == "r") a = a + 4
        if (bits[3] == "w") a = a + 2
        if (bits[4] == "x") a = a + 1        
        if (bits[4] == "S") d = d + 4
            
        if (bits[4] == "s" ) {
            a = a + 1
            d = d + 4
        }
    
        if (bits[5] == "r") b = b + 4
        if (bits[6] == "w") b = b + 2
        if (bits[7] == "x") b = b + 1
        if (bits[7] == "S") d = d + 2
    
        if (bits[7] == "s" ) {
            b = b + 1
            d = d + 2
        }
    
        if (bits[8] == "r") c = c + 4
        if (bits[9] == "w") c = c + 2
        if (bits[10] == "x") c = c + 1
        if (bits[10] == "t") d = d + 1
    
        if (d == 0) {
            rv = a""b""c
        } else {
    
            rv = d""a""b""c
        }
        return rv   
    }
    
    BEGIN {
        # Orders of magnitude:
        # kilo, mega, giga, tera, peta, exa
        n = split ("K M G T P E", om)
        dc = 0
        total_size = 0
        delete files[0]
        delete dirs[0]
    }
    
    $1 ~ /^[-d]/ {
        ac++
        size = format_size($5) # verify its always $5
        total_size = total_size + $5
    
        if (os == "netbsd") {
            #ls -lT
            #-rwx------  1 gj  arpa     5623 Feb  2 21:09:59 2004 zapa
            # date -d "Feb 20 18:16:25 2012" +%m-%d-%Y
            filename = $10
            rawdate = $6" "$7" "$8" "$9
            date = format_date(rawdate)
        } else if (os == "freebsd") {
            #ls -l -D %m-%d-%Y
            #-rw-r--r--  1 qa  qa    478 02-03-2015 Makefile
            date = $6
            filename = $7
        } else if (os == "sunos") {
            # /usr/bin/ls -le
            # -rw-r--r--   1 qa       qa          1763 Jan 30 20:03:49 2015 README
            filename = $10
            rawdate = $6" "$7" "$8" "$9
            date = format_date(rawdate)
            
        } else {
            # drwxr-xr-x. 2 koba koba 4096 01-28-2015 Desktop
            date = $6;
            filename = $7
        }
    
        perms = calculate_p($1)
        if ($1 ~ /^d/) {
            dc++
            #$ ls -l Videos/
            #total 0 <- 1 line
            # a option? wont here as is           
            #("ls -l "filename" | wc -l") | getline kids
            ("ls -1 "af" "filename" | wc -l") | getline kids
            line = sprintf("%4d %5s %10s %s\n", perms,kids,date,filename)
            dirs[length(dirs) + 1] = line
            #print "kids are" kids
        #} else if ($1 ~ /^-/) {
        } else if ($1 ~ /^-/) {
            line = sprintf("%4d %4s %10s %s\n", perms,size,date,filename)
            files[length(files) + 1] = line
        }
    }
    
    END {
    
        if ( length(dirs) > 0 ) {
            print "Directories:\n";
            printf("%4s %5s %10s %s\n","Mode","Kids","Date","Name") 
            printf("%4s %5s %10s %s\n","----","----","----------","----")
            for (x=1; x <= length(dirs); x++) {
                printf("%s", dirs[x])
            }
        }
    
        if ( length(files) > 0 ) {
            print "\nFiles:\n";
            printf("%4s %4s %10s %s\n","Mode","Size","Date","Name")
            printf("%4s %4s %10s %s\n","----","----","----------","----")
            for (z=1; z <= length(files); z++) {
                printf("%s", files[z])
            }
        }
    
        total_size_readable = format_size(total_size)
        print "\nSummary:\n"
        print dc " directories, "ac " files total, " total_size_readable " total size."
    
    }'
}

ll "$@"

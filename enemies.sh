#!/bin/bash

outputfile=index.html

cat <<OUTPUT > $outputfile
<html>
 <head>
  <title>Enemies List</title> 
  <script src="http://ajax.googleapis.com/ajax/libs/jquery/1.7.2/jquery.min.js" type="text/javascript"></script>
  <script>
  function show_hidden(toggleClass) {
      \$("." + toggleClass).slideToggle();
  }
  </script>
  <style type="text/css">
    body {
      padding: 20px 20px 20px 20px;
      font-size: 120%;
    }
    .hidden {
      display: none;
    }
    .hidden_li {
      display: none;
      color: red;
    }
    ul {
      list-style-type: none;
    }
   </style>
 </head>
 <body>
  <h1>Enemies List for $(date +%Y-%m-%d)</h1>
  <p>The following allocations were added to a bad AS, and might need to be addressed.</p>
OUTPUT

while read asn; do 

    # for the convenience of having fresh links every time the script runs -- I don't clear my cache very often    
    now=$(date +%s)

    echo '<a name="'${asn% *}$now'"></a>' >> $outputfile
    echo '<h2><a href="#'${asn% *}$now'" onclick="show_hidden('${asn% *}')">'${asn#* }' ('${asn% *}')</a></h2>' >> $outputfile 
    echo '<ul class="hidden '${asn% *}'">' >> $outputfile
    
    echo 0 > /tmp/${asn% *} 
    echo 0 > /tmp/${asn% *}p 
      
    for alloc in $( whois -h whois.cymru.com dump as${asn% *} | grep ${asn% *} | grep -v '::' | awk '{print $3}' ); do        
    
        query=$( echo ${alloc%/*} | awk -F. '{print $4"."$3"."$2"."$1".bl.spamcop.net"}' )  
    
        host $query | grep has >/dev/null
    
        if [ $? -eq 1 ]; then 
            echo '<li>' $alloc '</li>' >> $outputfile
            echo 1 > /tmp/${asn% *} 
        else 
            echo '<li class="hidden_li '${asn% *}'p">' $alloc '</li>' >> $outputfile
            echo 1 > /tmp/${asn% *}p 
        fi
    
    done
    
    if [ $(< /tmp/${asn% *} ) -eq 0 ]; then
        echo '<li> No unfiltered allocations. </li>' >> $outputfile
    fi

    if [ $(< /tmp/${asn% *}p ) -eq 0 ]; then
        echo '<li> No filtered allocations.</li>' >> $outputfile
    else 
        echo '<li><a href="#'${asn% *}p${now}'" onclick="'"show_hidden('"${asn% *}p"')"'">filtered allocations</a></li>' >> $outputfile
    fi

    echo '</ul>' >> $outputfile    
    rm /tmp/${asn% *}*
    sleep 1

done <<EOF
$(< enemies.txt )
EOF

cat <<OUTPUT >> $outputfile 
<br />
<hr />
This page created by $0 on $( date ).
</body>
</html>
OUTPUT

prompt(){
    printf "$PS1"
}

faketype(){
    echo  "$1" | pv -qL $[$typingspeed+(-2 + RANDOM%5)]
    /bin/sleep $shortpause
}

comment(){
    command="# $1"
    /bin/sleep $shortpause
    prompt
    printf "$ESC[32;1m"  
    echo "$command" | fold -s -w 80 | $slowtype
    printf "$RESET"
    /bin/sleep $shortpause
}

poof(){
    command="# *** POOF: $1 ***"
    printf "$ESC[35;1m"  
    echo "$command" | $slowtype
    printf "$RESET"
    /bin/sleep $shortpause
}

fakedo(){
    prompt
    faketype "$1"
}

typedo (){
    command=$1
    prompt
    echo -n $command | $slowtype
    /bin/sleep $shortpause
    echo
    # $REPLY is a magic variable set by read
    eval $command | sponge | (while read; do printf  -- "%s\n" "$REPLY"; sleep $scrolllinepause; done)
}
  
pretend_interact(){
    echo -en $1 | fold -s -w 80
    echo -n " "
    /bin/sleep $longpause
    faketype $2 
    echo 
}

banner (){
    figlet -W $1
}

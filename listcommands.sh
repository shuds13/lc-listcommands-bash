#!/bin/bash

lc_prompt='hpwd=$(history 1); 
hpwd="${hpwd# *[0-9]*  }"; 
if [[ ${hpwd%% *} == "cd" ]]; 
	then cwd=$OLDPWD; else cwd=$PWD; 
fi; 
hpwd="$cwd $hpwd";
echo "$hpwd" >> ~/.lc_history;'
if [[ -n $PROMPT_COMMAND ]]; then
  if [[ $PROMPT_COMMAND =~ \;[[:space:]]*$ ]]; then
    export PROMPT_COMMAND="$PROMPT_COMMAND$lc_prompt"
  else
    export PROMPT_COMMAND="$PROMPT_COMMAND;$lc_prompt"
  fi
else
  export PROMPT_COMMAND="$lc_prompt"
fi

function lc() {
	echo List commands run in $PWD
	rm ~/.lc_tmp
	grep $PWD" " ~/.lc_history | while read line; do echo ${line#* }; done >> ~/.lc_tmp
	awk ' !x[$0]++' ~/.lc_tmp
}

function hist() {
    # List history with directory:
    if [[ -n $1 ]]; then
      tail -n $1 ~/.lc_history
    else
      cat ~/.lc_history
    fi
}

function histfrom() {
    # More history with directory from last match of $1
    # Ignore entries which are histfrom commands themself
    # This could be improved maybe. It matches dir or command, and only allows from last
    # Good for finding commands after last login - if capture (e.g. type start when login).
    if [[ -n $1 ]]; then
      last_match=$(grep -n $1 .lc_history |grep -v "histfrom"|cut -f1 -d:|tail -n 1)
      [[ -n $last_match ]] && more +$last_match ~/.lc_history
    else
      echo Supply a string to search from.
    fi
}

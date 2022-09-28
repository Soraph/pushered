#!/bin/bash
# Author: Matteo Canu
# 2022-09-28

# Borrowed from https://github.com/fearside/ProgressBar
function ProgressBar {
	let _progress=(${1}*100/${2}*100)/100
	let _done=(${_progress}*4)/10
	let _left=40-$_done
    
	_done=$(printf "%${_done}s")
	_left=$(printf "%${_left}s")

    printf "\rWorking : [${_done// /#}${_left// /-}] ${_progress}%%"
}

source=($(git ls-files -ic --exclude-from=.gitignore))
source_to_array_of_indexes=${!source[@]}
removeable=()

for index in ${source_to_array_of_indexes}; do
    gfile=${source[index]}

    let progress_index=(${index} + 1)
    ProgressBar ${progress_index} ${#source[@]}

    if $(git ls-files --error-unmatch ${gfile} > /dev/null 2>&1); then
        removeable+=(${gfile})
    fi
done
echo -ne '\n'

if [ ${#removeable[@]} -gt 0 ]; then
    printf "%s\n" "${removeable[@]}" > pushered-files.txt

    echo "Found ${#removeable[@]} files that should not be pushed according to .gitignore"
    echo "List saved to file pushered-files.txt"
    echo "You can remove unwanted files from staging with git rm --cached"
else
    echo "Repository seems clean!"
fi

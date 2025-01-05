#!/bin/bash
actual="$(sort -R /usr/share/dict/words | grep -xEm 1 '\w{5}' | tr '[:lower:]' '[:upper:]')"
guess_count=0 max_guess=6
[[ "${1//unlimit}" != "${1:-}" ]] && max_guess=999999
while true; do
    guess_count=$(( guess_count + 1 ))
    if [[ $guess_count -le $max_guess ]]; then
        while read -r -p "Enter your guess ($guess_count / $max_guess): " guess; do
            grep -ixF "${guess:-inv.alid}" /usr/share/dict/words | grep -xqE '\w{5}' && break
            [[ ${#guess} != 5 ]] && echo "Too short/long." && continue
            echo "Not a real word."
        done
        [ ${#guess} -eq 0 ] && echo && echo "Giving up so soon?  The answer was $actual." && break
        guess="$(tr '[:lower:]' '[:upper:]' <<<"$guess")"
        output="" remaining=""
        for ((i = 0; i < ${#actual}; i++)); do
            [[ "${actual:$i:1}" != "${guess:$i:1}" ]] && remaining+=${actual:$i:1}
        done
        for ((i = 0; i < ${#actual}; i++)); do
            if [[ "${actual:$i:1}" != "${guess:$i:1}" ]]; then
                if [[ "$remaining" == *"${guess:$i:1}"* ]]; then
                    output+="$(tput setaf 0)$(tput setab 11) ${guess:$i:1} $(tput sgr0)"
                    remaining=${remaining/"${guess:$i:1}"/}
                else
                    output+="$(tput setaf 0)$(tput setab 15) ${guess:$i:1} $(tput sgr0)"
                fi
            else
                output+="$(tput setaf 0)$(tput setab 10) ${guess:$i:1} $(tput sgr0)"
            fi
        done
        echo "$output"
        [ "$actual" = "$guess" ] && echo "You guessed right!" && break
    else
        echo "You lose!  The word was $(tput setaf 1)$(tput bold)$actual$(tput sgr0)."
        break
    fi
done
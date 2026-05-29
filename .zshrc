# Path to your oh-my-zsh installation.
ZSH=/usr/share/oh-my-zsh/

# Path to powerlevel10k theme
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme

# List of plugins used
plugins=()
source $ZSH/oh-my-zsh.sh

# In case a command is not found, try to find the package that has it
function command_not_found_handler {
    local purple='\e[1;35m' bright='\e[0;1m' green='\e[1;32m' reset='\e[0m'
    printf 'zsh: command not found: %s\n' "$1"
    local entries=( ${(f)"$(/usr/bin/pacman -F --machinereadable -- "/usr/bin/$1")"} )
    if (( ${#entries[@]} )) ; then
        printf "${bright}$1${reset} may be found in the following packages:\n"
        local pkg
        for entry in "${entries[@]}" ; do
            local fields=( ${(0)entry} )
            if [[ "$pkg" != "${fields[2]}" ]] ; then
                printf "${purple}%s/${bright}%s ${green}%s${reset}\n" "${fields[1]}" "${fields[2]}" "${fields[3]}"
            fi
            printf '    /%s\n' "${fields[4]}"
            pkg="${fields[2]}"
        done
    fi
    return 127
}

# Detect the AUR wrapper
if pacman -Qi yay &>/dev/null ; then
   aurhelper="yay"
elif pacman -Qi paru &>/dev/null ; then
   aurhelper="paru"
fi

function in {
    local -a inPkg=("$@")
    local -a arch=()
    local -a aur=()

    for pkg in "${inPkg[@]}"; do
        if pacman -Si "${pkg}" &>/dev/null ; then
            arch+=("${pkg}")
        else
            aur+=("${pkg}")
        fi
    done

    if [[ ${#arch[@]} -gt 0 ]]; then
        sudo pacman -S "${arch[@]}"
    fi

    if [[ ${#aur[@]} -gt 0 ]]; then
        ${aurhelper} -S "${aur[@]}"
    fi
}

# Helpful aliases
alias  c='clear' # clear terminal
alias e='exit' # exit terminal
alias  l='eza -lh  --icons=auto' # long list
alias ls='eza -1   --icons=auto' # short list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias ld='eza -lhD --icons=auto' # long list dirs
alias lt='eza --icons=auto --tree' # list folder as tree
alias un='$aurhelper -Rns' # uninstall package
alias up='$aurhelper -Syu' # update system/package/aur
alias pl='$aurhelper -Qs' # list installed package
alias pa='$aurhelper -Ss' # list available package
alias pc='$aurhelper -Sc' # remove unused cache
alias po='$aurhelper -Qtdq | $aurhelper -Rns -' # remove unused packages, also try > $aurhelper -Qqd | $aurhelper -Rsu --print -
alias vc='code' # gui code editor

# Handy change dir shortcuts
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'
alias fastanime="viu-media --icons --preview full --selector fzf anilist"
alias vpn='sudo xvpn ui'

# Always mkdir a path (this doesn't inhibit functionality to make a single dir)
alias mkdir='mkdir -p'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#Display Pokemon

if [[ "$PWD" == "$HOME" ]]; then
    cd ~/.config
fi

neofetch

function cd() {
    builtin cd "$@"   # Use the original cd command
    if [[ -z "$INSIDE_TODO" ]]; then
        clear             # Clear the terminal
        neofetch
        ls -l -a
    fi
}

function todo() {
    local original_dir="$PWD"  # Store the current directory
    export INSIDE_TODO=1

    if [[ $1 == "add" ]]; then
        # Change to the home directory
        cd ~

        # Pull the latest changes from the remote repository
        git fetch origin
        git reset --hard origin/main

        # Add the item to the todo list
        command todo add "${@:2}"

        # Check if there are changes to commit
        if [[ $(git status --porcelain) ]]; then
            git add .todo
            git commit -m "linux add"
            git push origin main  # Change 'main' to your branch name if different
        else
            echo "No changes to commit."
        fi

        # Switch back to the original directory
        cd "$original_dir"
	todo
    elif [[ $1 == "rm" ]]; then
        # Change to the home directory
        cd ~

        # Pull the latest changes from the remote repository
        git fetch origin
        git reset --hard origin/main

        # Remove the item from the todo list
        command todo rm "${@:2}"

        # Check if there are changes to commit
        if [[ $(git status --porcelain) ]]; then
            git add .todo
            git commit -m "linux remove"
            git push origin main  # Change 'main' to your branch name if different
        else
            echo "No changes to commit."
        fi

        # Switch back to the original directory
        cd "$original_dir"
	todo
    elif [[ $1 == "done" ]]; then
        # Change to the home directory
        cd ~

        # Pull the latest changes from the remote repository
        git fetch origin
        git reset --hard origin/main

        # Mark the item as done in the todo list
        command todo done "${@:2}"

        # Check if there are changes to commit
        if [[ $(git status --porcelain) ]]; then
            git add .todo
            git commit -m "linux done"
            git push origin main  # Change 'main' to your branch name if different
        else
            echo "No changes to commit."
        fi

        # Switch back to the original directory
        cd "$original_dir"
	todo
    else
        # For other todo commands, just run them
	cd ~
	git fetch origin
        git reset --hard origin/main
	cd "$original_dir"
        command todo "$@"
    fi
    unset INSIDE_TODO
}

function songs() {
    local original_dir="$PWD" # Store the current directory

    if [[ $1 == "url" ]]; then
        cd "/home/kitty/Desktop/Audio files/"
        mkdir "${@:3}"
        cd "${@:3}"
        spotdl --user-auth --client-id ace63d40f09d49a9a1f31931c2d089ed --client-secret ee5672dd8e414e208375c04d9fe14e02 download "${@:2}" --save-file "${@:3}.spotdl" --output "{title} - {artists}"
        cd "$original_dir"
    elif [[ $1 == "liked" ]]; then
        cd "/home/kitty/Desktop/Audio files/"
        mkdir "${@:2}"
        cd "${@:2}"
        spotdl --user-auth --client-id ace63d40f09d49a9a1f31931c2d089ed --client-secret ee5672dd8e414e208375c04d9fe14e02 saved --save-file "${@:2}.spotdl" --output "{title} - {artists}"
        cd "$original_dir"
    fi
}

export PATH=/opt/cuda/bin:$PATH

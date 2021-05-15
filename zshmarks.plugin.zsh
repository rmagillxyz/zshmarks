# ------------------------------------------------------------------------------
#          FILE:  zshmarks.plugin.zsh
#        AUTHOR: Robert Magill
#        FORKED_FROM:  Jocelyn Mallon
#       VERSION:  1.7.1
#       DEPENDS: trash-cli
# ------------------------------------------------------------------------------


# dir="${foo%%|*}"
# bm="${foo##*|}"

# Set BOOKMARKS_FILE if it doesn't exist to the default.
# Allows for a user-configured BOOKMARKS_FILE.
if [[ -z $BOOKMARKS_FILE ]] ; then
		# export BOOKMARKS_FILE="$HOME/.local/share/bookmarks"
    [[ ! -d "$HOME/.config/shell" ]] && mkdir -p "$HOME/.config/shell" 
		export BOOKMARKS_FILE="$HOME/.config/shell/bookmarks"
fi

zsh_named_dirs="${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshmarks_named_dir"


# Check if $BOOKMARKS_FILE is a symlink.
	 if [[ -L $BOOKMARKS_FILE ]]; then
		BOOKMARKS_FILE=$(readlink $BOOKMARKS_FILE)
fi

# Create bookmarks_file it if it doesn't exist
if [[ ! -f $BOOKMARKS_FILE ]]; then
		touch $BOOKMARKS_FILE
fi

_zshmarks_move_bak_to_trash(){
		if [[ $(uname) == "Linux"* || $(uname) == "FreeBSD"*  ]]; then
				label=`date +%s`
				mkdir -p ~/.local/share/Trash/info ~/.local/share/Trash/files
				\mv "${BOOKMARKS_FILE}.bak" ~/.local/share/Trash/files/bookmarks-$label
				echo "[Trash Info]
				Path=/home/"$USER"/.bookmarks
				DeletionDate="`date +"%Y-%m-%dT%H:%M:%S"`"
				">~/.local/share/Trash/info/bookmarks-$label.trashinfo
		elif [[ $(uname) = "Darwin" ]]; then
				\mv "${BOOKMARKS_FILE}.bak" ~/.Trash/"bookmarks"$(date +%H-%M-%S)
		else
				\rm -f "${BOOKMARKS_FILE}.bak"
		fi
}

function bookmark() {
		local bookmark_name=$1
		if [[ -z $bookmark_name ]]; then
				bookmark_name="${PWD##*/}"
		fi
		cur_dir="$(pwd)"
		# Replace /home/uname with $HOME
		if [[ "$cur_dir" =~ ^"$HOME"(/|$) ]]; then
				cur_dir="\$HOME${cur_dir#$HOME}"
		fi
		# Store the bookmark as folder|name
		bookmark="$cur_dir|$bookmark_name"

	# TODO: this could be sped up sorting and using a search algorithm
	for line in $(cat $BOOKMARKS_FILE) 
	do

			if [[ $(echo $line |  awk -F'|' '{print $2}') == $bookmark_name ]]; then
					echo "Bookmark name already existed"
					echo "old: $line"
					echo "new: $bookmark"
					_ask_to_overwrite $bookmark_name 
					return 1

			elif [[ $(echo $line |  awk -F'|' '{print $1}') == $cur_dir  ]]; then
					echo "Bookmark dir already existed"
					echo "old: $line"
					echo "new: $bookmark"
					local bm="${line##*|}"
					_ask_to_overwrite $bm $bookmark_name 
					return 1
			fi
	done

	# no duplicates, make bookmark
	echo $bookmark >> $BOOKMARKS_FILE
	echo "Bookmark '$bookmark_name' saved"

   echo "hash -d $bookmark_name=$cur_dir" >> $zsh_named_dirs
   echo "Created named dir ~$bookmark_name"
   # source "$ZDOTDIR/.zshrc"
   source "$zsh_named_dirs"
}

__zshmarks_zgrep() {
		local outvar="$1"; shift
		local pattern="$1"
		local filename="$2"
		# echo "zshmarks/init.zsh: 94 outvar: $outvar"
		# echo "zshmarks/init.zsh: 96 pattern: $pattern"
		# echo "zshmarks/init.zsh: 98 filename: $filename"
		local file_contents="$(<"$filename")"
		# echo "zshmarks/init.zsh: 100 file_contents: $file_contents"
		local file_lines; file_lines=(${(f)file_contents})

		# echo "zshmarks/init.zsh: 101 file_lines: $file_lines"
		for line in "${file_lines[@]}"; do
				# echo "zgrep: line : $line "
				if [[ "$line" =~ "$pattern" ]]; then
						eval "$outvar=\"$line\""
						return 0
				fi
		done
		return 1
}

function jump() {
		local bookmark_name=$1
		local bookmark
		if ! __zshmarks_zgrep bookmark "\\|$bookmark_name\$" "$BOOKMARKS_FILE"; then
				echo "Invalid name, please provide a valid bookmark name. For example:"
				echo "  jump foo"
				echo
				echo "To bookmark a folder, go to the folder then do this (naming the bookmark 'foo'):"
				echo "  bookmark foo"
				return 1
		else
				# echo "zshmarks/init.zsh: 124 bookmark : $bookmark "
				local dir="${bookmark%%|*}"
				eval "cd \"${dir}\""
		fi
}

# Show a list of the bookmarks
function showmarks() {
		local bookmark_file="$(<"$BOOKMARKS_FILE")"
		local bookmark_array; bookmark_array=(${(f)bookmark_file});
		local bookmark_name bookmark_path bookmark_line
		if [[ $# -eq 1 ]]; then
				bookmark_name="*\|${1}"
				bookmark_line=${bookmark_array[(r)$bookmark_name]}
				bookmark_path="${bookmark_line%%|*}"
				bookmark_path="${bookmark_path/\$HOME/~}"
				printf "%s \n" $bookmark_path
		else
				for bookmark_line in $bookmark_array; do
						bookmark_path="${bookmark_line%%|*}"
						bookmark_path="${bookmark_path/\$HOME/~}"
						bookmark_name="${bookmark_line#*|}"
						printf "%s\t\t%s\n" "$bookmark_name" "$bookmark_path"
				done
		fi
}

# Delete a bookmark
function deletemark()  {
		local bookmark_name=$1
		if [[ -z $bookmark_name ]]; then
				printf "%s \n" "Please provide a name for your bookmark to delete. For example:"
				printf "\t%s \n" "deletemark foo"
				return 1
		else
				local bookmark_line bookmark_search
				local bookmark_file="$(<"$BOOKMARKS_FILE")"
				local bookmark_array; bookmark_array=(${(f)bookmark_file});
				bookmark_search="*\|${bookmark_name}"
				if [[ -z ${bookmark_array[(r)$bookmark_search]} ]]; then
						eval "printf '%s\n' \"'${bookmark_name}' not found, skipping.\""
				else
						\cp "${BOOKMARKS_FILE}" "${BOOKMARKS_FILE}.bak"
						bookmark_line=${bookmark_array[(r)$bookmark_search]}
						bookmark_array=(${bookmark_array[@]/$bookmark_line})
						eval "printf '%s\n' \"\${bookmark_array[@]}\"" >! $BOOKMARKS_FILE
						_zshmarks_move_bak_to_trash
            
            # generate new named dir to sync with bookmarks
            # "$HOME/.local/bin/gen_zshmarks_named_dir" 1> /dev/null
            _gen_zshmarks_named_dir 1> /dev/null
            echo "Deleted and synced named dirs"
				fi
		fi
}

_zshmarks_clear_all(){
		trash-put "$BOOKMARKS_FILE"
}


_ask_to_overwrite() {
		usage='usage: ${FUNCNAME[0]} to-overwrite <replacement>'
		[ ! $# -ge 1 ] && echo "$usage" && return 1 

		local overwrite=$1
		local replacement=$1
		[[  $# == 2 ]] && replacement=$2
		echo "overwrite: $overwrite"
		echo "replacement: $replacement"

		echo -n "overwrite mark $1 (y/n)? "
		read answer
		if  [ "$answer" != "${answer#[Yy]}" ];then 
				deletemark $1
				bookmark $2
		else
				return 1
		fi
}

_gen_zshmarks_named_dir(){

   trash-put $zsh_named_dirs

   while read line
   do
      # echo "bin/named_dir_mark_shortcuts: 14 line: $line"
      dir="${line%%|*}"
      # echo "bin/named_dir_mark_shortcuts: 18 dir: $dir"
      bm="${line##*|}"
      # echo "bin/named_dir_mark_shortcuts: 20 bm: $bm"
      echo "~$bm"
      echo "hash -d $bm=$dir" >> $zsh_named_dirs

   done < "$BOOKMARKS_FILE"

}

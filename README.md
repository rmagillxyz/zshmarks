zmarks
========
## Directory and file bookmarks for zsh with completions

A fork of [Zshmarks (by Jocelyn Mallon)](https://github.com/jocelynmallon/zshmarks) (Thanks Jocelyn!)
 
## How to install
--------------
##### required dependency: [fzf](https://github.com/junegunn/fzf#installation)

##### Ensure `$ZDOTDIR` environment variable is set.

###### clone repo:
```
	git clone http://github.com/rmagillxyz/zmarks $ZDOTDIR/zmarks
```

###### source repo in `$ZDOTDIR/.zshrc`: 
** Must be sourced before  `autoload -U compinit; compinit` **
```
source "$ZDOTDIR/zmarks/init.zsh"
```


Zmarks only works with zsh and neovim or vim. If you have neovim installed, it will set your EDITOR environment variable to neovim. If you prefer vim, make sure `$EDITOR` env variable is set to `vim`:

`export EDITOR="vim"`

Usage
--------------
```
zm <OPTION> <MARK> [PATH|PATTERN]
  -D, --mark-dir <MARK> [PATH] 			Mark directory. Will use current 
						directory name if not specified. 
  -d, --dir-jump <MARK> 			Jump to directory mark. 
  -F, --mark-file <MARK> [PATH]			Mark file. Will use fzf to select
						from files if pattern not specified.  
  -f, --file-jump <MARK> [PATTERN] 		Jump to file mark and search for
						optional pattern. 
  -j, --jump <MARK> [PATTERN]			Jump to directory or jump into file.
						Marked files accept a search pattern.
  -s, --show [PATTERN] 				Show Marks. 
  --clear-all 					Clear all directory and file marks.
  --clear-all-dirs 				Clear all directory marks.
  --clear-all-files 				Clear all file marks.
  -h, --help 					Show this message.
```
Examples
--------------
#### Set directory mark name `z` to `$ZDOTDIR` directory:

`zm -D z $ZDOTDIR`	               

#### Jump to dir mark `z`:

`zm -j z`

#### Set file mark name `_rc` to .zshrc file:
While inside $ZDOTDIR
`zm -F _rc`

and then, select `.zshrc` or any other file with fuzzy selector.
The fuzzy selector will search 3 directories deep from cwd by default, but this can be changed.

##### Jump into `_rc` mark and search for pattern `PATTERN`:
`zm -j _rc PATTERN`

#### Setting directories also works using current working directory and the basename
```
cd ~/.config/nvim
zm -D
```

#### Marking files will also accept a path

`zm -F init ~/.config/nvim/init.lua`

#### Remove a mark:
`zm -r init`

#### Show all marks:
`zm -s`

#### Show marks starting with `z`:
`zm -s z`

##### Tab completion shows all marks for above commands, but to show and jump to only directories use:
`zm -d <TAB>`

##### or using only files
`zm -f <TAB>`

#### Named Hash Table
Each time you create a mark, a named hash is created. 

This allows you to use your marks via tilda+mark. 

If you have a directory mark named `foo`, then you can use like such from anywhere:

`ls ~foo`

`mv bar ~foo`

This is generally used for directories, but named hashes are also created for files:  

`echo 'alias now="date +%T"' >> ~zali` 

`cat ~zali | tail`

I find named hashes especially useful in aliases or shell functions.

And by sourcing  `$ZM_NAMED_DIRS` or `$ZM_NAMED_FILES` in a script, marks can also be used there. Only works in zsh not bash. 

```
#!/bin/zsh

source "$ZM_NAMED_DIRS" 
source "$ZM_NAMED_FILES" 

cd ~mydir
echo 'foo bar' >>  ~myfile
```

FZF bindings: 
------------
```
_fzf_zm_jump #(directories and files)
_fzf_zm_dir_jump
_fzf_zm_file_jump
_zm_quick_man
```
##### zsh bindings, just add these lines to a file sourced by zsh:
```
bindkey '\ej' _zm_fuzzy_jump
bindkey '\ef' _zm_fuzzy_file_jump
bindkey '\ed' _zm_fuzzy_dir_jump
bindkey '^k' _zm_quick_man
```
*\e* is alt, `^` is control. Change to what works for you. 

`_zm_quick_man` allows you to jump to the man page of the first command on the command line while in the middle of a line without losing or having to save the line. 

`echo "foo bar"`  (without entering)
	
Use the _zm_quick_man binding, now you're in the echo man page, quit and you have your line back how you left it. 

Additional/functions:
-------------------
* `_zm_jump_n_source`   jump to zsh file mark and source it on exit
 
	`zm -F zali $ZDOTDIR/aliases`

	`alias jali='_zm_jump_n_source zali'`

	`jali [PATTERN]`

* If you find yourself jumping to files and moving to a specific spot in the file, you can automattically jump to that spot by adding `__zm_zoom__` to a comment and it will jump to that comment upon opening if pattern option is not supplied.

* You can use `zm -i <CMD> [PATTERN] ` to jump into a script in your `PATH` and search for pattern:  

	`zm -i fzf-tmux opt` 

Notes/Tips:
-----------
Directory and files are saved in separate files, but the mark names cannot clash. I recommend using your own convention to keep dirs and files separate so you can use the combined jump feature more efficiently. i.e. Start each file mark with an underscore or specific letter. All mark names must contain only alphanumerics or underscores. Mark paths can contain alphanumerics, underscores or dashes, but no spaces or escaped characters. 

Optional environment variables 
-----------------------------
Change the location of the zmark files (default: $HOME/.local/share/zsh/zmarks). 

`export ZMARKS_DIR="/some/other/path"`
				
Change the (default: `__zm_zoom__`) default search pattern for file jumps.

`export _ZM_ZOOM_MARK="__jump_here__"`

Change the fuzzy selector (default: `fzf`).

`export FUZZY_CMD='fzy'`
or 
`export FUZZY_CMD='fzf-tmux'`

Change the mark file fuzzy selector search depth (default: 3):

`export _ZM_MARK_FILE_SEARCH_DEPTH=1`

Obviously you can shorten the commands up even more by adding aliases:

```
alias \
	 zf='zm -F' \
	 zd='zm -D' \
	 zs='zm -s' \
	 zr='zm -r' \
	 j='zm -j' \
	 jf='zm -f' \
	 jd='zm -d' \
	 zi='zi -i' 
```
Contributions welcome and please report any bugs. 
=================

Plugin Managers
-------------------
If you use a plugin manager, you can try these I got from [Jocelyn](https://github.com/jocelynmallon/zshmarks) and modified for this repo. The format has not changed much and should work, but have not tried. Let me know if it works!

oh-my-zsh
---------
* Download the script or clone this repository in [oh-my-zsh](http://github.com/robbyrussell/oh-my-zsh) plugins directory:

        cd ~/.oh-my-zsh/custom/plugins
        git clone https://github.com/rmagillxyz/zmarks.git

* Activate the plugin in `~/.zshrc`:

        plugins=( [plugins...] zmarks [plugins...])

* Source `~/.zshrc`  to take changes into account:

        source ~/.zshrc

antigen
-------
Add `antigen bundle rmagillxyz/zmarks` to your .zshrc where you're adding your other plugins. Antigen will clone the plugin for you and add it to your antigen setup the next time you start a new shell.

prezto
------
For most people the easiest way to use zmarks with [prezto](https://github.com/sorin-ionescu/prezto) is to manually clone the zmarks repo to a directory of your choice (e.g. /usr/local or ~/bin) and symlink the zmarks folder into your zpretzo/modules folder:

        ln -s ~/bin/zmarks ~/.zprezto/modules/zmarks

Alternatively, you can add the zmarks repository as a submodule to your prezto repo by manually editing the '.gitmodules' file:

        [submodule "modules/zmarks"]
        	path = modules/zmarks
        	url = https://github.com/rmagillxyz/zmarks.git

Then make sure you activate the plugin in your .zpreztorc file:

        zstyle ':prezto:load' pmodule \
        zmarks \
        ...

zplug
-----
Add the following to your .zshrc file somewhere after you source zplug.

        zplug "rmagillxyz/zmarks"



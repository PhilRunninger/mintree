# MinTree

A minimalist version of [NERDTree](https://github.com/scrooloose/nerdtree). How much of NERDTree can I replicate with the fewest lines of code while, at the same time, doing it faster? This project is my answer to that question.

## Installation

Use your favorite plugin manager to install this plugin. My personal favorite is [vim-plug](https://github.com/junegunn/vim-plug). In your **`.vimrc`**, add the following line.
```vim
Plug 'git@github.com:PhilRunninger/mintree.git'
```

[Vundle](https://github.com/VundleVim/Vundle.vim), [pathogen](https://github.com/tpope/vim-pathogen), and others should also work as easily. Just follow the convention set up by the plugin manager of your choice.

## Commands

The only command is **`:MinTree [path]`**. This command opens a buffer with the name **`=MinTree=`** in the current window, and shows a tree of either the path given or the current working directory.

The command can be assigned to a key, and this assignment is left to the user, so as not to interfere with any existing mappings. For example,
```
nnoremap <leader>o :MinTree<CR>
```

## Key Mappings

The following key mappings are used only within the **`=MinTree=`** buffer. They are configurable by setting the corresponding global variables.

Default Key | Variable                   | Function
---         | ---                        | ---
**`o`**     | `g:MinTreeOpen`            | Open the selected file in the current window, or expand/close the directory.
**`O`**     | `g:MinTreeOpenRecursively` | Fully expand the tree under the cursor.
**`s`**     | `g:MinTreeOpenSplit`       | Split the window horizontally, and open the selected file there.
**`v`**     | `g:MinTreeOpenVSplit`      | Split the window vertically, and open the selected file there.
**`t`**     | `g:MinTreeOpenTab`         | Open the selected file in a new tab.
**`p`**     | `g:MinTreeGoToParent`      | Navigate quickly to the next closest parent folder.
**`u`**     | `g:MinTreeSetRootUp`       | Change the root of the tree to the parent directory of the current root.
**`C`**     | `g:MinTreeSetRoot`         | Change the root of the tree to the directory under the cursor.
**`x`**     | `g:MinTreeCloseParent`     | Close the directory containing the current file or directory.
**`q`**     | `g:MinTreeExit`            | Exit the MinTree, and return to the previous buffer.
**`?`**     |                            | Display short descriptions of these commands.

# MinTree

A minimalist version of [NERDTree](https://github.com/scrooloose/nerdtree). How much of NERDTree can I replicate with the fewest lines of code while, at the same time, doing it faster? This project is my answer to that question.

## Prerequisite

MinTree requires Vim version 8.0+, and it must be compiled with the `folding`, `conceal`, and `lambda` features turned on. Make sure you see `+folding`, `+conceal`, and `+lambda` in the output of `:version` or `vim --version`.

## Installation

Use your favorite plugin manager to install this plugin. If you have no favorite, I recommend [vim-plug](https://github.com/junegunn/vim-plug). In your **`.vimrc`**, add the following line.

```vim
Plug 'git@github.com:PhilRunninger/mintree.git'
```

[Vundle](https://github.com/VundleVim/Vundle.vim), [pathogen](https://github.com/tpope/vim-pathogen), and others should also work as easily. Just follow the convention set up by the plugin manager of your choice.

## Commands

### **`:MinTree [path]`**
This command opens a buffer with the name **`=MinTree=`** in the current window, and shows a tree of either the path given or the current working directory.

### **`:MinTreeFind [path]`**
This command searches the **`=MinTree=`** buffer for the given path. If no path was given, it looks for the current buffer. If not found in the current tree, a new one is created to show the file being sought.

The commands can be assigned to a key, and these assignments are left to the user, so as not to interfere with any existing mappings. For example,

```vim
nnoremap <leader>o :MinTree<CR>
nnoremap <leader>f :MinTreeFind<CR>
```

## Key Bindings

The following key bindings are used only within the **`=MinTree=`** buffer. They are configurable by setting the corresponding global variables.

Default Key | Variable                   | Function
---         | ---                        | ---
**`o`**     | `g:MinTreeOpen`            | Open the selected file in the current window, or expand/close the directory.
**`O`**     | `g:MinTreeOpenRecursively` | Fully expand the tree under the cursor.
**`s`**     | `g:MinTreeOpenSplit`       | Split the window horizontally, and open the selected file there.
**`v`**     | `g:MinTreeOpenVSplit`      | Split the window vertically, and open the selected file there.
**`t`**     | `g:MinTreeOpenTab`         | Open the selected file in a new tab.
**`p`**     | `g:MinTreeGoToParent`      | Navigate quickly to the next closest parent directory.
**`J`**     | `g:MinTreeLastSibling`     | Navigate quickly to the last sibling file or directory.
**`K`**     | `g:MinTreeFirstSibling`    | Navigate quickly to the first sibling file or directory.
**`<C-J>`** | `g:MinTreeNextSibling`     | Navigate quickly to the next sibling file or directory.
**`<C-K>`** | `g:MinTreePrevSibling`     | Navigate quickly to the previous sibling file or directory.
**`u`**     | `g:MinTreeSetRootUp`       | Change the root of the tree to the parent directory of the current root.
**`C`**     | `g:MinTreeSetRoot`         | Change the root of the tree to the directory under the cursor.
**`x`**     | `g:MinTreeCloseParent`     | Close the directory containing the current file or directory.
**`r`**     | `g:MinTreeRefresh`         | Refresh the directory under the cursor, or the directory containing the file under the cursor.
**`R`**     | `g:MinTreeRefreshRoot`     | Refresh the whole tree.
**`I`**     | `g:MinTreeToggleHidden`    | Toggles the display of hidden files, those starting with a period, or marked hidden in Windows.
**`m`**     | `g:MinTreeCreateMark`      | Creates a single-letter bookmark for the current node.
**`'`**     | `g:MinTreeGotoMark`        | Displays all bookmarks, and opens the one selected.
**`dm`**    | `g:MinTreeCreateMark`      | Displays all bookmarks, and deletes the ones selected. This is the same variable used for creating bookmarks, but prefixed with a `d`.
**`q`**     | `g:MinTreeExit`            | Exit the MinTree, and return to the previous buffer.

## Settings

* The following variables define the OS commands that gather files and directories. If necessary, you can customize them for your unique situation.

    Variable | Default
    --- | ---
    **`g:MinTreeDirAll`**<br>returns all files/dirs in the `%s` directory. | Windows: `dir /b %s`<br>others: `ls -A %s \| sort -f`
    **`g:MinTreeDirNoHidden`**<br>returns all non hidden files/dirs in the `%s` directory. | Windows: `dir /b /a:-h %s \| findstr -v "^\."`<br>others: `ls %s \| sort -f`
    **`g:MinTreeShowHidden`**<br>sets which of the above two commands to use by default. | 0

* The characters used to indicate whether a directory is collapsed or expanded can be customized with these two variables

    Variable | Default
    --- | ---
    **`g:MinTreeExpanded`**<br>Character used to indicate a directory's contents are being shown. | `▾`
    **`g:MinTreeCollapsed`**<br>Character used to indicate a directory's contents are hidden or not yet retrieved. | `▸`

* To change the indentation level, change the value of **`g:MinTreeIndentSize`**. It is the number of spaces to use for each level of indentation, and its default value is `2`.

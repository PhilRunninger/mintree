# MinTree

MinTree is a minimalist tree-based file explorer. It initially was a proof of concept to solve [NERDTree](https://github.com/scrooloose/nerdtree)'s performance issues with very large directories. It was very successful in that effort, and has grown in its functionality since. It was never intended to be, and will never be, a feature-for-feature replacement of NERDTree. A lot of features overlap, but each will have its own unique set of capabilities.

## Prerequisite

MinTree requires Vim version 8.0+, and it must be compiled with the `folding`, `conceal`, and `lambda` features turned on. Make sure you see `+folding`, `+conceal`, and `+lambda` in the output of `:version` or `vim --version`.

## Installation

Use your favorite plugin manager to install this plugin. [vim-pathogen](https://github.com/tpope/vim-pathogen), [Vundle.vim](https://github.com/VundleVim/Vundle.vim), [vim-plug](https://github.com/junegunn/vim-plug), [neobundle.vim](https://github.com/Shougo/neobundle.vim), and [dein.vim](https://github.com/Shougo/dein.vim) are some of the more popular ones. A lengthy discussion of these and other managers can be found on [vi.stackexchange.com](https://vi.stackexchange.com/questions/388/what-is-the-difference-between-the-vim-plugin-managers).

If you have no favorite, or want to manage your plugins without 3rd-party dependencies, I recommend using Vim 8 packages, as described in Greg Hurrell's excellent Youtube video: [Vim screencast #75: Plugin managers](https://www.youtube.com/watch?v=X2_R3uxDN6g)

## Commands

### `:MinTree [path]`
This command opens a buffer with the name **`=MinTree=`** in the current window, and shows a tree of either the path given or the current working directory.

### `:MinTreeFind [path]`
This command searches the **`=MinTree=`** buffer for the given path. If no path was given, it looks for the current buffer. If not found in the current tree, a new one is created to show the file being sought.

The commands can be assigned to a key, and these assignments are left to the user, so as not to interfere with any existing mappings. For example,

```vim
nnoremap <leader>o :MinTree<CR>
nnoremap <leader>f :MinTreeFind<CR>
```

To split the window first, mappings like these can be used:

```vim
nnoremap <leader>vo :vsplit<Bar>wincmd H<Bar>MinTree<CR>
nnoremap <leader>ho :split<Bar>wincmd J<Bar>MinTree<CR>
```

## Key Bindings

The following, configurable key bindings are used only within the **`=MinTree=`** buffer. The lists below show the default key bindings, a description of the action each key performs, and the corresponding global variable.

#### Opening/Closing Buffers
**`o`** ⮕ Open the selected file in the current window, or expand or collapse the directory. (`g:MinTreeOpen`)
<br>**`O`** ⮕ Fully expand the selected directory. (`g:MinTreeOpenRecursively`)
<br>**`s`** ⮕ Split the window horizontally, and open the selected file there. (`g:MinTreeOpenSplit`)
<br>**`v`** ⮕ Split the window vertically, and open the selected file there. (`g:MinTreeOpenVSplit`)
<br>**`t`** ⮕ Open the selected file in a new tab. (`g:MinTreeOpenTab`)
<br>**`w`** ⮕ Close the buffer associated with the selected node. (`g:MinTreeWipeout`)
#### Navigating the Tree
**`p`** ⮕ Navigate quickly to the closest parent directory. (`g:MinTreeGoToParent`)
<br>**`J`** ⮕ Navigate quickly to the last sibling file or directory. (`g:MinTreeLastSibling`)
<br>**`K`** ⮕ Navigate quickly to the first sibling file or directory. (`g:MinTreeFirstSibling`)
<br>**`<C-J>`** ⮕ Navigate quickly to the next sibling file or directory. (`g:MinTreeNextSibling`)
<br>**`<C-K>`** ⮕ Navigate quickly to the previous sibling file or directory. (`g:MinTreePrevSibling`)
#### Updating the Tree
**`u`** ⮕ Change the root of the tree to the parent directory of the current root. (`g:MinTreeSetRootUp`)
<br>**`C`** ⮕ Change the root of the tree to the directory under the cursor. (`g:MinTreeSetRoot`)
<br>**`x`** ⮕ Collapse the directory containing the current file or directory. (`g:MinTreeCloseParent`)
<br>**`r`** ⮕ Refresh the selected directory or the directory containing the selected file. (`g:MinTreeRefresh`)
<br>**`R`** ⮕ Refresh the whole tree. (`g:MinTreeRefreshRoot`)
<br>**`I`** ⮕ Toggles hidden files and directories, those starting with a period. (`g:MinTreeToggleHidden`)
<br>**`F`** ⮕ Toggles files, leaving only directories showing. (`g:MinTreeToggleFiles`)
#### Bookmarks
**`m`** ⮕ Creates a single-letter bookmark for the current node. (`g:MinTreeCreateMark`)
<br>**`'`** ⮕ Displays all bookmarks, and opens the one selected. (`g:MinTreeGotoMark`)
<br>**`dm`** ⮕ Displays all bookmarks, and deletes the ones selected. This is the same key used for creating bookmarks, but prefixed with a `d`. (`g:MinTreeCreateMark`)
#### Miscellaneous
**`cd`** ⮕ Change the current working directory to that of the selected node. (`g:MinTreeSetCWD`)
<br>**`q`** ⮕ Exit the MinTree, and return to the previous buffer. (`g:MinTreeExit`)
<br>**`?`** ⮕ Display short descriptions of these commands.

## Settings

* The following variables govern which nodes MinTree shows or hides. **Note:** MinTree will always respect the `'wildignore'` setting. Any file or directory that matches one of its patterns be excluded from the tree.

    Variable | Default
    --- | ---
    **`g:MinTreeShowHidden`**<br>show hidden files or directories (those that begin with a period) | `0`<br>keep them hidden
    **`g:MinTreeShowFiles`**<br>show or hide all files | `1`<br>show both files and directories

* The characters used to indicate whether a directory is collapsed or expanded can be customized with these two variables

    Variable | Default
    --- | ---
    **`g:MinTreeExpanded`**<br>Character used to indicate a directory's contents are being shown. | `▾`
    **`g:MinTreeCollapsed`**<br>Character used to indicate a directory's contents are hidden or not yet retrieved. | `▸`

* To change the indentation level, change the value of **`g:MinTreeIndentSize`**. It is the number of spaces to use for each level of indentation, and its default value is `2`.

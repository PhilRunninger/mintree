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
nnoremap <silent> <leader>vo <Cmd>leftabove vsplit<Bar>MinTree<CR>
nnoremap <silent> <leader>ho <Cmd>leftabove split<Bar>MinTree<CR>
```

## Key Bindings

The following, configurable key bindings are used only within the **`=MinTree=`** buffer. The lists below show the default key bindings, a description of the action each key performs, and the corresponding global variable.

#### Opening/Closing Files
<kbd>o</kbd> → Open the selected file in the current window. (`g:MinTreeOpen`)
<br><kbd>s</kbd> → Split the window horizontally, and open the selected file there. (`g:MinTreeOpenSplit`)
<br><kbd>v</kbd> → Split the window vertically, and open the selected file there. (`g:MinTreeOpenVSplit`)
<br><kbd>t</kbd> → Open the selected file in a new tab. (`g:MinTreeOpenTab`)
<br><kbd>w</kbd> → Close the buffer associated with the selected node. (`g:MinTreeWipeout`)
#### Opening/Closing Directories
<kbd>o</kbd> → Expand the selected directory. (`g:MinTreeOpen`)
<br><kbd>O</kbd> → Recursively expand the selected directory. (`g:MinTreeOpenRecursively`)
<br><kbd>x</kbd> → Collapse the current of containing directory. (`g:MinTreeCloseParent`)
#### Navigating the Tree
<kbd>p</kbd> → Navigate quickly to the closest parent directory. (`g:MinTreeGoToParent`)
<br><kbd>J</kbd> → Navigate quickly to the last sibling file or directory. (`g:MinTreeLastSibling`)
<br><kbd>K</kbd> → Navigate quickly to the first sibling file or directory. (`g:MinTreeFirstSibling`)
<br><kbd>Ctrl+J</kbd> → Navigate quickly to the next sibling file or directory. (`g:MinTreeNextSibling`)
<br><kbd>Ctrl+K</kbd> → Navigate quickly to the previous sibling file or directory. (`g:MinTreePrevSibling`)
<br><kbd>f</kbd> → Find next node starting with `<char>`. (`g:MinTreeFindCharNext`)
<br><kbd>F</kbd> → Find previous node starting with `<char>`. (`g:MinTreeFindCharPrev`)
#### Updating the Tree
<kbd>C</kbd> → Change the root of the tree to be the directory under the cursor. (`g:MinTreeSetRoot`)
<br><kbd>r</kbd> → Refresh the selected directory or the directory containing the selected file. (`g:MinTreeRefresh`)
<br><kbd>R</kbd> → Refresh the whole tree. (`g:MinTreeRefreshRoot`)
<br><kbd>I</kbd> → Toggles hidden files and directories, those starting with a period. (`g:MinTreeToggleHidden`)
#### Bookmarks
<kbd>m</kbd> → Creates a single-letter bookmark for the current node. (`g:MinTreeCreateMark`)
<br><kbd>'</kbd> → Displays all bookmarks, and opens the one selected. (`g:MinTreeGotoMark`)
<br><kbd>dm</kbd> → Displays all bookmarks, and deletes the ones selected. (`g:MinTreeCreateMark`, prefixed by <kbd>d</kbd>)
#### Miscellaneous
<kbd>cd</kbd> → Change the current working directory to that of the selected node. (`g:MinTreeSetCWD`)
<br><kbd>q</kbd> → Exit the MinTree, and return to the previous buffer. (`g:MinTreeExit`)
<br><kbd>?</kbd> → Display short descriptions of these commands.

## Settings

* This variable governs which nodes MinTree shows or hides. **Note:** MinTree will always respect the `'wildignore'` setting. Any file or directory that matches one of its patterns will be excluded from the tree.

    Variable | Default
    --- | ---
    **`g:MinTreeShowHidden`**<br>show hidden files or directories (those that begin with a period) | `0`<br>keep them hidden

* The characters used to indicate whether a directory is collapsed or expanded can be customized with these two variables

    Variable | Default
    --- | ---
    **`g:MinTreeExpanded`**<br>Character used to indicate a directory's contents are being shown. | `▾`
    **`g:MinTreeCollapsed`**<br>Character used to indicate a directory's contents are hidden or not yet retrieved. | `▸`

* To change the indentation level, change the value of **`g:MinTreeIndentSize`**. It is the number of spaces to use for each level of indentation, and its default value is `2`.

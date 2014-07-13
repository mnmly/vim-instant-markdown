vim-instant-preview
====================

Heavily based on [vim-instant-markdown](https://github.com/suan/vim-instant-markdown)
This plugin works only when you run [instant-preview-server](https://github.com/mnmly/instant-preview-server)

Installation
------------
- Use pathogen (e.g `git submodule add https://github.com/mnmly/vim-instant-preview.git bundle/vim-instant-preview`)
- Ensure you have the line `filetype plugin on` in your `.vimrc`
- Open a javascript / css file and enjoy.

Configuration
-------------
### g:instant_preview_slow

By default, vim-instant-preview will update the display in realtime.  If that taxes your system too much, you can specify

```
let g:instant_preview_slow = 1
```

before loading the plugin (for example place that in your `~/.vimrc`). This will cause vim-instant-preview to only refresh on the following events:

- No keys have been pressed for a while
- A while after you leave insert mode
- You save the file being edited

### g:instant_preview_autostart
By default, vim-instant-preview will automatically launch the preview window when you open a preview file. If you want to manually control this behavior, you can specify

```
let g:instant_preview_autostart = 0
```

in your .vimrc. You can then manually trigger preview via the command ```:InstantMarkdownPreview```. This command is only available inside preview buffers and when the autostart option is turned off.

Supported Platforms
-------------------
OSX and Unix/Linuxes*.

etc.
---
If you're curious, the code for the mini-server component for this plugin can be found at http://github.com/mnmly/instant-preview-server. A plugin can easily be written for any editor to interface with the server to get the same functionality found here.

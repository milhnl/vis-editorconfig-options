# vis-editorconfig-options - .editorconfig support for vis

A plugin for [vis](https://github.com/martanne/vis) to read `.editorconfig`
files and set `vis.win.options`.

### Installation

Clone this repository to where you install your plugins. (If this is your first
plugin, running `git clone https://github.com/milhnl/vis-editorconfig-options`
in `~/.config/vis/` will probably work).

Then, add `require('vis-editorconfig-options')` to your `visrc`.

#### Note on vis versions before 0.9

This plugin uses the `options` table, introduced in version 0.9. This version
has been released, but your distribution may not have the package yet. In that
case, you will also need
[vis-options-backport](https://github.com/milhnl/vis-options-backport). This
will 'polyfill' the `options` table for older versions.

### Usage

Nothing. The plugin will find `.editorconfig` files and set the
`win.options.expandtab`, `win.options.tabwidth` and `win.options.colorcolumn`
settings in the editor. It reads `indent_style`, `indent_size`, `tab_width`,
and `max_line_length` for this. All other properties are silently ignored.

### Alternatives

There is also
[vis-editorconfig](https://github.com/seifferth/vis-editorconfig), which also
supports editorconfig properties that do not map neatly to vis options, and
requires a platform-dependent library for parsing the editorconfig files.

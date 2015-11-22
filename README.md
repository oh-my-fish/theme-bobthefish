# bobthefish

`bobthefish` is a Powerline-style, Git-aware [fish][fish] theme optimized for awesome.

[![](https://img.shields.io/badge/Framework-Oh My Fish-blue.svg?style=flat)](https://github.com/oh-my-fish/oh-my-fish) ![](https://img.shields.io/cocoapods/l/AFNetworking.svg) [![Join the chat at https://gitter.im/oh-my-fish/oh-my-fish](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/oh-my-fish/oh-my-fish?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

![bobthefish][screenshot]

### Installation

Be sure to have Oh My Fish installed. Then just:

    omf install bobthefish

You will probably need a [Powerline-patched font][patching] for this to work.
[I recommend picking one of these][fonts].

This theme is based loosely on [agnoster][agnoster].

### Features

 * A helpful, but not too distracting, greeting.
 * A subtle timestamp hanging out off to the right.
 * Powerline-style visual hotness.
 * More colors than you know what to do with.
 * An abbreviated path which doesn't abbreviate the name of the current project.
 * All the things you need to know about Git in a glance.
 * Visual indication that you can't write to the current directory.

### The Prompt

 * Flags:
     * Previous command failed (**`!`**)
     * Background jobs (**`%`**)
     * You currently have superpowers (**`$`**)
 * Current vi mode
     * _You'll need to `set -g theme_display_vi yes` to enable_
 * `User@Host` (unless you're the default user)
 * Current RVM or rbenv (Ruby) version
 * Current virtualenv (Python) version
     * _If you use virtualenv, you will probably need to disable the default virtualenv prompt, since it doesn't play nice with fish: `set -x VIRTUAL_ENV_DISABLE_PROMPT 1`_
 * Abbreviated parent directory
 * Current directory, or Git or Mercurial project name
 * Current project's repo branch (<img width="16" alt="branch-glyph" src="https://cloud.githubusercontent.com/assets/53660/8768360/53ee9b58-2e32-11e5-9977-cee0063936fa.png"> master) or detached head (`➦` d0dfd9b)
 * Git or Mercurial status, via colors and flags:
     * Dirty working directory (**`*`**)
     * Untracked files (**`…`**)
     * Staged changes (**`~`**)
     * Stashed changes (**`$`**)
     * Unpulled commits (**`-`**)
     * Unpushed commits (**`+`**)
     * Unpulled _and_ unpushed commits (**`±`**)
     * _Note that not all of these have been implemented for hg yet :)_
 * Abbreviated project-relative path

### Configuration

You can override some of the following default options in your `config.fish`:

```fish
set -g theme_display_git no
set -g theme_display_git_untracked no
set -g theme_display_git_ahead_verbose yes
set -g theme_display_hg yes
set -g theme_display_virtualenv no
set -g theme_display_ruby no
set -g theme_display_user yes
set -g theme_display_vi yes
set -g theme_display_vi_hide_mode default
set -g theme_title_display_process yes
set -g theme_title_display_path no
set -g theme_title_use_abbreviated_path no
set -g theme_date_format "+%a %H:%M"
set -g theme_avoid_ambiguous_glyphs yes
set -g default_user your_normal_user
```

**Title options**

- `theme_title_display_process`. By default theme doesn't show current process name in terminal title. If you want to show it, just set to `yes`.
- `theme_title_display_path`. Use `no` to hide current working directory from title.
- `theme_title_use_abbreviated_path`. Default is `yes`. This means your home directory will be displayed as `~` and `/usr/local` as `/u/local`. Set it to `no` if you prefer full paths in title.

**Prompt options**
- `theme_display_ruby`. Use `no` to completely hide all information about Ruby version. By default Ruby version displayed if there is the difference from default settings.

[fish]:       https://github.com/fish-shell/fish-shell
[screenshot]: http://i.0x7f.us/bobthefish.png
[patching]:   https://powerline.readthedocs.org/en/latest/fontpatching.html
[fonts]:      https://github.com/Lokaltog/powerline-fonts
[agnoster]:   https://gist.github.com/agnoster/3712874

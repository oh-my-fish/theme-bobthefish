# bobthefish

`bobthefish` is a Powerline-style, Git-aware [fish][fish] theme optimized for awesome.

[![Oh My Fish](https://img.shields.io/badge/Framework-Oh_My_Fish-blue.svg?style=flat)](https://github.com/oh-my-fish/oh-my-fish) [![MIT License](https://img.shields.io/github/license/oh-my-fish/theme-bobthefish.svg?style=flat)](/LICENSE.md) [![Slack Status](https://oh-my-fish-slack.herokuapp.com/badge.svg)](https://oh-my-fish-slack.herokuapp.com)

![bobthefish][screencast]

### Installation

Be sure to have Oh My Fish installed. Then just:

    omf install bobthefish

You will need a [Powerline-patched font][patching] for this to work, unless you enable the compatibility fallback option:

    set -g theme_powerline_fonts no

[I recommend picking one of these][fonts]. For more advanced awesome, install a [nerd fonts patched font][nerd-fonts], and enable nerd fonts support:

    set -g theme_nerd_fonts yes

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
 * Current RVM, rbenv or chruby (Ruby) version
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
set -g theme_git_worktree_support yes
set -g theme_display_vagrant yes
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
set -g theme_powerline_fonts no
set -g theme_nerd_fonts yes
set -g theme_show_exit_status yes
set -g default_user your_normal_user
```

**Title options**

- `theme_title_display_process`. By default theme doesn't show current process name in terminal title. If you want to show it, just set to `yes`.
- `theme_title_display_path`. Use `no` to hide current working directory from title.
- `theme_title_use_abbreviated_path`. Default is `yes`. This means your home directory will be displayed as `~` and `/usr/local` as `/u/local`. Set it to `no` if you prefer full paths in title.

**Prompt options**
- `theme_display_ruby`. Use `no` to completely hide all information about Ruby version. By default Ruby version displayed if there is the difference from default settings.
- `theme_display_vagrant`. This feature is disabled by default, use `yes` to display Vagrant status in your prompt. Please note that only the VirtualBox and VMWare providers are supported.
- `theme_show_exit_status`. Set this option to yes to have the prompt show the last exit code if it was non_zero instead of just the exclamation mark.
- `theme_git_worktree_support`. If you do any git worktree shenanigans, setting this to `yes` will fix incorrect project-relative path display. If you don't do any git worktree shenanigans, leave it disabled. It's faster this way :)

[fish]:       https://github.com/fish-shell/fish-shell
[screencast]: https://cloud.githubusercontent.com/assets/53660/15454890/5649a9a6-1ff9-11e6-9bab-ac1f9278f0cb.gif
[patching]:   https://powerline.readthedocs.org/en/master/installation.html#patched-fonts
[fonts]:      https://github.com/Lokaltog/powerline-fonts
[nerd-fonts]: https://github.com/ryanoasis/nerd-fonts
[agnoster]:   https://gist.github.com/agnoster/3712874

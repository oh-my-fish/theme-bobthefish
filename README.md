# bobthefish

`bobthefish` is a Powerline-style, Git-aware [fish][btf-fish] theme optimized for awesome.

[![Oh My Fish](https://img.shields.io/badge/Framework-Oh_My_Fish-blue.svg?style=flat)](https://github.com/oh-my-fish/oh-my-fish) [![MIT License](https://img.shields.io/github/license/oh-my-fish/theme-bobthefish.svg?style=flat)](/LICENSE.md)

![bobthefish][btf-screencast]



## Installation

Be sure to have Oh My Fish installed. Then just:

    omf install bobthefish

You will need a [Powerline-patched font][btf-patching] for this to work, unless you enable the compatibility fallback option:

    set -g theme_powerline_fonts no

[I recommend picking one of these][btf-fonts]. For more advanced awesome, install a [nerd fonts patched font][btf-nerd-fonts], and enable nerd fonts support:

    set -g theme_nerd_fonts yes

This theme is based loosely on [agnoster][btf-agnoster].



## Features

 * A helpful, but not too distracting, greeting.
 * A subtle timestamp hanging out off to the right.
 * Powerline-style visual hotness.
 * More colors than you know what to do with.
 * An abbreviated path which doesn't abbreviate the name of the current project.
 * All the things you need to know about Git in a glance.
 * Visual indication that you can't write to the current directory.



## The Prompt

 * Status flags:
     * Previous command failed (**`!`**)
     * Private mode (**🔒** or **`⦸`**)
     * You currently have superpowers (**`$`**)
     * Background jobs (**`%`**)
 * Current vi mode
 * `User@Host` (unless you're the default user)
 * Current RVM, rbenv or chruby (Ruby) version
 * Current virtualenv (Python) version
     * _If you use virtualenv, you will probably need to disable the default virtualenv prompt, since it doesn't play nice with fish: `set -x VIRTUAL_ENV_DISABLE_PROMPT 1`_
 * Current NVM/FNM version (Nodejs) (inactive by default; see configurations in the next paragraph)
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



## Configuration

You can override theme defaults in a Fish config file (for example `~/.config/fish/conf.d/bobthefish.fish`):

```fish
set -g theme_nerd_fonts yes
set -g theme_color_scheme dark
set -g theme_display_user ssh
set -g default_user bobthecow
```

See (many) more options below.



### Prompt options

#### `set -g theme_display_vi yes`

By default the vi mode indicator will be shown if vi or hybrid key bindings are enabled. Use `no` to always hide the indicator, or `yes` to always show the indicator.

#### `set -g theme_show_exit_status yes`

Use `yes` to show any non-zero exit code next to the exclamation mark.

#### `set -g theme_display_jobs_verbose yes`

Use `yes` to display the number of currently running background jobs next to the percent sign.

#### `set -g theme_display_user yes`

Set to `yes` to always display the username, to `ssh` to display only when an SSH session is active, or to `no` to never display the username.

#### `set -g default_user your_normal_user`

If a `default_user` is provided, the username will only be shown when it differs from the default.

#### `set -g theme_display_sudo_user yes`

If set to `yes`, displays the sudoer's username in a root shell. For example, when calling `sudo -s` with this option set to `yes`, the user who called `sudo -s` will be displayed.

#### `set -g theme_display_hostname yes`

Set to `yes` to always display the hostname, to `ssh` to display only when an SSH session is active, or to `no` to never display the hostname.

#### `set -g fish_prompt_pwd_dir_length 1`

Bobthefish respects the Fish `$fish_prompt_pwd_dir_length` setting to abbreviate the prompt path; set to `0` to show the full path, `1` (default) to show only the first character of each parent directory name, or any other number to show up to that many characters.

#### `set -g theme_project_dir_length 1`

The same as `$fish_prompt_pwd_dir_length`, but for the path relative to the current project root. Defaults to `0`; set to any other number to show an abbreviated path.

#### `set -g theme_show_project_parent no`

Use `no` to only show the project directory name, and not its parent path, when inside a project.

#### `set -g theme_newline_cursor yes`

Use `yes` to place the cursor on the next line, rather than the same line as the prompt. Setting this to `clean` instead of `yes` suppresses the caret on the new line.

#### `set -g theme_newline_prompt "\$"`

Use a custom prompt with newline cursor. By default this is the chevron right glyph or `>` when powerline fonts are disabled.

#### `set -g theme_avoid_ambiguous_glyphs yes`

You probably don't need this option, unless your terminal doesn't like Unicode. Setting to `yes` will avoid ambiguous-width characters in an attempt to

#### `set -g theme_powerline_fonts no`

Bobthefish really likes Powerline-enhanced fonts. If you can't make that work, set to `no` to use plaintext fallbacks.

#### `set -g theme_nerd_fonts yes`

Bobthefish likes Nerd Fonts even better! Use `yes` if you've got Nerd Font capable fonts.

#### `set -g theme_color_scheme dark`

See below for all the color scheming you can handle.



### Virtual environments and version manager options

#### `set -g theme_display_vagrant yes`

This feature is disabled by default, use `yes` to display Vagrant status in your prompt. Please note that only the VirtualBox and VMWare providers are supported.

#### `set -g theme_display_docker_machine no`

Use `no` to disable the current Docker machine name.

#### `set -g theme_display_ruby no`

Use `no` to disable Ruby version information. By default, the Ruby version is displayed unless it's your system Ruby version.

#### `set -g theme_display_virtualenv no`

Use `no` to disable Python version information. By default, the Python version is shown when it's interesting, along with the Virtualenv or Conda environmenmt.

#### `set -g theme_display_go verbose`

Use `no` to disable the Go version information. Set to `verbose` to show both the required and current Go version.

#### `set -g theme_display_node yes`

This feature is disabled by default. Use `yes`, display the version if an `.nvmrc`, `.node-version` or `package.json` file is found in the parent path. Set to `always` to always display the current NPM, NVM or FNM node version.

#### `set -g theme_display_nix no`

Use `no` to disable Nix environment information.

#### `set -g theme_display_k8s_context yes`

This feature is disabled by default. Use `yes` to show the current Kubernetes context (`> kubectl config current-context`).

#### `set -g theme_display_k8s_namespace yes`

This feature is disabled by default. Use `yes` to show the current Kubernetes namespace.

#### `set -g theme_display_aws_vault_profile yes`

This feature is disabled by default. Use `yes` to show the currently executing [AWS Vault](https://github.com/99designs/aws-vault) profile.



### Git (and other VCS) options

#### `set -g theme_display_git no`

Use `no` to disable Git integration. If you're doing this for performance reasons, try some of the options below before disabling it entirely!

#### `set -g theme_display_git_dirty no`

Use `no` to hide Git dirty state. Set the Git `bash.showDirtyState` option on a per-repository basis to disable it just for especially large repos.

#### `set -g theme_display_git_dirty_verbose yes`

This feature is disabled by default. Use `yes` to show more verbose dirty state information.

#### `set -g theme_display_git_untracked no`

Use `no` to hide Git untracked file state. Set the Git `bash.showUntrackedFiles` option on a per-repository basis to disable it just for especially large repos.

#### `set -g theme_display_git_ahead_verbose yes`

This feature is disabled by default. Use `yes` to show more verbose ahead/behind state information.

#### `set -g theme_display_git_stashed_verbose yes`

This feature is disabled by default. Use `yes` to show more verbose stashed state information.

#### `set -g theme_display_git_default_branch yes`

By default, Bobthefish hides the default branch name (e.g. `main` or `master`). Use `yes` to always show these branche names.

#### `set -g theme_git_default_branches main trunk`

By default, Bobthefish hides default branch names (e.g. `main` or `master`). To hide other branch names, you can set a custom default branch name via the `init.defaultBranch` Git config option, or override the list entirely.

#### `set -g theme_use_abbreviated_branch_name yes`

This feature is disabled by default. Use `yes` to truncate extremely long Git branch names.

#### `set -g theme_git_worktree_support yes`

If you do any Git worktree shenanigans, setting this to `yes` will fix incorrect project-relative paths. If you don't do any Git worktree shenanigans, leave it disabled. It's faster this way :)

#### `set -g theme_display_hg yes`

This feature is disabled by default. Use `yes` to enable Mercurial support in Bobthefish. If you don't use Mercurial, leave it disabled because it's ... not fast.

#### `set -g theme_vcs_ignore_paths /some/path /some/other/path{foo,bar}`

Ignore project paths for Git or Mercurial. Supports glob patterns.



### Right prompt options

The right prompt can be configured with the following options, or overridden entirely by supplying your own `fish_right_prompt` function.

#### `set -g theme_display_date`

Use `no` to disable the date in the right prompt.

#### `set -g theme_date_format +%c`

Customize date formatting. See `man date` for more information.

#### `set -g theme_date_timezone America/Los_Angeles`

Supply a TZ argument variable for date formatting. See `man date` for more information.

#### `set -g theme_display_cmd_duration no`

Use `no` to disable command duration in the right prompt.



### Title options

#### `set -g theme_title_display_process yes`

This feature is disabled by default. Use `yes` to show current process name in the terminal title.

#### `set -g theme_title_display_path no`

Use `no` to hide current working directory from the terminal title.

#### `set -g theme_title_display_user yes`

Use `yes` to show the current user in the tab title (unless you're the default user).

#### `set -g theme_title_use_abbreviated_path no`

By default, directory names will be abbreviated in the terminal title, for example `~` instead of `$HOME` and `/u/local` instead of `/usr/local`. Set to `no` to always show full paths in the title.



### Color schemes

| ![dark][btf-dark]           | ![light][btf-light]                     |
| --------------------------- | --------------------------------------- |
| ![solarized][btf-solarized] | ![solarized-light][btf-solarized-light] |
| ![base16][btf-base16]       | ![base16-light][btf-base16-light]       |
| ![zenburn][btf-zenburn]     | ![terminal-dark][btf-terminal-dark]     |
| ![nord][btf-nord]           |                                         |

You can use the function `bobthefish_display_colors` to preview the prompts in
any color scheme.

Set `theme_color_scheme` in a terminal session or in your fish startup files to
one of the following options to change the prompt colors.

- `dark`. The default bobthefish theme.
- `light`. A lighter version of the default theme.
- `solarized` (or `solarized-dark`), `solarized-light`. Dark and light variants
  of Solarized.
- `base16` (or `base16-dark`), `base16-light`. Dark and light variants of the
  default Base16 theme.
- `zenburn`. An adaptation of Zenburn.
- `gruvbox`. An adaptation of gruvbox.
- `dracula`. An adaptation of dracula.
- `nord`. An adaptation of nord.

Some of these may not look right if your terminal does not support 24 bit color,
in which case you can try one of the `terminal` schemes (below). However, if
you're using Solarized, Base16 (default), or Zenburn in your terminal and the
terminal *does* support 24 bit color, the built in schemes will look nicer.

There are several scheme that use whichever colors you currently have loaded
into your terminal. The advantage of using the schemes that fall through to the
terminal colors is that they automatically adapt to something acceptable
whenever you change the 16 colors in your terminal profile.
- `terminal` (or `terminal-dark` or `terminal-dark-black`)
- `terminal-dark-white`. Same as `terminal`, but use white as the foreground
  color on top of colored segments (in case your colors are very dark).
- `terminal-light` (or `terminal-light-white`)
- `terminal-light-black`. Same as `terminal-light`, but use black as the
  foreground color on top of colored segments (in case your colors are very
  bright).

For some terminal themes, like dark base16 themes, the path segments in the
prompt will be indistinguishable from the background. In those cases, try one of
the following variations; they are identical to the `terminal` schemes except
for using bright black (`brgrey`) and dull white (`grey`) in the place of black
and bright white.
- `terminal2` (or `terminal2-dark` or `terminal2-dark-black`)
- `terminal2-dark-white`
- `terminal2-light` (or `terminal2-light-white`)
- `terminal2-light-black`

Finally, you can specify your very own color scheme by setting
`theme_color_scheme` to `user`. In that case, you also need to define some
variables to set the colors of the prompt. See the "Colors" section of
`fish_prompt.fish` for details.



## Overrides

You can disable the theme default greeting, vi mode prompt, right prompt, or title entirely — or override with your own — by adding custom functions to `~/.config/fish/functions`:

- `~/.config/fish/functions/fish_greeting.fish`
- `~/.config/fish/functions/fish_mode_prompt.fish`
- `~/.config/fish/functions/fish_right_prompt.fish`
- `~/.config/fish/functions/fish_title.fish`

To disable them completely, use an empty function:

```fish
function fish_right_prompt; end
```

… Or copy one from your favorite theme, make up something of your own, or copy/paste a bobthefish default function and modify it to your taste!

```fish
function fish_greeting
  set_color $fish_color_autosuggestion
  echo "I'm completely operational, and all my circuits are functioning perfectly."
  set_color normal
end
```


[btf-fish]:       https://github.com/fish-shell/fish-shell
[btf-screencast]: https://cloud.githubusercontent.com/assets/53660/18028510/f16f6b2c-6c35-11e6-8eb9-9f23ea3cce2e.gif
[btf-patching]:   https://powerline.readthedocs.org/en/master/installation.html#patched-fonts
[btf-fonts]:      https://github.com/Lokaltog/powerline-fonts
[btf-nerd-fonts]: https://github.com/ryanoasis/nerd-fonts
[btf-agnoster]:   https://gist.github.com/agnoster/3712874

[btf-dark]:            https://cloud.githubusercontent.com/assets/53660/16141569/ee2bbe4a-3411-11e6-85dc-3d9b0226e833.png "dark"
[btf-light]:           https://cloud.githubusercontent.com/assets/53660/16141570/f106afc6-3411-11e6-877d-fc2a8f6d3175.png "light"
[btf-solarized]:       https://cloud.githubusercontent.com/assets/53660/16141572/f7724032-3411-11e6-8771-b43769e7afec.png "solarized"
[btf-solarized-light]: https://cloud.githubusercontent.com/assets/53660/16141575/fbed8036-3411-11e6-92e9-90da6d45f94b.png "solarized-light"
[btf-base16]:          https://cloud.githubusercontent.com/assets/53660/16141577/0134763a-3412-11e6-9cca-6040d39c8fd4.png "base16"
[btf-base16-light]:    https://cloud.githubusercontent.com/assets/53660/16141579/02f7245e-3412-11e6-97c6-5f3cecffb73c.png "base16-light"
[btf-zenburn]:         https://cloud.githubusercontent.com/assets/53660/16141580/06229dd4-3412-11e6-84aa-a48de127b6da.png "zenburn"
[btf-terminal-dark]:   https://cloud.githubusercontent.com/assets/53660/16141583/0b3e8eea-3412-11e6-8068-617c5371f6ea.png "terminal-dark"
[btf-nord]:            https://user-images.githubusercontent.com/39213657/72811435-f64ca800-3c5f-11ea-8711-dcce8cfc50fb.png "nord"

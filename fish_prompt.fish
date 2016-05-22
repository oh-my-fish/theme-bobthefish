# name: bobthefish
#
# bobthefish is a Powerline-style, Git-aware fish theme optimized for awesome.
#
# You will need a Powerline-patched font for this to work:
#
#     https://powerline.readthedocs.org/en/master/installation.html#patched-fonts
#
# I recommend picking one of these:
#
#     https://github.com/Lokaltog/powerline-fonts
#
# For more advanced awesome, install a nerd fonts patched font (and be sure to
# enable nerd fonts support with `set -g theme_nerd_fonts yes`):
#
#     https://github.com/ryanoasis/nerd-fonts
#
# You can override some default prompt options in your config.fish:
#
#     set -g theme_display_git no
#     set -g theme_display_git_untracked no
#     set -g theme_display_git_ahead_verbose yes
#     set -g theme_git_worktree_support yes
#     set -g theme_display_vagrant yes
#     set -g theme_display_hg yes
#     set -g theme_display_virtualenv no
#     set -g theme_display_ruby no
#     set -g theme_display_user yes
#     set -g theme_display_vi yes
#     set -g theme_display_vi_hide_mode default
#     set -g theme_avoid_ambiguous_glyphs yes
#     set -g theme_powerline_fonts no
#     set -g theme_nerd_fonts yes
#     set -g theme_show_exit_status yes
#     set -g default_user your_normal_user

# ===========================
# Helper methods
# ===========================

# function __bobthefish_in_git -S -d 'Check whether pwd is inside a git repo'
#   command which git > /dev/null ^&1
#     and command git rev-parse --is-inside-work-tree >/dev/null ^&1
# end

# function __bobthefish_in_hg -S -d 'Check whether pwd is inside a hg repo'
#   command which hg > /dev/null ^&1
#     and command hg stat > /dev/null ^&1
# end

function __bobthefish_git_branch -S -d 'Get the current git branch (or commitish)'
  set -l ref (command git symbolic-ref HEAD ^/dev/null)
  if [ $status -gt 0 ]
    set -l branch (command git show-ref --head -s --abbrev | head -n1 ^/dev/null)
    set ref "$__bobthefish_detached_glyph $branch"
  end
  echo $ref | sed "s#refs/heads/#$__bobthefish_branch_glyph #"
end

function __bobthefish_hg_branch -S -d 'Get the current hg branch'
  set -l branch (command hg branch ^/dev/null)
  set -l book (command hg book | command grep \* | cut -d\  -f3)
  echo "$__bobthefish_branch_glyph $branch @ $book"
end

function __bobthefish_pretty_parent -S -a current_dir -d 'Print a parent directory, shortened to fit the prompt'
  echo -n (dirname $current_dir) | sed -e 's#/private##' -e "s#^$HOME#~#" -e 's#/\(\.\{0,1\}[^/]\)\([^/]*\)#/\1#g' -e 's#/$##'
end

function __bobthefish_git_project_dir -S -d 'Print the current git project base directory'
  [ "$theme_display_git" = 'no' ]; and return
  if [ "$theme_git_worktree_support" != 'yes' ]
    command git rev-parse --show-toplevel ^/dev/null
    return
  end

  set -l git_dir (command git rev-parse --git-dir ^/dev/null); or return

  pushd $git_dir
  set git_dir $PWD
  popd

  switch $PWD/
    case $git_dir/\*
      # Nothing works quite right if we're inside the git dir
      # TODO: fix the underlying issues then re-enable the stuff below

      # # if we're inside the git dir, sweet. just return that.
      # set -l toplevel (command git rev-parse --show-toplevel ^/dev/null)
      # if [ "$toplevel" ]
      #   switch $git_dir/
      #     case $toplevel/\*
      #       echo $git_dir
      #   end
      # end
      return
  end

  set -l project_dir (dirname $git_dir)

  switch $PWD/
    case $project_dir/\*
      echo $project_dir
      return
  end

  set project_dir (command git rev-parse --show-toplevel ^/dev/null)
  switch $PWD/
    case $project_dir/\*
      echo $project_dir
  end
end

function __bobthefish_hg_project_dir -S -d 'Print the current hg project base directory'
  [ "$theme_display_hg" = 'yes' ]; or return
  set -l d $PWD
  while not [ $d = / ]
    if [ -e $d/.hg ]
      command hg root --cwd "$d" ^/dev/null
      return
    end
    set d (dirname $d)
  end
end

function __bobthefish_project_pwd -S -a current_dir -d 'Print the working directory relative to project root'
  echo "$PWD" | sed -e "s#$current_dir##g" -e 's#^/##'
end

function __bobthefish_git_ahead -S -d 'Print the ahead/behind state for the current branch'
  if [ "$theme_display_git_ahead_verbose" = 'yes' ]
    __bobthefish_git_ahead_verbose
    return
  end

  command git rev-list --left-right '@{upstream}...HEAD' ^/dev/null | awk '/>/ {a += 1} /</ {b += 1} {if (a > 0 && b > 0) nextfile} END {if (a > 0 && b > 0) print "±"; else if (a > 0) print "+"; else if (b > 0) print "-"}'
end

function __bobthefish_git_ahead_verbose -S -d 'Print a more verbose ahead/behind state for the current branch'
  set -l commits (command git rev-list --left-right '@{upstream}...HEAD' ^/dev/null)
  [ $status != 0 ]; and return

  set -l behind (count (for arg in $commits; echo $arg; end | command grep '^<'))
  set -l ahead (count (for arg in $commits; echo $arg; end | command grep -v '^<'))

  switch "$ahead $behind"
    case '' # no upstream
    case '0 0' # equal to upstream
      return
    case '* 0' # ahead of upstream
      echo "↑$ahead"
    case '0 *' # behind upstream
      echo "↓$behind"
    case '*' # diverged from upstream
      echo "↑$ahead↓$behind"
  end
end

# ===========================
# Segment functions
# ===========================

function __bobthefish_start_segment -S -d 'Start a prompt segment'
  set -l bg $argv[1]
  set -e argv[1]
  set -l fg $argv[1]
  set -e argv[1]

  set_color normal # clear out anything bold or underline...
  set_color -b $bg
  set_color $fg $argv

  switch "$__bobthefish_current_bg"
    case ''
      # If there's no background, just start one
      echo -n ' '
    case "$bg"
      # If the background is already the same color, draw a separator
      echo -ns $__bobthefish_right_arrow_glyph ' '
    case '*'
      # otherwise, draw the end of the previous segment and the start of the next
      set_color $__bobthefish_current_bg
      echo -ns $__bobthefish_right_black_arrow_glyph ' '
      set_color $fg $argv
  end

  set __bobthefish_current_bg $bg
end

function __bobthefish_path_segment -S -a current_dir -d 'Display a shortened form of a directory'
  set -l bg_color $__bobthefish_dk_grey
  set -l fg_color $__bobthefish_med_grey

  if not [ -w "$current_dir" ]
    set bg_color $__bobthefish_dk_red
    set fg_color $__bobthefish_lt_red
  end

  __bobthefish_start_segment $bg_color $fg_color

  set -l directory
  set -l parent

  switch "$current_dir"
    case /
      set directory '/'
    case "$HOME"
      set directory '~'
    case '*'
      set parent    (__bobthefish_pretty_parent "$current_dir")
      set parent    "$parent/"
      set directory (basename "$current_dir")
  end

  echo -n $parent
  set_color fff --bold
  echo -ns $directory ' '
  set_color normal
end

function __bobthefish_finish_segments -S -d 'Close open prompt segments'
  if [ "$__bobthefish_current_bg" != '' ]
    set_color -b normal
    set_color $__bobthefish_current_bg
    echo -ns $__bobthefish_right_black_arrow_glyph ' '
  end

  set __bobthefish_current_bg
  set_color normal
end


# ===========================
# Theme components
# ===========================

function __bobthefish_prompt_vagrant -S -d 'Display Vagrant status'
  [ "$theme_display_vagrant" = 'yes' -a -f Vagrantfile ]; or return
  if type -q VBoxManage
    __bobthefish_prompt_vagrant_vbox
  else if grep vmware_fusion Vagrantfile >/dev/null ^&1
    __bobthefish_prompt_vagrant_vmware
  end
end

function __bobthefish_vagrant_ids -S -d 'List Vagrant machine ids'
  for file in .vagrant/machines/**/id
    read id <$file
    echo $id
  end
end

function __bobthefish_prompt_vagrant_vbox -S -d 'Display VirtualBox Vagrant status'
  set -l vagrant_status
  for id in (__bobthefish_vagrant_ids)
    set -l vm_status (VBoxManage showvminfo --machinereadable $id ^/dev/null | command grep 'VMState=' | tr -d '"' | cut -d '=' -f 2)
    switch "$vm_status"
      case 'running'
        set vagrant_status "$vagrant_status$__bobthefish_vagrant_running_glyph"
      case 'poweroff'
        set vagrant_status "$vagrant_status$__bobthefish_vagrant_poweroff_glyph"
      case 'aborted'
        set vagrant_status "$vagrant_status$__bobthefish_vagrant_aborted_glyph"
      case 'saved'
        set vagrant_status "$vagrant_status$__bobthefish_vagrant_saved_glyph"
      case 'stopping'
        set vagrant_status "$vagrant_status$__bobthefish_vagrant_stopping_glyph"
      case ''
        set vagrant_status "$vagrant_status$__bobthefish_vagrant_unknown_glyph"
    end
  end
  [ -z "$vagrant_status" ]; and return

  __bobthefish_start_segment $__bobthefish_vagrant fff --bold
  echo -ns $vagrant_status ' '
  set_color normal
end

function __bobthefish_prompt_vagrant_vmware -S -d 'Display VMWare Vagrant status'
  set -l vagrant_status
  for id in (__bobthefish_vagrant_ids)
    if [ (pgrep -f "$id") ]
      set vagrant_status "$vagrant_status$__bobthefish_vagrant_running_glyph"
    else
      set vagrant_status "$vagrant_status$__bobthefish_vagrant_poweroff_glyph"
    end
  end
  [ -z "$vagrant_status" ]; and return

  __bobthefish_start_segment $__bobthefish_vagrant fff --bold
  echo -ns $vagrant_status ' '
  set_color normal
end

function __bobthefish_prompt_status -S -a last_status -d 'Display symbols for a non zero exit status, root and background jobs'
  set -l nonzero
  set -l superuser
  set -l bg_jobs

  # Last exit was nonzero
  [ $last_status -ne 0 ]
    and set nonzero $__bobthefish_nonzero_exit_glyph

  # if superuser (uid == 0)
  [ (id -u $USER) -eq 0 ]
    and set superuser $__bobthefish_superuser_glyph

  # Jobs display
  [ (jobs -l | wc -l) -gt 0 ]
    and set bg_jobs $__bobthefish_bg_job_glyph

  if [ "$nonzero" -o "$superuser" -o "$bg_jobs" ]
    __bobthefish_start_segment fff 000
    if [ "$nonzero" ]
      set_color $__bobthefish_med_red --bold
      if [ "$theme_show_exit_status" = 'yes' ]
      	echo -ns $last_status ' '
      else
      	echo -n $__bobthefish_nonzero_exit_glyph
      end
    end

    if [ "$superuser" ]
      set_color $__bobthefish_med_green --bold
      echo -n $__bobthefish_superuser_glyph
    end

    if [ "$bg_jobs" ]
      set_color $__bobthefish_slate_blue --bold
      echo -n $__bobthefish_bg_job_glyph
    end

    set_color normal
  end
end

function __bobthefish_prompt_user -S -d 'Display actual user if different from $default_user'
  if [ "$theme_display_user" = 'yes' ]
    if [ "$USER" != "$default_user" -o -n "$SSH_CLIENT" ]
      __bobthefish_start_segment $__bobthefish_lt_grey $__bobthefish_slate_blue
      set -l IFS .
      hostname | read -l hostname __
      echo -ns (whoami) '@' $hostname ' '
    end
  end
end

function __bobthefish_prompt_hg -S -a current_dir -d 'Display the actual hg state'
  set -l dirty (command hg stat; or echo -n '*')

  set -l flags "$dirty"
  [ "$flags" ]
    and set flags ""

  set -l flag_bg $__bobthefish_lt_green
  set -l flag_fg $__bobthefish_dk_green
  if [ "$dirty" ]
    set flag_bg $__bobthefish_med_red
    set flag_fg fff
  end

  __bobthefish_path_segment $current_dir

  __bobthefish_start_segment $flag_bg $flag_fg
  echo -ns $__bobthefish_hg_glyph ' '

  __bobthefish_start_segment $flag_bg $flag_fg --bold
  echo -ns (__bobthefish_hg_branch) $flags ' '
  set_color normal

  set -l project_pwd  (__bobthefish_project_pwd $current_dir)
  if [ "$project_pwd" ]
    if [ -w "$PWD" ]
      __bobthefish_start_segment $__bobthefish_dk_grey $__bobthefish_med_grey
    else
      __bobthefish_start_segment $__bobthefish_med_red $__bobthefish_lt_red
    end

    echo -ns $project_pwd ' '
  end
end

function __bobthefish_prompt_git -S -a current_dir -d 'Display the actual git state'
  set -l dirty   (command git diff --no-ext-diff --quiet --exit-code; or echo -n '*')
  set -l staged  (command git diff --cached --no-ext-diff --quiet --exit-code; or echo -n '~')
  set -l stashed (command git rev-parse --verify --quiet refs/stash >/dev/null; and echo -n '$')
  set -l ahead   (__bobthefish_git_ahead)

  set -l new ''
  set -l show_untracked (command git config --bool bash.showUntrackedFiles)
  if [ "$theme_display_git_untracked" != 'no' -a "$show_untracked" != 'false' ]
    set new (command git ls-files --other --exclude-standard --directory --no-empty-directory)
    if [ "$new" ]
      if [ "$theme_avoid_ambiguous_glyphs" = 'yes' ]
        set new '...'
      else
        set new '…'
      end
    end
  end

  set -l flags "$dirty$staged$stashed$ahead$new"
  [ "$flags" ]
    and set flags " $flags"

  set -l flag_bg $__bobthefish_lt_green
  set -l flag_fg $__bobthefish_dk_green
  if [ "$dirty" ]
    set flag_bg $__bobthefish_med_red
    set flag_fg fff
  else if [ "$staged" ]
    set flag_bg $__bobthefish_lt_orange
    set flag_fg $__bobthefish_dk_orange
  end

  __bobthefish_path_segment $current_dir

  __bobthefish_start_segment $flag_bg $flag_fg --bold
  echo -ns (__bobthefish_git_branch) $flags ' '
  set_color normal

  if [ "$theme_git_worktree_support" != 'yes' ]
    set -l project_pwd (__bobthefish_project_pwd $current_dir)
    if [ "$project_pwd" ]
      if [ -w "$PWD" ]
        __bobthefish_start_segment $__bobthefish_dk_grey $__bobthefish_med_grey
      else
        __bobthefish_start_segment $__bobthefish_med_red $__bobthefish_lt_red
      end

      echo -ns $project_pwd ' '
    end
    return
  end

  set -l project_pwd (command git rev-parse --show-prefix ^/dev/null | sed -e 's#/$##')
  set -l work_dir (command git rev-parse --show-toplevel ^/dev/null)

  # only show work dir if it's a parent…
  if [ "$work_dir" ]
    switch $PWD/
      case $work_dir/\*
        set work_dir (echo $work_dir | sed -e "s#^$current_dir##")
      case \*
        set -e work_dir
    end
  end

  if [ "$project_pwd" -o "$work_dir" ]
    set -l bg_color $__bobthefish_dk_grey
    set -l fg_color $__bobthefish_med_grey
    if not [ -w "$PWD" ]
      set bg_color $__bobthefish_med_red
      set fg_color $__bobthefish_lt_red
    end

    __bobthefish_start_segment $bg_color $fg_color

    # handle work_dir != project dir
    if [ "$work_dir" ]
      set -l work_parent (dirname $work_dir | sed -e 's#^/##')
      if [ "$work_parent" ]
        set_color --background $bg_color $fg_color
        echo -n "$work_parent/"
      end
      set_color fff --bold
      echo -n (basename $work_dir)
      set_color --background $bg_color $fg_color
      [ "$project_pwd" ]
        and echo -n '/'
    end

    echo -ns $project_pwd ' '
  else
    set project_pwd (echo $PWD | sed -e "s#^$current_dir##" -e 's#^/##')
    if [ "$project_pwd" ]
      set -l bg_color $__bobthefish_dk_grey
      set -l fg_color $__bobthefish_med_grey
      if not [ -w "$PWD" ]
        set bg_color $__bobthefish_med_red
        set fg_color $__bobthefish_lt_red
      end

      __bobthefish_start_segment $bg_color $fg_color

      echo -ns $project_pwd ' '
    end
  end
end

function __bobthefish_prompt_dir -S -d 'Display a shortened form of the current directory'
  __bobthefish_path_segment "$PWD"
end

function __bobthefish_prompt_vi -S -d 'Display vi mode'
  [ "$theme_display_vi" = 'yes' -a "$fish_bind_mode" != "$theme_display_vi_hide_mode" ]; or return
  switch $fish_bind_mode
    case default
      __bobthefish_start_segment $__bobthefish_med_grey $__bobthefish_dk_grey --bold
      echo -n 'N '
    case insert
      __bobthefish_start_segment $__bobthefish_lt_green $__bobthefish_dk_grey --bold
      echo -n 'I '
    case visual
      __bobthefish_start_segment $__bobthefish_lt_orange $__bobthefish_dk_grey --bold
      echo -n 'V '
  end
  set_color normal
end

function __bobthefish_virtualenv_python_version -S -d 'Get current python version'
  set -l python_version (readlink (which python))
  [ -z "$python_version" ]
    and set python_version (which python)
  switch (basename "$python_version")
    case 'python' 'python2*'
      echo $__bobthefish_superscript_glyph[2]
    case 'python3*'
      echo $__bobthefish_superscript_glyph[3]
    case 'pypy*'
      echo $__bobthefish_pypy_glyph
  end
end

function __bobthefish_prompt_virtualfish -S -d "Display activated virtual environment (only for virtualfish, virtualenv's activate.fish changes prompt by itself)"
  [ "$theme_display_virtualenv" = 'no' -o -z "$VIRTUAL_ENV" ]; and return
  set -l version_glyph (__bobthefish_virtualenv_python_version)
  if [ "$version_glyph" ]
    __bobthefish_start_segment $__bobthefish_med_blue $__bobthefish_lt_grey
    echo -ns $__bobthefish_virtualenv_glyph $version_glyph ' '
  end
  echo -ns (basename "$VIRTUAL_ENV") ' '
  set_color normal
end

function __bobthefish_rvm_parse_ruby -S -a ruby_string scope -d 'Parse RVM Ruby string'
  # Function arguments:
  # - 'ruby-2.2.3@rails', 'jruby-1.7.19'...
  # - 'default' or 'current'
  set -l IFS @
  echo "$ruby_string" | read __ruby __rvm_{$scope}_ruby_gemset __
  set IFS -
  echo "$__ruby" | read __rvm_{$scope}_ruby_interpreter __rvm_{$scope}_ruby_version __
  set -e __ruby
  set -e __
end

function __bobthefish_rvm_info -S -d 'Current Ruby information from RVM'
  # More `sed`/`grep`/`cut` magic...
  set -l __rvm_default_ruby (grep GEM_HOME ~/.rvm/environments/default | sed -e"s/'//g" | sed -e's/.*\///')
  set -l __rvm_current_ruby (rvm-prompt i v g)
  [ "$__rvm_default_ruby" = "$__rvm_current_ruby" ]; and return

  set -l __rvm_default_ruby_gemset
  set -l __rvm_default_ruby_interpreter
  set -l __rvm_default_ruby_version
  set -l __rvm_current_ruby_gemset
  set -l __rvm_current_ruby_interpreter
  set -l __rvm_current_ruby_version

  # Parse default and current Rubies to global variables
  __bobthefish_rvm_parse_ruby $__rvm_default_ruby default
  __bobthefish_rvm_parse_ruby $__rvm_current_ruby current
  # Show unobtrusive RVM prompt

  # If interpreter differs form default interpreter, show everything:
  if [ "$__rvm_default_ruby_interpreter" != "$__rvm_current_ruby_interpreter" ]
    if [ "$__rvm_current_ruby_gemset" = 'global' ]
      rvm-prompt i v
    else
      rvm-prompt i v g
    end
  # If version differs form default version
  else if [ "$__rvm_default_ruby_version" != "$__rvm_current_ruby_version" ]
    if [ "$__rvm_current_ruby_gemset" = 'global' ]
      rvm-prompt v
    else
      rvm-prompt v g
    end
  # If gemset differs form default or 'global' gemset, just show it
  else if [ "$__rvm_default_ruby_gemset" != "$__rvm_current_ruby_gemset" ]
    rvm-prompt g
  end
end

function __bobthefish_show_ruby -S -d 'Current Ruby (rvm/rbenv)'
  set -l ruby_version
  if type -q rvm-prompt
    set ruby_version (__bobthefish_rvm_info)
  else if type -q rbenv
    set ruby_version (rbenv version-name)
    # Don't show global ruby version...
    set -q RBENV_ROOT
      or set -l RBENV_ROOT $HOME/.rbenv

    read -l global_ruby_version <$RBENV_ROOT/version

    [ "$global_ruby_version" ]
      or set global_ruby_version system

    [ "$ruby_version" = "$global_ruby_version" ]; and return
  end
  [ -z "$ruby_version" ]; and return
  __bobthefish_start_segment $__bobthefish_ruby_red $__bobthefish_lt_grey --bold
  echo -ns $__bobthefish_ruby_glyph $ruby_version ' '
  set_color normal
end

function __bobthefish_prompt_rubies -S -d 'Display current Ruby information'
  [ "$theme_display_ruby" = 'no' ]; and return
  __bobthefish_show_ruby
end

# ===========================
# Apply theme
# ===========================

function fish_prompt -d 'bobthefish, a fish theme optimized for awesome'
  # Save the last status for later (do this before the `set` calls below)
  set -l last_status $status

  # Powerline glyphs
  set -l __bobthefish_branch_glyph            \uE0A0
  set -l __bobthefish_ln_glyph                \uE0A1
  set -l __bobthefish_padlock_glyph           \uE0A2
  set -l __bobthefish_right_black_arrow_glyph \uE0B0
  set -l __bobthefish_right_arrow_glyph       \uE0B1
  set -l __bobthefish_left_black_arrow_glyph  \uE0B2
  set -l __bobthefish_left_arrow_glyph        \uE0B3

  if [ "$theme_powerline_fonts" = "no" ]
    set __bobthefish_branch_glyph            \u2387
    set __bobthefish_ln_glyph                ''
    set __bobthefish_padlock_glyph           ''
    set __bobthefish_right_black_arrow_glyph ''
    set __bobthefish_right_arrow_glyph       ''
    set __bobthefish_left_black_arrow_glyph  ''
    set __bobthefish_left_arrow_glyph        ''
  end

  # Additional glyphs
  set -l __bobthefish_detached_glyph          \u27A6
  set -l __bobthefish_nonzero_exit_glyph      '! '
  set -l __bobthefish_superuser_glyph         '$ '
  set -l __bobthefish_bg_job_glyph            '% '
  set -l __bobthefish_hg_glyph                \u263F

  # Python glyphs
  set -l __bobthefish_superscript_glyph       \u00B9 \u00B2 \u00B3
  set -l __bobthefish_virtualenv_glyph        \u25F0
  set -l __bobthefish_pypy_glyph              \u1D56

  set -l __bobthefish_ruby_glyph              ''

  # Vagrant glyphs
  set -l __bobthefish_vagrant_running_glyph   \u2191 # ↑ 'running'
  set -l __bobthefish_vagrant_poweroff_glyph  \u2193 # ↓ 'poweroff'
  set -l __bobthefish_vagrant_aborted_glyph   \u2715 # ✕ 'aborted'
  set -l __bobthefish_vagrant_saved_glyph     \u21E1 # ⇡ 'saved'
  set -l __bobthefish_vagrant_stopping_glyph  \u21E3 # ⇣ 'stopping'
  set -l __bobthefish_vagrant_unknown_glyph   '!'    # strange cases

  # Colors
  set -l __bobthefish_lt_green   addc10
  set -l __bobthefish_med_green  189303
  set -l __bobthefish_dk_green   0c4801

  set -l __bobthefish_lt_red     C99
  set -l __bobthefish_med_red    ce000f
  set -l __bobthefish_dk_red     600
  set -l __bobthefish_ruby_red   af0000

  set -l __bobthefish_slate_blue 255e87
  set -l __bobthefish_med_blue   005faf

  set -l __bobthefish_lt_orange  f6b117
  set -l __bobthefish_dk_orange  3a2a03

  set -l __bobthefish_dk_grey    333
  set -l __bobthefish_med_grey   999
  set -l __bobthefish_lt_grey    ccc

  set -l __bobthefish_dk_brown   4d2600
  set -l __bobthefish_med_brown  803F00
  set -l __bobthefish_lt_brown   BF5E00

  set -l __bobthefish_vagrant    48B4FB

  if [ "$theme_nerd_fonts" = "yes" ]
    set __bobthefish_virtualenv_glyph \uE73C ' '
    set __bobthefish_ruby_glyph       \uE791 ' '
  end

  # Start each line with a blank slate
  set -l __bobthefish_current_bg

  __bobthefish_prompt_status $last_status
  __bobthefish_prompt_vi
  __bobthefish_prompt_vagrant
  __bobthefish_prompt_user
  __bobthefish_prompt_rubies
  __bobthefish_prompt_virtualfish

  set -l git_root (__bobthefish_git_project_dir)
  set -l hg_root  (__bobthefish_hg_project_dir)

  if [ "$git_root" -a "$hg_root" ]
    # only show the closest parent
    switch $git_root
      case $hg_root\*
        __bobthefish_prompt_git $git_root
      case \*
        __bobthefish_prompt_hg $hg_root
    end
  else if [ "$git_root" ]
    __bobthefish_prompt_git $git_root
  else if [ "$hg_root" ]
    __bobthefish_prompt_hg $hg_root
  else
    __bobthefish_prompt_dir
  end

  __bobthefish_finish_segments
end

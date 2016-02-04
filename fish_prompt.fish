# name: bobthefish
#
# bobthefish is a Powerline-style, Git-aware fish theme optimized for awesome.
#
# You will need a Powerline-patched font for this to work:
#
#     https://powerline.readthedocs.org/en/latest/fontpatching.html
#
# I recommend picking one of these:
#
#     https://github.com/Lokaltog/powerline-fonts
#
# You can override some default prompt options in your config.fish:
#
#     set -g theme_display_git no
#     set -g theme_display_git_untracked no
#     set -g theme_display_git_ahead_verbose yes
#     set -g theme_display_vagrant yes
#     set -g theme_display_hg yes
#     set -g theme_display_virtualenv no
#     set -g theme_display_ruby no
#     set -g theme_display_user yes
#     set -g theme_display_vi yes
#     set -g theme_display_vi_hide_mode default
#     set -g theme_avoid_ambiguous_glyphs yes
#     set -g default_user your_normal_user

# ===========================
# Helper methods
# ===========================

# function __bobthefish_in_git -S -d 'Check whether pwd is inside a git repo'
#   command which git > /dev/null 2>&1; and command git rev-parse --is-inside-work-tree >/dev/null 2>&1
# end

# function __bobthefish_in_hg -S -d 'Check whether pwd is inside a hg repo'
#   command which hg > /dev/null 2>&1; and command hg stat > /dev/null 2>&1
# end

function __bobthefish_git_branch -S -d 'Get the current git branch (or commitish)'
  set -l ref (command git symbolic-ref HEAD ^/dev/null)
  if [ $status -gt 0 ]
    set -l branch (command git show-ref --head -s --abbrev | head -n1 ^/dev/null)
    set ref "$__bobthefish_detached_glyph $branch"
  end
  echo $ref | sed  "s#refs/heads/#$__bobthefish_branch_glyph #"
end

function __bobthefish_hg_branch -S -d 'Get the current hg branch'
  set -l branch (command hg branch ^/dev/null)
  set -l book (command hg book | grep \* | cut -d\  -f3)
  echo "$__bobthefish_branch_glyph $branch @ $book"
end

function __bobthefish_pretty_parent -S -a current_dir -d 'Print a parent directory, shortened to fit the prompt'
  echo -n (dirname $current_dir) | sed -e 's#/private##' -e "s#^$HOME#~#" -e 's#/\(\.\{0,1\}[^/]\)\([^/]*\)#/\1#g' -e 's#/$##'
end

function __bobthefish_git_project_dir -S -d 'Print the current git project base directory'
  [ "$theme_display_git" = 'no' ]; and return
  command git rev-parse --show-toplevel ^/dev/null
end

function __bobthefish_hg_project_dir -S -d 'Print the current hg project base directory'
  [ "$theme_display_hg" = 'yes' ]; or return
  set d (pwd)
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
  if [ $status != 0 ]
    return
  end

  set -l behind (count (for arg in $commits; echo $arg; end | grep '^<'))
  set -l ahead (count (for arg in $commits; echo $arg; end | grep -v '^<'))

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
      echo -n "$__bobthefish_right_arrow_glyph "
    case '*'
      # otherwise, draw the end of the previous segment and the start of the next
      set_color $__bobthefish_current_bg
      echo -n "$__bobthefish_right_black_arrow_glyph "
      set_color $fg $argv
  end

  set __bobthefish_current_bg $bg
end

function __bobthefish_path_segment -S -a current_dir -d 'Display a shortened form of a directory'
  if [ -w "$current_dir" ]
    __bobthefish_start_segment $__bobthefish_dk_grey $__bobthefish_med_grey
  else
    __bobthefish_start_segment $__bobthefish_dk_red $__bobthefish_lt_red
  end

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

  [ "$parent" ]; and echo -n -s "$parent"
  set_color fff --bold
  echo -n "$directory "
  set_color normal
end

function __bobthefish_finish_segments -S -d 'Close open prompt segments'
  if [ "$__bobthefish_current_bg" != '' ]
    set_color -b normal
    set_color $__bobthefish_current_bg
    echo -n "$__bobthefish_right_black_arrow_glyph "
    set_color normal
  end

  set __bobthefish_current_bg
end


# ===========================
# Theme components
# ===========================

function __bobthefish_prompt_vagrant -S -d 'Display Vagrant status'
  [ "$theme_display_vagrant" != 'yes' ]; and return
  which VBoxManage >/dev/null 2>&1; and set -l __vbox_installed yes
  if [ -f Vagrantfile -a "$__vbox_installed" = 'yes' ]
    # Get machine UUIDs
    set -e __vagrant_ids
    set -e __vagrant_statuses
    for m in .vagrant/machines/**/id
      set -l __machine_id (cat $m)
      set __vagrant_ids $__vagrant_ids $__machine_id
    end
    for i in $__vagrant_ids
      set -l __vm_status (VBoxManage showvminfo --machinereadable $i 2>/dev/null | grep 'VMState=' | tr -d '"' | cut -d '=' -f 2)
      set __vagrant_statuses "$__vagrant_statuses<$__vm_status>"
    end
    # Transform statuses to glyphs
    set __vagrant_statuses ( echo -n $__vagrant_statuses | sed \
      -e "s#<running>#$__bobthefish_vagrant_running_glyph#g" \
      -e "s#<poweroff>#$__bobthefish_vagrant_poweroff_glyph#g" \
      -e "s#<aborted>#$__bobthefish_vagrant_aborted_glyph#g" \
      -e "s#<saved>#$__bobthefish_vagrant_saved_glyph#g" \
      -e "s#<stopping>#$__bobthefish_vagrant_stopping_glyph#g" \
      -e "s#<>#$__bobthefish_vagrant_unknown_glyph#g"
      )
    # Display status if any status
    if [ "$__vagrant_statuses" != '' ]
      __bobthefish_start_segment $__bobthefish_vagrant fff --bold
      echo -n -s "$__vagrant_statuses "
      set_color normal
    end
  end
end

function __bobthefish_prompt_status -S -a last_status -d 'Display symbols for a non zero exit status, root and background jobs'
  set -l nonzero
  set -l superuser
  set -l bg_jobs

  # Last exit was nonzero
  if [ $last_status -ne 0 ]
    set nonzero $__bobthefish_nonzero_exit_glyph
  end

  # if superuser (uid == 0)
  if [ (id -u $USER) -eq 0 ]
    set superuser $__bobthefish_superuser_glyph
  end

  # Jobs display
  if [ (jobs -l | wc -l) -gt 0 ]
    set bg_jobs $__bobthefish_bg_job_glyph
  end

  if [ "$nonzero" -o "$superuser" -o "$bg_jobs" ]
    __bobthefish_start_segment fff 000
    if [ "$nonzero" ]
      set_color $__bobthefish_med_red --bold
      echo -n $__bobthefish_nonzero_exit_glyph
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
      echo -n -s (whoami) '@' (hostname | cut -d . -f 1) ' '
    end
  end
end

function __bobthefish_prompt_hg -S -a current_dir -d 'Display the actual hg state'
  set -l dirty (command hg stat; or echo -n '*')

  set -l flags "$dirty"
  [ "$flags" ]; and set flags ""

  set -l flag_bg $__bobthefish_lt_green
  set -l flag_fg $__bobthefish_dk_green
  if [ "$dirty" ]
    set flag_bg $__bobthefish_med_red
    set flag_fg fff
  end

  __bobthefish_path_segment $current_dir

  __bobthefish_start_segment $flag_bg $flag_fg
  echo -n -s $__bobthefish_hg_glyph ' '

  __bobthefish_start_segment $flag_bg $flag_fg --bold
  echo -n -s (__bobthefish_hg_branch) $flags ' '
  set_color normal

  set -l project_pwd  (__bobthefish_project_pwd $current_dir)
  if [ "$project_pwd" ]
    if [ -w "$PWD" ]
      __bobthefish_start_segment 333 999
    else
      __bobthefish_start_segment $__bobthefish_med_red $__bobthefish_lt_red
    end

    echo -n -s $project_pwd ' '
  end
end

function __bobthefish_prompt_git -S -a current_dir -d 'Display the actual git state'
  set -l dirty   (command git diff --no-ext-diff --quiet --exit-code; or echo -n '*')
  set -l staged  (command git diff --cached --no-ext-diff --quiet --exit-code; or echo -n '~')
  set -l stashed (command git rev-parse --verify --quiet refs/stash >/dev/null; and echo -n '$')
  set -l ahead   (__bobthefish_git_ahead)

  set -l new ''
  set -l show_untracked (git config --bool bash.showUntrackedFiles)
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
  [ "$flags" ]; and set flags " $flags"

  set -l flag_bg $__bobthefish_lt_green
  set -l flag_fg $__bobthefish_dk_green
  if [ "$dirty" -o "$staged" ]
    set flag_bg $__bobthefish_med_red
    set flag_fg fff
  else if [ "$stashed" ]
    set flag_bg $__bobthefish_lt_orange
    set flag_fg $__bobthefish_dk_orange
  end

  __bobthefish_path_segment $current_dir

  __bobthefish_start_segment $flag_bg $flag_fg --bold
  echo -n -s (__bobthefish_git_branch) $flags ' '
  set_color normal

  set -l project_pwd (__bobthefish_project_pwd $current_dir)
  if [ "$project_pwd" ]
    if [ -w "$PWD" ]
      __bobthefish_start_segment 333 999
    else
      __bobthefish_start_segment $__bobthefish_med_red $__bobthefish_lt_red
    end

    echo -n -s $project_pwd ' '
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
      echo -n -s 'N '
    case insert
      __bobthefish_start_segment $__bobthefish_lt_green $__bobthefish_dk_grey --bold
      echo -n -s 'I '
    case visual
      __bobthefish_start_segment $__bobthefish_lt_orange $__bobthefish_dk_grey --bold
      echo -n -s 'V '
  end
  set_color normal
end

function __bobthefish_virtualenv_python_version -S -d 'Get current python version'
  set -l python_version (readlink (which python))
  [ -z "$python_version" ]; and set python_version (which python)
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
    echo -n -s $__bobthefish_virtualenv_glyph $version_glyph ' '
  end
  __bobthefish_start_segment $__bobthefish_med_blue $__bobthefish_lt_grey --bold
  echo -n -s (basename "$VIRTUAL_ENV") ' '
  set_color normal
end

function __bobthefish_rvm_parse_ruby -S -a ruby_string scope -d 'Parse RVM Ruby string'
  # Function arguments:
  # - 'ruby-2.2.3@rails', 'jruby-1.7.19'...
  # - 'default' or 'current'
  set -l __ruby (echo $ruby_string | cut -d '@' -f 1 2>/dev/null)
  set -g __rvm_{$scope}_ruby_interpreter (echo $__ruby | cut -d '-' -f 1 2>/dev/null)
  set -g __rvm_{$scope}_ruby_version (echo $__ruby | cut -d '-' -f 2 2>/dev/null)
  set -g __rvm_{$scope}_ruby_gemset (echo $ruby_string | cut -d '@' -f 2 2>/dev/null)
  [ "$__ruby_gemset" = "$__ruby" ]; and set -l __ruby_gemset global
end

function __bobthefish_rvm_info -S -d 'Current Ruby information from RVM'
  # More `sed`/`grep`/`cut` magic...
  set -l __rvm_default_ruby (grep GEM_HOME ~/.rvm/environments/default | \
    sed -e"s/'//g" | sed -e's/.*\///')
  set -l __rvm_current_ruby (rvm-prompt i v g)
  # Parse default and current Rubies to global variables
  __bobthefish_rvm_parse_ruby $__rvm_default_ruby default
  __bobthefish_rvm_parse_ruby $__rvm_current_ruby current
  # Show unobtrusive RVM prompt
  if [ "$__rvm_default_ruby" = "$__rvm_current_ruby" ]; return
  # If interpreter differs form default interpreter, show everything:
  else if [ "$__rvm_default_ruby_interpreter" != "$__rvm_current_ruby_interpreter" ]
    if [ "$__rvm_current_ruby_gemset" = 'global' ]; rvm-prompt i v
      else; rvm-prompt i v g; end
  # If version differs form default version
  else if [ "$__rvm_default_ruby_version" != "$__rvm_current_ruby_version" ]
    if [ "$__rvm_current_ruby_gemset" = 'global' ]; rvm-prompt v
    else; rvm-prompt v g; end
  # If gemset differs form default or 'global' gemset, just show it
  else if [ "$__rvm_default_ruby_gemset" != "$__rvm_current_ruby_gemset" ]
    rvm-prompt g;
  end
  set --erase --global __rvm_current_ruby_gemset
  set --erase --global __rvm_current_ruby_interpreter
  set --erase --global __rvm_current_ruby_version
  set --erase --global __rvm_default_ruby_gemset
  set --erase --global __rvm_default_ruby_interpreter
  set --erase --global __rvm_default_ruby_version
end

function __bobthefish_show_ruby -S -d 'Current Ruby (rvm/rbenv)'
  set -l ruby_version
  if which rvm-prompt >/dev/null 2>&1
    set ruby_version (__bobthefish_rvm_info)
  else if which rbenv >/dev/null 2>&1
    set ruby_version (rbenv version-name)
    # Don't show global ruby version...
    set -q RBENV_ROOT; and set rbenv_root $RBENV_ROOT; or set rbenv_root ~/.rbenv
    [ "$ruby_version" = (cat $rbenv_root/version 2>/dev/null; or echo 'system') ]; and return
  end
  [ -z "$ruby_version" ]; and return
  __bobthefish_start_segment $__bobthefish_ruby_red $__bobthefish_lt_grey --bold
  echo -n -s $ruby_version ' '
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
  if [ (echo "$hg_root" | wc -c) -gt (echo "$git_root" | wc -c) ]
    __bobthefish_prompt_hg $hg_root
  else if [ "$git_root" ]
    __bobthefish_prompt_git $git_root
  else
    __bobthefish_prompt_dir
  end
  __bobthefish_finish_segments
end

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
#     set -g theme_display_docker_machine no
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
#     set -g theme_color_scheme dark

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
  set -l segment_color $__color_path
  set -l segment_basename_color $__color_path_basename

  if not [ -w "$current_dir" ]
    set segment_color $__color_path_nowrite
    set segment_basename_color $__color_path_nowrite_basename
  end

  __bobthefish_start_segment $segment_color

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
  set_color -b $segment_basename_color
  echo -ns $directory ' '
  set_color normal
end

function __bobthefish_finish_segments -S -d 'Close open prompt segments'
  if [ "$__bobthefish_current_bg" != '' ]
    set_color normal
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

  __bobthefish_start_segment $__color_vagrant
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

  __bobthefish_start_segment $__color_vagrant
  echo -ns $vagrant_status ' '
  set_color normal
end

function __bobthefish_prompt_docker -S -d 'Show docker machine name'
    [ "$theme_display_docker_machine" = 'no' -o -z "$DOCKER_MACHINE_NAME" ]; and return
    __bobthefish_start_segment $__color_vagrant
    echo -ns $DOCKER_MACHINE_NAME ' '
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
    __bobthefish_start_segment $__color_initial_segment_exit
    if [ "$nonzero" ]
       set_color normal; set_color -b $__color_initial_segment_exit
      if [ "$theme_show_exit_status" = 'yes' ]
      	echo -ns $last_status ' '
      else
      	echo -n $__bobthefish_nonzero_exit_glyph
      end
    end

    if [ "$superuser" ]
      set_color normal; set_color -b $__color_initial_segment_su
      echo -n $__bobthefish_superuser_glyph
    end

    if [ "$bg_jobs" ]
      set_color normal; set_color -b $__color_initial_segment_jobs
      echo -n $__bobthefish_bg_job_glyph
    end

    set_color normal
  end
end

function __bobthefish_prompt_user -S -d 'Display actual user if different from $default_user'
  if [ "$theme_display_user" = 'yes' ]
    if [ "$USER" != "$default_user" -o -n "$SSH_CLIENT" ]
      __bobthefish_start_segment $__color_username
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

  set -l flag_colors $__color_repo
  if [ "$dirty" ]
    set flag_colors $__color_repo_dirty
  end

  __bobthefish_path_segment $current_dir

  __bobthefish_start_segment $flag_colors
  echo -ns $__bobthefish_hg_glyph ' '

  __bobthefish_start_segment $flag_colors
  echo -ns (__bobthefish_hg_branch) $flags ' '
  set_color normal

  set -l project_pwd  (__bobthefish_project_pwd $current_dir)
  if [ "$project_pwd" ]
    if [ -w "$PWD" ]
      __bobthefish_start_segment $__color_path
    else
      __bobthefish_start_segment $__color_path_nowrite
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

  set -l flag_colors $__color_repo
  if [ "$dirty" ]
    set flag_colors $__color_repo_dirty
  else if [ "$staged" ]
    set flag_colors $__color_repo_staged
  end

  __bobthefish_path_segment $current_dir

  __bobthefish_start_segment $flag_colors
  echo -ns (__bobthefish_git_branch) $flags ' '
  set_color normal

  if [ "$theme_git_worktree_support" != 'yes' ]
    set -l project_pwd (__bobthefish_project_pwd $current_dir)
    if [ "$project_pwd" ]
      if [ -w "$PWD" ]
        __bobthefish_start_segment $__color_path
      else
        __bobthefish_start_segment $__color_path_nowrite
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
    set -l colors $__color_path
    if not [ -w "$PWD" ]
      set colors $__color_path_nowrite
    end

    __bobthefish_start_segment $colors

    # handle work_dir != project dir
    if [ "$work_dir" ]
      set -l work_parent (dirname $work_dir | sed -e 's#^/##')
      if [ "$work_parent" ]
        echo -n "$work_parent/"
      end
      set_color normal; set_color -b $__color_repo_work_tree
      echo -n (basename $work_dir)
      set_color normal; set_color --background $colors
      [ "$project_pwd" ]
        and echo -n '/'
    end

    echo -ns $project_pwd ' '
  else
    set project_pwd (echo $PWD | sed -e "s#^$current_dir##" -e 's#^/##')
    if [ "$project_pwd" ]
      set -l colors $color_path
      if not [ -w "$PWD" ]
        set colors $color_path_nowrite
      end

      __bobthefish_start_segment $colors

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
      __bobthefish_start_segment $__color_vi_mode_default
      echo -n 'N '
    case insert
      __bobthefish_start_segment $__color_vi_mode_insert
      echo -n 'I '
    case visual
      __bobthefish_start_segment $__color_vi_mode_visual
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
    __bobthefish_start_segment $__color_virtualfish
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
  else if type -q chruby
    set ruby_version $RUBY_VERSION
  end
  [ -z "$ruby_version" ]; and return
  __bobthefish_start_segment $__color_rvm
  echo -ns $__bobthefish_ruby_glyph $ruby_version ' '
  set_color normal
end

function __bobthefish_prompt_rubies -S -d 'Display current Ruby information'
  [ "$theme_display_ruby" = 'no' ]; and return
  __bobthefish_show_ruby
end

# ===========================
# Debugging functions
# ===========================

function __bobthefish_display_colors -d 'Print example prompts using the current color scheme'
  set -g __bobthefish_display_colors
end

function __bobthefish_maybe_display_colors -S
  if not set -q __bobthefish_display_colors
    return
  end

  set -e __bobthefish_display_colors

  echo
  set_color normal

  __bobthefish_start_segment $__color_initial_segment_exit
  echo -n exit '! '
  set_color -b $__color_initial_segment_su
  echo -n su '$ '
  set_color -b $__color_initial_segment_jobs
  echo -n jobs '% '
  __bobthefish_finish_segments
  set_color normal
  echo -n "(<- color_initial_segment)"
  echo

  __bobthefish_start_segment $__color_path
  echo -n /color/path/
  set_color -b $__color_path_basename
  echo -ns basename ' '
  __bobthefish_finish_segments
  echo

  __bobthefish_start_segment $__color_path_nowrite
  echo -n /color/path/nowrite/
  set_color -b $__color_path_nowrite_basename
  echo -ns basename ' '
  __bobthefish_finish_segments
  echo

  __bobthefish_start_segment $__color_path
  echo -n /color/path/
  set_color -b $__color_path_basename
  echo -ns basename ' '
  __bobthefish_start_segment $__color_repo
  echo -ns $__bobthefish_branch_glyph ' '
  echo -n "color-repo "
  __bobthefish_finish_segments
  echo

  __bobthefish_start_segment $__color_path
  echo -n /color/path/
  set_color -b $__color_path_basename
  echo -ns basename ' '
  __bobthefish_start_segment $__color_repo_dirty
  echo -ns $__bobthefish_branch_glyph ' '
  echo -n "color-repo-dirty "
  __bobthefish_finish_segments
  echo

  __bobthefish_start_segment $__color_path
  echo -n /color/path/
  set_color -b $__color_path_basename
  echo -ns basename ' '
  __bobthefish_start_segment $__color_repo_staged
  echo -ns $__bobthefish_branch_glyph ' '
  echo -n "color-repo-staged "
  __bobthefish_finish_segments
  echo

  __bobthefish_start_segment $__color_vi_mode_default
  echo -ns vi_mode_default ' '
  __bobthefish_finish_segments
  __bobthefish_start_segment $__color_vi_mode_insert
  echo -ns vi_mode_insert ' '
  __bobthefish_finish_segments
  __bobthefish_start_segment $__color_vi_mode_visual
  echo -ns vi_mode_visual ' '
  __bobthefish_finish_segments
  echo

  __bobthefish_start_segment $__color_vagrant
  echo -n color_vagrant ' '
  __bobthefish_finish_segments
  echo

  __bobthefish_start_segment $__color_username
  echo -n color_username ' '
  __bobthefish_finish_segments
  echo

  __bobthefish_start_segment $__color_rvm
  echo -n color_rvm ' '
  __bobthefish_finish_segments
  __bobthefish_start_segment $__color_virtualfish
  echo -ns color_virtualfish ' '
  __bobthefish_finish_segments
  echo -e "\n"

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

  switch "$theme_color_scheme"
    case 'user'
      # Do not set any variables in this section.

      # If you want to create your own color scheme, set `theme_color_scheme` to
      # `user` and define the `__color_*` variables listed below in your fish
      # startup file (`$OMF_CONFIG/init.fish`, or similar).

      # The value for each variable is an argument to pass to `set_color -b`.
      # You can copy the commented code below as a base for your custom colors.
      # Use `__bobthefish_display_colors` at the command line to easily see what
      # these variables are used for.

      # See the built-in color schemes below for more examples.

      # # Example bobthefish color scheme:
      # set -g theme_color_scheme user
      #
      # set -g __color_initial_segment_exit  ffffff ce000f --bold
      # set -g __color_initial_segment_su    ffffff 189303 --bold
      # set -g __color_initial_segment_jobs  ffffff 255e87 --bold
      #
      # set -g __color_path                  333333 999999
      # set -g __color_path_basename         333333 ffffff --bold
      # set -g __color_path_nowrite          660000 cc9999
      # set -g __color_path_nowrite_basename 660000 cc9999 --bold
      #
      # set -g __color_repo                  addc10 0c4801
      # set -g __color_repo_work_tree        addc10 ffffff --bold
      # set -g __color_repo_dirty            ce000f ffffff
      # set -g __color_repo_staged           f6b117 3a2a03
      #
      # set -g __color_vi_mode_default       999999 333333 --bold
      # set -g __color_vi_mode_insert        189303 333333 --bold
      # set -g __color_vi_mode_visual        f6b117 3a2a03 --bold
      #
      # set -g __color_vagrant               48b4fb ffffff --bold
      # set -g __color_username              cccccc 255e87
      # set -g __color_rvm                   af0000 cccccc --bold
      # set -g __color_virtualfish           005faf cccccc --bold

    case 'terminal' 'terminal-dark*'
      set -l colorfg black
      [ $theme_color_scheme = 'terminal-dark-white' ]; and set colorfg white
      set __color_initial_segment_exit     white red --bold
      set __color_initial_segment_su       white green --bold
      set __color_initial_segment_jobs     white blue --bold

      set __color_path                     black white
      set __color_path_basename            black white --bold
      set __color_path_nowrite             magenta $colorfg
      set __color_path_nowrite_basename    magenta $colorfg --bold

      set __color_repo                     green $colorfg
      set __color_repo_work_tree           green $colorfg --bold
      set __color_repo_dirty               brred $colorfg
      set __color_repo_staged              yellow $colorfg

      set __color_vi_mode_default          brblue $colorfg --bold
      set __color_vi_mode_insert           brgreen $colorfg --bold
      set __color_vi_mode_visual           bryellow $colorfg --bold

      set __color_vagrant                  brcyan $colorfg
      set __color_username                 white black
      set __color_rvm                      brmagenta $colorfg --bold
      set __color_virtualfish              brblue $colorfg --bold

    case 'terminal-light*'
      set -l colorfg white
      [ $theme_color_scheme = 'terminal-light-black' ]; and set colorfg black
      set __color_initial_segment_exit     black red --bold
      set __color_initial_segment_su       black green --bold
      set __color_initial_segment_jobs     black blue --bold

      set __color_path                     white black
      set __color_path_basename            white black --bold
      set __color_path_nowrite             magenta $colorfg
      set __color_path_nowrite_basename    magenta $colorfg --bold

      set __color_repo                     green $colorfg
      set __color_repo_work_tree           green $colorfg --bold
      set __color_repo_dirty               brred $colorfg
      set __color_repo_staged              yellow $colorfg

      set __color_vi_mode_default          brblue $colorfg --bold
      set __color_vi_mode_insert           brgreen $colorfg --bold
      set __color_vi_mode_visual           bryellow $colorfg --bold

      set __color_vagrant                  brcyan $colorfg
      set __color_username                 black white
      set __color_rvm                      brmagenta $colorfg --bold
      set __color_virtualfish              brblue $colorfg --bold

    case 'terminal2' 'terminal2-dark*'
      set -l colorfg black
      [ $theme_color_scheme = 'terminal2-dark-white' ]; and set colorfg white
      set __color_initial_segment_exit     grey red --bold
      set __color_initial_segment_su       grey green --bold
      set __color_initial_segment_jobs     grey blue --bold

      set __color_path                     brgrey white
      set __color_path_basename            brgrey white --bold
      set __color_path_nowrite             magenta $colorfg
      set __color_path_nowrite_basename    magenta $colorfg --bold

      set __color_repo                     green $colorfg
      set __color_repo_work_tree           green $colorfg --bold
      set __color_repo_dirty               brred $colorfg
      set __color_repo_staged              yellow $colorfg

      set __color_vi_mode_default          brblue $colorfg --bold
      set __color_vi_mode_insert           brgreen $colorfg --bold
      set __color_vi_mode_visual           bryellow $colorfg --bold

      set __color_vagrant                  brcyan $colorfg
      set __color_username                 brgrey white
      set __color_rvm                      brmagenta $colorfg --bold
      set __color_virtualfish              brblue $colorfg --bold

    case 'terminal2-light*'
      set -l colorfg white
      [ $theme_color_scheme = 'terminal2-light-black' ]; and set colorfg black
      set __color_initial_segment_exit     brgrey red --bold
      set __color_initial_segment_su       brgrey green --bold
      set __color_initial_segment_jobs     brgrey blue --bold

      set __color_path                     grey black
      set __color_path_basename            grey black --bold
      set __color_path_nowrite             magenta $colorfg
      set __color_path_nowrite_basename    magenta $colorfg --bold

      set __color_repo                     green $colorfg
      set __color_repo_work_tree           green $colorfg --bold
      set __color_repo_dirty               brred $colorfg
      set __color_repo_staged              yellow $colorfg

      set __color_vi_mode_default          brblue $colorfg --bold
      set __color_vi_mode_insert           brgreen $colorfg --bold
      set __color_vi_mode_visual           bryellow $colorfg --bold

      set __color_vagrant                  brcyan $colorfg
      set __color_username                 grey black
      set __color_rvm                      brmagenta $colorfg --bold
      set __color_virtualfish              brblue $colorfg --bold

    case 'zenburn'
      set -l grey   333333 # a bit darker than normal zenburn grey
      set -l red    CC9393
      set -l green  7F9F7F
      set -l yellow E3CEAB
      set -l orange DFAF8F
      set -l blue   8CD0D3
      set -l white  DCDCCC

      set __color_initial_segment_exit     $white $red --bold
      set __color_initial_segment_su       $white $green --bold
      set __color_initial_segment_jobs     $white $blue --bold

      set __color_path                     $grey $white
      set __color_path_basename            $grey $white --bold
      set __color_path_nowrite             $grey $red
      set __color_path_nowrite_basename    $grey $red --bold

      set __color_repo                     $green $grey
      set __color_repo_work_tree           $green $grey --bold
      set __color_repo_dirty               $red $grey
      set __color_repo_staged              $yellow $grey

      set __color_vi_mode_default          $grey $yellow --bold
      set __color_vi_mode_insert           $green $white --bold
      set __color_vi_mode_visual           $yellow $grey --bold

      set __color_vagrant                  $blue $green --bold
      set __color_username                 $grey $blue
      set __color_rvm                      $red $grey --bold
      set __color_virtualfish              $blue $grey --bold

    case 'base16-light'
      set -l base00 181818
      set -l base01 282828
      set -l base02 383838
      set -l base03 585858
      set -l base04 b8b8b8
      set -l base05 d8d8d8
      set -l base06 e8e8e8
      set -l base07 f8f8f8
      set -l base08 ab4642 # red
      set -l base09 dc9656 # orange
      set -l base0A f7ca88 # yellow
      set -l base0B a1b56c # green
      set -l base0C 86c1b9 # cyan
      set -l base0D 7cafc2 # blue
      set -l base0E ba8baf # violet
      set -l base0F a16946 # brown

      set -l colorfg $base00

      set __color_initial_segment_exit     $base02 $base08 --bold
      set __color_initial_segment_su       $base02 $base0B --bold
      set __color_initial_segment_jobs     $base02 $base0D --bold

      set __color_path                     $base06 $base02
      set __color_path_basename            $base06 $base01 --bold
      set __color_path_nowrite             $base06 $base08
      set __color_path_nowrite_basename    $base06 $base08 --bold

      set __color_repo                     $base0B $colorfg
      set __color_repo_work_tree           $base0B $colorfg --bold
      set __color_repo_dirty               $base08 $colorfg
      set __color_repo_staged              $base09 $colorfg

      set __color_vi_mode_default          $base04 $colorfg --bold
      set __color_vi_mode_insert           $base0B $colorfg --bold
      set __color_vi_mode_visual           $base09 $colorfg --bold

      set __color_vagrant                  $base0C $colorfg --bold
      set __color_username                 $base02 $base0D
      set __color_rvm                      $base08 $colorfg --bold
      set __color_virtualfish              $base0D $colorfg --bold

    case 'base16' 'base16-dark'
      set -l base00 181818
      set -l base01 282828
      set -l base02 383838
      set -l base03 585858
      set -l base04 b8b8b8
      set -l base05 d8d8d8
      set -l base06 e8e8e8
      set -l base07 f8f8f8
      set -l base08 ab4642 # red
      set -l base09 dc9656 # orange
      set -l base0A f7ca88 # yellow
      set -l base0B a1b56c # green
      set -l base0C 86c1b9 # cyan
      set -l base0D 7cafc2 # blue
      set -l base0E ba8baf # violet
      set -l base0F a16946 # brown

      set -l colorfg $base07

      set __color_initial_segment_exit     $base05 $base08 --bold
      set __color_initial_segment_su       $base05 $base0B --bold
      set __color_initial_segment_jobs     $base05 $base0D --bold

      set __color_path                     $base02 $base05
      set __color_path_basename            $base02 $base06 --bold
      set __color_path_nowrite             $base02 $base08
      set __color_path_nowrite_basename    $base02 $base08 --bold

      set __color_repo                     $base0B $colorfg
      set __color_repo_work_tree           $base0B $colorfg --bold
      set __color_repo_dirty               $base08 $colorfg
      set __color_repo_staged              $base09 $colorfg

      set __color_vi_mode_default          $base03 $colorfg --bold
      set __color_vi_mode_insert           $base0B $colorfg --bold
      set __color_vi_mode_visual           $base09 $colorfg --bold

      set __color_vagrant                  $base0C $colorfg --bold
      set __color_username                 $base02 $base0D
      set __color_rvm                      $base08 $colorfg --bold
      set __color_virtualfish              $base0D $colorfg --bold

    case 'solarized-light'
      set -l base03  002b36
      set -l base02  073642
      set -l base01  586e75
      set -l base00  657b83
      set -l base0   839496
      set -l base1   93a1a1
      set -l base2   eee8d5
      set -l base3   fdf6e3
      set -l yellow  b58900
      set -l orange  cb4b16
      set -l red     dc322f
      set -l magenta d33682
      set -l violet  6c71c4
      set -l blue    268bd2
      set -l cyan    2aa198
      set -l green   859900

      set colorfg $base03

      set __color_initial_segment_exit     $base02 $red --bold
      set __color_initial_segment_su       $base02 $green --bold
      set __color_initial_segment_jobs     $base02 $blue --bold

      set __color_path                     $base2 $base00
      set __color_path_basename            $base2 $base01 --bold
      set __color_path_nowrite             $base2 $orange
      set __color_path_nowrite_basename    $base2 $orange --bold

      set __color_repo                     $green $colorfg
      set __color_repo_work_tree           $green $colorfg --bold
      set __color_repo_dirty               $red $colorfg
      set __color_repo_staged              $yellow $colorfg

      set __color_vi_mode_default          $blue $colorfg --bold
      set __color_vi_mode_insert           $green $colorfg --bold
      set __color_vi_mode_visual           $yellow $colorfg --bold

      set __color_vagrant                  $violet $colorfg --bold
      set __color_username                 $base2 $blue
      set __color_rvm                      $red $colorfg --bold
      set __color_virtualfish              $cyan $colorfg --bold

    case 'solarized' 'solarized-dark'
      set -l base03  002b36
      set -l base02  073642
      set -l base01  586e75
      set -l base00  657b83
      set -l base0   839496
      set -l base1   93a1a1
      set -l base2   eee8d5
      set -l base3   fdf6e3
      set -l yellow  b58900
      set -l orange  cb4b16
      set -l red     dc322f
      set -l magenta d33682
      set -l violet  6c71c4
      set -l blue    268bd2
      set -l cyan    2aa198
      set -l green   859900

      set colorfg $base3

      set __color_initial_segment_exit     $base2 $red --bold
      set __color_initial_segment_su       $base2 $green --bold
      set __color_initial_segment_jobs     $base2 $blue --bold

      set __color_path                     $base02 $base0
      set __color_path_basename            $base02 $base1 --bold
      set __color_path_nowrite             $base02 $orange
      set __color_path_nowrite_basename    $base02 $orange --bold

      set __color_repo                     $green $colorfg
      set __color_repo_work_tree           $green $colorfg --bold
      set __color_repo_dirty               $red $colorfg
      set __color_repo_staged              $yellow $colorfg

      set __color_vi_mode_default          $blue $colorfg --bold
      set __color_vi_mode_insert           $green $colorfg --bold
      set __color_vi_mode_visual           $yellow $colorfg --bold

      set __color_vagrant                  $violet $colorfg --bold
      set __color_username                 $base02 $blue
      set __color_rvm                      $red $colorfg --bold
      set __color_virtualfish              $cyan $colorfg --bold

    case 'light'
      #               light  medium dark
      #               ------ ------ ------
      set -l red      cc9999 ce000f 660000
      set -l green    addc10 189303 0c4801
      set -l blue     48b4fb 005faf 255e87
      set -l orange   f6b117 unused 3a2a03
      set -l brown    bf5e00 803f00 4d2600
      set -l grey     cccccc 999999 333333
      set -l white    ffffff
      set -l black    000000
      set -l ruby_red af0000

      set __color_initial_segment_exit     $grey[3] $red[2] --bold
      set __color_initial_segment_su       $grey[3] $green[2] --bold
      set __color_initial_segment_jobs     $grey[3] $blue[3] --bold

      set __color_path                     $grey[1] $grey[2]
      set __color_path_basename            $grey[1] $grey[3] --bold
      set __color_path_nowrite             $red[1] $red[3]
      set __color_path_nowrite_basename    $red[1] $red[3] --bold

      set __color_repo                     $green[1] $green[3]
      set __color_repo_work_tree           $green[1] $white --bold
      set __color_repo_dirty               $red[2] $white
      set __color_repo_staged              $orange[1] $orange[3]

      set __color_vi_mode_default          $grey[2] $grey[3] --bold
      set __color_vi_mode_insert           $green[2] $grey[3] --bold
      set __color_vi_mode_visual           $orange[1] $orange[3] --bold

      set __color_vagrant                  $blue[1] $white --bold
      set __color_username                 $grey[1] $blue[3]
      set __color_rvm                      $ruby_red $grey[1] --bold
      set __color_virtualfish              $blue[2] $grey[1] --bold

    case '*' # default dark theme
      #               light  medium dark
      #               ------ ------ ------
      set -l red      cc9999 ce000f 660000
      set -l green    addc10 189303 0c4801
      set -l blue     48b4fb 005faf 255e87
      set -l orange   f6b117 unused 3a2a03
      set -l brown    bf5e00 803f00 4d2600
      set -l grey     cccccc 999999 333333
      set -l white    ffffff
      set -l black    000000
      set -l ruby_red af0000

      set __color_initial_segment_exit     $white $red[2] --bold
      set __color_initial_segment_su       $white $green[2] --bold
      set __color_initial_segment_jobs     $white $blue[3] --bold

      set __color_path                     $grey[3] $grey[2]
      set __color_path_basename            $grey[3] $white --bold
      set __color_path_nowrite             $red[3] $red[1]
      set __color_path_nowrite_basename    $red[3] $red[1] --bold

      set __color_repo                     $green[1] $green[3]
      set __color_repo_work_tree           $green[1] $white --bold
      set __color_repo_dirty               $red[2] $white
      set __color_repo_staged              $orange[1] $orange[3]

      set __color_vi_mode_default          $grey[2] $grey[3] --bold
      set __color_vi_mode_insert           $green[2] $grey[3] --bold
      set __color_vi_mode_visual           $orange[1] $orange[3] --bold

      set __color_vagrant                  $blue[1] $white --bold
      set __color_username                 $grey[1] $blue[3]
      set __color_rvm                      $ruby_red $grey[1] --bold
      set __color_virtualfish              $blue[2] $grey[1] --bold
  end

  if [ "$theme_nerd_fonts" = "yes" ]
    set __bobthefish_virtualenv_glyph \uE73C ' '
    set __bobthefish_ruby_glyph       \uE791 ' '
  end

  # Start each line with a blank slate
  set -l __bobthefish_current_bg

  __bobthefish_maybe_display_colors

  __bobthefish_prompt_status $last_status
  __bobthefish_prompt_vi
  __bobthefish_prompt_vagrant
  __bobthefish_prompt_docker
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

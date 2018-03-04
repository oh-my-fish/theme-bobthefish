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
#     set -g theme_display_git_dirty no
#     set -g theme_display_git_untracked no
#     set -g theme_display_git_ahead_verbose yes
#     set -g theme_display_git_dirty_verbose yes
#     set -g theme_display_git_master_branch no
#     set -g theme_git_worktree_support yes
#     set -g theme_display_vagrant yes
#     set -g theme_display_docker_machine no
#     set -g theme_display_k8s_context no
#     set -g theme_display_hg yes
#     set -g theme_display_virtualenv no
#     set -g theme_display_ruby no
#     set -g theme_display_user yes
#     set -g theme_display_hostname yes
#     set -g theme_display_vi no
#     set -g theme_avoid_ambiguous_glyphs yes
#     set -g theme_powerline_fonts no
#     set -g theme_nerd_fonts yes
#     set -g theme_show_exit_status yes
#     set -g default_user your_normal_user
#     set -g theme_color_scheme dark
#     set -g fish_prompt_pwd_dir_length 0
#     set -g theme_project_dir_length 1
#     set -g theme_newline_cursor yes


# ==============================
# Helper methods
# ==============================

function __bobthefish_basename -d 'basically basename, but faster'
  string replace -r '^.*/' '' -- $argv
end

function __bobthefish_dirname -d 'basically dirname, but faster'
  string replace -r '/[^/]+/?$' '' -- $argv
end

function __bobthefish_git_branch -S -d 'Get the current git branch (or commitish)'
  set -l ref (command git symbolic-ref HEAD ^/dev/null); and begin
    [ "$theme_display_git_master_branch" = 'no' -a "$ref" = 'refs/heads/master' ]
      and echo $__bobthefish_branch_glyph
      and return

    string replace 'refs/heads/' "$__bobthefish_branch_glyph " $ref
      and return
  end

  set -l tag (command git describe --tags --exact-match ^/dev/null)
    and echo "$__bobthefish_tag_glyph $tag"
    and return

  set -l branch (command git show-ref --head -s --abbrev | head -n1 ^/dev/null)
  echo "$__bobthefish_detached_glyph $branch"
end

function __bobthefish_hg_branch -S -d 'Get the current hg branch'
  set -l branch (command hg branch ^/dev/null)
  set -l book (command hg book | command grep \* | cut -d\  -f3)
  echo "$__bobthefish_branch_glyph $branch @ $book"
end

function __bobthefish_pretty_parent -S -a current_dir -d 'Print a parent directory, shortened to fit the prompt'
  set -q fish_prompt_pwd_dir_length
    or set -l fish_prompt_pwd_dir_length 1

  # Replace $HOME with ~
  set -l real_home ~
  set -l parent_dir (string replace -r '^'"$real_home"'($|/)' '~$1' (__bobthefish_dirname $current_dir))

  # Must check whether `$parent_dir = /` if using native dirname
  if [ -z "$parent_dir" ]
    echo -n /
    return
  end

  if [ $fish_prompt_pwd_dir_length -eq 0 ]
    echo -n "$parent_dir/"
    return
  end

  string replace -ar '(\.?[^/]{'"$fish_prompt_pwd_dir_length"'})[^/]*/' '$1/' "$parent_dir/"
end

function __bobthefish_ignore_vcs_dir -d 'Check whether the current directory should be ignored as a VCS segment'
  for p in $theme_vcs_ignore_paths
    set ignore_path (realpath $p ^/dev/null)
    switch $PWD/
      case $ignore_path/\*
        echo 1
        return
    end
  end
end

function __bobthefish_git_project_dir -S -d 'Print the current git project base directory'
  [ "$theme_display_git" = 'no' ]; and return

  set -q theme_vcs_ignore_paths
    and [ (__bobthefish_ignore_vcs_dir) ]
    and return

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

  set -l project_dir (__bobthefish_dirname $git_dir)

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

  set -q theme_vcs_ignore_paths
    and [ (__bobthefish_ignore_vcs_dir) ]
    and return

  set -l d $PWD
  while not [ -z "$d" ]
    if [ -e $d/.hg ]
      command hg root --cwd "$d" ^/dev/null
      return
    end
    [ "$d" = '/' ]; and return
    set d (__bobthefish_dirname $d)
  end
end

function __bobthefish_project_pwd -S -a current_dir -d 'Print the working directory relative to project root'
  set -q theme_project_dir_length
    or set -l theme_project_dir_length 0

  set -l project_dir (string replace -r '^'"$current_dir"'($|/)' '' $PWD)

  if [ $theme_project_dir_length -eq 0 ]
    echo -n $project_dir
    return
  end

  string replace -ar '(\.?[^/]{'"$theme_project_dir_length"'})[^/]*/' '$1/' $project_dir
end

function __bobthefish_git_ahead -S -d 'Print the ahead/behind state for the current branch'
  if [ "$theme_display_git_ahead_verbose" = 'yes' ]
    __bobthefish_git_ahead_verbose
    return
  end

  set -l ahead 0
  set -l behind 0
  for line in (command git rev-list --left-right '@{upstream}...HEAD' ^/dev/null)
    switch "$line"
      case '>*'
        if [ $behind -eq 1 ]
          echo '±'
          return
        end
        set ahead 1
      case '<*'
        if [ $ahead -eq 1 ]
          echo "$__bobthefish_git_plus_minus_glyph"
          return
        end
        set behind 1
    end
  end

  if [ $ahead -eq 1 ]
    echo "$__bobthefish_git_plus_glyph"
  else if [ $behind -eq 1 ]
    echo "$__bobthefish_git_minus_glyph"
  end
end

function __bobthefish_git_ahead_verbose -S -d 'Print a more verbose ahead/behind state for the current branch'
  set -l commits (command git rev-list --left-right '@{upstream}...HEAD' ^/dev/null)
    or return

  set -l behind (count (for arg in $commits; echo $arg; end | command grep '^<'))
  set -l ahead (count (for arg in $commits; echo $arg; end | command grep -v '^<'))

  switch "$ahead $behind"
    case '' # no upstream
    case '0 0' # equal to upstream
      return
    case '* 0' # ahead of upstream
      echo "$__bobthefish_git_ahead_glyph$ahead"
    case '0 *' # behind upstream
      echo "$__bobthefish_git_behind_glyph$behind"
    case '*' # diverged from upstream
      echo "$__bobthefish_git_ahead_glyph$ahead$__bobthefish_git_behind_glyph$behind"
  end
end

function __bobthefish_git_dirty_verbose -S -d 'Print a more verbose dirty state for the current working tree'
  set -l changes (command git diff --numstat | awk '{ added += $1; removed += $2 } END { print "+" added "/-" removed }')
    or return

  echo "$changes " | string replace -r '(\+0/(-0)?|/-0)' ''
end

# ==============================
# Segment functions
# ==============================

function __bobthefish_start_segment -S -d 'Start a prompt segment'
  set -l bg $argv[1]
  set -e argv[1]
  set -l fg $argv[1]
  set -e argv[1]

  set_color normal # clear out anything bold or underline...
  set_color -b $bg $fg $argv

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
      set directory (__bobthefish_basename "$current_dir")
  end

  echo -n $parent
  set_color -b $segment_basename_color
  echo -ns $directory ' '
end

function __bobthefish_finish_segments -S -d 'Close open prompt segments'
  if [ -n "$__bobthefish_current_bg" ]
    set_color normal
    set_color $__bobthefish_current_bg
    echo -ns $__bobthefish_right_black_arrow_glyph ' '
  end

  if [ "$theme_newline_cursor" = 'yes' ]
    echo -ens "\n"
    set_color $fish_color_autosuggestion
    if [ "$theme_powerline_fonts" = "no" ]
      echo -ns '> '
    else
      echo -ns "$__bobthefish_right_arrow_glyph "
    end
  else if [ "$theme_newline_cursor" = 'clean' ]
    echo -ens "\n"
  end

  set_color normal
  set __bobthefish_current_bg
end


# ==============================
# Status and input mode segments
# ==============================

function __bobthefish_prompt_status -S -a last_status -d 'Display flags for a non-zero exit status, root user, and background jobs'
  set -l nonzero
  set -l superuser
  set -l bg_jobs

  # Last exit was nonzero
  [ $last_status -ne 0 ]
    and set nonzero 1

  # If superuser (uid == 0)
  #
  # Note that iff the current user is root and '/' is not writeable by root this
  # will be wrong. But I can't think of a single reason that would happen, and
  # it is literally 99.5% faster to check it this way, so that's a tradeoff I'm
  # willing to make.
  [ -w / ]
    and [ (id -u) -eq 0 ]
    and set superuser 1

  # Jobs display
  jobs -p >/dev/null
    and set bg_jobs 1

  if [ "$nonzero" -o "$superuser" -o "$bg_jobs" ]
    __bobthefish_start_segment $__color_initial_segment_exit
    if [ "$nonzero" ]
      set_color normal
      set_color -b $__color_initial_segment_exit
      if [ "$theme_show_exit_status" = 'yes' ]
        echo -ns $last_status ' '
      else
        echo -n $__bobthefish_nonzero_exit_glyph
      end
    end

    if [ "$superuser" ]
      set_color normal
      if [ -z "$FAKEROOTKEY" ]
        set_color -b $__color_initial_segment_su
      else
        set_color -b $__color_initial_segment_exit
      end

      echo -n $__bobthefish_superuser_glyph
    end

    if [ "$bg_jobs" ]
      set_color normal
      set_color -b $__color_initial_segment_jobs
      echo -n $__bobthefish_bg_job_glyph
    end
  end
end

function __bobthefish_prompt_vi -S -d 'Display vi mode'
  [ "$theme_display_vi" != 'no' ]; or return
  [ "$fish_key_bindings" = 'fish_vi_key_bindings' \
    -o "$fish_key_bindings" = 'hybrid_bindings' \
    -o "$fish_key_bindings" = 'fish_hybrid_key_bindings' \
    -o "$theme_display_vi" = 'yes' ]; or return
  switch $fish_bind_mode
    case default
      __bobthefish_start_segment $__color_vi_mode_default
      echo -n 'N '
    case insert
      __bobthefish_start_segment $__color_vi_mode_insert
      echo -n 'I '
    case replace_one replace-one
      __bobthefish_start_segment $__color_vi_mode_insert
      echo -n 'R '
    case visual
      __bobthefish_start_segment $__color_vi_mode_visual
      echo -n 'V '
  end
end


# ==============================
# Container and VM segments
# ==============================

function __bobthefish_prompt_vagrant -S -d 'Display Vagrant status'
  [ "$theme_display_vagrant" = 'yes' -a -f Vagrantfile ]; or return

  # .vagrant/machines/$machine/$provider/id
  for file in .vagrant/machines/*/*/id
    read -l id <"$file"

    if [ -n "$id" ]
      switch "$file"
        case '*/virtualbox/id'
          __bobthefish_prompt_vagrant_vbox $id
        case '*/vmware_fusion/id'
          __bobthefish_prompt_vagrant_vmware $id
        case '*/parallels/id'
          __bobthefish_prompt_vagrant_parallels $id
      end
    end
  end
end

function __bobthefish_prompt_vagrant_vbox -S -a id -d 'Display VirtualBox Vagrant status'
  set -l vagrant_status
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
  [ -z "$vagrant_status" ]; and return

  __bobthefish_start_segment $__color_vagrant
  echo -ns $vagrant_status ' '
end

function __bobthefish_prompt_vagrant_vmware -S -a id -d 'Display VMWare Vagrant status'
  set -l vagrant_status
  if [ (pgrep -f "$id") ]
    set vagrant_status "$vagrant_status$__bobthefish_vagrant_running_glyph"
  else
    set vagrant_status "$vagrant_status$__bobthefish_vagrant_poweroff_glyph"
  end
  [ -z "$vagrant_status" ]; and return

  __bobthefish_start_segment $__color_vagrant
  echo -ns $vagrant_status ' '
end

function __bobthefish_prompt_vagrant_parallels -S -d 'Display Parallels Vagrant status'
  set -l vagrant_status
  set -l vm_status (prlctl list $id -o status ^/dev/null | command tail -1)
  switch "$vm_status"
    case 'running'
      set vagrant_status "$vagrant_status$__bobthefish_vagrant_running_glyph"
    case 'stopped'
      set vagrant_status "$vagrant_status$__bobthefish_vagrant_poweroff_glyph"
    case 'paused'
      set vagrant_status "$vagrant_status$__bobthefish_vagrant_saved_glyph"
    case 'suspended'
      set vagrant_status "$vagrant_status$__bobthefish_vagrant_saved_glyph"
    case 'stopping'
      set vagrant_status "$vagrant_status$__bobthefish_vagrant_stopping_glyph"
    case ''
      set vagrant_status "$vagrant_status$__bobthefish_vagrant_unknown_glyph"
  end
  [ -z "$vagrant_status" ]; and return

  __bobthefish_start_segment $__color_vagrant
  echo -ns $vagrant_status ' '
end

function __bobthefish_prompt_docker -S -d 'Display Docker machine name'
  [ "$theme_display_docker_machine" = 'no' -o -z "$DOCKER_MACHINE_NAME" ]; and return
  __bobthefish_start_segment $__color_vagrant
  echo -ns $DOCKER_MACHINE_NAME ' '
end

function __bobthefish_prompt_k8s_context -S -d 'Show current Kubernetes context'
  [ "$theme_display_k8s_context" = 'no' ]; and return

  set -l config_paths "$HOME/.kube/config"
  [ -n "$KUBECONFIG" ]
    and set config_paths (string split ':' "$KUBECONFIG") $config_paths

  for file in $config_paths
    [ -f "$file" ]; or continue

    while read -l key val
      if [ "$key" = 'current-context:' ]
        set -l context (string trim -c '"\' ' -- $val)
        [ -z "$context" ]; and return

        __bobthefish_start_segment $__color_k8s
        echo -ns $context ' '
        return
      end
    end < $file
  end
end


# ==============================
# User / hostname info segments
# ==============================

function __bobthefish_prompt_user -S -d 'Display current user and hostname'
  [ "$theme_display_user" = 'yes' -o -n "$SSH_CLIENT" -o \( -n "$default_user" -a "$USER" != "$default_user" \) ]
    and set -l display_user
  [ "$theme_display_hostname" = 'yes' -o -n "$SSH_CLIENT" ]
    and set -l display_hostname

  if set -q display_user
    __bobthefish_start_segment $__color_username
    echo -ns (whoami)
  end

  if set -q display_hostname
    set -l IFS .
    hostname | read -l hostname __
    if set -q display_user
      # reset colors without starting a new segment...
      # (so we can have a bold username and non-bold hostname)
      set_color normal
      set_color -b $__color_hostname[1] $__color_hostname[2..-1]
      echo -ns '@' $hostname
    else
      __bobthefish_start_segment $__color_hostname
      echo -ns $hostname
    end
  end

  set -q display_user
    or set -q display_hostname
    and echo -ns ' '
end


# ==============================
# Virtual environment segments
# ==============================

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

function __bobthefish_prompt_rubies -S -d 'Display current Ruby information'
  [ "$theme_display_ruby" = 'no' ]; and return

  set -l ruby_version
  if type -q rvm-prompt
    set ruby_version (__bobthefish_rvm_info)
  else if type -q rbenv
    set ruby_version (rbenv version-name)
    # Don't show global ruby version...
    set -q RBENV_ROOT
      or set -l RBENV_ROOT $HOME/.rbenv

    [ -e "$RBENV_ROOT/version" ]
      and read -l global_ruby_version <"$RBENV_ROOT/version"

    [ "$global_ruby_version" ]
      or set -l global_ruby_version system

    [ "$ruby_version" = "$global_ruby_version" ]; and return
  else if type -q chruby
    set ruby_version $RUBY_VERSION
  else if type -q asdf
    asdf current ruby ^/dev/null | read -l asdf_ruby_version asdf_provenance
      or return

    # If asdf changes their ruby version provenance format, update this to match
    [ "$asdf_provenance" = "(set by $HOME/.tool-versions)" ]; and return

    set ruby_version $asdf_ruby_version
  end
  [ -z "$ruby_version" ]; and return
  __bobthefish_start_segment $__color_rvm
  echo -ns $__bobthefish_ruby_glyph $ruby_version ' '
end

function __bobthefish_virtualenv_python_version -S -d 'Get current Python version'
  switch (python --version ^&1 | tr '\n' ' ')
    case 'Python 2*PyPy*'
      echo $__bobthefish_pypy_glyph
    case 'Python 3*PyPy*'
      echo -s $__bobthefish_pypy_glyph $__bobthefish_superscript_glyph[3]
    case 'Python 2*'
      echo $__bobthefish_superscript_glyph[2]
    case 'Python 3*'
      echo $__bobthefish_superscript_glyph[3]
  end
end

function __bobthefish_prompt_virtualfish -S -d "Display current Python virtual environment (only for virtualfish, virtualenv's activate.fish changes prompt by itself)"
  [ "$theme_display_virtualenv" = 'no' -o -z "$VIRTUAL_ENV" ]; and return
  set -l version_glyph (__bobthefish_virtualenv_python_version)
  if [ "$version_glyph" ]
    __bobthefish_start_segment $__color_virtualfish
    echo -ns $__bobthefish_virtualenv_glyph $version_glyph ' '
  end
  echo -ns (basename "$VIRTUAL_ENV") ' '
end

function __bobthefish_prompt_virtualgo -S -d 'Display current Go virtual environment'
  [ "$theme_display_virtualgo" = 'no' -o -z "$VIRTUALGO" ]; and return
  __bobthefish_start_segment $__color_virtualgo
  echo -ns $__bobthefish_go_glyph
  echo -ns (basename "$VIRTUALGO") ' '
  set_color normal
end


# ==============================
# VCS segments
# ==============================

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
  set -l dirty ''
  if [ "$theme_display_git_dirty" != 'no' ]
    set -l show_dirty (command git config --bool bash.showDirtyState ^/dev/null)
    if [ "$show_dirty" != 'false' ]
      set dirty (command git diff --no-ext-diff --quiet --exit-code ^/dev/null; or echo -n "$__bobthefish_git_dirty_glyph")
      if [ "$dirty" -a "$theme_display_git_dirty_verbose" = 'yes' ]
        set dirty "$dirty"(__bobthefish_git_dirty_verbose)
      end
    end
  end

  set -l staged  (command git diff --cached --no-ext-diff --quiet --exit-code ^/dev/null; or echo -n "$__bobthefish_git_staged_glyph")
  set -l stashed (command git rev-parse --verify --quiet refs/stash >/dev/null; and echo -n "$__bobthefish_git_stashed_glyph")
  set -l ahead   (__bobthefish_git_ahead)

  set -l new ''
  if [ "$theme_display_git_untracked" != 'no' ]
    set -l show_untracked (command git config --bool bash.showUntrackedFiles ^/dev/null)
    if [ "$show_untracked" != 'false' ]
      set new (command git ls-files --other --exclude-standard --directory --no-empty-directory ^/dev/null)
      if [ "$new" ]
        set new "$__bobthefish_git_untracked_glyph"
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

  set -l project_pwd (command git rev-parse --show-prefix ^/dev/null | string trim --right --chars=/)
  set -l work_dir (command git rev-parse --show-toplevel ^/dev/null)

  # only show work dir if it's a parent…
  if [ "$work_dir" ]
    switch $PWD/
      case $work_dir/\*
        string match "$current_dir*" $work_dir >/dev/null
          and set work_dir (string sub -s (math 1 + (string length $current_dir)) $work_dir)
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
      set -l work_parent (__bobthefish_dirname $work_dir)
      if [ "$work_parent" ]
        echo -n "$work_parent/"
      end
      set_color normal
      set_color -b $__color_repo_work_tree
      echo -n (__bobthefish_basename $work_dir)
      set_color normal
      set_color -b $colors
      [ "$project_pwd" ]
        and echo -n '/'
    end

    echo -ns $project_pwd ' '
  else
    set project_pwd $PWD
    string match "$current_dir*" $project_pwd >/dev/null
      and set project_pwd (string sub -s (math 1 + (string length $current_dir)) $project_pwd)
    set project_pwd (string trim --left --chars=/ -- $project_pwd)

    if [ "$project_pwd" ]
      set -l colors $__color_path
      if not [ -w "$PWD" ]
        set colors $__color_path_nowrite
      end

      __bobthefish_start_segment $colors

      echo -ns $project_pwd ' '
    end
  end
end

function __bobthefish_prompt_dir -S -d 'Display a shortened form of the current directory'
  __bobthefish_path_segment "$PWD"
end


# ==============================
# Debugging functions
# ==============================

function __bobthefish_display_colors -d 'Print example prompts using the current color scheme'
  set -g __bobthefish_display_colors
end

function __bobthefish_maybe_display_colors -S
  set -q __bobthefish_display_colors; or return
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
  echo -n "(<- initial_segment)"
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
  echo -n "$__bobthefish_branch_glyph repo $__bobthefish_git_stashed_glyph "
  __bobthefish_finish_segments
  echo

  __bobthefish_start_segment $__color_path
  echo -n /color/path/
  set_color -b $__color_path_basename
  echo -ns basename ' '
  __bobthefish_start_segment $__color_repo_dirty
  echo -n "$__bobthefish_tag_glyph repo_dirty $__bobthefish_git_dirty_glyph "
  __bobthefish_finish_segments
  echo

  __bobthefish_start_segment $__color_path
  echo -n /color/path/
  set_color -b $__color_path_basename
  echo -ns basename ' '
  __bobthefish_start_segment $__color_repo_staged
  echo -n "$__bobthefish_detached_glyph repo_staged $__bobthefish_git_staged_glyph "
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
  echo -ns $__bobthefish_vagrant_running_glyph ' ' vagrant ' '
  __bobthefish_finish_segments
  echo

  __bobthefish_start_segment $__color_username
  echo -n username
  set_color normal
  set_color -b $__color_hostname[1] $__color_hostname[2..-1]
  echo -ns @hostname ' '
  __bobthefish_finish_segments
  echo

  __bobthefish_start_segment $__color_rvm
  echo -ns $__bobthefish_ruby_glyph rvm ' '
  __bobthefish_finish_segments

  __bobthefish_start_segment $__color_virtualfish
  echo -ns $__bobthefish_virtualenv_glyph virtualfish ' '
  __bobthefish_finish_segments

  __bobthefish_start_segment $__color_virtualgo
  echo -ns $__bobthefish_go_glyph virtualgo ' '
  __bobthefish_finish_segments

  echo -e "\n"

end


# ==============================
# Apply theme
# ==============================

function fish_prompt -d 'bobthefish, a fish theme optimized for awesome'
  # Save the last status for later (do this before the `set` calls below)
  set -l last_status $status

  # Powerline glyphs
  set -l __bobthefish_branch_glyph            \uE0A0
  set -l __bobthefish_right_black_arrow_glyph \uE0B0
  set -l __bobthefish_right_arrow_glyph       \uE0B1
  set -l __bobthefish_left_black_arrow_glyph  \uE0B2
  set -l __bobthefish_left_arrow_glyph        \uE0B3

  # Additional glyphs
  set -l __bobthefish_detached_glyph          \u27A6
  set -l __bobthefish_tag_glyph               \u2302
  set -l __bobthefish_nonzero_exit_glyph      '! '
  set -l __bobthefish_superuser_glyph         '$ '
  set -l __bobthefish_bg_job_glyph            '% '
  set -l __bobthefish_hg_glyph                \u263F

  # Python glyphs
  set -l __bobthefish_superscript_glyph       \u00B9 \u00B2 \u00B3
  set -l __bobthefish_virtualenv_glyph        \u25F0
  set -l __bobthefish_pypy_glyph              \u1D56

  set -l __bobthefish_ruby_glyph              ''
  set -l __bobthefish_go_glyph                ''

  # Vagrant glyphs
  set -l __bobthefish_vagrant_running_glyph   \u2191 # ↑ 'running'
  set -l __bobthefish_vagrant_poweroff_glyph  \u2193 # ↓ 'poweroff'
  set -l __bobthefish_vagrant_aborted_glyph   \u2715 # ✕ 'aborted'
  set -l __bobthefish_vagrant_saved_glyph     \u21E1 # ⇡ 'saved'
  set -l __bobthefish_vagrant_stopping_glyph  \u21E3 # ⇣ 'stopping'
  set -l __bobthefish_vagrant_unknown_glyph   '!'    # strange cases

  # Git glyphs
  set -l __bobthefish_git_dirty_glyph      '*'
  set -l __bobthefish_git_staged_glyph     '~'
  set -l __bobthefish_git_stashed_glyph    '$'
  set -l __bobthefish_git_untracked_glyph  '…'
  set -l __bobthefish_git_ahead_glyph      \u2191 # '↑'
  set -l __bobthefish_git_behind_glyph     \u2193 # '↓'
  set -l __bobthefish_git_plus_glyph       '+'
  set -l __bobthefish_git_minus_glyph      '-'
  set -l __bobthefish_git_plus_minus_glyph '±'

  # Disable Powerline fonts
  if [ "$theme_powerline_fonts" = "no" ]
    set __bobthefish_branch_glyph            \u2387
    set __bobthefish_right_black_arrow_glyph ''
    set __bobthefish_right_arrow_glyph       ''
    set __bobthefish_left_black_arrow_glyph  ''
    set __bobthefish_left_arrow_glyph        ''
  end

  # Use prettier Nerd Fonts glyphs
  if [ "$theme_nerd_fonts" = "yes" ]
    set __bobthefish_branch_glyph     \uF418
    set __bobthefish_detached_glyph   \uF417
    set __bobthefish_tag_glyph        \uF412

    set __bobthefish_virtualenv_glyph \uE73C ' '
    set __bobthefish_ruby_glyph       \uE791 ' '
    set __bobthefish_go_glyph         \uE626 ' '

    set __bobthefish_vagrant_running_glyph  \uF431 # ↑ 'running'
    set __bobthefish_vagrant_poweroff_glyph \uF433 # ↓ 'poweroff'
    set __bobthefish_vagrant_aborted_glyph  \uF468 # ✕ 'aborted'
    set __bobthefish_vagrant_unknown_glyph  \uF421 # strange cases

    set __bobthefish_git_dirty_glyph      \uF448 '' # nf-oct-pencil
    set __bobthefish_git_staged_glyph     \uF0C7 '' # nf-fa-save
    set __bobthefish_git_stashed_glyph    \uF0C6 '' # nf-fa-paperclip
    set __bobthefish_git_untracked_glyph  \uF128 '' # nf-fa-question
    # set __bobthefish_git_untracked_glyph  \uF141 '' # nf-fa-ellipsis_h

    set __bobthefish_git_ahead_glyph      \uF47B # nf-oct-chevron_up
    set __bobthefish_git_behind_glyph     \uF47C # nf-oct-chevron_down

    set __bobthefish_git_plus_glyph       \uF0DE # fa-sort-asc
    set __bobthefish_git_minus_glyph      \uF0DD # fa-sort-desc
    set __bobthefish_git_plus_minus_glyph \uF0DC # fa-sort
  end

  # Avoid ambiguous glyphs
  if [ "$theme_avoid_ambiguous_glyphs" = "yes" ]
    set __bobthefish_git_untracked_glyph '...'
  end


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
      # set -g __color_repo_work_tree        333333 ffffff --bold
      # set -g __color_repo_dirty            ce000f ffffff
      # set -g __color_repo_staged           f6b117 3a2a03
      #
      # set -g __color_vi_mode_default       999999 333333 --bold
      # set -g __color_vi_mode_insert        189303 333333 --bold
      # set -g __color_vi_mode_visual        f6b117 3a2a03 --bold
      #
      # set -g __color_vagrant               48b4fb ffffff --bold
      # set -g __color_username              cccccc 255e87 --bold
      # set -g __color_hostname              cccccc 255e87
      # set -g __color_rvm                   af0000 cccccc --bold
      # set -g __color_virtualfish           005faf cccccc --bold
      # set -g __color_virtualgo             005faf cccccc --bold

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
      set __color_repo_work_tree           black $colorfg --bold
      set __color_repo_dirty               brred $colorfg
      set __color_repo_staged              yellow $colorfg

      set __color_vi_mode_default          brblue $colorfg --bold
      set __color_vi_mode_insert           brgreen $colorfg --bold
      set __color_vi_mode_visual           bryellow $colorfg --bold

      set __color_vagrant                  brcyan $colorfg
      set __color_k8s                      magenta white --bold
      set __color_username                 white black --bold
      set __color_hostname                 white black
      set __color_rvm                      brmagenta $colorfg --bold
      set __color_virtualfish              brblue $colorfg --bold
      set __color_virtualgo                brblue $colorfg --bold

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
      set __color_repo_work_tree           white $colorfg --bold
      set __color_repo_dirty               brred $colorfg
      set __color_repo_staged              yellow $colorfg

      set __color_vi_mode_default          brblue $colorfg --bold
      set __color_vi_mode_insert           brgreen $colorfg --bold
      set __color_vi_mode_visual           bryellow $colorfg --bold

      set __color_vagrant                  brcyan $colorfg
      set __color_k8s                      magenta white --bold
      set __color_username                 black white --bold
      set __color_hostname                 black white
      set __color_rvm                      brmagenta $colorfg --bold
      set __color_virtualfish              brblue $colorfg --bold
      set __color_virtualgo                brblue $colorfg --bold

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
      set __color_repo_work_tree           brgrey $colorfg --bold
      set __color_repo_dirty               brred $colorfg
      set __color_repo_staged              yellow $colorfg

      set __color_vi_mode_default          brblue $colorfg --bold
      set __color_vi_mode_insert           brgreen $colorfg --bold
      set __color_vi_mode_visual           bryellow $colorfg --bold

      set __color_vagrant                  brcyan $colorfg
      set __color_k8s                      magenta white --bold
      set __color_username                 brgrey white --bold
      set __color_hostname                 brgrey white
      set __color_rvm                      brmagenta $colorfg --bold
      set __color_virtualfish              brblue $colorfg --bold
      set __color_virtualgo                brblue $colorfg --bold

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
      set __color_repo_work_tree           grey $colorfg --bold
      set __color_repo_dirty               brred $colorfg
      set __color_repo_staged              yellow $colorfg

      set __color_vi_mode_default          brblue $colorfg --bold
      set __color_vi_mode_insert           brgreen $colorfg --bold
      set __color_vi_mode_visual           bryellow $colorfg --bold

      set __color_vagrant                  brcyan $colorfg
      set __color_k8s                      magenta white --bold
      set __color_username                 grey black --bold
      set __color_hostname                 grey black
      set __color_rvm                      brmagenta $colorfg --bold
      set __color_virtualfish              brblue $colorfg --bold
      set __color_virtualgo                brblue $colorfg --bold

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
      set __color_repo_work_tree           $grey $grey --bold
      set __color_repo_dirty               $red $grey
      set __color_repo_staged              $yellow $grey

      set __color_vi_mode_default          $grey $yellow --bold
      set __color_vi_mode_insert           $green $white --bold
      set __color_vi_mode_visual           $yellow $grey --bold

      set __color_vagrant                  $blue $green --bold
      set __color_k8s                      $green $white --bold
      set __color_username                 $grey $blue --bold
      set __color_hostname                 $grey $blue
      set __color_rvm                      $red $grey --bold
      set __color_virtualfish              $blue $grey --bold
      set __color_virtualgo                $blue $grey --bold

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
      set __color_repo_work_tree           $base06 $colorfg --bold
      set __color_repo_dirty               $base08 $colorfg
      set __color_repo_staged              $base09 $colorfg

      set __color_vi_mode_default          $base04 $colorfg --bold
      set __color_vi_mode_insert           $base0B $colorfg --bold
      set __color_vi_mode_visual           $base09 $colorfg --bold

      set __color_vagrant                  $base0C $colorfg --bold
      set __color_k8s                      $base06 $colorfg --bold
      set __color_username                 $base02 $base0D --bold
      set __color_hostname                 $base02 $base0D
      set __color_rvm                      $base08 $colorfg --bold
      set __color_virtualfish              $base0D $colorfg --bold
      set __color_virtualgo                $base0D $colorfg --bold

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
      set __color_repo_work_tree           $base02 $colorfg --bold
      set __color_repo_dirty               $base08 $colorfg
      set __color_repo_staged              $base09 $colorfg

      set __color_vi_mode_default          $base03 $colorfg --bold
      set __color_vi_mode_insert           $base0B $colorfg --bold
      set __color_vi_mode_visual           $base09 $colorfg --bold

      set __color_vagrant                  $base0C $colorfg --bold
      set __color_k8s                      $base0B $colorfg --bold
      set __color_username                 $base02 $base0D --bold
      set __color_hostname                 $base02 $base0D
      set __color_rvm                      $base08 $colorfg --bold
      set __color_virtualfish              $base0D $colorfg --bold
      set __color_virtualgo                $base0D $colorfg --bold

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
      set __color_repo_work_tree           $base2 $colorfg --bold
      set __color_repo_dirty               $red $colorfg
      set __color_repo_staged              $yellow $colorfg

      set __color_vi_mode_default          $blue $colorfg --bold
      set __color_vi_mode_insert           $green $colorfg --bold
      set __color_vi_mode_visual           $yellow $colorfg --bold

      set __color_vagrant                  $violet $colorfg --bold
      set __color_k8s                      $green $colorfg --bold
      set __color_username                 $base2 $blue --bold
      set __color_hostname                 $base2 $blue
      set __color_rvm                      $red $colorfg --bold
      set __color_virtualfish              $cyan $colorfg --bold
      set __color_virtualgo                $cyan $colorfg --bold

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
      set __color_repo_work_tree           $base02 $colorfg --bold
      set __color_repo_dirty               $red $colorfg
      set __color_repo_staged              $yellow $colorfg

      set __color_vi_mode_default          $blue $colorfg --bold
      set __color_vi_mode_insert           $green $colorfg --bold
      set __color_vi_mode_visual           $yellow $colorfg --bold

      set __color_vagrant                  $violet $colorfg --bold
      set __color_k8s                      $green $colorfg --bold
      set __color_username                 $base02 $blue --bold
      set __color_hostname                 $base02 $blue
      set __color_rvm                      $red $colorfg --bold
      set __color_virtualfish              $cyan $colorfg --bold
      set __color_virtualgo                $cyan $colorfg --bold

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
      set __color_repo_work_tree           $grey[1] $white --bold
      set __color_repo_dirty               $red[2] $white
      set __color_repo_staged              $orange[1] $orange[3]

      set __color_vi_mode_default          $grey[2] $grey[3] --bold
      set __color_vi_mode_insert           $green[2] $grey[3] --bold
      set __color_vi_mode_visual           $orange[1] $orange[3] --bold

      set __color_vagrant                  $blue[1] $white --bold
      set __color_k8s                      $green[1] $colorfg --bold
      set __color_username                 $grey[1] $blue[3] --bold
      set __color_hostname                 $grey[1] $blue[3]
      set __color_rvm                      $ruby_red $grey[1] --bold
      set __color_virtualfish              $blue[2] $grey[1] --bold
      set __color_virtualgo                $blue[2] $grey[1] --bold

    case 'gruvbox'
      #               light  medium  dark  darkest
      #               ------ ------ ------ -------
      set -l red      fb4934 cc241d
      set -l green    b8bb26 98971a
      set -l yellow   fabd2f d79921
      set -l aqua     8ec07c 689d6a
      set -l blue     83a598 458588
      set -l grey     cccccc 999999 333333
      set -l fg       fbf1c7 ebdbb2 d5c4a1 a89984
      set -l bg       504945 282828

      set __color_initial_segment_exit  $fg[1] $red[2] --bold
      set __color_initial_segment_su    $fg[1] $green[2] --bold
      set __color_initial_segment_jobs  $fg[1] $aqua[2] --bold

      set __color_path                  $bg[1] $fg[2]
      set __color_path_basename         $bg[1] $fg[2] --bold
      set __color_path_nowrite          $red[1] $fg[2]
      set __color_path_nowrite_basename $red[1] $fg[2] --bold

      set __color_repo                  $green[2] $bg[1]
      set __color_repo_work_tree        $bg[1] $fg[2] --bold
      set __color_repo_dirty            $red[2] $fg[2]
      set __color_repo_staged           $yellow[1] $bg[1]

      set __color_vi_mode_default       $fg[4] $bg[2] --bold
      set __color_vi_mode_insert        $blue[1] $bg[2] --bold
      set __color_vi_mode_visual        $yellow[1] $bg[2] --bold

      set __color_vagrant               $blue[2] $fg[2] --bold
      set __color_k8s                   $green[2] $fg[2] --bold
      set __color_username              $fg[3] $blue[2] --bold
      set __color_hostname              $fg[3] $blue[2]
      set __color_rvm                   $red[2] $fg[2] --bold
      set __color_virtualfish           $blue[2] $fg[2] --bold
      set __color_virtualgo             $blue[2] $fg[2] --bold

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
      set __color_repo_work_tree           $grey[3] $white --bold
      set __color_repo_dirty               $red[2] $white
      set __color_repo_staged              $orange[1] $orange[3]

      set __color_vi_mode_default          $grey[2] $grey[3] --bold
      set __color_vi_mode_insert           $green[2] $grey[3] --bold
      set __color_vi_mode_visual           $orange[1] $orange[3] --bold

      set __color_vagrant                  $blue[1] $white --bold
      set __color_k8s                      $green[2] $white --bold
      set __color_username                 $grey[1] $blue[3] --bold
      set __color_hostname                 $grey[1] $blue[3]
      set __color_rvm                      $ruby_red $grey[1] --bold
      set __color_virtualfish              $blue[2] $grey[1] --bold
      set __color_virtualgo                $blue[2] $grey[1] --bold
  end

  # Start each line with a blank slate
  set -l __bobthefish_current_bg

  # Internal: used for testing color schemes
  __bobthefish_maybe_display_colors

  # Status flags and input mode
  __bobthefish_prompt_status $last_status
  __bobthefish_prompt_vi

  # Containers and VMs
  __bobthefish_prompt_vagrant
  __bobthefish_prompt_docker
  __bobthefish_prompt_k8s_context

  # User / hostname info
  __bobthefish_prompt_user

  # Virtual environments
  __bobthefish_prompt_rubies
  __bobthefish_prompt_virtualfish
  __bobthefish_prompt_virtualgo

  # VCS
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

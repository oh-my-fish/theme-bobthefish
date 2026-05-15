function __bobthefish_git_counts -S -d 'Print behind and ahead counts for the current branch'
    set -l counts (command git rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null)
    or return

    set counts (string split \t -- $counts)
    if [ (count $counts) -lt 2 ]
        set counts (string split ' ' -- $counts)
    end

    [ (count $counts) -ge 2 ]
    or return

    printf '%s\n%s\n' $counts[1] $counts[2]
end

function __bobthefish_git_branch -S -d 'Get the current git branch (or commitish)'
    set -l tag (command git describe --tags --exact-match 2>/dev/null)
    set -l branch (command git symbolic-ref --quiet --short HEAD 2>/dev/null)

    set -l detached
    [ -z "$tag" -a -z "$branch" ]
    and set detached (command git rev-parse --short HEAD 2>/dev/null)

    # Only resolve the configured default branch when it's actually needed
    set -l configured_default_branch
    [ -n "$branch" -a -z "$theme_git_default_branches" ]
    and set configured_default_branch (command git config init.defaultBranch 2>/dev/null)

    __bobthefish_git_branch_from_parts "$tag" "$branch" "$detached" "$configured_default_branch"
end

function __bobthefish_git_ahead -S -d 'Print the ahead/behind state for the current branch'
    if [ "$theme_display_git_ahead_verbose" = yes ]
        __bobthefish_git_ahead_verbose
        return
    end

    set -l counts (__bobthefish_git_counts)
    or return

    set -l behind $counts[1]
    set -l ahead $counts[2]

    if [ $ahead -gt 0 -a $behind -gt 0 ]
        echo "$git_plus_minus_glyph"
    else if [ $ahead -gt 0 ]
        echo "$git_plus_glyph"
    else if [ $behind -gt 0 ]
        echo "$git_minus_glyph"
    end
end

function __bobthefish_git_ahead_verbose -S -d 'Print a more verbose ahead/behind state for the current branch'
    set -l counts (__bobthefish_git_counts)
    or return

    set -l behind $counts[1]
    set -l ahead $counts[2]

    switch "$ahead $behind"
        case '' # no upstream
        case '0 0' # equal to upstream
            return
        case '* 0' # ahead of upstream
            echo "$git_ahead_glyph$ahead"
        case '0 *' # behind upstream
            echo "$git_behind_glyph$behind"
        case '*' # diverged from upstream
            echo "$git_ahead_glyph$ahead$git_behind_glyph$behind"
    end
end

function __bobthefish_git_dirty_verbose -S -d 'Print a more verbose dirty state for the current working tree'
    set -l diff_stats (command git diff --numstat)
    or return

    set -l added 0
    set -l removed 0
    for line in $diff_stats
        set -l fields (string split \t -- $line)
        string match -rq '^\d+$' -- $fields[1]
        and set added (math $added + $fields[1])
        string match -rq '^\d+$' -- $fields[2]
        and set removed (math $removed + $fields[2])
    end

    set -l changes "+$added/-$removed"
    echo "$changes " | string replace -r '(\+0/(-0)?|/-0)' ''
end

function __bobthefish_git_stashed -S -d 'Print the stashed state for the current branch'
    if [ "$theme_display_git_stashed_verbose" = yes ]
        set -l stashed (command git rev-list --walk-reflogs --count refs/stash 2>/dev/null)
        or return

        echo -n "$git_stashed_glyph$stashed"
    else
        command git rev-parse --verify --quiet refs/stash >/dev/null
        and echo -n "$git_stashed_glyph"
    end
end

function __bobthefish_prompt_git_sync -S -a git_root_dir -a real_pwd -d 'Display the actual git state synchronously'
    set -l dirty ''
    if [ "$theme_display_git_dirty" != no ]
        set -l show_dirty (command git config --bool bash.showDirtyState 2>/dev/null)
        if [ "$show_dirty" != false ]
            set dirty (command git diff --no-ext-diff --quiet --exit-code 2>/dev/null; or echo -n "$git_dirty_glyph")
            if [ "$dirty" -a "$theme_display_git_dirty_verbose" = yes ]
                set dirty "$dirty"(__bobthefish_git_dirty_verbose)
            end
        end
    end

    set -l staged (command git diff --cached --no-ext-diff --quiet --exit-code 2>/dev/null; or echo -n "$git_staged_glyph")
    set -l stashed (__bobthefish_git_stashed)
    set -l ahead (__bobthefish_git_ahead)

    set -l new ''
    if [ "$theme_display_git_untracked" != no ]
        set -l show_untracked (command git config --bool bash.showUntrackedFiles 2>/dev/null)
        if [ "$show_untracked" != false ]
            set new (command git ls-files --other --exclude-standard --directory --no-empty-directory "$git_root_dir" 2>/dev/null)
            if [ "$new" ]
                set new "$git_untracked_glyph"
            end
        end
    end

    set -l flags "$dirty$staged$stashed$ahead$new"

    [ "$flags" ]
    and set flags " $flags"

    set -l flag_colors $color_repo
    if [ "$dirty" ]
        set flag_colors $color_repo_dirty
    else if [ "$staged" ]
        set flag_colors $color_repo_staged
    end

    __bobthefish_path_segment $git_root_dir project

    __bobthefish_start_segment $flag_colors
    echo -ns (__bobthefish_git_branch) $flags ' '
    set_color normal

    if [ "$theme_git_worktree_support" != yes ]
        __bobthefish_prompt_git_pwd $git_root_dir $real_pwd
        return
    end

    set -l project_pwd (command git rev-parse --show-prefix 2>/dev/null | string trim --right --chars=/)
    set -l work_dir (command git rev-parse --show-toplevel 2>/dev/null)

    # only show work dir if it's a parent…
    if [ "$work_dir" ]
        switch $real_pwd/
            case $work_dir/\*
                string match "$git_root_dir*" $work_dir >/dev/null
                and set work_dir (string sub -s (math 1 + (string length $git_root_dir)) $work_dir)
            case \*
                set -e work_dir
        end
    end

    if [ "$project_pwd" -o "$work_dir" ]
        set -l colors $color_path
        if not [ -w "$real_pwd" ]
            set colors $color_path_nowrite
        end

        __bobthefish_start_segment $colors

        # handle work_dir != project dir
        if [ "$work_dir" ]
            set -l work_parent (__bobthefish_dirname $work_dir)
            if [ "$work_parent" ]
                echo -n "$work_parent/"
            end

            set_color normal
            set_color -b $color_repo_work_tree
            echo -n (__bobthefish_basename $work_dir)

            set_color normal
            set_color -b $colors
            [ "$project_pwd" ]
            and echo -n /
        end

        echo -ns $project_pwd ' '
    else
        set project_pwd $real_pwd

        string match "$git_root_dir*" $project_pwd >/dev/null
        and set project_pwd (string sub -s (math 1 + (string length $git_root_dir)) $project_pwd)

        set project_pwd (string trim --left --chars=/ -- $project_pwd)

        if [ "$project_pwd" ]
            set -l colors $color_path
            if not [ -w "$real_pwd" ]
                set colors $color_path_nowrite
            end

            __bobthefish_start_segment $colors

            echo -ns $project_pwd ' '
        end
    end
end

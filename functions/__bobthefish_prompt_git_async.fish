function __bobthefish_git_count_or_zero -S -a count -d 'Normalize a git count for numeric comparisons'
    string match -qr '^\d+$' -- "$count"
    and echo $count
    or echo 0
end

function __bobthefish_git_pending_branch -S -a git_root_dir -d 'Get cheap branch metadata while async git state is pending'
    # The placeholder is only shown until the worker first publishes for this
    # repo. Caching by root keeps rapid renders (e.g. holding Enter in a fresh
    # repo) from re-forking git on every prompt during that brief window.
    if set -q __bobthefish_git_pending_root
        and [ "$__bobthefish_git_pending_root" = "$git_root_dir" ]
        echo $__bobthefish_git_pending_branch_cache
        return
    end

    set -l rendered
    set -l branch (command git symbolic-ref --quiet --short HEAD 2>/dev/null)
    if [ -n "$branch" ]
        # Keep the common branch path cheap. We intentionally do not call
        # `git config init.defaultBranch` here; the worker will apply the full
        # default-branch rules when it publishes complete metadata.
        set rendered (__bobthefish_git_branch_from_parts '' "$branch" '')
    else
        set -l detached (command git rev-parse --short HEAD 2>/dev/null)
        [ -n "$detached" ]
        and set rendered (__bobthefish_git_branch_from_parts '' '' "$detached")
    end

    set -g __bobthefish_git_pending_root $git_root_dir
    set -g __bobthefish_git_pending_branch_cache $rendered
    echo $rendered
end

function __bobthefish_prompt_git_pending -S -a git_root_dir -a real_pwd -d 'Display an indeterminate repo segment while async git state is pending'
    __bobthefish_path_segment $git_root_dir project

    __bobthefish_start_segment $color_repo_pending
    echo -ns (__bobthefish_git_pending_branch $git_root_dir) ' '
    set_color normal

    __bobthefish_prompt_git_pwd $git_root_dir $real_pwd
end

function __bobthefish_prompt_git_async -S -a git_root_dir -a real_pwd -a repaint -d 'Display git state from cached async metadata'
    if [ "$repaint" != 1 ]
        __bobthefish_git_async_start $git_root_dir
    end

    # Field order is the contract published by __bobthefish_git_async_worker.
    set -l git_data $$__bobthefish_git_async_var
    if [ "$git_data[1]" != "$git_root_dir" ]
        if [ "$repaint" = 1 ]
            __bobthefish_git_async_start $git_root_dir
        end

        set -l budget_ms (__bobthefish_git_async_first_render_budget_ms)
        set -l waited_ms 0
        while [ "$budget_ms" -gt 0 -a "$waited_ms" -lt "$budget_ms" ]
            sleep 0.01
            set git_data $$__bobthefish_git_async_var
            [ "$git_data[1]" = "$git_root_dir" ]
            and break
            set waited_ms (math $waited_ms + 10)
        end
    end

    if [ "$git_data[1]" != "$git_root_dir" ]
        __bobthefish_prompt_git_pending $git_root_dir $real_pwd
        return
    end

    set -l tag $git_data[2]
    set -l branch $git_data[3]
    set -l detached $git_data[4]
    set -l dirty $git_data[5]
    set -l dirty_stats $git_data[6]
    set -l staged $git_data[7]
    set -l stashed $git_data[8]
    set -l ahead (__bobthefish_git_count_or_zero $git_data[9])
    set -l behind (__bobthefish_git_count_or_zero $git_data[10])
    set -l new $git_data[11]
    set -l configured_default_branch $git_data[12]

    [ "$dirty" ]
    and set dirty "$git_dirty_glyph$dirty_stats"
    [ "$staged" ]
    and set staged "$git_staged_glyph"
    if [ "$stashed" ]
        [ "$theme_display_git_stashed_verbose" = yes ]
        and set stashed "$git_stashed_glyph$stashed"
        or set stashed "$git_stashed_glyph"
    end

    set -l ahead_flag
    set -l verbose
    [ "$theme_display_git_ahead_verbose" = yes ]
    and set verbose 1
    switch "$ahead $behind"
        case '0 0' # equal to upstream
        case '* 0' # ahead of upstream
            [ -n "$verbose" ]
            and set ahead_flag "$git_ahead_glyph$ahead"
            or set ahead_flag "$git_plus_glyph"
        case '0 *' # behind upstream
            [ -n "$verbose" ]
            and set ahead_flag "$git_behind_glyph$behind"
            or set ahead_flag "$git_minus_glyph"
        case '*' # diverged from upstream
            [ -n "$verbose" ]
            and set ahead_flag "$git_ahead_glyph$ahead$git_behind_glyph$behind"
            or set ahead_flag "$git_plus_minus_glyph"
    end

    [ "$new" ]
    and set new "$git_untracked_glyph"

    set -l flags "$dirty$staged$stashed$ahead_flag$new"

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
    echo -ns (__bobthefish_git_branch_from_parts "$tag" "$branch" "$detached" "$configured_default_branch") $flags ' '
    set_color normal

    __bobthefish_prompt_git_pwd $git_root_dir $real_pwd
end

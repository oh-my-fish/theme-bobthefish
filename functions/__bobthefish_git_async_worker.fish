# __bobthefish_git_async_counts / __bobthefish_git_async_dirty_verbose are
# deliberate copies of __bobthefish_git_counts / __bobthefish_git_dirty_verbose
# from __bobthefish_prompt_git_sync.fish. The worker runs in a non-interactive
# `fish --private -c` that bootstraps by sourcing only this file, so it must not
# rely on the theme's autoload path being configured (some shells load omf for
# interactive sessions only). Keep these in sync with their sync counterparts.
function __bobthefish_git_async_counts -S -d 'Print behind and ahead counts for the current branch'
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

function __bobthefish_git_async_dirty_verbose -S -d 'Print a more verbose dirty state for the current working tree'
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

function __bobthefish_git_async_worker -S -a git_async_var -a git_root_dir -a display_dirty -a display_dirty_verbose -a display_untracked -a display_stashed_verbose -d 'Compute git prompt metadata in a background fish'
    set -l tag (command git describe --tags --exact-match 2>/dev/null)
    set -l branch (command git symbolic-ref --quiet --short HEAD 2>/dev/null)
    set -l detached
    [ -z "$tag" -a -z "$branch" ]
    and set detached (command git rev-parse --short HEAD 2>/dev/null)

    # Only resolve the configured default branch when it's actually needed
    set -l configured_default_branch
    [ -n "$branch" -a -z "$theme_git_default_branches" ]
    and set configured_default_branch (command git config init.defaultBranch 2>/dev/null)

    set -l dirty
    set -l dirty_stats
    if [ "$display_dirty" != no ]
        set -l show_dirty (command git config --bool bash.showDirtyState 2>/dev/null)
        if [ "$show_dirty" != false ]
            command git diff --no-ext-diff --quiet --exit-code 2>/dev/null
            or begin
                set dirty 1
                [ "$display_dirty_verbose" = yes ]
                and set dirty_stats (__bobthefish_git_async_dirty_verbose)
            end
        end
    end

    set -l staged
    command git diff --cached --no-ext-diff --quiet --exit-code 2>/dev/null
    or set staged 1

    set -l stashed
    if [ "$display_stashed_verbose" = yes ]
        set stashed (command git rev-list --walk-reflogs --count refs/stash 2>/dev/null)
        or set stashed
    else
        command git rev-parse --verify --quiet refs/stash >/dev/null
        and set stashed 1
    end

    set -l ahead 0
    set -l behind 0
    set -l counts (__bobthefish_git_async_counts)
    and begin
        set behind $counts[1]
        set ahead $counts[2]
    end

    set -l new
    if [ "$display_untracked" != no ]
        set -l show_untracked (command git config --bool bash.showUntrackedFiles 2>/dev/null)
        if [ "$show_untracked" != false ]
            set new (command git ls-files --other --exclude-standard --directory --no-empty-directory "$git_root_dir" 2>/dev/null)
            [ "$new" ]
            and set new 1
        end
    end

    # Field order is a contract shared with __bobthefish_prompt_git_async,
    # which unpacks these by position. Keep the two in sync.
    set -l next "$git_root_dir" "$tag" "$branch" "$detached" "$dirty" "$dirty_stats" "$staged" "$stashed" "$ahead" "$behind" "$new" "$configured_default_branch"

    # Skip the universal-variable write (disk I/O + a repaint broadcast to
    # every fish session) when nothing actually changed since the last run.
    set -l current $$git_async_var
    set -l next_key (string join \x1e -- $next)
    set -l current_key (string join \x1e -- $current)
    [ "$next_key" = "$current_key" ]
    and return

    set -U $git_async_var $next
end

function __bobthefish_git_async_enabled -S -d 'Check whether async git prompt updates should be used'
    if [ "$argv[1]" = --init ]
        if status is-interactive; and __bobthefish_version_at_least 3.0.0 $version
            # The git metadata var must be universal: the detached background fish
            # writes it, and a universal variable is the only channel that can deliver
            # a value back into this (the parent) shell. It's namespaced by pid so
            # concurrent sessions don't clobber each other.
            set -g __bobthefish_git_async_var __bobthefish_git_async_$fish_pid
            set -U $__bobthefish_git_async_var

            # Fires when the background worker publishes new metadata. The pending
            # flag tells the next fish_prompt that this render is the async repaint
            # (so it must not spawn another worker).
            function __bobthefish_git_async_repaint --on-variable $__bobthefish_git_async_var
                set -g __bobthefish_git_async_repaint_pending 1
                commandline --function repaint
            end

            function __bobthefish_git_async_cleanup --on-event fish_exit
                set -q __bobthefish_git_async_pid
                and command kill $__bobthefish_git_async_pid 2>/dev/null
                set -q __bobthefish_git_async_trailing_pid
                and command kill $__bobthefish_git_async_trailing_pid 2>/dev/null

                set -q __bobthefish_git_async_var
                and set -e $__bobthefish_git_async_var
            end

            __bobthefish_git_async_gc
        end

    # The git metadata var must be universal: the detached background fish
    # writes it, and a universal variable is the only channel that can deliver
    # a value back into this (the parent) shell. It's namespaced by pid so
    # concurrent sessions don't clobber each other.
    set -g __bobthefish_git_async_var __bobthefish_git_async_$fish_pid
    set -U $__bobthefish_git_async_var

    # Fires when the background worker publishes new metadata. The pending
    # flag tells the next fish_prompt that this render is the async repaint
    # (so it must not spawn another worker).
    function __bobthefish_git_async_repaint --on-variable $__bobthefish_git_async_var
        set -g __bobthefish_git_async_repaint_pending 1
        commandline --function repaint
    end

    function __bobthefish_git_async_cleanup --on-event fish_exit
        set -q __bobthefish_git_async_pid
        and command kill $__bobthefish_git_async_pid 2>/dev/null
        set -q __bobthefish_git_async_trailing_pid
        and command kill $__bobthefish_git_async_trailing_pid 2>/dev/null
        set -q __bobthefish_git_async_poll_pid
        and command kill $__bobthefish_git_async_poll_pid 2>/dev/null

        set -q __bobthefish_git_async_var
        and set -e $__bobthefish_git_async_var
    end

    __bobthefish_git_async_gc
end

function __bobthefish_git_async_enabled -S -d 'Check whether async git prompt updates should be used'
    [ "$theme_display_git_async" = no ]
    and return 1

    [ "$theme_git_worktree_support" = yes ]
    and return 1

    __bobthefish_version_at_least 3.0.0 $version
    and status is-interactive
    and set -q __bobthefish_git_async_var
    and command -q fish
    and __bobthefish_git_async_worker_path >/dev/null
end

function __bobthefish_git_async_worker_path -S -d 'Resolve and cache the async git worker file'
    set -q __bobthefish_git_async_worker_path_cache
    and echo $__bobthefish_git_async_worker_path_cache
    and return

    set -l prompt_path (functions --details fish_prompt)
    [ -f "$prompt_path" ]
    or return

    set -l resolved (dirname "$prompt_path")/__bobthefish_git_async_worker.fish
    [ -f "$resolved" ]
    or return

    set -g __bobthefish_git_async_worker_path_cache $resolved
    echo $resolved
end

function __bobthefish_git_async_fish -S -d 'Resolve and cache the fish binary used for async git workers'
    set -q __bobthefish_git_async_fish_path
    or set -g __bobthefish_git_async_fish_path (command -s fish)
    echo $__bobthefish_git_async_fish_path
end

function __bobthefish_git_async_gc -S -d 'Remove async git metadata left behind by dead fish sessions'
    set -l prefix __bobthefish_git_async_
    for var in (set --names --universal | string match "$prefix*")
        [ "$var" = "$__bobthefish_git_async_var" ]
        and continue

        set -l pid (string replace $prefix '' -- $var)
        string match -qr '^\d+$' -- "$pid"
        or continue

        command kill -0 $pid 2>/dev/null
        or set -e $var
    end
end

function __bobthefish_git_async_refresh_interval -S -d 'Get the minimum seconds between async git workers'
    set -l interval 1
    string match -qr '^\d+$' -- "$theme_git_async_refresh_interval"
    and set interval $theme_git_async_refresh_interval

    echo $interval
end

function __bobthefish_git_async_schedule_trailing -S -a git_root_dir -a delay -d 'Schedule a trailing async git refresh'
    [ "$delay" -gt 0 ]
    or return
    set -q __bobthefish_git_async_var
    or return

    set -l worker_path (__bobthefish_git_async_worker_path)
    or return
    set -l fish_bin (__bobthefish_git_async_fish)

    if set -q __bobthefish_git_async_trailing_pid
        command kill -0 $__bobthefish_git_async_trailing_pid 2>/dev/null
        and [ "$__bobthefish_git_async_trailing_root_dir" = "$git_root_dir" ]
        and return

        __bobthefish_git_async_clear_trailing
    end

    command $fish_bin --private -c '
        sleep $argv[1]
        source $argv[2]
        __bobthefish_git_async_worker $argv[3] $argv[4] $argv[5] $argv[6] $argv[7] $argv[8]
    ' $delay $worker_path $__bobthefish_git_async_var $git_root_dir "$theme_display_git_dirty" "$theme_display_git_dirty_verbose" "$theme_display_git_untracked" "$theme_display_git_stashed_verbose" &
    builtin -q disown
    and builtin disown
    set -g __bobthefish_git_async_trailing_pid $last_pid
    set -g __bobthefish_git_async_trailing_root_dir $git_root_dir
end

function __bobthefish_git_async_start -S -a git_root_dir -d 'Start a background git prompt metadata update'
    set -q __bobthefish_git_async_var
    or return

    # Keep at most one worker active per prompt session. Re-rendering while a
    # worker is still collecting git state should not kill the worker that will
    # publish the fresh cache.
    if set -q __bobthefish_git_async_pid
        if command kill -0 $__bobthefish_git_async_pid 2>/dev/null
            [ "$__bobthefish_git_async_root_dir" = "$git_root_dir" ]
            and return

            command kill $__bobthefish_git_async_pid 2>/dev/null
        end

        set -e __bobthefish_git_async_pid
    end

    if set -q __bobthefish_git_async_trailing_pid
        if [ "$__bobthefish_git_async_trailing_root_dir" != "$git_root_dir" ]
            __bobthefish_git_async_clear_trailing
        else if not command kill -0 $__bobthefish_git_async_trailing_pid 2>/dev/null
            set -e __bobthefish_git_async_trailing_pid
        end
    end

    set -l now (date +%s)
    set -l interval (__bobthefish_git_async_refresh_interval)
    # Git state can change inside a repo between prompts, so this is a short
    # debounce rather than a same-repo cache. Set theme_git_async_refresh_interval
    # to 0 to spawn a worker on every eligible prompt render.
    if [ "$interval" -gt 0 -a "$__bobthefish_git_async_root_dir" = "$git_root_dir" -a -n "$__bobthefish_git_async_last_start" ]
        set -l elapsed (math $now - $__bobthefish_git_async_last_start)
        if [ "$elapsed" -lt "$interval" ]
            __bobthefish_git_async_schedule_trailing $git_root_dir (math $interval - $elapsed)
            return
        end
    end

    __bobthefish_git_async_clear_trailing

    set -l worker_path (__bobthefish_git_async_worker_path)
    or return
    set -l fish_bin (__bobthefish_git_async_fish)

    set -l cmd source (string escape -- $worker_path) ';' __bobthefish_git_async_worker \
        (string escape -- $__bobthefish_git_async_var) \
        (string escape -- $git_root_dir) \
        (string escape -- "$theme_display_git_dirty") \
        (string escape -- "$theme_display_git_dirty_verbose") \
        (string escape -- "$theme_display_git_untracked") \
        (string escape -- "$theme_display_git_stashed_verbose")

    set -g __bobthefish_git_async_root_dir $git_root_dir
    set -g __bobthefish_git_async_last_start $now
    command $fish_bin --private --command "$cmd" &
    builtin -q disown
    and builtin disown
    set -g __bobthefish_git_async_pid $last_pid
end

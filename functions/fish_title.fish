# See "Title options" in README.md for configuration options

function __bobthefish_title_user -S -d 'Display actual user if different from $default_user'
    if [ "$theme_title_display_user" = yes ]
        if [ "$USER" != "$default_user" -o -n "$SSH_CLIENT" ]
            set -l host (string split . -- (uname -n))[1]
            [ -n "$USER" ]
            and echo -ns $USER
            or echo -ns (whoami)
            echo -ns '@' $host ' '
        end
    end
end

function fish_title
    __bobthefish_title_user

    if [ "$theme_title_display_process" = yes ]
        status current-command

        [ "$theme_title_display_path" != no ]
        and echo ' '
    end

    if [ "$theme_title_display_path" != no ]
        if [ "$theme_title_use_abbreviated_path" = no ]
            echo $PWD
        else
            prompt_pwd
        end
    end
end

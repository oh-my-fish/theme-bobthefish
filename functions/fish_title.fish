# You can override some default title options in your config.fish:
#     set -g theme_title_display_process no
#     set -g theme_title_display_path no
#     set -g theme_title_display_user yes
#     set -g theme_title_use_abbreviated_path no

function __bobthefish_title_user -S -d 'Display actual user if different from $default_user'
    if [ "$theme_title_display_user" = 'yes' ]
        if [ "$USER" != "$default_user" -o -n "$SSH_CLIENT" ]
            set -l IFS .
            hostname | read -l hostname __
            echo -ns (whoami) '@' $hostname ' '
        end
    end
end

function fish_title
    __bobthefish_title_user

    if [ "$theme_title_display_process" = 'yes' ]
        echo $_

        [ "$theme_title_display_path" != 'no' ]
        and echo ' '
    end

    if [ "$theme_title_display_path" != 'no' ]
        if [ "$theme_title_use_abbreviated_path" = 'no' ]
            echo $PWD
        else
            prompt_pwd
        end
    end
end

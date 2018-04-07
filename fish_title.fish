# You can override some default title options in your config.fish:
#     set -g theme_title_display_process no
#     set -g theme_title_display_command no
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

function __display_path -d 'Display the full or abbreviated path'
  if [ "$theme_title_use_abbreviated_path" = 'no' ]
    echo $PWD
  else
    prompt_pwd
  end
end

function fish_title
  __bobthefish_title_user

  if [ "$theme_title_display_process" = 'yes' -a "$theme_title_display_command" != 'yes' ]
    echo $_

    [ "$theme_title_display_path" != 'no' ]
      and echo ' '
      and __display_path
  else
      if [ $_ != 'fish' ]
        echo $argv[1]
      else
        __display_path
  end
end

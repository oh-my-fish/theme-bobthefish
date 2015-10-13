function fish_title
  [ "$theme_title_display_process" = 'yes' ]; and echo $_ ' '
  [ "$theme_title_display_path" != 'no' ]; and prompt_pwd
end

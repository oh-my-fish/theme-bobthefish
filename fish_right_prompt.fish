# You can override some default title options in your config.fish:
#     set -g theme_date_format "+%a %H:%M"

function fish_right_prompt -d 'bobthefish is all about the right prompt'
  set_color $fish_color_autosuggestion[1]
  set -q theme_date_format; or set -l theme_date_format "+%c"
  date $theme_date_format
  set_color normal
end

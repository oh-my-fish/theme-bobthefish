# You can override some default right prompt options in your config.fish:
#     set -g theme_date_format "+%a %H:%M"

function __bobthefish_cmd_duration -S -d 'Show command duration'
  [ "$theme_display_cmd_duration" = "no" ]; and return
  [ "$CMD_DURATION" -lt 100 ]; and return

  if [ "$CMD_DURATION" -lt 5000 ]
    echo -ns $CMD_DURATION 'ms'
  else if [ "$CMD_DURATION" -lt 60000 ]
    math "scale=1;$CMD_DURATION/1000" | sed 's/\\.0$//'
    echo -n 's'
  else if [ "$CMD_DURATION" -lt 3600000 ]
    set_color $fish_color_error
    math "scale=1;$CMD_DURATION/60000" | sed 's/\\.0$//'
    echo -n 'm'
  else
    set_color $fish_color_error
    math "scale=2;$CMD_DURATION/3600000" | sed 's/\\.0$//'
    echo -n 'h'
  end

  set_color $fish_color_normal
  set_color $fish_color_autosuggestion

  [ "$theme_display_date" = "no" ]
    or echo -ns ' ' $__bobthefish_left_arrow_glyph
end

function __bobthefish_timestamp -S -d 'Show the current timestamp'
  [ "$theme_display_date" = "no" ]; and return
  set -q theme_date_format
    or set -l theme_date_format "+%c"

  echo -n ' '
  date $theme_date_format
end

function fish_right_prompt -d 'bobthefish is all about the right prompt'
  set -l __bobthefish_left_arrow_glyph \uE0B3
  if [ "$theme_powerline_fonts" = "no" ]
    set __bobthefish_left_arrow_glyph '<'
  end

  set_color $fish_color_autosuggestion

  __bobthefish_cmd_duration
  __bobthefish_timestamp
  set_color normal
end

# You can override some default right prompt options in your config.fish:
#     set -g theme_date_format "+%a %H:%M"

function __bobthefish_cmd_duration -S -d 'Show command duration'
    [ "$theme_display_cmd_duration" = "no" ]
    and return

    [ -z "$CMD_DURATION" -o "$CMD_DURATION" -lt 100 ]
    and return

    if [ "$CMD_DURATION" -lt 5000 ]
        echo -ns $CMD_DURATION 'ms'
    else if [ "$CMD_DURATION" -lt 60000 ]
        __bobthefish_pretty_ms $CMD_DURATION s
    else if [ "$CMD_DURATION" -lt 3600000 ]
        set_color $fish_color_error
        __bobthefish_pretty_ms $CMD_DURATION m
    else
        set_color $fish_color_error
        __bobthefish_pretty_ms $CMD_DURATION h
    end

    set_color $fish_color_normal
    set_color $fish_color_autosuggestion

    [ "$theme_display_date" = "no" ]
    or echo -ns ' '
end

function __bobthefish_pretty_ms -S -a ms -a interval -d 'Millisecond formatting for humans'
    set -l interval_ms
    set -l scale 1

    switch $interval
        case s
            set interval_ms 1000
        case m
            set interval_ms 60000
        case h
            set interval_ms 3600000
            set scale 2
    end

    switch $FISH_VERSION
        case 2.0.\* 2.1.\* 2.2.\* 2.3.\*
            # Fish 2.3 and lower doesn't know about the -s argument to math.
            math "scale=$scale;$ms/$interval_ms" | string replace -r '\\.?0*$' $interval
        case 2.\*
            # Fish 2.x always returned a float when given the -s argument.
            math -s$scale "$ms/$interval_ms" | string replace -r '\\.?0*$' $interval
        case \*
            math -s$scale "$ms/$interval_ms"
            echo -ns $interval
    end
end

function __bobthefish_timestamp -S -d 'Show the current timestamp'
    [ "$theme_display_date" = "no" ]
    and return

    set -q theme_date_format
    or set -l theme_date_format "+%H:%M:%S"

    set_color $color_path
    echo -ns $left_black_arrow_glyph

    set_color -b $color_path
    echo -ns ' '
    date $theme_date_format
    echo -ns ' '
end

function fish_right_prompt -d 'bobthefish is all about the right prompt'
    __bobthefish_colors $theme_color_scheme
    __bobthefish_glyphs

    set_color $fish_color_autosuggestion

    __bobthefish_cmd_duration
    __bobthefish_timestamp
    set_color normal
end

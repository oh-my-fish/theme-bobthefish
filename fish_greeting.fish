function fish_greeting -d "What's up, fish?"
    set_color $fish_color_autosuggestion
    uname -nmsr
    command -q -s uptime; and uptime
    set_color normal
end

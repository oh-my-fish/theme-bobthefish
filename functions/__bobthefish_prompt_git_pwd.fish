function __bobthefish_prompt_git_pwd -S -a git_root_dir -a real_pwd -d 'Display the in-project path segment'
    set -l project_pwd (__bobthefish_project_pwd $git_root_dir $real_pwd)
    [ "$project_pwd" ]
    or return

    if [ -w "$real_pwd" ]
        __bobthefish_start_segment $color_path
    else
        __bobthefish_start_segment $color_path_nowrite
    end

    echo -ns $project_pwd ' '
end

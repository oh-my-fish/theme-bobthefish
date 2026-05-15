function __bobthefish_git_branch_from_parts -S -a tag -a branch -a detached -a configured_default_branch -d 'Format a git branch from git metadata'
    [ -n "$tag" ]
    and echo "$tag_glyph $tag "

    if [ -n "$branch" ]
        [ -n "$theme_git_default_branches" ]
        or set -l theme_git_default_branches master main $configured_default_branch

        [ "$theme_display_git_master_branch" != yes -a "$theme_display_git_default_branch" != yes ]
        and contains $branch $theme_git_default_branches
        and echo $branch_glyph
        and return

        set -l truncname $branch
        [ "$theme_use_abbreviated_branch_name" = yes ]
        and set truncname (string replace -r '^(.{17}).{3,}(.{5})$' "\$1…\$2" $branch)

        echo $branch_glyph $truncname
        and return
    end

    if [ -z "$tag" -a -n "$detached" ]
        echo "$detached_glyph $detached"
    end
end

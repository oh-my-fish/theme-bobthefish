function __bobthefish_colors -S -a color_scheme -d 'Define colors used by bobthefish'
  switch "$color_scheme"
    case 'user'
      __bobthefish_user_color_scheme_deprecated
      return

    case 'terminal' 'terminal-dark*'
      set -l colorfg black
      [ "$color_scheme" = 'terminal-dark-white' ]; and set colorfg white
      set -x color_initial_segment_exit     white red --bold
      set -x color_initial_segment_private  white black
      set -x color_initial_segment_su       white green --bold
      set -x color_initial_segment_jobs     white blue --bold

      set -x color_path                     black white
      set -x color_path_basename            black white --bold
      set -x color_path_nowrite             magenta $colorfg
      set -x color_path_nowrite_basename    magenta $colorfg --bold

      set -x color_repo                     green $colorfg
      set -x color_repo_work_tree           black $colorfg --bold
      set -x color_repo_dirty               brred $colorfg
      set -x color_repo_staged              yellow $colorfg

      set -x color_vi_mode_default          brblue $colorfg --bold
      set -x color_vi_mode_insert           brgreen $colorfg --bold
      set -x color_vi_mode_visual           bryellow $colorfg --bold

      set -x color_vagrant                  brcyan $colorfg
      set -x color_k8s                      magenta white --bold
      set -x color_aws_vault                blue $colorfg --bold
      set -x color_aws_vault_expired        blue red --bold
      set -x color_username                 white black --bold
      set -x color_hostname                 white black
      set -x color_rvm                      brmagenta $colorfg --bold
      set -x color_node                     brgreen $colorfg --bold
      set -x color_virtualfish              brblue $colorfg --bold
      set -x color_virtualgo                brblue $colorfg --bold
      set -x color_desk                     brblue $colorfg --bold
      set -x color_nix                      brblue $colorfg --bold

    case 'terminal-light*'
      set -l colorfg white
      [ "$color_scheme" = 'terminal-light-black' ]; and set colorfg black
      set -x color_initial_segment_exit     black red --bold
      set -x color_initial_segment_private  black white
      set -x color_initial_segment_su       black green --bold
      set -x color_initial_segment_jobs     black blue --bold

      set -x color_path                     white black
      set -x color_path_basename            white black --bold
      set -x color_path_nowrite             magenta $colorfg
      set -x color_path_nowrite_basename    magenta $colorfg --bold

      set -x color_repo                     green $colorfg
      set -x color_repo_work_tree           white $colorfg --bold
      set -x color_repo_dirty               brred $colorfg
      set -x color_repo_staged              yellow $colorfg

      set -x color_vi_mode_default          brblue $colorfg --bold
      set -x color_vi_mode_insert           brgreen $colorfg --bold
      set -x color_vi_mode_visual           bryellow $colorfg --bold

      set -x color_vagrant                  brcyan $colorfg
      set -x color_k8s                      magenta white --bold
      set -x color_aws_vault                blue $colorfg --bold
      set -x color_aws_vault_expired        blue red --bold
      set -x color_username                 black white --bold
      set -x color_hostname                 black white
      set -x color_rvm                      brmagenta $colorfg --bold
      set -x color_node                     brgreen $colorfg --bold
      set -x color_virtualfish              brblue $colorfg --bold
      set -x color_virtualgo                brblue $colorfg --bold
      set -x color_desk                     brblue $colorfg --bold
      set -x color_nix                      brblue $colorfg --bold

    case 'terminal2' 'terminal2-dark*'
      set -l colorfg black
      [ "$color_scheme" = 'terminal2-dark-white' ]; and set colorfg white
      set -x color_initial_segment_exit     grey red --bold
      set -x color_initial_segment_private  grey black
      set -x color_initial_segment_su       grey green --bold
      set -x color_initial_segment_jobs     grey blue --bold

      set -x color_path                     brgrey white
      set -x color_path_basename            brgrey white --bold
      set -x color_path_nowrite             magenta $colorfg
      set -x color_path_nowrite_basename    magenta $colorfg --bold

      set -x color_repo                     green $colorfg
      set -x color_repo_work_tree           brgrey $colorfg --bold
      set -x color_repo_dirty               brred $colorfg
      set -x color_repo_staged              yellow $colorfg

      set -x color_vi_mode_default          brblue $colorfg --bold
      set -x color_vi_mode_insert           brgreen $colorfg --bold
      set -x color_vi_mode_visual           bryellow $colorfg --bold

      set -x color_vagrant                  brcyan $colorfg
      set -x color_k8s                      magenta white --bold
      set -x color_aws_vault                blue $colorfg --bold
      set -x color_aws_vault_expired        blue red --bold
      set -x color_username                 brgrey white --bold
      set -x color_hostname                 brgrey white
      set -x color_rvm                      brmagenta $colorfg --bold
      set -x color_node                     brgreen $colorfg --bold
      set -x color_virtualfish              brblue $colorfg --bold
      set -x color_virtualgo                brblue $colorfg --bold
      set -x color_desk                     brblue $colorfg --bold
      set -x color_nix                      brblue $colorfg --bold

    case 'terminal2-light*'
      set -l colorfg white
      [ "$color_scheme" = 'terminal2-light-black' ]; and set colorfg black
      set -x color_initial_segment_exit     brgrey red --bold
      set -x color_initial_segment_private  brgrey black
      set -x color_initial_segment_su       brgrey green --bold
      set -x color_initial_segment_jobs     brgrey blue --bold

      set -x color_path                     grey black
      set -x color_path_basename            grey black --bold
      set -x color_path_nowrite             magenta $colorfg
      set -x color_path_nowrite_basename    magenta $colorfg --bold

      set -x color_repo                     green $colorfg
      set -x color_repo_work_tree           grey $colorfg --bold
      set -x color_repo_dirty               brred $colorfg
      set -x color_repo_staged              yellow $colorfg

      set -x color_vi_mode_default          brblue $colorfg --bold
      set -x color_vi_mode_insert           brgreen $colorfg --bold
      set -x color_vi_mode_visual           bryellow $colorfg --bold

      set -x color_vagrant                  brcyan $colorfg
      set -x color_k8s                      magenta white --bold
      set -x color_aws_vault                blue $colorfg --bold
      set -x color_aws_vault_expired        blue red --bold
      set -x color_username                 grey black --bold
      set -x color_hostname                 grey black
      set -x color_rvm                      brmagenta $colorfg --bold
      set -x color_node                     brgreen $colorfg --bold
      set -x color_virtualfish              brblue $colorfg --bold
      set -x color_virtualgo                brblue $colorfg --bold
      set -x color_desk                     brblue $colorfg --bold
      set -x color_nix                      brblue $colorfg --bold

    case 'zenburn'
      set -l grey   333333 # a bit darker than normal zenburn grey
      set -l red    CC9393
      set -l green  7F9F7F
      set -l yellow E3CEAB
      set -l orange DFAF8F
      set -l blue   8CD0D3
      set -l white  DCDCCC

      set -x color_initial_segment_exit     $white $red --bold
      set -x color_initial_segment_private  $white $grey
      set -x color_initial_segment_su       $white $green --bold
      set -x color_initial_segment_jobs     $white $blue --bold

      set -x color_path                     $grey $white
      set -x color_path_basename            $grey $white --bold
      set -x color_path_nowrite             $grey $red
      set -x color_path_nowrite_basename    $grey $red --bold

      set -x color_repo                     $green $grey
      set -x color_repo_work_tree           $grey $grey --bold
      set -x color_repo_dirty               $red $grey
      set -x color_repo_staged              $yellow $grey

      set -x color_vi_mode_default          $grey $yellow --bold
      set -x color_vi_mode_insert           $green $white --bold
      set -x color_vi_mode_visual           $yellow $grey --bold

      set -x color_vagrant                  $blue $green --bold
      set -x color_k8s                      $green $white --bold
      set -x color_aws_vault                $blue $grey --bold
      set -x color_aws_vault_expired        $blue $red --bold
      set -x color_username                 $grey $blue --bold
      set -x color_hostname                 $grey $blue
      set -x color_rvm                      $red $grey --bold
      set -x color_node                     $green $white --bold
      set -x color_virtualfish              $blue $grey --bold
      set -x color_virtualgo                $blue $grey --bold
      set -x color_desk                     $blue $grey --bold
      set -x color_nix                      $blue $grey --bold

    case 'base16-light'
      set -l base00 181818
      set -l base01 282828
      set -l base02 383838
      set -l base03 585858
      set -l base04 b8b8b8
      set -l base05 d8d8d8
      set -l base06 e8e8e8
      set -l base07 f8f8f8
      set -l base08 ab4642 # red
      set -l base09 dc9656 # orange
      set -l base0A f7ca88 # yellow
      set -l base0B a1b56c # green
      set -l base0C 86c1b9 # cyan
      set -l base0D 7cafc2 # blue
      set -l base0E ba8baf # violet
      set -l base0F a16946 # brown

      set -l colorfg $base00

      set -x color_initial_segment_exit     $base02 $base08 --bold
      set -x color_initial_segment_private  $base02 $base06
      set -x color_initial_segment_su       $base02 $base0B --bold
      set -x color_initial_segment_jobs     $base02 $base0D --bold

      set -x color_path                     $base06 $base02
      set -x color_path_basename            $base06 $base01 --bold
      set -x color_path_nowrite             $base06 $base08
      set -x color_path_nowrite_basename    $base06 $base08 --bold

      set -x color_repo                     $base0B $colorfg
      set -x color_repo_work_tree           $base06 $colorfg --bold
      set -x color_repo_dirty               $base08 $colorfg
      set -x color_repo_staged              $base09 $colorfg

      set -x color_vi_mode_default          $base04 $colorfg --bold
      set -x color_vi_mode_insert           $base0B $colorfg --bold
      set -x color_vi_mode_visual           $base09 $colorfg --bold

      set -x color_vagrant                  $base0C $colorfg --bold
      set -x color_k8s                      $base06 $colorfg --bold
      set -x color_aws_vault                $base0D $colorfg --bold
      set -x color_aws_vault_expired        $base0D $base08 --bold
      set -x color_username                 $base02 $base0D --bold
      set -x color_hostname                 $base02 $base0D
      set -x color_rvm                      $base08 $colorfg --bold
      set -x color_node                     $base0B $colorfg --bold
      set -x color_virtualfish              $base0D $colorfg --bold
      set -x color_virtualgo                $base0D $colorfg --bold
      set -x color_desk                     $base0D $colorfg --bold
      set -x color_nix                      $base0D $colorfg --bold

    case 'base16' 'base16-dark'
      set -l base00 181818
      set -l base01 282828
      set -l base02 383838
      set -l base03 585858
      set -l base04 b8b8b8
      set -l base05 d8d8d8
      set -l base06 e8e8e8
      set -l base07 f8f8f8
      set -l base08 ab4642 # red
      set -l base09 dc9656 # orange
      set -l base0A f7ca88 # yellow
      set -l base0B a1b56c # green
      set -l base0C 86c1b9 # cyan
      set -l base0D 7cafc2 # blue
      set -l base0E ba8baf # violet
      set -l base0F a16946 # brown

      set -l colorfg $base07

      set -x color_initial_segment_exit     $base05 $base08 --bold
      set -x color_initial_segment_private  $base05 $base02
      set -x color_initial_segment_su       $base05 $base0B --bold
      set -x color_initial_segment_jobs     $base05 $base0D --bold

      set -x color_path                     $base02 $base05
      set -x color_path_basename            $base02 $base06 --bold
      set -x color_path_nowrite             $base02 $base08
      set -x color_path_nowrite_basename    $base02 $base08 --bold

      set -x color_repo                     $base0B $colorfg
      set -x color_repo_work_tree           $base02 $colorfg --bold
      set -x color_repo_dirty               $base08 $colorfg
      set -x color_repo_staged              $base09 $colorfg

      set -x color_vi_mode_default          $base03 $colorfg --bold
      set -x color_vi_mode_insert           $base0B $colorfg --bold
      set -x color_vi_mode_visual           $base09 $colorfg --bold

      set -x color_vagrant                  $base0C $colorfg --bold
      set -x color_k8s                      $base0B $colorfg --bold
      set -x color_aws_vault                $base0D $base0A --bold
      set -x color_aws_vault_expired        $base0D $base08 --bold
      set -x color_username                 $base02 $base0D --bold
      set -x color_hostname                 $base02 $base0D
      set -x color_rvm                      $base08 $colorfg --bold
      set -x color_node                     $base0B $colorfg --bold
      set -x color_virtualfish              $base0D $colorfg --bold
      set -x color_virtualgo                $base0D $colorfg --bold
      set -x color_desk                     $base0D $colorfg --bold
      set -x color_nix                      $base0D $colorfg --bold

    case 'solarized-light'
      set -l base03  002b36
      set -l base02  073642
      set -l base01  586e75
      set -l base00  657b83
      set -l base0   839496
      set -l base1   93a1a1
      set -l base2   eee8d5
      set -l base3   fdf6e3
      set -l yellow  b58900
      set -l orange  cb4b16
      set -l red     dc322f
      set -l magenta d33682
      set -l violet  6c71c4
      set -l blue    268bd2
      set -l cyan    2aa198
      set -l green   859900

      set colorfg $base03

      set -x color_initial_segment_exit     $base02 $red --bold
      set -x color_initial_segment_private  $base02 $base2
      set -x color_initial_segment_su       $base02 $green --bold
      set -x color_initial_segment_jobs     $base02 $blue --bold

      set -x color_path                     $base2 $base00
      set -x color_path_basename            $base2 $base01 --bold
      set -x color_path_nowrite             $base2 $orange
      set -x color_path_nowrite_basename    $base2 $orange --bold

      set -x color_repo                     $green $colorfg
      set -x color_repo_work_tree           $base2 $colorfg --bold
      set -x color_repo_dirty               $red $colorfg
      set -x color_repo_staged              $yellow $colorfg

      set -x color_vi_mode_default          $blue $colorfg --bold
      set -x color_vi_mode_insert           $green $colorfg --bold
      set -x color_vi_mode_visual           $yellow $colorfg --bold

      set -x color_vagrant                  $violet $colorfg --bold
      set -x color_k8s                      $green $colorfg --bold
      set -x color_aws_vault                $violet $base3 --bold
      set -x color_aws_vault_expired        $violet $orange --bold
      set -x color_username                 $base2 $blue --bold
      set -x color_hostname                 $base2 $blue
      set -x color_rvm                      $red $colorfg --bold
      set -x color_node                     $green $colorfg --bold
      set -x color_virtualfish              $cyan $colorfg --bold
      set -x color_virtualgo                $cyan $colorfg --bold
      set -x color_desk                     $cyan $colorfg --bold
      set -x color_nix                      $cyan $colorfg --bold

    case 'solarized' 'solarized-dark'
      set -l base03  002b36
      set -l base02  073642
      set -l base01  586e75
      set -l base00  657b83
      set -l base0   839496
      set -l base1   93a1a1
      set -l base2   eee8d5
      set -l base3   fdf6e3
      set -l yellow  b58900
      set -l orange  cb4b16
      set -l red     dc322f
      set -l magenta d33682
      set -l violet  6c71c4
      set -l blue    268bd2
      set -l cyan    2aa198
      set -l green   859900

      set colorfg $base3

      set -x color_initial_segment_exit     $base2 $red --bold
      set -x color_initial_segment_private  $base2 $base02
      set -x color_initial_segment_su       $base2 $green --bold
      set -x color_initial_segment_jobs     $base2 $blue --bold

      set -x color_path                     $base02 $base0
      set -x color_path_basename            $base02 $base1 --bold
      set -x color_path_nowrite             $base02 $orange
      set -x color_path_nowrite_basename    $base02 $orange --bold

      set -x color_repo                     $green $colorfg
      set -x color_repo_work_tree           $base02 $colorfg --bold
      set -x color_repo_dirty               $red $colorfg
      set -x color_repo_staged              $yellow $colorfg

      set -x color_vi_mode_default          $blue $colorfg --bold
      set -x color_vi_mode_insert           $green $colorfg --bold
      set -x color_vi_mode_visual           $yellow $colorfg --bold

      set -x color_vagrant                  $violet $colorfg --bold
      set -x color_k8s                      $green $colorfg --bold
      set -x color_aws_vault                $violet $base3 --bold
      set -x color_aws_vault_expired        $violet $orange --bold
      set -x color_username                 $base02 $blue --bold
      set -x color_hostname                 $base02 $blue
      set -x color_rvm                      $red $colorfg --bold
      set -x color_node                     $green $colorfg --bold
      set -x color_virtualfish              $cyan $colorfg --bold
      set -x color_virtualgo                $cyan $colorfg --bold
      set -x color_desk                     $cyan $colorfg --bold
      set -x color_nix                      $cyan $colorfg --bold

    case 'light'
      #               light  medium dark
      #               ------ ------ ------
      set -l red      cc9999 ce000f 660000
      set -l green    addc10 189303 0c4801
      set -l blue     48b4fb 005faf 255e87
      set -l orange   f6b117 unused 3a2a03
      set -l brown    bf5e00 803f00 4d2600
      set -l grey     cccccc 999999 333333
      set -l white    ffffff
      set -l black    000000
      set -l ruby_red af0000

      set -x color_initial_segment_exit     $grey[3] $red[2] --bold
      set -x color_initial_segment_private  $grey[3] $grey[1]
      set -x color_initial_segment_su       $grey[3] $green[2] --bold
      set -x color_initial_segment_jobs     $grey[3] $blue[3] --bold

      set -x color_path                     $grey[1] $grey[2]
      set -x color_path_basename            $grey[1] $grey[3] --bold
      set -x color_path_nowrite             $red[1] $red[3]
      set -x color_path_nowrite_basename    $red[1] $red[3] --bold

      set -x color_repo                     $green[1] $green[3]
      set -x color_repo_work_tree           $grey[1] $white --bold
      set -x color_repo_dirty               $red[2] $white
      set -x color_repo_staged              $orange[1] $orange[3]

      set -x color_vi_mode_default          $grey[2] $grey[3] --bold
      set -x color_vi_mode_insert           $green[2] $grey[3] --bold
      set -x color_vi_mode_visual           $orange[1] $orange[3] --bold

      set -x color_vagrant                  $blue[1] $white --bold
      set -x color_k8s                      $green[1] $colorfg --bold
      set -x color_aws_vault                $blue[3] $orange[1] --bold
      set -x color_aws_vault_expired        $blue[3] $red[3] --bold
      set -x color_username                 $grey[1] $blue[3] --bold
      set -x color_hostname                 $grey[1] $blue[3]
      set -x color_rvm                      $ruby_red $grey[1] --bold
      set -x color_node                     $green $grey[1] --bold
      set -x color_virtualfish              $blue[2] $grey[1] --bold
      set -x color_virtualgo                $blue[2] $grey[1] --bold
      set -x color_desk                     $blue[2] $grey[1] --bold
      set -x color_nix                      $blue[2] $grey[1] --bold

    case 'gruvbox'
      #               light  medium  dark  darkest
      #               ------ ------ ------ -------
      set -l red      fb4934 cc241d
      set -l green    b8bb26 98971a
      set -l yellow   fabd2f d79921
      set -l aqua     8ec07c 689d6a
      set -l blue     83a598 458588
      set -l grey     cccccc 999999 333333
      set -l fg       fbf1c7 ebdbb2 d5c4a1 a89984
      set -l bg       504945 282828

      set -x color_initial_segment_exit     $fg[1] $red[2] --bold
      set -x color_initial_segment_private  $fg[1] $bg[1]
      set -x color_initial_segment_su       $fg[1] $green[2] --bold
      set -x color_initial_segment_jobs     $fg[1] $aqua[2] --bold

      set -x color_path                     $bg[1] $fg[2]
      set -x color_path_basename            $bg[1] $fg[2] --bold
      set -x color_path_nowrite             $red[1] $fg[2]
      set -x color_path_nowrite_basename    $red[1] $fg[2] --bold

      set -x color_repo                     $green[2] $bg[1]
      set -x color_repo_work_tree           $bg[1] $fg[2] --bold
      set -x color_repo_dirty               $red[2] $fg[2]
      set -x color_repo_staged              $yellow[1] $bg[1]

      set -x color_vi_mode_default          $fg[4] $bg[2] --bold
      set -x color_vi_mode_insert           $blue[1] $bg[2] --bold
      set -x color_vi_mode_visual           $yellow[1] $bg[2] --bold

      set -x color_vagrant                  $blue[2] $fg[2] --bold
      set -x color_k8s                      $green[2] $fg[2] --bold
      set -x color_aws_vault                $blue[2] $yellow[1] --bold
      set -x color_aws_vault_expired        $blue[2] $red[1] --bold
      set -x color_username                 $fg[3] $blue[2] --bold
      set -x color_hostname                 $fg[3] $blue[2]
      set -x color_rvm                      $red[2] $fg[2] --bold
      set -x color_node                     $green[1] $fg[2] --bold
      set -x color_virtualfish              $blue[2] $fg[2] --bold
      set -x color_virtualgo                $blue[2] $fg[2] --bold
      set -x color_desk                     $blue[2] $fg[2] --bold
      set -x color_nix                      $blue[2] $fg[2] --bold

    case 'dracula' # https://draculatheme.com
      set -l bg           282a36
      set -l current_line 44475a
      set -l selection    44475a
      set -l fg           f8f8f2
      set -l comment      6272a4
      set -l cyan         8be9fd
      set -l green        50fa7b
      set -l orange       ffb86c
      set -l pink         ff79c6
      set -l purple       bd93f9
      set -l red          ff5555
      set -l yellow       f1fa8c

      set -x color_initial_segment_exit     $fg $red  --bold
      set -x color_initial_segment_private  $fg $selection
      set -x color_initial_segment_su       $fg $purple --bold
      set -x color_initial_segment_jobs     $fg $comment --bold

      set -x color_path                     $selection $fg
      set -x color_path_basename            $selection $fg --bold
      set -x color_path_nowrite             $selection $red
      set -x color_path_nowrite_basename    $selection $red --bold

      set -x color_repo                     $green $bg
      set -x color_repo_work_tree           $selection $fg --bold
      set -x color_repo_dirty               $red $bg
      set -x color_repo_staged              $yellow $bg

      set -x color_vi_mode_default          $bg $yellow --bold
      set -x color_vi_mode_insert           $green $bg --bold
      set -x color_vi_mode_visual           $orange $bg --bold

      set -x color_vagrant                  $pink $bg --bold
      set -x color_k8s                      $purple $bg --bold
      set -x color_aws_vault                $comment $yellow --bold
      set -x color_aws_vault_expired        $comment $red --bold
      set -x color_username                 $selection $cyan --bold
      set -x color_hostname                 $selection $cyan
      set -x color_rvm                      $red $bg --bold
      set -x color_node                     $green $bg --bold
      set -x color_virtualfish              $comment $bg --bold
      set -x color_virtualgo                $cyan $bg --bold
      set -x color_desk                     $comment $bg --bold
      set -x color_nix                      $cyan $bg --bold

    case 'nord'
      set -l base00  2E3440
      set -l base01  3B4252
      set -l base02  434C5E
      set -l base03  4C566A
      set -l base04  D8DEE9
      set -l base05  E5E9F0
      set -l base06  ECEFF4
      set -l base07  8FBCBB
      set -l base08  88C0D0
      set -l base09  81A1C1
      set -l base0A  5E81AC
      set -l base0B  BF616A
      set -l base0C  D08770
      set -l base0D  EBCB8B
      set -l base0E  A3BE8C
      set -l base0F  B48EAD

      set -l colorfg $base00

      set -x color_initial_segment_exit     $base05 $base0B --bold
      set -x color_initial_segment_private  $base05 $base02
      set -x color_initial_segment_su       $base05 $base0E --bold
      set -x color_initial_segment_jobs     $base05 $base0C --bold

      set -x color_path                     $base02 $base05
      set -x color_path_basename            $base02 $base06 --bold
      set -x color_path_nowrite             $base02 $base08
      set -x color_path_nowrite_basename    $base02 $base08 --bold

      set -x color_repo                     $base0E $colorfg
      set -x color_repo_work_tree           $base02 $colorfg --bold
      set -x color_repo_dirty               $base0B $colorfg
      set -x color_repo_staged              $base0D $colorfg

      set -x color_vi_mode_default          $base08 $colorfg --bold
      set -x color_vi_mode_insert           $base06 $colorfg --bold
      set -x color_vi_mode_visual           $base07 $colorfg --bold

      set -x color_vagrant                  $base02 $colorfg --bold
      set -x color_k8s                      $base02 $colorfg --bold
      set -x color_aws_vault                $base0A $base0D --bold
      set -x color_aws_vault_expired        $base0A $base0B --bold
      set -x color_username                 $base02 $base0D --bold
      set -x color_hostname                 $base02 $base0D
      set -x color_rvm                      $base09 $colorfg --bold
      set -x color_node                     $base09 $colorfg --bold
      set -x color_virtualfish              $base09 $colorfg --bold
      set -x color_virtualgo                $base09 $colorfg --bold
      set -x color_desk                     $base09 $colorfg --bold

    case '*' # default dark theme
      #               light  medium dark
      #               ------ ------ ------
      set -l red      cc9999 ce000f 660000
      set -l green    addc10 189303 0c4801
      set -l blue     48b4fb 005faf 255e87
      set -l orange   f6b117 unused 3a2a03
      set -l brown    bf5e00 803f00 4d2600
      set -l grey     cccccc 999999 333333
      set -l white    ffffff
      set -l black    000000
      set -l ruby_red af0000
      set -l go_blue  00d7d7

      set -x color_initial_segment_exit     $white $red[2] --bold
      set -x color_initial_segment_private  $white $grey[3]
      set -x color_initial_segment_su       $white $green[2] --bold
      set -x color_initial_segment_jobs     $white $blue[3] --bold

      set -x color_path                     $grey[3] $grey[2]
      set -x color_path_basename            $grey[3] $white --bold
      set -x color_path_nowrite             $red[3] $red[1]
      set -x color_path_nowrite_basename    $red[3] $red[1] --bold

      set -x color_repo                     $green[1] $green[3]
      set -x color_repo_work_tree           $grey[3] $white --bold
      set -x color_repo_dirty               $red[2] $white
      set -x color_repo_staged              $orange[1] $orange[3]

      set -x color_vi_mode_default          $grey[2] $grey[3] --bold
      set -x color_vi_mode_insert           $green[2] $grey[3] --bold
      set -x color_vi_mode_visual           $orange[1] $orange[3] --bold

      set -x color_vagrant                  $blue[1] $white --bold
      set -x color_k8s                      $green[2] $white --bold
      set -x color_aws_vault                $blue[3] $orange[1] --bold
      set -x color_aws_vault_expired        $blue[3] $red[3] --bold
      set -x color_username                 $grey[1] $blue[3] --bold
      set -x color_hostname                 $grey[1] $blue[3]
      set -x color_rvm                      $ruby_red $grey[1] --bold
      set -x color_node                     $green[1] $white --bold
      set -x color_virtualfish              $blue[2] $grey[1] --bold
      set -x color_virtualgo                $go_blue $black --bold
      set -x color_desk                     $blue[2] $grey[1] --bold
      set -x color_nix                      $blue[2] $grey[1] --bold
  end
end

function __bobthefish_user_color_scheme_deprecated
  set -q __color_initial_segment_exit;     or set -l __color_initial_segment_exit     ffffff ce000f --bold
  set -q __color_initial_segment_private;  or set -l __color_initial_segment_private  ffffff 255e87
  set -q __color_initial_segment_su;       or set -l __color_initial_segment_su       ffffff 189303 --bold
  set -q __color_initial_segment_jobs;     or set -l __color_initial_segment_jobs     ffffff 255e87 --bold
  set -q __color_path;                     or set -l __color_path                     333333 999999
  set -q __color_path_basename;            or set -l __color_path_basename            333333 ffffff --bold
  set -q __color_path_nowrite;             or set -l __color_path_nowrite             660000 cc9999
  set -q __color_path_nowrite_basename;    or set -l __color_path_nowrite_basename    660000 cc9999 --bold
  set -q __color_repo;                     or set -l __color_repo                     addc10 0c4801
  set -q __color_repo_work_tree;           or set -l __color_repo_work_tree           333333 ffffff --bold
  set -q __color_repo_dirty;               or set -l __color_repo_dirty               ce000f ffffff
  set -q __color_repo_staged;              or set -l __color_repo_staged              f6b117 3a2a03
  set -q __color_vi_mode_default;          or set -l __color_vi_mode_default          999999 333333 --bold
  set -q __color_vi_mode_insert;           or set -l __color_vi_mode_insert           189303 333333 --bold
  set -q __color_vi_mode_visual;           or set -l __color_vi_mode_visual           f6b117 3a2a03 --bold
  set -q __color_vagrant;                  or set -l __color_vagrant                  48b4fb ffffff --bold
  set -q __color_username;                 or set -l __color_username                 cccccc 255e87 --bold
  set -q __color_hostname;                 or set -l __color_hostname                 cccccc 255e87
  set -q __color_rvm;                      or set -l __color_rvm                      af0000 cccccc --bold
  set -q __color_virtualfish;              or set -l __color_virtualfish              005faf cccccc --bold
  set -q __color_virtualgo;                or set -l __color_virtualgo                005faf cccccc --bold
  set -q __color_desk;                     or set -l __color_desk                     005faf cccccc --bold
  set -q __color_nix;                      or set -l __color_nix                      005faf cccccc --bold

  set_color black -b red --bold
  echo "The 'user' color scheme is deprecated."
  set_color normal
  set_color black -b red
  echo "To define a custom color scheme, create a 'bobthefish_colors' function:"
  set_color normal
  echo

  echo "function bobthefish_colors -S -d 'Define a custom bobthefish color scheme'

  # optionally include a base color scheme...
  ___bobthefish_colors default

  # then override everything you want! note that these must be defined with `set -x`
  set -x color_initial_segment_exit     $__color_initial_segment_exit
  set -x color_initial_segment_private  $__color_initial_segment_private
  set -x color_initial_segment_su       $__color_initial_segment_su
  set -x color_initial_segment_jobs     $__color_initial_segment_jobs
  set -x color_path                     $__color_path
  set -x color_path_basename            $__color_path_basename
  set -x color_path_nowrite             $__color_path_nowrite
  set -x color_path_nowrite_basename    $__color_path_nowrite_basename
  set -x color_repo                     $__color_repo
  set -x color_repo_work_tree           $__color_repo_work_tree
  set -x color_repo_dirty               $__color_repo_dirty
  set -x color_repo_staged              $__color_repo_staged
  set -x color_vi_mode_default          $__color_vi_mode_default
  set -x color_vi_mode_insert           $__color_vi_mode_insert
  set -x color_vi_mode_visual           $__color_vi_mode_visual
  set -x color_vagrant                  $__color_vagrant
  set -x color_aws_vault                $__color_aws_vault
  set -x color_aws_vault_expired        $__color_aws_vault_expired
  set -x color_username                 $__color_username
  set -x color_hostname                 $__color_hostname
  set -x color_rvm                      $__color_rvm
  set -x color_virtualfish              $__color_virtualfish
  set -x color_virtualgo                $__color_virtualgo
  set -x color_desk                     $__color_desk
  set -x color_nix                      $__color_nix
end"

  echo
end

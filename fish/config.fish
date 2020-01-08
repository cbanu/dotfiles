# prompt
function fish_prompt
        set_color brblack
        echo -n "["(date "+%H:%M")"] "
        set_color yellow
        echo -n (whoami)
        set_color normal
        echo -n "@"
        set_color blue
        echo -n (hostname)
        if [ $PWD != $HOME ]
                set_color brblack
                echo -n ':'
                set_color yellow
                echo -n (basename $PWD)
        end
        set_color green
        printf '%s ' (__fish_git_prompt)
        set_color red
        echo -n '| '
        set_color normal
end

# abbreviations

abbr -a l   "exa"
abbr -a ls  "exa"
abbr -a ll  "exa -l"
abbr -a lll "exa -la"

abbr -a g   "git"
abbr -a gst "git status"
abbr -a gss "git stash save"
abbr -a gsl "git stash list"
abbr -a gl  "git log"
abbr -a gll "git log --oneline --graph --all"
abbr -a gco "git checkout"
abbr -a gf  "git fetch"
abbr -a gr  "git rebase"
abbr -a gd  "git diff"
abbr -a gds "git diff --staged"
abbr -a ga  "git add"
abbr -a gc  "git commit"
abbr -a gcm "git commit --message"
abbr -a gp  "git push"

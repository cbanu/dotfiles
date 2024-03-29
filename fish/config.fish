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
abbr -a gll "git log --oneline --color --decorate --graph --branches --remotes"
abbr -a gco "git checkout"
abbr -a gf  "git fetch --no-tags"
abbr -a gsu "git submodule update"
abbr -a gr  "git rebase"
abbr -a gd  "git diff"
abbr -a gds "git diff --staged"
abbr -a ga  "git add"
abbr -a gc  "git commit"
abbr -a gcm "git commit --message"
abbr -a gp  "git push"

# paths
if test -d ~/bin
    set -U fish_user_paths $fish_user_paths ~/bin
end
if test -d ~/.cargo/bin/
    set -U fish_user_paths $fish_user_paths ~/.cargo/bin/
end

# SSH agent
if test -z "$SSH_AUTH_SOCK"
    # check for a currently running instance of the agent
    set RUNNING_AGENT (ps -ax | grep 'ssh-agent -s' | grep -v grep | wc -l | tr -d '[:space:]')
    if test "$RUNNING_AGENT" = "0"
        # launch a new instance of the agent
        ssh-agent -s > $HOME/.ssh/ssh-agent
    end
    # we need fish equivalent of bash's eval:
    #   eval $(cat $HOME/.ssh/ssh-agent) >/dev/null
    bash -c "eval '$(cat $HOME/.ssh/ssh-agent)' >/dev/null ; printenv | grep -E '^(SSH_AUTH_SOCK|SSH_AGENT_PID)=' | sed 's/^/export /'" \
        | source
end

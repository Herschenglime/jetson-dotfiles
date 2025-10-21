function git_commit_and_push -d "Commit with arguments as comment and push"
    if test (count $argv) -eq 0
        git commit -a && git push
    else
        git commit -a -m "$argv" && git push
    end
end

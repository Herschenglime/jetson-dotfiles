function yadm-commit-and-push -d "Commit with arguments as comment and push"
    # defined in yadm.fish, adds folders that should catch all new files automatically
    echo "adding $yadm_auto_add_folders"
    yadm add $yadm_auto_add_folders
    if test (count $argv) -eq 0
        yadm commit -a && yadm push
    else
        yadm commit -a -m "$argv" && yadm push
    end
end

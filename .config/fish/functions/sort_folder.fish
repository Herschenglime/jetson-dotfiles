#!/usr/bin/env fish

function get-destination
    set -l dir

    # make directory for fzf history if needed, otherwise does nothing
    mkdir -p "$HOME/.config/fzf"

    # pick a dest
    echo (
      cd ~ &&
      fd -0 --type d \
        --ignore-file ~/.config/fd/ds_ignore --follow | \
      sed 's/\.\///g' | \
      sed 's/$/\0Trash/' | \
      fzf --read0 --history="$HOME/.config/fzf/dest_history" --scheme=history
    )

end

function sort_folder
    argparse s/source_dir= -- $argv

    # get source dir
    if not set -ql _flag_source_dir
        # no folder selected, defaulting to ~/Downloads
        set -f source_dir ~/Downloads
    else
        set -f source_dir $_flag_source_dir
    end

    if test (count (ls -A $source_dir)) -eq 0
        echo "Already cleared!"
        return 0
    end

    # check if Downloads folder is not empty
    while test (count (ls -A $source_dir)) -gt 0
        # Use fzf to select files to move
        set -l batch (ls -t $source_dir | fzf --multi --exit-0 --no-sort --prompt "Choose files: ")

        # exit if no files selected
        if test -z "$batch"
            echo "No files selected" && return 1
        end

        # Get destination directory
        set -l dir (get-destination)

        # exit if destination is not selected
        if test -z "$dir"
            return 1
        end

        set -l destination_confirmed false

        while test $destination_confirmed = false
            echo "Chosen files are: $batch"
            echo "Destination is: $dir"

            read -l -P "Continue with move? [Y/n] " choice
            if test -z "$choice" -o "$choice" = Y -o "$choice" = y
                cd $source_dir

                if test "$dir" = Trash
                    for file in $batch
                        trash "$file"
                    end
                    echo "Files moved to trash."
                else
                    for file in $batch
                        mv -i -v "$file" "$HOME/$dir"
                    end
                    echo "Move complete!"
                end

                set destination_confirmed true
            else
                read -l -P "Move canceled. Change destination? [Y/n] " choice
                if test -z "$choice" -o "$choice" = Y -o "$choice" = y
                    echo ""
                    set dir (get-destination)
                else
                    echo "Exiting sorter."
                    return
                end
            end
        end
    end

    echo "Downloads folder cleared!"
end

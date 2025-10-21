#!/usr/bin/env fish

function dir_picker -d "Given -s/--source_dir, list dirs in that source and pipe them to fzf, echoing the output. Any other arguments are treated as a query"
    # We tell argparse about -h/--help and -s/--second - these are short and long forms of the same option.
    # The "--" here is mandatory, it tells it from where to read the arguments.
    argparse s/source_dir= -- $argv
    # exit if argparse failed because it found an option it didn't recognize - it will print an error
    or return

    # If -s or --source_dir isn't given, set to current folder by default
    if not set -ql _flag_source_dir
        set -f source_dir .
    else
        set -f source_dir $_flag_source_dir
    end

    # put dirs found into a variable so we can add a base to the directory
    set -f found_dirs (fd --type=dir . $source_dir)
    set -p found_dirs $source_dir # add source as an option to choose

    # trim off leading path to source dir
    set found_dirs (string replace (dirname $source_dir)/ "" $found_dirs)


    # call fzf, with or without a prefilled query
    if not test (count $argv) -eq 0
        # prepopulate with query
        set -f selected_dir (printf "%s\n" $found_dirs | fzf --height=100% --select-1 --query "$argv")
    else
        set -f selected_dir (printf "%s\n" $found_dirs | fzf --height=100%)
    end

    # https://stackoverflow.com/a/47743269
    if test -z "$selected_dir"
        echo "No dir selected"
        return 1
    else
        xdg-open "$selected_dir"
    end

end

#!/usr/bin/env fish

function find-and-edit -d "Given -s/--source_dir, list files in that source and pipe them to fzf, echoing the output. Any other arguments are treated as a query"
    # We tell argparse about -h/--help and -s/--second - these are short and long forms of the same option.
    # The "--" here is mandatory, it tells it from where to read the arguments.
    argparse s/source_dir= -- $argv
    # exit if argparse failed because it found an option it didn't recognize - it will print an error
    or return

    # If -s or --source_dir isn't given, we exit
    if not set -ql _flag_source_dir
        set -f sourceDir .
    else
        set -f sourceDir $_flag_source_dir
    end

    # call fzf, with or without a prefilled query
    if not test (count $argv) -eq 0
        # prepopulate with query
        set -f selectedFile (fd -t f . $sourceDir | fzf --select-1 --query "$argv")
    else
        set -f selectedFile (fd -t f . $sourceDir | fzf)
    end

    # https://stackoverflow.com/a/47743269
    if test -z "$selectedFile"
        echo "No file selected"
        return 1
    else
        e "$selectedFile"
    end

end

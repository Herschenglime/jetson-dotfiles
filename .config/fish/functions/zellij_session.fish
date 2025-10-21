#!/usr/bin/env fish

# attach to zellij session if it already exists, otherwise create a new one with that name
function zellij_session --wraps='zellij' --description "attach to zellij session if it already exists, otherwise create a new one with that name"
    if test (count $argv) -eq 0
        echo "error: must supply a session name. exiting."
        return -1
    else
        zellij -s "$argv[1]" || zellij attach "$argv[1]"
    end
end


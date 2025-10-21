#!/usr/bin/env fish


function moonmerge --description "Merge moonlander config off oryx and local qmk"
    cd ~/dev/moonlander-config
    bash merge_configs.sh
end

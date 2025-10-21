function multicd --description "Expand a series of ... into that many directories back"
    echo (string repeat -n (math (string length -- $argv[1]) - 1) ../)
end

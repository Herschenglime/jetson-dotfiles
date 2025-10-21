function e --wraps='$EDITOR' --description "Call whatever's set by $EDITOR"
  eval $EDITOR $argv
end


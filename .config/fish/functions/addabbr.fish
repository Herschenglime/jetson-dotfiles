function addabbr -w abbr
    abbr --add $argv
    and echo -- abbr --add $argv >> ~/.config/fish/conf.d/99-abbrs.fish
end

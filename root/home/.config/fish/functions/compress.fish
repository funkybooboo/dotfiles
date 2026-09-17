function compress --description 'tar.gz a file or directory'
    tar -czf (string replace -r '/$' '' -- $argv[1]).tar.gz $argv[1]
end

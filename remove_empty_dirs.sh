find $1 -type d -print0 | xargs -0 rmdir --ignore-fail-on-non-empty --parents

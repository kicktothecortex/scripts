#!/bin/bash

calibre-server --daemonize --port 1984 --with-library=/portamedia/calibre_library

## Options ##
#############

# --version
# show program's version number and exit

# -h, --help
# show this help message and exit

# -p PORT, --port=PORT
# The port on which to listen. Default is 8080

# -t TIMEOUT, --timeout=TIMEOUT
# The server timeout in seconds. Default is 120

# --thread-pool=THREAD_POOL
# The max number of worker threads to use. Default is 30

# --password=PASSWORD
# Set a password to restrict access. By default access is unrestricted.

# --username=USERNAME
# Username for access. By default, it is: 'calibre'

# --develop
# Development mode. Server automatically restarts on file changes and serves code files (html, css, js) from the file system instead of calibre's resource system.

# --max-cover=MAX_COVER
# The maximum size for displayed covers. Default is '600x800'.

# --max-opds-items=MAX_OPDS_ITEMS
# The maximum number of matches to return per OPDS query. This affects Stanza, WordPlayer, etc. integration.

# --with-library=WITH_LIBRARY
# Path to the library folder to serve with the content server

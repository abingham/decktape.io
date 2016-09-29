1. git pull
2. workon decktape-io
3. python setup.py install
4. Restart worker(s). These are running in a tmux, so `tmux a` and `Ctrl-b n` to navigate the consoles.
5. Restart the pyramid server, also in the tmux.
6. cd decktape_io/elm && elm-make Main.elm --yes --output=decktape_io.js

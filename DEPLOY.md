# Deployment of decktape.io

## Onto a new machine

We're targeting ubuntu-xenial machines on the google cloud.

 1. Create a new micro ubuntu-xenial instance
<<<<<<< HEAD
 Allow HTTPS traffic
=======
 Allow HTTP traffic. (We still need to sort out https.)
>>>>>>> Updated DEPLOY.md instructions.

 2. Update apt repos

 ```
 sudo apt-get update
 ```

 3. Install a bunch of stuff

 ```
 sudo apt-get install git nginx mongodb tmux make virtualenvwrapper python3.5 rabbitmq-server
 ```

 4. Install node and npm
 ```
 curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
 sudo apt-get install -y nodejs
 ```

 5. Clone the repo

 ```
 mkdir src
 pushd src
 git clone https://github.com/abingham/decktape.io
 popd
 ```

 6. Create a virtual environment

 ```
 mkvirtualenv -p `which python3.5` decktape-io
 ```

 Note that you may have to start a new bash terminal for this to work.

 7. Build the project

 ```
 pushd src/decktape.io
 workon decktape-io
 make install
 popd
 ```

 8. Install the nginx configuration
 ```
 sudo rm /etc/nginx/sites-enabled/default
 sudo ln -s ~/src/decktape.io/nginx.conf /etc/nginx/sites-enabled/default
 sudo service nginx restart
 ```

 9. Start celery worker in a tmux terminal
 ```
 tmux
 workon decktape-io
 celery -A decktape_io.worker worker
 <C-b c>
 workon decktape-io
 cd ~/src/decktape.io
 pserve production.ini
 <C-b d>
 ```

## Updating a running system

1. git pull
2. workon decktape-io
3. make install
4. Restart worker(s). These are running in a tmux, so `tmux a` and `Ctrl-b n` to navigate the consoles.
5. Restart the pyramid server, also in the tmux.

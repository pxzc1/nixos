- To push local commit to github.com, use the following commands: (+: sudo chown -R $USER:users /etc/nixos)
1. git init
2. git add .
3. git status (check for changes; optional)
4. git commin -m "<msg>"
5. eval $(ssh-agent) -> must return Agent PID
6. ssh-add ~/.ssh/id_ed25519
7. ssh -T git@github.com
8. sudo SSH_AUTH_SOCK=$SSH_AUTH_SOCK git --git-dir=/etc/nixos/.git --work-tree=/etc/nixos push -u origin main

# ws_pegass
Webservice to Pegass

# Lancement en local
Pour installer, après avoir cloner le projet

```gem install bundler```

```bundle install```

Vous pouvez ajouter 'rack' et 'rerun' avec une commande 'gem install'.

```
rerun rackup
```

#Via Docker

```
docker build -t ws_pegass .
docker run --name ws_pegass_server -p 3000 -d ws_pegass
```

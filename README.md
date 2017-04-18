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
docker build -t slavayssiere/ws_pegass .
docker build -t slavayssiere/bot_pegass -f ./DockerfileBot
docker run --name ws_pegass_server -p 3000 -d ws_pegass
```

sudo docker run --name pegass-bot -d --env PEGASS_LOGIN=* --env PEGASS_PASSWORD=* --env SLACK_API_TOKEN=* slavayssiere/bot_pegass

sudo docker run --name pegass-ws -p 8080:8080 -d slavayssiere/ws_pegass
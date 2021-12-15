.PHONY: build up stop down show
NAME=web_app
VERSION=1.0

#imageの作成
build:
    docker-compose build
#起動
up:
    docker-compose up -d
#停止
stop:
    docker-compose stop
#削除
down:
    docker-compose down --volumes
#コンテナ一覧
show:
    docker container ls -a
#イメージの削除
rmi:
    docker image prune
#Laravelプロジェクトの作成
project:
    docker exec $(NAME) composer create-project "laravel/laravel=~6.0" --prefer-dist webapp
#Laravel環境へのログイン
login:
    docker exec -it $(NAME) /bin/bash
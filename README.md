# プロジェクトフォルダ作成

```shell:setup.sh

mkdir docker src docker/app docker/db
touch docker/app/000-default.conf
touch docker/app/Dockerfile
touch docker/app/php.ini
touch docker-compose.yml
touch Makefile

```

# ファイル内容入力（参考サイト通りにやる）

```conf:000-default.conf

<VirtualHost *:80>
       ServerAdmin webmaster@localhost
       DocumentRoot /var/www/html/webapp/public
       ErrorLog ${APACHE_LOG_DIR}/error.log
       CustomLog ${APACHE_LOG_DIR}/access.log combined
       <Directory /var/www/html/webapp/public>
           AllowOverride All
       </Directory>
</VirtualHost>

```

```Dockerfile:Dockerfile
FROM php:7.4-apache

#Composerのインストール
COPY --from=composer /usr/bin/composer /usr/bin/composer

# ミドルウェアのインストール
RUN apt-get update \
&& apt-get install -y \
git \
zip \
unzip \
vim \
libpng-dev \
libpq-dev \
&& docker-php-ext-install pdo_mysql

# 設定ファイルの読み込み
COPY php.ini /usr/local/etc/php/
COPY 000-default.conf /etc/apache2/sites-enabled/
```

```ini:php.ini
[Date]
date.timezone = "Asia/Tokyo"
[mbstring]
mbstring.internal_encoding = "UTF-8"
mbstring.language = "Japanese"
```

```yml:docker-compose.yml
version: '3'
services:
# laravel
  app:
    build: ./docker/app
    container_name: web_app
    ports:
       - 8080:80
    volumes:
     - ./src:/var/www/html
# mariadb
  db:
    image: mariadb:5.5
    container_name: web_db
    environment:
      - MYSQL_ROOT_PASSWORD=password
      - MYSQL_DATABASE=webapp
    ports:
      - 3306:3306
    volumes:
      - ./docker/db:/var/lib/mariadb
      - ./docker/db:/docker-entrypoint-initdb.d
# phpMyAdmin
  phpmyadmin:
    image: phpmyadmin/phpmyadmin
    container_name: web_phpmyadmin
    environment:
      - PMA_ARBITRARY=1
      - PMA_HOST=db
      - PMA_USER=root
      - PMA_PASSWORD=password
    ports:
      - 8081:80
# mailhog
  mailhog:
    container_name: web_smtp
    image: mailhog/mailhog
    ports:
      - 8025:8025
      - 1025:1025
```

```Makefile:Makefile
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
```

# コマンド実行

<details>
  <summary>docker-compose build</summary>

```log:docker-compose build
$ docker-compose build
[+] Building 28.7s (13/13) FINISHED
 => [internal] load build definition from Dockerfile                                                                                                                                                                                                                       0.0s
 => => transferring dockerfile: 460B                                                                                                                                                                                                                                       0.0s
 => [internal] load .dockerignore                                                                                                                                                                                                                                          0.0s
 => => transferring context: 2B                                                                                                                                                                                                                                            0.0s
 => [internal] load metadata for docker.io/library/php:7.4-apache                                                                                                                                                                                                          2.4s
 => [auth] library/php:pull token for registry-1.docker.io                                                                                                                                                                                                                 0.0s
 => FROM docker.io/library/composer:latest                                                                                                                                                                                                                                 7.1s
 => => resolve docker.io/library/composer:latest                                                                                                                                                                                                                           2.3s
 => => sha256:64272a1ff5e0dccdc7015fe532e30f239359e890ba73ecd68aa68129dac8a56c 3.25kB / 3.25kB                                                                                                                                                                             0.0s
 => => sha256:17b996f72d084992245591794772ce69d13ea7ee4b75a611f09adbe982550314 12.89kB / 12.89kB                                                                                                                                                                           0.0s
 => => sha256:78a6e12e5b4f04e4f94ff5b9dc8dc05a6178c6262f99fcb4eb9fefa1e3f57e6d 1.65kB / 1.65kB                                                                                                                                                                             0.0s
 => => sha256:7c7da25b2876b1c935b05d7e6efa3e8cd559d031cf30b246d7659ed438726acd 1.71MB / 1.71MB                                                                                                                                                                             0.7s
 => => sha256:2bc599114627e3bd98e0204b93b161e03065bf9a228bb02ae202469655f12b8d 1.26kB / 1.26kB                                                                                                                                                                             0.2s
 => => sha256:927a0b37a45a98d7d74a6d7d1567230eca834fb89417274557de7986d1f39401 268B / 268B                                                                                                                                                                                 0.4s
 => => sha256:764e508e2224218d8b25345cb5032292db8bd457f09e91a8bccb495588ce5f38 11.76MB / 11.76MB                                                                                                                                                                           1.9s
 => => sha256:07210dc10f8b68d3d56bba59cc7528a5af177c81633b27d159f60a19d0333946 493B / 493B                                                                                                                                                                                 0.8s
 => => extracting sha256:7c7da25b2876b1c935b05d7e6efa3e8cd559d031cf30b246d7659ed438726acd                                                                                                                                                                                  0.3s
 => => sha256:156cbca52176c4c8815ef25385b64e9b1fc00ca289feb16a7389a40b8e7a06de 15.45MB / 15.45MB                                                                                                                                                                           2.7s
 => => sha256:b5e3adb8097dfa29c611698eb232236bb8c30e96e663baf91ab347afe8150a49 2.31kB / 2.31kB                                                                                                                                                                             1.3s
 => => extracting sha256:2bc599114627e3bd98e0204b93b161e03065bf9a228bb02ae202469655f12b8d                                                                                                                                                                                  0.1s
 => => extracting sha256:927a0b37a45a98d7d74a6d7d1567230eca834fb89417274557de7986d1f39401                                                                                                                                                                                  0.0s
 => => sha256:7d0ee9e608a2c8ba86aef3ea2d35a618a5db6a2b098c1ff9781b1daa372fdfce 18.39kB / 18.39kB                                                                                                                                                                           1.6s
 => => sha256:cac9bee6091ebdda81b20ee0a949cdf27abe6d290c168fa7e0515a6efd14c9f8 34.65MB / 34.65MB                                                                                                                                                                           4.9s
 => => sha256:bc1d019d7265b29a5680eb37a50a88662dcd05d8e12257bb8e3c7db77b7a7239 259B / 259B                                                                                                                                                                                 2.2s
 => => extracting sha256:764e508e2224218d8b25345cb5032292db8bd457f09e91a8bccb495588ce5f38                                                                                                                                                                                  0.1s
 => => extracting sha256:07210dc10f8b68d3d56bba59cc7528a5af177c81633b27d159f60a19d0333946                                                                                                                                                                                  0.0s
 => => sha256:2dd061f3ee0e4c274fa45a85c43278cf6bbf47c45d0a459eba928741f85c148f 1.38MB / 1.38MB                                                                                                                                                                             2.7s
 => => extracting sha256:156cbca52176c4c8815ef25385b64e9b1fc00ca289feb16a7389a40b8e7a06de                                                                                                                                                                                  0.8s
 => => sha256:1edcd8bb518411cbac634219d087de02e19f8c5378ff5a7ee1b9a9d6711cc42e 408B / 408B                                                                                                                                                                                 2.9s
 => => sha256:2830af490668fb20eda6203e218d91467b86d0cc8e81dfd997db347185caf527 124B / 124B                                                                                                                                                                                 3.0s
 => => extracting sha256:b5e3adb8097dfa29c611698eb232236bb8c30e96e663baf91ab347afe8150a49                                                                                                                                                                                  0.0s
 => => extracting sha256:7d0ee9e608a2c8ba86aef3ea2d35a618a5db6a2b098c1ff9781b1daa372fdfce                                                                                                                                                                                  0.0s
 => => extracting sha256:cac9bee6091ebdda81b20ee0a949cdf27abe6d290c168fa7e0515a6efd14c9f8                                                                                                                                                                                  1.5s
 => => extracting sha256:bc1d019d7265b29a5680eb37a50a88662dcd05d8e12257bb8e3c7db77b7a7239                                                                                                                                                                                  0.0s
 => => extracting sha256:2dd061f3ee0e4c274fa45a85c43278cf6bbf47c45d0a459eba928741f85c148f                                                                                                                                                                                  0.1s
 => => extracting sha256:1edcd8bb518411cbac634219d087de02e19f8c5378ff5a7ee1b9a9d6711cc42e                                                                                                                                                                                  0.0s
 => => extracting sha256:2830af490668fb20eda6203e218d91467b86d0cc8e81dfd997db347185caf527                                                                                                                                                                                  0.0s
 => CACHED [stage-0 1/5] FROM docker.io/library/php:7.4-apache@sha256:50e659446dc4db3b120f239993f8cd308c193e5b833810827b4015d7245203aa                                                                                                                                     0.0s
 => [internal] load build context                                                                                                                                                                                                                                          0.0s
 => => transferring context: 522B                                                                                                                                                                                                                                          0.0s
 => [auth] library/composer:pull token for registry-1.docker.io                                                                                                                                                                                                            0.0s
 => [stage-0 2/5] COPY --from=composer /usr/bin/composer /usr/bin/composer                                                                                                                                                                                                 0.1s
 => [stage-0 3/5] RUN apt-get update && apt-get install -y git zip unzip vim libpng-dev libpq-dev && docker-php-ext-install pdo_mysql                                                                                                                                     15.9s
 => [stage-0 4/5] COPY php.ini /usr/local/etc/php/                                                                                                                                                                                                                         0.0s
 => [stage-0 5/5] COPY 000-default.conf /etc/apache2/sites-enabled/                                                                                                                                                                                                        0.0s
 => exporting to image                                                                                                                                                                                                                                                     0.6s
 => => exporting layers                                                                                                                                                                                                                                                    0.6s
 => => writing image sha256:c5751d6a5b48b6e1704a62d5741aaf0ce19eec016c6648c5d34f8e645520e955                                                                                                                                                                               0.0s
 => => naming to docker.io/library/lalaveldocker_app                                                                                                                                                                                                                       0.0s

Use 'docker scan' to run Snyk tests against images to find vulnerabilities and learn how to fix them

```

</details>

<details>
  <summary>docker-compose up -d</summary>

```log:docker-compose up -d （ログは全部記録できなかった。）
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       24.2s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       24.2s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       24.2s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       24.2s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       24.2s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       24.2s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       24.2s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       24.2s
[+] Running 22/42 Waiting                                                                                                                                                                                                                                                 24.2s
 - db Pulling                                                                                                                                                                                                                                                             28.7s
   - a7344f52cb74 Extracting [==============>                                    ]  20.05MB/67.19MB                                                                                                                                                                       24.3s
   - 515c9bb51536 Download complete                                                                                                                                                                                                                                       24.3s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       24.3s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       24.3s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       24.3s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       24.3s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       24.3s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       24.3s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       24.3s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       24.3s
[+] Running 22/42 Waiting                                                                                                                                                                                                                                                 24.3s
 - db Pulling                                                                                                                                                                                                                                                             28.8s
   - a7344f52cb74 Extracting [================>                                  ]  22.84MB/67.19MB                                                                                                                                                                       24.4s
   - 515c9bb51536 Download complete                                                                                                                                                                                                                                       24.4s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       24.4s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       24.4s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       24.4s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       24.4s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       24.4s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       24.4s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       24.4s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       24.4s
[+] Running 22/42 Download complete                                                                                                                                                                                                                                       24.4s
 - db Pulling                                                                                                                                                                                                                                                             28.9s
   - a7344f52cb74 Extracting [==================>                                ]  25.07MB/67.19MB                                                                                                                                                                       24.5s
   - 515c9bb51536 Download complete                                                                                                                                                                                                                                       24.5s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       24.5s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       24.5s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       24.5s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       24.5s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       24.5s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       24.5s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       24.5s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       24.5s
[+] Running 22/42 Download complete                                                                                                                                                                                                                                       24.5s
 - db Pulling                                                                                                                                                                                                                                                             29.0s
   - a7344f52cb74 Extracting [====================>                              ]  27.85MB/67.19MB                                                                                                                                                                       24.6s
   - 515c9bb51536 Download complete                                                                                                                                                                                                                                       24.6s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       24.6s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       24.6s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       24.6s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       24.6s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       24.6s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       24.6s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       24.6s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       24.6s
[+] Running 22/42 Download complete                                                                                                                                                                                                                                       24.6s
 - db Pulling                                                                                                                                                                                                                                                             29.1s
   - a7344f52cb74 Extracting [=====================>                             ]  29.52MB/67.19MB                                                                                                                                                                       24.7s
   - 515c9bb51536 Download complete                                                                                                                                                                                                                                       24.7s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       24.7s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       24.7s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       24.7s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       24.7s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       24.7s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       24.7s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       24.7s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       24.7s
[+] Running 22/42 Download complete                                                                                                                                                                                                                                       24.7s
 - db Pulling                                                                                                                                                                                                                                                             29.2s
   - a7344f52cb74 Extracting [=======================>                           ]  31.75MB/67.19MB                                                                                                                                                                       24.8s
   - 515c9bb51536 Download complete                                                                                                                                                                                                                                       24.8s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       24.8s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       24.8s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       24.8s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       24.8s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       24.8s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       24.8s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       24.8s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       24.8s
[+] Running 22/42 Download complete                                                                                                                                                                                                                                       24.8s
 - db Pulling                                                                                                                                                                                                                                                             29.3s
   - a7344f52cb74 Extracting    [=======================>                           ]  31.75MB/67.19MB                                                                                                                                                                    24.9s
   - 515c9bb51536 Download complete                                                                                                                                                                                                                                       24.9s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       24.9s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       24.9s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       24.9s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       24.9s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       24.9s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       24.9s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       24.9s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       24.9s
[+] Running 22/42 Download complete                                                                                                                                                                                                                                       24.9s
 - db Pulling                                                                                                                                                                                                                                                             29.4s
   - a7344f52cb74 Extracting    [=========================>                         ]  34.54MB/67.19MB                                                                                                                                                                    25.0s
   - 515c9bb51536 Download complete                                                                                                                                                                                                                                       25.0s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       25.0s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       25.0s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       25.0s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       25.0s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       25.0s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       25.0s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       25.0s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       25.0s
[+] Running 22/42 Download complete                                                                                                                                                                                                                                       25.0s
 - db Pulling                                                                                                                                                                                                                                                             29.5s
   - a7344f52cb74 Extracting    [============================>                      ]  37.88MB/67.19MB                                                                                                                                                                    25.1s
   - 515c9bb51536 Download complete                                                                                                                                                                                                                                       25.1s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       25.1s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       25.1s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       25.1s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       25.1s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       25.1s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       25.1s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       25.1s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       25.1s
[+] Running 22/42 Download complete                                                                                                                                                                                                                                       25.1s
 - db Pulling                                                                                                                                                                                                                                                             29.6s
   - a7344f52cb74 Extracting      [=============================>                     ]  39.55MB/67.19MB                                                                                                                                                                  25.2s
   - 515c9bb51536 Download complete                                                                                                                                                                                                                                       25.2s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       25.2s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       25.2s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       25.2s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       25.2s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       25.2s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       25.2s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       25.2s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       25.2s
[+] Running 22/42 Download complete                                                                                                                                                                                                                                       25.2s
 - db Pulling                                                                                                                                                                                                                                                             29.7s
   - a7344f52cb74 Extracting      [===============================>                   ]  41.78MB/67.19MB                                                                                                                                                                  25.3s
   - 515c9bb51536 Download complete                                                                                                                                                                                                                                       25.3s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       25.3s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       25.3s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       25.3s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       25.3s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       25.3s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       25.3s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       25.3s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       25.3s
[+] Running 22/42 Download complete                                                                                                                                                                                                                                       25.3s
 - db Pulling                                                                                                                                                                                                                                                             29.8s
   - a7344f52cb74 Extracting      [================================>                  ]  44.01MB/67.19MB                                                                                                                                                                  25.4s
   - 515c9bb51536 Download complete                                                                                                                                                                                                                                       25.4s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       25.4s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       25.4s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       25.4s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       25.4s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       25.4s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       25.4s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       25.4s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       25.4s
[+] Running 22/42 Download complete                                                                                                                                                                                                                                       25.4s
 - db Pulling                                                                                                                                                                                                                                                             29.9s
   - a7344f52cb74 Extracting      [==================================>                ]  46.79MB/67.19MB                                                                                                                                                                  25.5s
   - 515c9bb51536 Download complete                                                                                                                                                                                                                                       25.5s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       25.5s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       25.5s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       25.5s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       25.5s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       25.5s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       25.5s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       25.5s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       25.5s
[+] Running 22/42 Download complete                                                                                                                                                                                                                                       25.5s
 - db Pulling                                                                                                                                                                                                                                                             30.0s
   - a7344f52cb74 Extracting      [====================================>              ]  49.02MB/67.19MB                                                                                                                                                                  25.6s
   - 515c9bb51536 Download complete                                                                                                                                                                                                                                       25.6s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       25.6s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       25.6s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       25.6s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       25.6s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       25.6s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       25.6s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       25.6s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       25.6s
[+] Running 22/42 Download complete                                                                                                                                                                                                                                       25.6s
 - db Pulling                                                                                                                                                                                                                                                             30.1s
   - a7344f52cb74 Extracting      [======================================>            ]  51.25MB/67.19MB                                                                                                                                                                  25.7s
   - 515c9bb51536 Download complete                                                                                                                                                                                                                                       25.7s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       25.7s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       25.7s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       25.7s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       25.7s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       25.7s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       25.7s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       25.7s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       25.7s
[+] Running 22/42 Download complete                                                                                                                                                                                                                                       25.7s
 - db Pulling                                                                                                                                                                                                                                                             30.2s
   - a7344f52cb74 Extracting      [======================================>            ]  51.25MB/67.19MB                                                                                                                                                                  25.8s
   - 515c9bb51536 Download complete                                                                                                                                                                                                                                       25.8s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       25.8s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       25.8s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       25.8s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       25.8s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       25.8s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       25.8s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       25.8s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       25.8s
[+] Running 22/42 Download complete                                                                                                                                                                                                                                       25.8s
 - db Pulling                                                                                                                                                                                                                                                             30.3s
   - a7344f52cb74 Extracting      [=======================================>           ]  53.48MB/67.19MB                                                                                                                                                                  25.9s
   - 515c9bb51536 Download complete                                                                                                                                                                                                                                       25.9s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       25.9s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       25.9s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       25.9s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       25.9s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       25.9s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       25.9s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       25.9s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       25.9s
[+] Running 22/42 Download complete                                                                                                                                                                                                                                       25.9s
 - db Pulling                                                                                                                                                                                                                                                             30.4s
   - a7344f52cb74 Extracting      [=========================================>         ]  55.15MB/67.19MB                                                                                                                                                                  26.0s
   - 515c9bb51536 Download complete                                                                                                                                                                                                                                       26.0s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       26.0s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       26.0s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       26.0s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       26.0s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       26.0s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       26.0s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       26.0s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       26.0s
[+] Running 22/42 Download complete                                                                                                                                                                                                                                       26.0s
 - db Pulling                                                                                                                                                                                                                                                             30.5s
   - a7344f52cb74 Extracting      [==========================================>        ]  56.82MB/67.19MB                                                                                                                                                                  26.1s
   - 515c9bb51536 Download complete                                                                                                                                                                                                                                       26.1s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       26.1s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       26.1s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       26.1s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       26.1s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       26.1s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       26.1s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       26.1s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       26.1s
[+] Running 22/42 Download complete                                                                                                                                                                                                                                       26.1s
 - db Pulling                                                                                                                                                                                                                                                             30.6s
   - a7344f52cb74 Extracting      [==========================================>        ]  56.82MB/67.19MB                                                                                                                                                                  26.2s
   - 515c9bb51536 Download complete                                                                                                                                                                                                                                       26.2s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       26.2s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       26.2s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       26.2s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       26.2s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       26.2s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       26.2s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       26.2s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       26.2s
[+] Running 22/42 Download complete                                                                                                                                                                                                                                       26.2s
 - db Pulling                                                                                                                                                                                                                                                             30.7s
   - a7344f52cb74 Extracting      [==========================================>        ]  56.82MB/67.19MB                                                                                                                                                                  26.3s
   - 515c9bb51536 Download complete                                                                                                                                                                                                                                       26.3s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       26.3s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       26.3s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       26.3s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       26.3s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       26.3s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       26.3s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       26.3s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       26.3s
[+] Running 22/42 Download complete                                                                                                                                                                                                                                       26.3s
 - db Pulling                                                                                                                                                                                                                                                             30.8s
   - a7344f52cb74 Extracting      [===========================================>       ]  58.49MB/67.19MB                                                                                                                                                                  26.4s
   - 515c9bb51536 Download complete                                                                                                                                                                                                                                       26.4s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       26.4s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       26.4s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       26.4s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       26.4s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       26.4s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       26.4s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       26.4s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       26.4s
[+] Running 22/42 Download complete                                                                                                                                                                                                                                       26.4s
 - db Pulling                                                                                                                                                                                                                                                             30.9s
   - a7344f52cb74 Extracting      [=============================================>     ]  61.28MB/67.19MB                                                                                                                                                                  26.5s
   - 515c9bb51536 Download complete                                                                                                                                                                                                                                       26.5s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       26.5s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       26.5s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       26.5s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       26.5s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       26.5s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       26.5s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       26.5s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       26.5s
[+] Running 22/42 Download complete                                                                                                                                                                                                                                       26.5s
 - db Pulling                                                                                                                                                                                                                                                             31.0s
   - a7344f52cb74 Extracting      [===============================================>   ]  64.06MB/67.19MB                                                                                                                                                                  26.6s
   - 515c9bb51536 Download complete                                                                                                                                                                                                                                       26.6s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       26.6s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       26.6s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       26.6s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       26.6s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       26.6s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       26.6s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       26.6s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       26.6s
[+] Running 22/42 Download complete                                                                                                                                                                                                                                       26.6s
 - db Pulling                                                                                                                                                                                                                                                             31.1s
   - a7344f52cb74 Extracting      [=================================================> ]  66.29MB/67.19MB                                                                                                                                                                  26.7s
   - 515c9bb51536 Download complete                                                                                                                                                                                                                                       26.7s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       26.7s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       26.7s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       26.7s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       26.7s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       26.7s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       26.7s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       26.7s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       26.7s
[+] Running 22/42 Download complete                                                                                                                                                                                                                                       26.7s
 - db Pulling                                                                                                                                                                                                                                                             31.2s
   - a7344f52cb74 Extracting      [=================================================> ]  66.29MB/67.19MB                                                                                                                                                                  26.8s
   - 515c9bb51536 Download complete                                                                                                                                                                                                                                       26.8s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       26.8s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       26.8s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       26.8s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       26.8s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       26.8s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       26.8s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       26.8s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       26.8s
[+] Running 23/42 Download complete                                                                                                                                                                                                                                       26.8s
 - db Pulling                                                                                                                                                                                                                                                             31.3s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Extracting      [======================>                            ]  32.77kB/72.65kB                                                                                                                                                                  26.9s
   - e1eabe0537eb Download complete                                                                                                                                                                                                                                       26.9s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       26.9s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       26.9s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       26.9s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       26.9s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       26.9s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       26.9s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       26.9s
[+] Running 24/42 Download complete                                                                                                                                                                                                                                       26.9s
 - db Pulling                                                                                                                                                                                                                                                             31.4s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Extracting      [==================================================>]     364B/364B                                                                                                                                                                     27.0s
   - 4701f1215c13 Download complete                                                                                                                                                                                                                                       27.0s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       27.0s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       27.0s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       27.0s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       27.0s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       27.0s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       27.0s
[+] Running 25/42 Download complete                                                                                                                                                                                                                                       27.0s
 - db Pulling                                                                                                                                                                                                                                                             31.5s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Extracting      [==================================================>]     162B/162B                                                                                                                                                                     27.1s
   - 1f47c10fd782 Download complete                                                                                                                                                                                                                                       27.1s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       27.1s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       27.1s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       27.1s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       27.1s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       27.1s
[+] Running 26/42 Download complete                                                                                                                                                                                                                                       27.1s
 - db Pulling                                                                                                                                                                                                                                                             31.6s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Extracting      [==================================================>]  1.829kB/1.829kB                                                                                                                                                                  27.2s
   - 05dea77d700c Download complete                                                                                                                                                                                                                                       27.2s
   - 65a316a38c29 Download complete                                                                                                                                                                                                                                       27.2s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       27.2s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       27.2s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       27.2s
[+] Running 28/42 Download complete                                                                                                                                                                                                                                       27.2s
 - db Pulling                                                                                                                                                                                                                                                             31.7s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Extracting      [=>                                                 ]  32.77kB/1.573MB                                                                                                                                                                  27.3s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       27.3s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       27.3s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       27.3s
[+] Running 28/42 Download complete                                                                                                                                                                                                                                       27.3s
 - db Pulling                                                                                                                                                                                                                                                             31.8s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Extracting      [============================>                      ]  884.7kB/1.573MB                                                                                                                                                                  27.4s
   - e177378e28a1 Download complete                                                                                                                                                                                                                                       27.4s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       27.4s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       27.4s
[+] Running 29/42 Download complete                                                                                                                                                                                                                                       27.4s
 - db Pulling                                                                                                                                                                                                                                                             31.9s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Extracting      [==================================================>]     115B/115B                                                                                                                                                                     27.5s
   - f2740814b03d Download complete                                                                                                                                                                                                                                       27.5s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       27.5s
[+] Running 30/42 Download complete                                                                                                                                                                                                                                       27.5s
 - db Pulling                                                                                                                                                                                                                                                             32.0s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Extracting      [>                                                  ]  65.54kB/4.264MB                                                                                                                                                                  27.6s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       27.6s
[+] Running 30/42 Download complete                                                                                                                                                                                                                                       27.6s
 - db Pulling                                                                                                                                                                                                                                                             32.1s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Extracting      [=========================>                         ]  2.163MB/4.264MB                                                                                                                                                                  27.7s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       27.7s
[+] Running 30/42 Download complete                                                                                                                                                                                                                                       27.7s
 - db Pulling                                                                                                                                                                                                                                                             32.2s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Extracting      [===========================================>       ]  3.736MB/4.264MB                                                                                                                                                                  27.8s
   - ebb1663f1313 Download complete                                                                                                                                                                                                                                       27.8s
[+] Running 31/42 Download complete                                                                                                                                                                                                                                       27.8s
 - db Pulling                                                                                                                                                                                                                                                             32.3s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Extracting      [==================================================>]  26.54kB/26.54kB                                                                                                                                                                  27.9s
[+] Running 32/42 Download complete                                                                                                                                                                                                                                       27.9s
 - db Pulling                                                                                                                                                                                                                                                             32.4s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 33/42 Extracting      [==================================================>]     327B/327B                                                                                                                                                                     28.0s
 - db Pulling                                                                                                                                                                                                                                                             32.5s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 33/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             32.6s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 33/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             32.7s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 33/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             32.8s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 33/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             32.9s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 33/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             33.0s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 33/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             33.1s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 33/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             33.2s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 33/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             33.3s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 33/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             33.4s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 33/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             33.5s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 33/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             33.6s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 33/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             33.7s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 33/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             33.8s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 33/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             33.9s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 33/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             34.0s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 33/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             34.1s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 35/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             34.2s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 35/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             34.3s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 35/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             34.4s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 35/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             34.5s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 36/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             34.6s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 38/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             34.7s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 38/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             34.8s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 38/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             34.9s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 38/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             35.0s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 38/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             35.1s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 38/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             35.2s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 38/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             35.3s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 38/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             35.4s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 38/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             35.5s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 38/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             35.6s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 38/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             35.7s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 38/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             35.8s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 38/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             35.9s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 38/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             36.0s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 38/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             36.1s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 38/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             36.2s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 38/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             36.3s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 38/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             36.4s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 38/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             36.5s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 38/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             36.6s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 40/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulling                                                                                                                                                                                                                                                             36.7s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
[+] Running 42/42 Pull complete                                                                                                                                                                                                                                           28.0s
 - db Pulled                                                                                                                                                                                                                                                              36.8s
   - a7344f52cb74 Pull complete                                                                                                                                                                                                                                           26.9s
   - 515c9bb51536 Pull complete                                                                                                                                                                                                                                           27.0s
   - e1eabe0537eb Pull complete                                                                                                                                                                                                                                           27.0s
   - 4701f1215c13 Pull complete                                                                                                                                                                                                                                           27.1s
   - 1f47c10fd782 Pull complete                                                                                                                                                                                                                                           27.2s
   - 05dea77d700c Pull complete                                                                                                                                                                                                                                           27.3s
   - 65a316a38c29 Pull complete                                                                                                                                                                                                                                           27.4s
   - e177378e28a1 Pull complete                                                                                                                                                                                                                                           27.5s
   - f2740814b03d Pull complete                                                                                                                                                                                                                                           27.9s
   - ebb1663f1313 Pull complete                                                                                                                                                                                                                                           28.0s
   - 62d0b7f1092f Pull complete                                                                                                                                                                                                                                           28.0s
   - 2d2abb92f8ed Pull complete                                                                                                                                                                                                                                           32.2s
   - 50de2d03b542 Pull complete                                                                                                                                                                                                                                           32.3s
   - 5bb6a676f73c Pull complete                                                                                                                                                                                                                                           32.3s
 - mailhog Pulled                                                                                                                                                                                                                                                         34.7s
   - df20fa9351a1 Pull complete                                                                                                                                                                                                                                           12.2s
   - ed8968b2872e Pull complete                                                                                                                                                                                                                                           12.3s
   - a92cc7c5fd73 Pull complete                                                                                                                                                                                                                                           12.3s
   - f17c8f1adafb Pull complete                                                                                                                                                                                                                                           30.5s
   - 03954754c53a Pull complete                                                                                                                                                                                                                                           30.5s
   - 60493946972a Pull complete                                                                                                                                                                                                                                           30.9s
   - 368ee3bc1dbb Pull complete                                                                                                                                                                                                                                           31.0s
 - phpmyadmin Pulled                                                                                                                                                                                                                                                      20.1s
   - 69692152171a Pull complete                                                                                                                                                                                                                                            6.4s
   - 2040822db325 Pull complete                                                                                                                                                                                                                                            6.5s
   - 9b4ca5ae9dfa Pull complete                                                                                                                                                                                                                                           12.6s
   - ac1fe7c6d966 Pull complete                                                                                                                                                                                                                                           12.6s
   - 5b26fc9ce030 Pull complete                                                                                                                                                                                                                                           13.4s
   - 3492f4769444 Pull complete                                                                                                                                                                                                                                           13.5s
   - 1dec05775a74 Pull complete                                                                                                                                                                                                                                           13.6s
   - 77107a42338e Pull complete                                                                                                                                                                                                                                           13.7s
   - f58e4093c52a Pull complete                                                                                                                                                                                                                                           13.8s
   - d32715f578d3 Pull complete                                                                                                                                                                                                                                           14.6s
   - 7a73fb2558ce Pull complete                                                                                                                                                                                                                                           14.7s
   - 667b573fcff7 Pull complete                                                                                                                                                                                                                                           14.8s
   - 75e2da936ffe Pull complete                                                                                                                                                                                                                                           14.8s
   - 399adc12532e Pull complete                                                                                                                                                                                                                                           15.1s
   - ac950b595ecd Pull complete                                                                                                                                                                                                                                           15.1s
   - f0b41b138477 Pull complete                                                                                                                                                                                                                                           16.3s
   - 8e5e7d658c40 Pull complete                                                                                                                                                                                                                                           16.3s
   - 2e982de2b8e5 Pull complete                                                                                                                                                                                                                                           16.4s
[+] Running 5/5
 - Network lalaveldocker_default  Created                                                                                                                                                                                                                                  0.0s
 - Container web_db               Started                                                                                                                                                                                                                                  2.4s
 - Container web_smtp             Started                                                                                                                                                                                                                                  2.1s
 - Container web_phpmyadmin       Started                                                                                                                                                                                                                                  1.8s
 - Container web_app              Started
```

</details>

<details>
  <summary>docker exec web_app composer create-project "laravel/laravel=~6.0" --prefer-dist webapp</summary>

```log:docker exec web_app composer create-project "laravel/laravel=~6.0" --prefer-dist webapp

$ docker exec web_app composer create-project "laravel/laravel=~6.0" --prefer-dist webapp
Creating a "laravel/laravel=~6.0" project at "./webapp"
Installing laravel/laravel (v6.20.1)

- Downloading laravel/laravel (v6.20.1)
- Installing laravel/laravel (v6.20.1): Extracting archive
Created project in /var/www/html/webapp
> @php -r "file_exists('.env') || copy('.env.example', '.env');"
> Loading composer repositories with package information
> Updating dependencies
> Lock file operations: 93 installs, 0 updates, 0 removals
- Locking doctrine/inflector (2.0.4)
- Locking doctrine/instantiator (1.4.0)
- Locking doctrine/lexer (1.2.1)
- Locking dragonmantank/cron-expression (v2.3.1)
- Locking egulias/email-validator (2.1.25)
- Locking facade/flare-client-php (1.9.1)
- Locking facade/ignition (1.18.0)
- Locking facade/ignition-contracts (1.0.2)
- Locking fakerphp/faker (v1.17.0)
- Locking fideloper/proxy (4.4.1)
- Locking filp/whoops (2.14.4)
- Locking hamcrest/hamcrest-php (v2.0.1)
- Locking laravel/framework (v6.20.43)
- Locking laravel/tinker (v2.6.3)
- Locking league/commonmark (1.6.6)
- Locking league/flysystem (1.1.9)
- Locking league/mime-type-detection (1.9.0)
- Locking mockery/mockery (1.4.4)
- Locking monolog/monolog (2.3.5)
- Locking myclabs/deep-copy (1.10.2)
- Locking nesbot/carbon (2.55.2)
- Locking nikic/php-parser (v4.13.2)
- Locking nunomaduro/collision (v3.2.0)
- Locking opis/closure (3.6.2)
- Locking paragonie/random_compat (v9.99.100)
- Locking phar-io/manifest (2.0.3)
- Locking phar-io/version (3.1.0)
- Locking php-parallel-lint/php-console-color (v0.3)
- Locking php-parallel-lint/php-console-highlighter (v0.5)
- Locking phpdocumentor/reflection-common (2.2.0)
- Locking phpdocumentor/reflection-docblock (5.3.0)
- Locking phpdocumentor/type-resolver (1.5.1)
- Locking phpoption/phpoption (1.8.1)
- Locking phpspec/prophecy (v1.15.0)
- Locking phpunit/php-code-coverage (9.2.10)
- Locking phpunit/php-file-iterator (3.0.6)
- Locking phpunit/php-invoker (3.1.1)
- Locking phpunit/php-text-template (2.0.4)
- Locking phpunit/php-timer (5.0.3)
- Locking phpunit/phpunit (9.5.10)
- Locking psr/container (1.1.2)
- Locking psr/log (1.1.4)
- Locking psr/simple-cache (1.0.1)
- Locking psy/psysh (v0.10.12)
- Locking ramsey/uuid (3.9.6)
- Locking scrivo/highlight.php (v9.18.1.8)
- Locking sebastian/cli-parser (1.0.1)
- Locking sebastian/code-unit (1.0.8)
- Locking sebastian/code-unit-reverse-lookup (2.0.3)
- Locking sebastian/comparator (4.0.6)
- Locking sebastian/complexity (2.0.2)
- Locking sebastian/diff (4.0.4)
- Locking sebastian/environment (5.1.3)
- Locking sebastian/exporter (4.0.4)
- Locking sebastian/global-state (5.0.3)
- Locking sebastian/lines-of-code (1.0.3)
- Locking sebastian/object-enumerator (4.0.4)
- Locking sebastian/object-reflector (2.0.4)
- Locking sebastian/recursion-context (4.0.4)
- Locking sebastian/resource-operations (3.0.3)
- Locking sebastian/type (2.3.4)
- Locking sebastian/version (3.0.2)
- Locking swiftmailer/swiftmailer (v6.3.0)
- Locking symfony/console (v4.4.34)
- Locking symfony/css-selector (v5.4.0)
- Locking symfony/debug (v4.4.31)
- Locking symfony/deprecation-contracts (v2.5.0)
- Locking symfony/error-handler (v4.4.34)
- Locking symfony/event-dispatcher (v4.4.34)
- Locking symfony/event-dispatcher-contracts (v1.1.11)
- Locking symfony/finder (v4.4.30)
- Locking symfony/http-client-contracts (v2.5.0)
- Locking symfony/http-foundation (v4.4.34)
- Locking symfony/http-kernel (v4.4.35)
- Locking symfony/mime (v5.4.0)
- Locking symfony/polyfill-ctype (v1.23.0)
- Locking symfony/polyfill-iconv (v1.23.0)
- Locking symfony/polyfill-intl-idn (v1.23.0)
- Locking symfony/polyfill-intl-normalizer (v1.23.0)
- Locking symfony/polyfill-mbstring (v1.23.1)
- Locking symfony/polyfill-php72 (v1.23.0)
- Locking symfony/polyfill-php73 (v1.23.0)
- Locking symfony/polyfill-php80 (v1.23.1)
- Locking symfony/process (v4.4.35)
- Locking symfony/routing (v4.4.34)
- Locking symfony/service-contracts (v2.5.0)
- Locking symfony/translation (v4.4.34)
- Locking symfony/translation-contracts (v2.5.0)
- Locking symfony/var-dumper (v4.4.34)
- Locking theseer/tokenizer (1.2.1)
- Locking tijsverkoyen/css-to-inline-styles (2.2.4)
- Locking vlucas/phpdotenv (v3.6.10)
- Locking webmozart/assert (1.10.0)
Writing lock file
Installing dependencies from lock file (including require-dev)
Package operations: 93 installs, 0 updates, 0 removals
- Downloading doctrine/inflector (2.0.4)
- Downloading doctrine/lexer (1.2.1)
- Downloading dragonmantank/cron-expression (v2.3.1)
- Downloading symfony/polyfill-php80 (v1.23.1)
- Downloading symfony/polyfill-php72 (v1.23.0)
- Downloading symfony/polyfill-mbstring (v1.23.1)
- Downloading symfony/var-dumper (v4.4.34)
- Downloading symfony/deprecation-contracts (v2.5.0)
- Downloading psr/container (1.1.2)
- Downloading symfony/service-contracts (v2.5.0)
- Downloading symfony/polyfill-php73 (v1.23.0)
- Downloading symfony/console (v4.4.34)
- Downloading scrivo/highlight.php (v9.18.1.8)
- Downloading psr/log (1.1.4)
- Downloading monolog/monolog (2.3.5)
- Downloading symfony/polyfill-ctype (v1.23.0)
- Downloading phpoption/phpoption (1.8.1)
- Downloading vlucas/phpdotenv (v3.6.10)
- Downloading symfony/css-selector (v5.4.0)
- Downloading tijsverkoyen/css-to-inline-styles (2.2.4)
- Downloading symfony/routing (v4.4.34)
- Downloading symfony/process (v4.4.35)
- Downloading symfony/polyfill-intl-normalizer (v1.23.0)
- Downloading symfony/polyfill-intl-idn (v1.23.0)
- Downloading symfony/mime (v5.4.0)
- Downloading symfony/http-foundation (v4.4.34)
- Downloading symfony/http-client-contracts (v2.5.0)
- Downloading symfony/event-dispatcher-contracts (v1.1.11)
- Downloading symfony/event-dispatcher (v4.4.34)
- Downloading symfony/debug (v4.4.31)
- Downloading symfony/error-handler (v4.4.34)
- Downloading symfony/http-kernel (v4.4.35)
- Downloading symfony/finder (v4.4.30)
- Downloading symfony/polyfill-iconv (v1.23.0)
- Downloading egulias/email-validator (2.1.25)
- Downloading swiftmailer/swiftmailer (v6.3.0)
- Downloading paragonie/random_compat (v9.99.100)
- Downloading ramsey/uuid (3.9.6)
- Downloading psr/simple-cache (1.0.1)
- Downloading opis/closure (3.6.2)
- Downloading symfony/translation-contracts (v2.5.0)
- Downloading symfony/translation (v4.4.34)
- Downloading nesbot/carbon (2.55.2)
- Downloading league/mime-type-detection (1.9.0)
- Downloading league/flysystem (1.1.9)
- Downloading league/commonmark (1.6.6)
- Downloading laravel/framework (v6.20.43)
- Downloading filp/whoops (2.14.4)
- Downloading facade/ignition-contracts (1.0.2)
- Downloading facade/flare-client-php (1.9.1)
- Downloading facade/ignition (1.18.0)
- Downloading fakerphp/faker (v1.17.0)
- Downloading fideloper/proxy (4.4.1)
- Downloading nikic/php-parser (v4.13.2)
- Downloading psy/psysh (v0.10.12)
- Downloading laravel/tinker (v2.6.3)
- Downloading hamcrest/hamcrest-php (v2.0.1)
- Downloading mockery/mockery (1.4.4)
- Downloading php-parallel-lint/php-console-color (v0.3)
- Downloading php-parallel-lint/php-console-highlighter (v0.5)
- Downloading nunomaduro/collision (v3.2.0)
- Downloading webmozart/assert (1.10.0)
- Downloading phpdocumentor/reflection-common (2.2.0)
- Downloading phpdocumentor/type-resolver (1.5.1)
- Downloading phpdocumentor/reflection-docblock (5.3.0)
- Downloading sebastian/version (3.0.2)
- Downloading sebastian/type (2.3.4)
- Downloading sebastian/resource-operations (3.0.3)
- Downloading sebastian/recursion-context (4.0.4)
- Downloading sebastian/object-reflector (2.0.4)
- Downloading sebastian/object-enumerator (4.0.4)
- Downloading sebastian/global-state (5.0.3)
- Downloading sebastian/exporter (4.0.4)
- Downloading sebastian/environment (5.1.3)
- Downloading sebastian/diff (4.0.4)
- Downloading sebastian/comparator (4.0.6)
- Downloading sebastian/code-unit (1.0.8)
- Downloading sebastian/cli-parser (1.0.1)
- Downloading phpunit/php-timer (5.0.3)
- Downloading phpunit/php-text-template (2.0.4)
- Downloading phpunit/php-invoker (3.1.1)
- Downloading phpunit/php-file-iterator (3.0.6)
- Downloading theseer/tokenizer (1.2.1)
- Downloading sebastian/lines-of-code (1.0.3)
- Downloading sebastian/complexity (2.0.2)
- Downloading sebastian/code-unit-reverse-lookup (2.0.3)
- Downloading phpunit/php-code-coverage (9.2.10)
- Downloading doctrine/instantiator (1.4.0)
- Downloading phpspec/prophecy (v1.15.0)
- Downloading phar-io/version (3.1.0)
- Downloading phar-io/manifest (2.0.3)
- Downloading myclabs/deep-copy (1.10.2)
- Downloading phpunit/phpunit (9.5.10)
0/93 [>---------------------------] 0%
3/93 [>---------------------------] 3%
9/93 [==>-------------------------] 9%
11/93 [===>------------------------] 11%
13/93 [===>------------------------] 13%
17/93 [=====>----------------------] 18%
20/93 [======>---------------------] 21%
21/93 [======>---------------------] 22%
22/93 [======>---------------------] 23%
25/93 [=======>--------------------] 26%
28/93 [========>-------------------] 30%
32/93 [=========>------------------] 34%
35/93 [==========>-----------------] 37%
38/93 [===========>----------------] 40%
42/93 [============>---------------] 45%
44/93 [=============>--------------] 47%
47/93 [==============>-------------] 50%
48/93 [==============>-------------] 51%
51/93 [===============>------------] 54%
53/93 [===============>------------] 56%
57/93 [=================>----------] 61%
58/93 [=================>----------] 62%
62/93 [==================>---------] 66%
70/93 [=====================>------] 75%
74/93 [======================>-----] 79%
78/93 [=======================>----] 83%
86/93 [=========================>--] 92%
90/93 [===========================>] 96%
93/93 [============================] 100%
- Installing doctrine/inflector (2.0.4): Extracting archive
- Installing doctrine/lexer (1.2.1): Extracting archive
- Installing dragonmantank/cron-expression (v2.3.1): Extracting archive
- Installing symfony/polyfill-php80 (v1.23.1): Extracting archive
- Installing symfony/polyfill-php72 (v1.23.0): Extracting archive
- Installing symfony/polyfill-mbstring (v1.23.1): Extracting archive
- Installing symfony/var-dumper (v4.4.34): Extracting archive
- Installing symfony/deprecation-contracts (v2.5.0): Extracting archive
- Installing psr/container (1.1.2): Extracting archive
- Installing symfony/service-contracts (v2.5.0): Extracting archive
- Installing symfony/polyfill-php73 (v1.23.0): Extracting archive
- Installing symfony/console (v4.4.34): Extracting archive
- Installing scrivo/highlight.php (v9.18.1.8): Extracting archive
- Installing psr/log (1.1.4): Extracting archive
- Installing monolog/monolog (2.3.5): Extracting archive
- Installing symfony/polyfill-ctype (v1.23.0): Extracting archive
- Installing phpoption/phpoption (1.8.1): Extracting archive
- Installing vlucas/phpdotenv (v3.6.10): Extracting archive
- Installing symfony/css-selector (v5.4.0): Extracting archive
- Installing tijsverkoyen/css-to-inline-styles (2.2.4): Extracting archive
- Installing symfony/routing (v4.4.34): Extracting archive
- Installing symfony/process (v4.4.35): Extracting archive
- Installing symfony/polyfill-intl-normalizer (v1.23.0): Extracting archive
- Installing symfony/polyfill-intl-idn (v1.23.0): Extracting archive
- Installing symfony/mime (v5.4.0): Extracting archive
- Installing symfony/http-foundation (v4.4.34): Extracting archive
- Installing symfony/http-client-contracts (v2.5.0): Extracting archive
- Installing symfony/event-dispatcher-contracts (v1.1.11): Extracting archive
- Installing symfony/event-dispatcher (v4.4.34): Extracting archive
- Installing symfony/debug (v4.4.31): Extracting archive
- Installing symfony/error-handler (v4.4.34): Extracting archive
- Installing symfony/http-kernel (v4.4.35): Extracting archive
- Installing symfony/finder (v4.4.30): Extracting archive
- Installing symfony/polyfill-iconv (v1.23.0): Extracting archive
- Installing egulias/email-validator (2.1.25): Extracting archive
- Installing swiftmailer/swiftmailer (v6.3.0): Extracting archive
- Installing paragonie/random_compat (v9.99.100): Extracting archive
- Installing ramsey/uuid (3.9.6): Extracting archive
- Installing psr/simple-cache (1.0.1): Extracting archive
- Installing opis/closure (3.6.2): Extracting archive
- Installing symfony/translation-contracts (v2.5.0): Extracting archive
- Installing symfony/translation (v4.4.34): Extracting archive
- Installing nesbot/carbon (2.55.2): Extracting archive
- Installing league/mime-type-detection (1.9.0): Extracting archive
- Installing league/flysystem (1.1.9): Extracting archive
- Installing league/commonmark (1.6.6): Extracting archive
- Installing laravel/framework (v6.20.43): Extracting archive
- Installing filp/whoops (2.14.4): Extracting archive
- Installing facade/ignition-contracts (1.0.2): Extracting archive
- Installing facade/flare-client-php (1.9.1): Extracting archive
- Installing facade/ignition (1.18.0): Extracting archive
- Installing fakerphp/faker (v1.17.0): Extracting archive
- Installing fideloper/proxy (4.4.1): Extracting archive
- Installing nikic/php-parser (v4.13.2): Extracting archive
- Installing psy/psysh (v0.10.12): Extracting archive
- Installing laravel/tinker (v2.6.3): Extracting archive
- Installing hamcrest/hamcrest-php (v2.0.1): Extracting archive
- Installing mockery/mockery (1.4.4): Extracting archive
- Installing php-parallel-lint/php-console-color (v0.3): Extracting archive
- Installing php-parallel-lint/php-console-highlighter (v0.5): Extracting archive
- Installing nunomaduro/collision (v3.2.0): Extracting archive
- Installing webmozart/assert (1.10.0): Extracting archive
- Installing phpdocumentor/reflection-common (2.2.0): Extracting archive
- Installing phpdocumentor/type-resolver (1.5.1): Extracting archive
- Installing phpdocumentor/reflection-docblock (5.3.0): Extracting archive
- Installing sebastian/version (3.0.2): Extracting archive
- Installing sebastian/type (2.3.4): Extracting archive
- Installing sebastian/resource-operations (3.0.3): Extracting archive
- Installing sebastian/recursion-context (4.0.4): Extracting archive
- Installing sebastian/object-reflector (2.0.4): Extracting archive
- Installing sebastian/object-enumerator (4.0.4): Extracting archive
- Installing sebastian/global-state (5.0.3): Extracting archive
- Installing sebastian/exporter (4.0.4): Extracting archive
- Installing sebastian/environment (5.1.3): Extracting archive
- Installing sebastian/diff (4.0.4): Extracting archive
- Installing sebastian/comparator (4.0.6): Extracting archive
- Installing sebastian/code-unit (1.0.8): Extracting archive
- Installing sebastian/cli-parser (1.0.1): Extracting archive
- Installing phpunit/php-timer (5.0.3): Extracting archive
- Installing phpunit/php-text-template (2.0.4): Extracting archive
- Installing phpunit/php-invoker (3.1.1): Extracting archive
- Installing phpunit/php-file-iterator (3.0.6): Extracting archive
- Installing theseer/tokenizer (1.2.1): Extracting archive
- Installing sebastian/lines-of-code (1.0.3): Extracting archive
- Installing sebastian/complexity (2.0.2): Extracting archive
- Installing sebastian/code-unit-reverse-lookup (2.0.3): Extracting archive
- Installing phpunit/php-code-coverage (9.2.10): Extracting archive
- Installing doctrine/instantiator (1.4.0): Extracting archive
- Installing phpspec/prophecy (v1.15.0): Extracting archive
- Installing phar-io/version (3.1.0): Extracting archive
- Installing phar-io/manifest (2.0.3): Extracting archive
- Installing myclabs/deep-copy (1.10.2): Extracting archive
- Installing phpunit/phpunit (9.5.10): Extracting archive
0/93 [>---------------------------] 0%
8/93 [==>-------------------------] 8%
10/93 [===>------------------------] 10%
15/93 [====>-----------------------] 16%
18/93 [=====>----------------------] 19%
22/93 [======>---------------------] 23%
26/93 [=======>--------------------] 27%
31/93 [=========>------------------] 33%
34/93 [==========>-----------------] 36%
39/93 [===========>----------------] 41%
41/93 [============>---------------] 44%
43/93 [============>---------------] 46%
44/93 [=============>--------------] 47%
45/93 [=============>--------------] 48%
46/93 [=============>--------------] 49%
47/93 [==============>-------------] 50%
48/93 [==============>-------------] 51%
49/93 [==============>-------------] 52%
51/93 [===============>------------] 54%
52/93 [===============>------------] 55%
53/93 [===============>------------] 56%
54/93 [================>-----------] 58%
55/93 [================>-----------] 59%
56/93 [================>-----------] 60%
57/93 [=================>----------] 61%
58/93 [=================>----------] 62%
59/93 [=================>----------] 63%
62/93 [==================>---------] 66%
63/93 [==================>---------] 67%
65/93 [===================>--------] 69%
68/93 [====================>-------] 73%
69/93 [====================>-------] 74%
71/93 [=====================>------] 76%
75/93 [======================>-----] 80%
77/93 [=======================>----] 82%
80/93 [========================>---] 86%
82/93 [========================>---] 88%
83/93 [========================>---] 89%
84/93 [=========================>--] 90%
85/93 [=========================>--] 91%
86/93 [=========================>--] 92%
87/93 [==========================>-] 93%
88/93 [==========================>-] 94%
89/93 [==========================>-] 95%
90/93 [===========================>] 96%
91/93 [===========================>] 97%
92/93 [===========================>] 98%
93/93 [============================] 100%
79 package suggestions were added by new dependencies, use `composer suggest` to see details.
Package swiftmailer/swiftmailer is abandoned, you should avoid using it. Use symfony/mailer instead.
Generating optimized autoload files
> Illuminate\Foundation\ComposerScripts::postAutoloadDump
> @php artisan package:discover --ansi
> Discovered Package: facade/ignition
> Discovered Package: fideloper/proxy
> Discovered Package: laravel/tinker
> Discovered Package: nesbot/carbon
> Discovered Package: nunomaduro/collision
> Package manifest generated successfully.
> 68 packages you are using are looking for funding.
> Use the `composer fund` command to find out more!
> @php artisan key:generate --ansi
> Application key set successfully.

```

</details>

ローカルホストにアクセス
http://localhost:8080/

するとエラーが出る

## エラー１

```shell
UnexpectedValueException
The stream or file "/var/www/html/webapp/storage/logs/laravel.log" could not be opened in append mode: failed to open stream: Permission denied
http://localhost:8080/

```

## エラー１ 解決策（×）

```shell
%  cd src/webapp/
%  sudo chmod 777 -R storage/
 chmod 777 webapp/storage/logs/

```

参考：https://error-search.com/error-post/detail/175/Laravel%25E3%2581%25A7%25E3%2582%25A8%25E3%2583%25A9%25E3%2583%25BC%25E3%2580%2580The%2Bstream%2Bor%2Bfile%2B%2522%252Fvar%252Fwww%252Fhtml%252Flaravel_pj%252Fstorage%252Flogs%252Flaravel-2018-04-06.log%2522%2Bcould%2Bnot%2Bbe%2Bopened%253A%2Bfailed%2Bto%2Bopen%2Bstream%253A%2BPermission%2Bdenied

↑ 上記で解決しない

## エラー１ 解決策（〇）

```
# ls
webapp
# cd webapp
# ls
README.md  artisan    composer.json  config    package.json  public     routes      storage  vendor
app        bootstrap  composer.lock  database  phpunit.xml   resources  server.php  tests    webpack.mix.js
# cd storage
# ls
app  framework  logs
# ll
/bin/sh: 6: ll: not found
# ls -l
total 0
drwxr-xr-x 1 root root 4096 May 11  2021 app
drwxr-xr-x 1 root root 4096 May 11  2021 framework
drwxr-xr-x 1 root root 4096 May 11  2021 logs
```

権限的に問題ないことは分かった。
ファイルがないのでは？

```
touch src/webapp/storage/logs/laravel.log
でlogファイルを作成する
```

エラー１－１

```エラー１－１
# ls
webapp
# cd webapp/storage
# ls
app  framework  logs
# ll
/bin/sh: 4: ll: not found
# ls -l
total 0
drwxr-xr-x 1 root root 4096 May 11  2021 app
drwxr-xr-x 1 root root 4096 May 11  2021 framework
drwxr-xr-x 1 root root 4096 Dec 15 11:21 logs
# ls -l framework
total 0
drwxr-xr-x 1 root root 4096 May 11  2021 cache
drwxr-xr-x 1 root root 4096 May 11  2021 sessions
drwxr-xr-x 1 root root 4096 May 11  2021 testing
drwxr-xr-x 1 root root 4096 May 11  2021 views
# groupe
/bin/sh: 7: groupe: not found
# groups
root
# /var/www/html/webapp/storage/framework/sessions/inJXiLhNJLjJzusexSjalwwRZXjsRapOXh0BTuCr): failed to open stream: Perm^C
# ls
app  framework  logs
# chmod 777 sessions
chmod: cannot access 'sessions': No such file or directory
# ls
app  framework  logs
# chmod 777 framework/sessions
```

```
 chmod 777 framework/views
```

## エラー２

```
Database name seems incorrect
You're using the default database name laravel. This database does not exist.

Edit the .env file and use the correct database name in the DB_DATABASE key.

READ MORE
Database: Getting Started docs
```

## エラー２ 解決策

```
% mysql -u root -p
```

% でパスワードを聞かれるので、`docker-compose.yml`に記載のパスワードを入力する

.env ファイルを編集する

```src/webapp/.env
- DB_DATABASE=laravel
+ DB_DATABASE=webapp
```

[./001.png]

# Windows の場合は Make ツールのインストール、環境変数への登録が必要

mac は自動で入ってるみたい
https://beyondjapan.com/blog/2020/10/makefile-docker/

# 参考

https://blog.sat.ne.jp/2021/03/12/laraveldocker%e7%92%b0%e5%a2%83/

https://simablog.net/aws-docker-laravel/
https://simablog.net/docker-laravel-nginx-mysql/

https://sg-report.com/laravel-docker-awsec2-web1/
https://sg-report.com/laravel-docker-awsec2-web2/

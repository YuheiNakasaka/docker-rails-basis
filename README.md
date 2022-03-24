[クジラに乗った Ruby: Evil Martians 流 Docker+Ruby/Rails 開発環境構築（翻訳）｜ TechRacho by BPS 株式会社](https://techracho.bpsinc.jp/hachi8833/2021_04_20/79035)

この記事の開発環境が良かったので自分用にまとめる。Rails で開発する時はこれをベースに必要なもの/不要なものを Dockerfile や docker-compose から足し引きするだけ。

# Clone

まずはリポジトリを clone しておく。

```sh:sh
git clone git@github.com:YuheiNakasaka/docker-rails-basis.git
```

https://github.com/YuheiNakasaka/docker-rails-basis

# デフォルトの構成

この環境では下記の構成がデフォルトで作成される。

- PostgreSQL + Redis
- Rails + Webpacker + sidekiq

# 基本方針

この環境は`docker-compose up`は使わずに`docker-compose up rails`などと具体的に指定して実行する。bundle exec などのコマンドは runner コンテナ内で行う想定。

# 開発環境の立ち上げ

`docker-compose.yml`の Ruby のバージョンを変更しておく。[https://hub.docker.com/\_/ruby](https://hub.docker.com/_/ruby)にある`-slim-buster`の tag を参考に。

```yml:docker-compose.yml
args:
  RUBY_VERSION: '2.6.3'
```

runner を立ち上げる。

```sh
docker-compose run --rm runner
```

これで runner 環境にログイン。以下 bundle コマンドの実行は runner 内のシェルで行うものとする。

# Rails アプリの作成(初回のみ)

version は適宜変更する。

```Gemfile:Gemfile
source 'https://rubygems.org'
gem 'rails', '~> 6.1.4'
```

```sh:sh
bundle install
bundle exec rails new . --force --no-deps --database=postgresql --webpack=typescript
rails db:create
```

# Rails アプリの起動

```sh:sh
docker-compose up rails
```

[http://0.0.0.0:3000/](http://0.0.0.0:3000/)

gem や db の作成は cache されているので 2 回目以降はいきなりこのコマンドを叩くだけでアプリが立ち上がる。

# 削除

```sh:sh
docker-compose down
```

# 以下は任意の作業

# JS ファイルの置き場所

`app/javascript/packs`配下にファイルを置くと[コンパイルのオーバーヘッドが大きくなり時間がかかる](https://railsguides.jp/webpacker.html#javascript%E3%82%92webpacker%E7%B5%8C%E7%94%B1%E3%81%A7%E5%88%A9%E7%94%A8%E3%81%99%E3%82%8B)のでファイルは基本的に`app/javascript/src`に配置する。

```sh:sh
mkdir app/javascript/src
```

# Slim 対応

```Gemfile:Gemfile
gem 'slim-rails' # 追加
```

```sh:sh
bundle install
```

`app/views/layouts`配下のファイルを slim に変更

```slim:application.html.slim
doctype html
 html
   head
     title
       | Myapp
     meta[name="viewport" content="width=device-width,initial-scale=1"]
     = csrf_meta_tags
     = csp_meta_tag
     = stylesheet_pack_tag 'application', media: 'all', 'data-turbolinks-track': 'reload'
     = javascript_pack_tag 'application', 'data-turbolinks-track': 'reload'
   body
     = yield
```

```slim:mailer.html
doctype html
 html
   head
     meta[http-equiv="Content-Type" content="text/html; charset=utf-8"]
     style
       |  /* Email styles need to be inline */
   body
     = yield
```

```text:mailer.text
= yield
```

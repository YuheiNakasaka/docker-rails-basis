
[クジラに乗った Ruby: Evil Martians 流 Docker+Ruby/Rails 開発環境構築（翻訳）｜ TechRacho by BPS 株式会社](https://techracho.bpsinc.jp/hachi8833/2022_04_07/116843)

この記事の開発環境が良かったので自分用にまとめる。Rails で開発する時はこれをベースに必要なもの/不要なものを Dockerfile や docker-compose から足し引きする。

# Clone

まずはリポジトリを clone しておく。`.git`は削除しておく。

```sh:sh
git clone git@github.com:YuheiNakasaka/docker-rails-basis.git sample-project
```

https://github.com/YuheiNakasaka/docker-rails-basis

# デフォルトの構成

この環境では下記の構成を作るのに必要そうなコンテナがデフォルトで作成される。

- Ruby(3.1)
- Rails(7.0)
- rubocop(formatter + linter)
- erblint
- PostgreSQL(13.0)
- Redis(3.0。セッション管理やsidekiqのキュー管理に使う)
- Hotwire

# 基本方針

VSCode + Dev Containersで開発することを想定。VSCodeで`runner`というコンテナを立ち上げ、そこでgemをインストールしたり`rails`コマンドを叩いたりする。

# 開発環境の立ち上げ

`docker-compose.yml`の Ruby のバージョンを好きなものに変更しておく。[https://hub.docker.com/\_/ruby](https://hub.docker.com/_/ruby)にある tag を参考に。

```yml:docker-compose.yml
args:
  RUBY_VERSION: '3.1'
```

`image: example-dev:1.1.3`を好きな名前に変更しておく。

VSCodeでDev Containersを開く。

# Rails アプリの作成(初回のみ)

Railsのversion は適宜変更する。

```Gemfile:Gemfile
source 'https://rubygems.org'
gem 'rails', '~> 7.1.0'
```

依存のインストール

```sh:sh
bundle install
```

アプリの作成。Hotwireを使う場合は下記で。

```sh:sh
bundle exec rails new . --force --database=postgresql --css=tailwind --javascript=importmap --skip-jbuilder -T -M
# skipオプションは下記を参考に
# bundle exec rails new . --force --database=postgresql --skip-action-mailer --skip-action-mailbox --skip-action-text --skip-active-job --skip-active-storage --skip-action-cable --skip-javascript --skip-hotwire --skip-jbuilder --skip-test --skip-system-test --skip-bootsnap --minimal
```

# Rspec/Rubocop/Erblintの設定
Gemfileに下記を追加して`bundle install`。

```
group :development, :test do
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'erb_lint'
  gem 'rubocop'
  gem 'rubocop-ast'
  gem 'rubocop-performance'
  gem 'rubocop-rails'
  gem 'rubocop-rake'
  gem 'rubocop-rspec'
  gem 'factory_bot_rails'
  gem 'rspec-rails'
end
```

rspecの初期化

```sh:sh
bin/rails generate rspec:install
```

lint/formatting

```sh:sh
rubocop -A
erblint --lint-all -a
```

# DBの設定

DBの作成。

```sh:sh
bin/rails db:create
```

# Rails アプリの起動

起動。

```sh:sh
bin/dev
```

下記にアクセスするとwelcomeページが表示される。

[http://0.0.0.0:3000/](http://0.0.0.0:3000/)

# その他

## Railsアプリの作成

Scaffoldなどを使って具体的なコードを書いていく。

## sidekiqの設定

[sidekiq/wiki](https://github.com/sidekiq/sidekiq/wiki)を見てActiveJobなどと連携しながら設定する。

## Dev Containersの再起動

fn > F1 > Dev Containers: Rebuild Containers

## 削除

fn > F1 > Remote: Close Remote Connection

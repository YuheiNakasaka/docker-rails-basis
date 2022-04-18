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
- Rails + sidekiq

# 基本方針

この環境は`docker-compose up`は使わずに`docker-compose up rails`などと具体的に指定して実行する。bundle exec などのコマンドは runner コンテナ内で行う想定。

# 開発環境の立ち上げ

`docker-compose.yml`の Ruby のバージョンを変更しておく。[https://hub.docker.com/\_/ruby](https://hub.docker.com/_/ruby)にある tag を参考に。

```yml:docker-compose.yml
args:
  RUBY_VERSION: '3.1'
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
gem 'rails', '~> 7.1.0'
```

```sh:sh
bundle install
bundle exec rails new . --force --no-deps --database=postgresql
rails db:create
```

# Rails アプリの起動

Procfile.dev を修正する。

```
web: bundle exec rails server -b 0.0.0.0 -p 3000
js: yarn build --watch
css: yarn build:css --watch
```

起動

```sh:sh
docker-compose up rails
```

[http://0.0.0.0:3000/](http://0.0.0.0:3000/)

gem や db の作成は cache されているので 2 回目以降はいきなりこのコマンドを叩くだけでアプリが立ち上がる。

# 削除

```sh:sh
docker-compose down
```

# その他

## Rubocop の設定

### 依存のインストール

ホスト側

```bash
gem install solargraph rubocop rubocop-rails
```

コンテナ側

```bash
...
group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri mingw x64_mingw]
  gem 'rubocop' # 追加
end
...
```

```
bundle install
```

### Solargraph に色々任せちゃう設定

.vscode/settings.json

```json
{
  "ruby.lint": {
    "rubocop": false
  },
  "solargraph.diagnostics": true,

  "ruby.format": false,
  "solargraph.formatting": true,
  "[ruby]": {
    "editor.defaultFormatter": "castwide.solargraph",
    "editor.formatOnSave": true
  },
  "[markdown]": {
    "editor.formatOnSave": false
  }
}
```

### rubocop ファイルの設定

- [.rubocop.yml](https://gist.github.com/YuheiNakasaka/4de74cb50659c0bc40b9b921b81130c1)
- [.rubocop_todo.yml](https://gist.github.com/YuheiNakasaka/6d0f8dd9b96a584b0e909f47241f1e02)

## ERB のフォーマット

VSCode 拡張 で[Beautify](https://marketplace.visualstudio.com/items?itemName=HookyQR.beautify)を入れる。

.vscode/settings.json

```json
...
  "beautify.language": {
    "js": {
      "type": ["javascript", "json"],
      "filename": [".jshintrc", ".jsbeautifyrc"]
    },
    "css": ["css", "scss"],
    "html": ["htm", "html", "erb"]
  }
}
```

# Mermaid-CLI のインストールに関する注意事項

## 概要

mermaid-cli (mmdc) は、Mermaid 図を PNG/SVG に変換するツールです。
内部で puppeteer を使用し、puppeteer は Chrome/Chromium を必要とします。
この依存関係が、特に Docker 環境（とりわけ ARM64）で問題を引き起こします。

## 問題点

### 1. puppeteer と Chrome のバージョン依存

puppeteer は特定バージョンの Chrome を要求します。
mermaid-cli にバンドルされている puppeteer のバージョンによって、
必要な Chrome のバージョンが決まります。

```
Error: Could not find Chrome (ver. 131.0.6778.204)
```

### 2. ARM Linux での Chrome の問題

Google は ARM Linux 版の Chrome を積極的に提供していません。
`@puppeteer/browsers` で ARM 版を指定しても、実際には x86_64 版が
ダウンロードされることがあります。

```bash
# これは期待通りに動かない場合がある
npx @puppeteer/browsers install chrome@131.0.6778.204 --platform linux_arm
```

ディレクトリ名は `linux_arm-131.0.6778.204` でも、
中身が x86_64 バイナリの場合があります。

```
qemu-x86_64: Could not open '/lib64/ld-linux-x86-64.so.2': No such file or directory
```

### 3. Ubuntu の snap 問題

Ubuntu は chromium を snap パッケージとしてのみ提供しています。
Docker コンテナ内では snap は動作しないため、Ubuntu の chromium パッケージは使えません。

```
Command '/usr/bin/chromium-browser' requires the chromium snap to be installed.
```

## 解決策

### Docker 環境（推奨）

Debian リポジトリから chromium をインストールします。
これは ARM64 と AMD64 の両方で動作します。

```dockerfile
# Debian リポジトリから chromium をインストール
RUN echo "deb [trusted=yes] http://deb.debian.org/debian bookworm main" > /etc/apt/sources.list.d/debian.list \
 && apt-get update -y \
 && apt-get install -y --no-install-recommends chromium \
 && rm /etc/apt/sources.list.d/debian.list \
 && apt-get update -y \
 && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/*

# puppeteer の Chrome ダウンロードをスキップ
ENV PUPPETEER_SKIP_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium

RUN npm install -g @mermaid-js/mermaid-cli
```

注意: `[trusted=yes]` は GPG 署名チェックをスキップします。
セキュリティ上の理由から、本番環境では適切な GPG キーをインポートすることを推奨します。

### puppeteer.json の設定

Docker 内で実行する場合、`--no-sandbox` オプションが必要です。

```json
{
  "executablePath": "/usr/bin/chromium",
  "args": ["--no-sandbox", "--disable-setuid-sandbox"]
}
```

mmdc の実行時に指定:
```bash
mmdc -p puppeteer.json -i input.mmd -o output.png
```

### ローカル環境（macOS）

Homebrew でインストールした mermaid-cli を使う場合、
puppeteer のキャッシュに正しいバージョンの Chrome が必要です。

```bash
# mermaid-cli が要求するバージョンを確認（エラーメッセージから）
# 例: Chrome (ver. 131.0.6778.204)

# 特定バージョンをインストール
npx @puppeteer/browsers install chrome-headless-shell@131.0.6778.204

# キャッシュを ~/.cache/puppeteer に移動
mv chrome-headless-shell/mac_arm-131.0.6778.204 ~/.cache/puppeteer/chrome-headless-shell/
```

または、システムの Chrome を使う設定:

```json
{
  "executablePath": "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
}
```

## Makefile での自動化

ローカルと Docker の両方で動作させるため、環境に応じて puppeteer.json を生成:

```makefile
puppeteer.json:
	@if [ -f /.dockerenv ]; then \
		echo '{"executablePath":"/usr/bin/chromium","args":["--no-sandbox","--disable-setuid-sandbox"]}' > $@; \
	else \
		echo '{}' > $@; \
	fi
```

## 教訓

1. **puppeteer のバンドル Chrome に頼らない** - バージョンやアーキテクチャの問題が発生しやすい
2. **システムの chromium を使う** - 最も確実な方法
3. **ARM Linux は特に注意** - Google の Chrome は ARM Linux を十分にサポートしていない
4. **Docker では Debian リポジトリを活用** - Ubuntu の snap 問題を回避できる

## 関連リンク

- https://github.com/mermaid-js/mermaid-cli
- https://pptr.dev/troubleshooting
- https://github.com/nickelow/chromium-docker (Docker での chromium 設定例)

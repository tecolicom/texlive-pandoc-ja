# texlive-pandoc-ja

日本語向け TeX Live + Pandoc Docker イメージ

pandoc/core をベースに paperist/texlive-ja から TeX Live 環境をコピーし、日本語ドキュメント作成に必要なフィルターやツールを追加したイメージ。

## 対応アーキテクチャ

- AMD64
- ARM64

## 含まれるツール

### TeX / Pandoc

- **TeX Live** (paperist/texlive-ja ベース)
- **Pandoc** (pandoc/core ベース)
- **latexmk**

### Pandoc フィルター / Python パッケージ

- **pandoc-embedz** — Jinja2 テンプレートによるデータ駆動コンテンツ生成
- **openpyxl** — pandoc-embedz の Excel ファイルサポート
- **pantable** — テーブル処理フィルター
- **pandocfilters** — Pandoc フィルターライブラリ
- **pandoc-plot** — Haskell 製プロットフィルター

### データ可視化

- **matplotlib** / **japanize-matplotlib** — グラフ描画（日本語対応）
- **plotly** / **kaleido** — インタラクティブ / 静的グラフ
- **numpy** / **scipy** / **statsmodels** — 数値計算・統計

### 図表生成

- **mermaid-cli (mmdc)** — Mermaid 図の PNG/SVG 変換（chromium 同梱）
  - 詳細は [MERMAID.md](MERMAID.md) を参照

### 翻訳ツール

- **App::Greple::xlate** — Greple 翻訳モジュール (Perl)
- **deepl** — DeepL API クライアント (Python)

## Install / インストール

Docker Hub からインストールできます。

```bash
docker pull tecolicom/texlive-pandoc-ja:latest
```

## Usage / 使い方

```bash
docker run --rm -it -v $PWD:/app tecolicom/texlive-pandoc-ja:latest \
    sh -c 'latexmk -C main.tex && latexmk main.tex && latexmk -c main.tex'
```

## SEE ALSO

- https://hub.docker.com/r/tecolicom/texlive-pandoc-ja
- https://github.com/tecolicom/docker-texlive-pandoc-ja

- https://hub.docker.com/r/paperist/texlive-ja
- https://github.com/Paperist/texlive-ja

## License / ライセンス

MIT ©︎ 2024 Kaz Utashiro, tecolicom

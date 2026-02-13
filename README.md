# texlive-pandoc-ja

日本語向け TeX Live + Pandoc Docker イメージ

[pandoc/core](https://hub.docker.com/r/pandoc/core) をベースに
[paperist/texlive-ja](https://hub.docker.com/r/paperist/texlive-ja) から
TeX Live 環境をコピーし、日本語ドキュメント作成に必要なフィルターやツールを追加したイメージ。
Markdown から PDF への変換パイプライン（Markdown → LaTeX → PDF）を
単一のコンテナで実行できる。

## 対応アーキテクチャ

- AMD64
- ARM64

GitHub Actions で両アーキテクチャのイメージをビルドし、マルチアーキテクチャマニフェストとして Docker Hub に公開している。

## 含まれるツール

### TeX / Pandoc

- [Pandoc](https://pandoc.org/) — 汎用ドキュメント変換ツール（pandoc/core ベース）
- [TeX Live](https://www.tug.org/texlive/) — TeX ディストリビューション（paperist/texlive-ja ベース、uplatex 対応）
- [latexmk](https://www.ctan.org/pkg/latexmk/) — LaTeX ビルド自動化

### Pandoc フィルター

- [pandoc-embedz](https://github.com/tecolicom/pandoc-embedz) — Jinja2 テンプレートによるデータ駆動コンテンツ生成（CSV, Excel, JSON, SQLite 対応）
- [pandoc-plot](https://github.com/LaurentRDC/pandoc-plot) — コードブロックからプロット画像を生成（Haskell 製）
- [pantable](https://github.com/ickc/pantable) — CSV データからテーブルを生成
- [pandocfilters](https://github.com/jgm/pandocfilters) — Pandoc フィルター作成ライブラリ

### データ可視化

- [matplotlib](https://matplotlib.org/) / [japanize-matplotlib](https://github.com/uehara1414/japanize-matplotlib) — グラフ描画（日本語フォント対応）
- [plotly](https://plotly.com/python/) / [kaleido](https://github.com/plotly/Kaleido) — インタラクティブ / 静的グラフ
- [numpy](https://numpy.org/) / [scipy](https://scipy.org/) / [statsmodels](https://www.statsmodels.org/) — 数値計算・統計

### Excel サポート

- [openpyxl](https://openpyxl.readthedocs.io/) — Excel ファイル（.xlsx）の読み書き（pandoc-embedz のデータソースとして使用）

### 図表生成

- [mermaid-cli (mmdc)](https://github.com/mermaid-js/mermaid-cli) — Mermaid 図の PNG/SVG 変換（chromium 同梱）
  - 詳細は [MERMAID.md](MERMAID.md) を参照

### 翻訳ツール

- [App::Greple::xlate](https://metacpan.org/pod/App::Greple::xlate) — Greple 翻訳モジュール (Perl)
- [deepl](https://pypi.org/project/deepl/) — DeepL API クライアント (Python)

### フォント

- Noto CJK — CJK（中日韓）フォント（fonts-noto-cjk）

## インストール

Docker Hub から pull できる。

```bash
docker pull tecolicom/texlive-pandoc-ja:latest
```

特定バージョンを指定する場合:

```bash
docker pull tecolicom/texlive-pandoc-ja:v1.22
```

## 使い方

### 基本的な使い方

```bash
docker run --rm -v $PWD:/app tecolicom/texlive-pandoc-ja:latest \
    sh -c 'latexmk main.tex && latexmk -c main.tex'
```

### Pandoc + LaTeX でPDF生成

```bash
docker run --rm -v $PWD:/app tecolicom/texlive-pandoc-ja:latest \
    sh -c 'pandoc input.md --filter pandoc-embedz -o output.tex && latexmk output.tex'
```

### 対話的に使う

```bash
docker run --rm -it -v $PWD:/app tecolicom/texlive-pandoc-ja:latest bash
```

### CI での利用例（GitLab CI）

```yaml
pdf:
  image: tecolicom/texlive-pandoc-ja:v1.22
  script:
    - make
  artifacts:
    paths:
      - "*.pdf"
```

## ビルド

ローカルでビルドする場合:

```bash
make                  # docker build -t tecolicom/texlive-pandoc-ja:dev .
make NOCACHE=1        # キャッシュなしで再ビルド
make run              # ビルドしたイメージで対話シェルを起動
```

## イメージ構成

マルチステージビルドを採用している。

1. **builder** — Haskell 環境で pandoc-plot をビルド
2. **texlive** — paperist/texlive-ja から TeX Live をコピー
3. **main** — pandoc/core ベースに全ツールを統合

pandoc-embedz は独立したレイヤーとして最後にインストールされるため、
バージョン更新時は最終レイヤーのみの再ビルドで済む。

## SEE ALSO

- [Docker Hub](https://hub.docker.com/r/tecolicom/texlive-pandoc-ja)
- [GitHub](https://github.com/tecolicom/docker-texlive-pandoc-ja)
- [paperist/texlive-ja](https://hub.docker.com/r/paperist/texlive-ja) — TeX Live ベースイメージ
- [pandoc/core](https://hub.docker.com/r/pandoc/core) — Pandoc ベースイメージ

## License

MIT (c) 2024 Kaz Utashiro, tecolicom

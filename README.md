# texlive-pandoc-ja

日本語向け TeX Live + Pandoc Docker イメージ

pandoc/core をベースに paperist/texlive-ja から /usr/local/texlive をコピーし、pandoc に必要なフィルター等を追加したイメージ

## Supported tags / タグ一覧

- [`latest`](./build/Dockerfile)
  - AMD64 に対応（Pandoc/core が arm64 に対応していないため）

## Install / インストール

The image can be installed from Docker Hub or GitHub Container Registry. <br/>
Docker Hub もしくは GitHub Container Registry からインストールできます

### Docker Hub

```bash
docker pull tecolicom/texlive-pandoc-ja:latest
```

## Usage / 使い方

```bash
$ docker run --rm -it -v $PWD:/app tecolicom/texlive-pandoc-ja:latest \
    sh -c 'latexmk -C main.tex && latexmk main.tex && latexmk -c main.tex'
```

## SEE ALSO

- https://hub.docker.com/r/tecolicom/texlive-pandoc-ja
- https://github.com/tecolicom/docker-texlive-pandoc-ja

- https://hub.docker.com/r/paperist/texlive-ja
- https://github.com/Paperist/texlive-ja

## License / ライセンス

MIT ©︎ 2024 Kaz Utashiro, tecolicom

---

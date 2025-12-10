#
# Builder stage for pandoc-plot
#
FROM haskell:9.10 AS builder
RUN apt-get update && apt-get install -y --no-install-recommends \
    zlib1g-dev \
    && apt-get clean
RUN cabal update
RUN cabal install pandoc-plot \
    --install-method=copy \
    --overwrite-policy=always \
    --installdir=/usr/local/bin \
    --jobs=1 \
    --verbose

#
# TexLive stage
#
FROM "paperist/texlive-ja:latest" AS texlive

#
# Main stage
#
FROM "pandoc/core:latest-ubuntu"
ENV HOME=/root

ENV LANG=ja_JP.UTF-8
ENV LC_CTYPE=ja_JP.UTF-8
RUN apt-get update && \
    apt-get -y upgrade \
    && apt-get install -y locales \
    && echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && :

COPY --from=texlive /usr/local/texlive /usr/local/texlive
COPY --from=texlive /usr/local/bin     /usr/local/bin
ENV PATH="/usr/local/bin/texlive:$PATH"

#
# basic package
#
RUN apt-get update -y \
 && apt-get install -y --no-install-recommends \
    git \
    make \
    curl \
    unzip \
    perl \
    python3-dev \
    python3-pip \
    python3-numpy \
    python3-scipy \
 && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/*

#
# mermaid-cli (mmdc) with chromium
#
RUN apt-get update -y \
 && apt-get install -y --no-install-recommends \
    nodejs \
    npm \
    ca-certificates \
    fonts-liberation \
    libasound2t64 \
    libatk-bridge2.0-0 \
    libatk1.0-0 \
    libcups2 \
    libdbus-1-3 \
    libdrm2 \
    libgbm1 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxkbcommon0 \
    libxrandr2 \
    xdg-utils \
 && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/*
# Install chromium from Debian repository (works on both amd64 and arm64)
RUN echo "deb [trusted=yes] http://deb.debian.org/debian bookworm main" > /etc/apt/sources.list.d/debian.list \
 && apt-get update -y \
 && apt-get install -y --no-install-recommends chromium \
 && rm /etc/apt/sources.list.d/debian.list \
 && apt-get update -y \
 && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/*
ENV PUPPETEER_SKIP_DOWNLOAD=true
ENV PUPPETEER_EXECUTABLE_PATH=/usr/bin/chromium
RUN npm install -g @mermaid-js/mermaid-cli

#
# additional package
#
RUN pip3 install --break-system-packages \
    japanize-matplotlib \
    plotly \
    pandocfilters \
    kaleido \
    pantable \
    pandoc-embedz
RUN apt-get update -y \
 && apt-get install -y --no-install-recommends \
    python3-matplotlib \
    python3-statsmodels \
    fonts-noto-cjk \
 && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/*

#
# translation tools
#
RUN apt-get update -y \
 && apt-get install -y --no-install-recommends \
    gcc \
    cpanminus \
 && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/*
RUN cpanm --notest --quiet  \
    App::Greple::xlate \
    && rm -fr ~/.cpanm
RUN pip3 install --break-system-packages \
    deepl

#
# Copy pandoc-plot from builder stage
#
COPY --from=builder /usr/local/bin/pandoc-plot /usr/local/bin/

WORKDIR /app

COPY root /root
RUN  cd /root && for rc in inputrc bashrc; do cat $rc >> $HOME/.$rc; done
RUN echo '{"args":["--no-sandbox","--disable-setuid-sandbox"]}' > /root/puppeteer.json

ENTRYPOINT []
CMD [ "/bin/bash" ]

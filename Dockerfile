FROM "paperist/texlive-ja:latest" AS texlive
FROM "ubuntu:latest" AS builder
ENV HOME=/root

ENV LANG=ja_JP.UTF-8
ENV LC_CTYPE=ja_JP.UTF-8
RUN apt-get update && \
    apt-get -y upgrade \
    && apt-get install -y locales \
    && echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && :

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
# additional package
#
RUN pip3 install --break-system-packages \
    japanize-matplotlib \
    plotly \
    pandocfilters \
    kaleido \
    pantable
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
# pandoc-plot
#
WORKDIR /tmp
SHELL [ "/bin/bash", "-c" ]
RUN \
    site=github.com user=LaurentRDC name=pandoc-plot \
    repo=https://${site}/${user}/${name} \
    arch=Linux-x86_64-static \
    file="${name}-${arch}.zip" \
    path="$(curl -sw '%header{location}' ${repo}/releases/latest)" \
    url="${path/tag/download}/${file}" \
    && echo Download ${url} \
    && curl -sLO "${url:?NO URL}" \
    && [ -s $file ] && unzip $file \
    && [ -s $name ] && install $name /usr/local/bin \
    && rm -fr ${name}*

FROM "pandoc/core:latest-ubuntu"

COPY --from=texlive /usr/local /usr/local
COPY --from=builder /usr/local /usr/local
COPY --from=builder /usr/lib/python3 /usr/lib/python3
COPY --from=builder /usr/lib/x86_64-linux-gnu /usr/lib/x86_64-linux-gnu
ENV PATH="/usr/local/bin/texlive:$PATH"

ENV LANG=ja_JP.UTF-8
ENV LC_CTYPE=ja_JP.UTF-8
RUN apt-get update && \
    apt-get -y upgrade \
    && apt-get install -y locales \
    && echo "ja_JP.UTF-8 UTF-8" >> /etc/locale.gen \
    && locale-gen \
    && :

#
# necessary runtime
#
RUN apt-get update -y \
 && apt-get install -y --no-install-recommends \
    git \
    make \
    perl \
    python3 \
 && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app

COPY root /root
RUN  cd /root && for rc in inputrc bashrc; do cat $rc >> $HOME/.$rc; done

ENTRYPOINT []
CMD [ "/bin/bash" ]

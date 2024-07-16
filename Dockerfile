FROM "paperist/texlive-ja:latest" AS texlive
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
# additional package
#
RUN pip3 install --break-system-packages \
    japanize-matplotlib \
    plotly \
    pandocfilters \
    kaleido
RUN apt-get update -y \
 && apt-get install -y --no-install-recommends \
    python3-matplotlib \
    python3-statsmodels \
    fonts-noto-cjk \
 && apt-get -y clean \
 && rm -rf /var/lib/apt/lists/*

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

WORKDIR /app

COPY root /root
RUN  cd /root && for rc in inputrc bashrc; do cat $rc >> $HOME/.$rc; done

ENTRYPOINT []
CMD [ "/bin/bash" ]

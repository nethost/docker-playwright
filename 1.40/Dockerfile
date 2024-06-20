FROM ubuntu:focal as node

ENV DEBIAN_FRONTEND=noninteractive
ENV NVM_DIR "/root/.nvm"
ENV NVM_VERSION "0.39.3"
ENV NODE_VERSION "22.2.0"
ENV NODE_PATH "$NVM_DIR/v$NODE_VERSION/lib/node_modules"
ENV PATH "$NVM_DIR/versions/node/v$NODE_VERSION/bin:$PATH"

RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN apt update && apt -y install curl libatomic1 ffmpeg make python3 gcc g++ lsb-core fonts-noto-cjk fonts-wqy-zenhei && apt-get clean
RUN curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/v$NVM_VERSION/install.sh" | bash && rm -rf "$NVM_DIR/.cache"
RUN fc-cache -vf

FROM node as base

ENV IMAGE_INFO="$(lsb_release -ds), Node $(node -v), Playwright $(playwright -V)"

RUN npm i -g playwright-core && rm -rf /root/.npm
CMD eval echo $IMAGE_INFO

FROM base as pnpm

ENV PNPM_HOME="/root/.local/share/pnpm"
ENV PATH="$PNPM_HOME:$PATH"

RUN npm i -g pnpm && rm -rf /root/.npm

FROM pnpm as chromium

ENV IMAGE_INFO="$IMAGE_INFO, $($(echo /root/.cache/ms-playwright/chromium-*/chrome-linux/chrome) --version)"

RUN playwright-core install --with-deps chromium

FROM pnpm as firefox

ENV IMAGE_INFO="$IMAGE_INFO, $($(echo /root/.cache/ms-playwright/firefox-*/firefox/firefox) --version)"

RUN playwright-core install --with-deps firefox

FROM pnpm as webkit

ENV IMAGE_INFO="$IMAGE_INFO, $($(echo /root/.cache/ms-playwright/webkit-*/minibrowser-wpe/MiniBrowser) --version)"

RUN [ $(arch) == "armv7l" ] || playwright-core install --with-deps webkit

FROM pnpm as chrome

ENV IMAGE_INFO="$IMAGE_INFO, $(/usr/bin/google-chrome --version)"

RUN [ $(arch) == "armv7l" ] || [ $(arch) == "aarch64" ] || playwright-core install --with-deps chrome

FROM pnpm as msedge

ENV IMAGE_INFO="$IMAGE_INFO, $(/usr/bin/microsoft-edge --version)"

RUN apt update && apt -y install gnupg && apt-get clean
RUN [ $(arch) == "armv7l" ] || [ $(arch) == "aarch64" ] || playwright-core install --with-deps msedge

FROM chromium as browsers

ENV IMAGE_INFO="$IMAGE_INFO, $($(echo /root/.cache/ms-playwright/firefox-*/firefox/firefox) --version)"
ENV IMAGE_INFO="$IMAGE_INFO, $($(echo /root/.cache/ms-playwright/webkit-*/minibrowser-wpe/MiniBrowser) --version)"
ENV IMAGE_INFO="$IMAGE_INFO, $(/usr/bin/google-chrome --version)"
ENV IMAGE_INFO="$IMAGE_INFO, $(/usr/bin/microsoft-edge --version)"

RUN apt update && apt -y install gnupg && apt-get clean
RUN playwright-core install --with-deps firefox
RUN [ $(arch) == "armv7l" ] || playwright-core install --with-deps webkit
RUN [ $(arch) == "armv7l" ] || [ $(arch) == "aarch64" ] || playwright-core install --with-deps chrome
RUN [ $(arch) == "armv7l" ] || [ $(arch) == "aarch64" ] || playwright-core install --with-deps msedge

### Lightweight Playwright ###

FROM node as latest
LABEL maintainer="hi@billgo.me"
ENV IMAGE_INFO="$(lsb_release -ds), Node $(node -v), Playwright $(playwright -V)"
RUN npm i -g yarn@1.22.19 playwright-core@1.40 && rm -rf /root/.npm
RUN playwright-core install --with-deps chromium
ENV PATH="/usr/bin/chromium:${PATH}"
CMD eval echo $IMAGE_INFO

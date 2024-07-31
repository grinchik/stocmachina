# https://docs.docker.com/reference/dockerfile/

FROM ubuntu:24.04

WORKDIR /stocmachina

# ------------------------------------------------------------------------------

RUN \
    apt-get \
        update \
    && \
    apt-get \
        upgrade \
            --assume-yes \
    && \
    apt-get \
        clean \
    && \
    echo;

# ------------------------------------------------------------------------------

RUN \
    apt-get \
        install \
            --assume-yes \
            git \
            python3-full \
            python3-pip \
            python3-opencv \
    && \
    apt-get \
        clean \
    && \
    echo;

RUN \
    apt-get \
        install \
            --assume-yes \
            curl \
            exiftool \
            nodejs \
            imagemagick \
    && \
    apt-get \
        clean \
    && \
    echo;

# ------------------------------------------------------------------------------

# git vulnerability CVE-2024-32002
RUN \
    git \
        config \
            --global \
            core.symlinks \
            false \
    && \
    echo;

# ------------------------------------------------------------------------------

RUN \
    git \
        clone \
            https://github.com/xinntao/Real-ESRGAN.git \
            /RealESRGAN \
    && \
    cd \
        /RealESRGAN \
    && \
    git \
        checkout \
            5ca1078535923d485892caee7d7804380bfc87fd \
    && \
    echo;

RUN \
    cd /RealESRGAN/weights/ \
    && \
    curl \
        --output RealESRGAN_x4plus.pth \
        --location \
        https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth \
    && \
    curl \
        --output RealESRNet_x4plus.pth \
        --location \
        https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.1/RealESRNet_x4plus.pth \
    && \
    curl \
        --output RealESRGAN_x2plus.pth \
        --location \
        https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.1/RealESRGAN_x2plus.pth \
    && \
    curl \
        --output RealESRGAN_x4plus_anime_6B.pth \
        --location \
        https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.2.4/RealESRGAN_x4plus_anime_6B.pth \
    && \
    curl \
        --output realesr-general-x4v3.pth \
        --location \
        https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesr-general-x4v3.pth \
    && \
    curl \
        --output realesr-general-wdn-x4v3.pth \
        --location \
        https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesr-general-wdn-x4v3.pth \
    && \
    curl \
        --output realesr-animevideov3.pth \
        --location \
        https://github.com/xinntao/Real-ESRGAN/releases/download/v0.2.5.0/realesr-animevideov3.pth \
    && \
    echo;

RUN \
    cd /RealESRGAN \
    && \
    python3 -m venv venv \
    && \
    ./venv/bin/pip install --no-cache-dir --requirement requirements.txt \
    && \
    echo;

RUN \
    sed \
        --in-place \
            's/from .version import \*//' \
        /RealESRGAN/realesrgan/__init__.py \
    && \
    sed \
        --in-place \
            's/from torchvision.transforms.functional_tensor import rgb_to_grayscale/from torchvision.transforms.functional import rgb_to_grayscale/' \
        /RealESRGAN/venv/lib/python3.12/site-packages/basicsr/data/degradations.py \
    && \
    echo;

# ------------------------------------------------------------------------------

RUN \
    apt-get \
        install \
            --assume-yes \
            openssh-server \
    && \
    apt-get \
        clean \
    && \
    echo;

COPY \
    .ssh/authorized_keys \
    /root/.ssh/authorized_keys

RUN \
    service ssh restart \
    && \
    echo;

EXPOSE 22

CMD [ "/usr/sbin/sshd", "-D" ]

# ------------------------------------------------------------------------------

COPY \
    src/ \
    .

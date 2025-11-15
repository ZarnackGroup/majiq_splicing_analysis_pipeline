# Use official Python 3.10 slim image
FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    build-essential \
    wget \
    curl \
    git \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libcurl4-openssl-dev \
    libzstd-dev \
    autoconf \
    automake \
    libtool \
    make \
    cmake \
    ninja-build \
    && rm -rf /var/lib/apt/lists/*

# Install HTSLib
WORKDIR /opt
RUN curl -OL https://github.com/samtools/htslib/releases/download/1.13/htslib-1.13.tar.bz2 && \
    tar -xf htslib-1.13.tar.bz2 && \
    cd htslib-1.13 && \
    ./configure --prefix=/opt/htslib && \
    make && make install

ENV HTSLIB_LIBRARY_DIR=/opt/htslib/lib
ENV HTSLIB_INCLUDE_DIR=/opt/htslib/include
ENV LD_LIBRARY_PATH=/opt/htslib/lib:$LD_LIBRARY_PATH

# Clone MAJIQ repository at tag v3.0.6
RUN git clone https://bitbucket.org/biociphers/majiq_academic.git /opt/majiq
WORKDIR /opt/majiq
RUN git checkout v3.0.6

# Install MAJIQ and dependencies
RUN pip install --upgrade pip setuptools wheel \
 && pip install numpy==2.0.1 scikit-build-core \
 && pip install .

CMD ["majiq", "--help"] 
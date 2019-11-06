FROM ubuntu:19.04
LABEL maintainer="tsangpo"

ARG USERNAME=coder
ARG USER_UID=1000
ARG USER_GID=$USER_UID


ENV RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH \
    RUST_VERSION=1.38.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends apt-utils software-properties-common 2>&1 \
    #
    # Verify git, process tools, lsb-release (common in install instructions for CLIs) installed
    && apt-get install -y zsh curl wget unzip git iproute2 procps lsb-release \
    #
    # *****************************************************
    # * Add steps for installing needed dependencies here *
    # *****************************************************
    #
    # Install Python
    # && apt-get install python3.8 \
    # Install Java
    && apt-get install -y openjdk-13-jdk \
    # Install Rust
    && wget "https://static.rust-lang.org/rustup/archive/1.19.0/x86_64-unknown-linux-gnu/rustup-init" \
    && chmod +x rustup-init \
    && ./rustup-init -y --no-modify-path --default-toolchain $RUST_VERSION \
    && rm rustup-init \
    && chmod -R a+w $RUSTUP_HOME $CARGO_HOME \
    # Install golang
    && add-apt-repository ppa:longsleep/golang-backports \
    && apt-get update \
    && apt-get install -y golang-go \
    # Install dotnet
    && wget -q https://packages.microsoft.com/config/ubuntu/19.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb \
    && dpkg -i packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y apt-transport-https \
    && apt-get update \
    && apt-get install -y dotnet-sdk-3.0 \
    # Install node
    && curl -sL https://deb.nodesource.com/setup_12.x | bash - \
    && apt-get install -y nodejs \
    && npm install -g eslint \
    #
    #
    # Create a non-root user to use if preferred - see https://aka.ms/vscode-remote/containers/non-root-user.
    && groupadd --gid $USER_GID $USERNAME \
    && useradd -s /bin/bash --uid $USER_UID --gid $USER_GID -m $USERNAME \
    # [Optional] Add sudo support for the non-root user
    && apt-get install -y sudo \
    && echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME\
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    ###################
    && apt-get -y install openssh-server rsync \
    && mkdir -p /var/run/sshd \
    ###################
    #
    # Clean up
    && apt-get autoremove -y \
    && apt-get clean -y \
    && rm -rf /var/lib/apt/lists/*


COPY entrypoint /
COPY rust-bin-path.sh /etc/profile.d/
RUN chmod a+x /entrypoint


EXPOSE 22
ENTRYPOINT ["/entrypoint"]

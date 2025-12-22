FROM ubuntu:24.04

# These are the default of ubuntu:24.04
ARG USER_NAME=ubuntu
ARG USER_UID=1000
ARG USER_GID=1000
ARG GOLANG_VERSION=1.25.5

# Environment Variables1
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# 1. System Setup & Common Packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    dumb-init \
    wget \
    tmux \
    git \
    build-essential \
    libssl-dev \
    pkg-config \
    zsh \
    sudo \
    unzip \
    locales \
    vim \
    neovim \
    htop \
    openssh-client \
    jq \
    ripgrep \
    fd-find \
    gh \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Golang (System-wide from go.dev)
# We install to /usr/local/go
ARG TARGETARCH
RUN wget -q https://go.dev/dl/go${GOLANG_VERSION}.linux-${TARGETARCH}.tar.gz \
    && tar -C /usr/local -xzf go${GOLANG_VERSION}.linux-${TARGETARCH}.tar.gz \
    && rm go${GOLANG_VERSION}.linux-${TARGETARCH}.tar.gz

# 3. Install Starship (System-wide)
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# 4. Add ubuntu to sudoers
# -s /bin/zsh: Sets default shell to Zsh
# -G sudo: Adds to sudo group
# We also configure sudo to not ask for password for convenience in a dev container
RUN usermod -aG sudo $USER_NAME -s /bin/zsh \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# --- SWITCH TO USER CONTEXT ---
USER $USER_NAME
WORKDIR /home/$USER_NAME
ENV SHELL=/bin/zsh

COPY --chown=$USER_NAME:$USER_NAME ../scripts /home/$USER_NAME/scripts
RUN chmod +x /home/$USER_NAME/scripts/*.sh

USER root
RUN /home/${USER_NAME}/scripts/install-lazygit.sh
RUN /home/${USER_NAME}/scripts/install-neovim.sh
RUN /home/${USER_NAME}/scripts/install-just.sh
RUN /home/${USER_NAME}/scripts/install-bat.sh
RUN /home/${USER_NAME}/scripts/install-eza.sh
USER ${USER_NAME}
RUN /home/$USER_NAME/scripts/setup-git-config.sh
RUN rm -rf /home/$USER_NAME/scripts

# 5. Install Rust (rustup)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# 6. Install uv (Python tool)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# 7. Install Deno
RUN curl -fsSL https://deno.land/install.sh | sh -s -- -y

# 8. Install Bun
RUN curl -fsSL https://bun.sh/install | bash

# 9. Install pnpm (Standalone)
RUN wget -qO- https://get.pnpm.io/install.sh | ENV="$HOME/.zshrc" SHELL="$(which zsh)" zsh -

# Setup environments
ENV PNPM_HOME="/home/$USER_NAME/.local/share/pnpm"
ENV PATH="$PNPM_HOME:/home/$USER_NAME/.local/bin:/usr/local/go/bin:/home/$USER_NAME/go/bin:$PATH"
ENV GOROOT="/usr/local/go"
ENV GOPATH="/home/$USER_NAME/go"

RUN pnpm env use --global lts
RUN uv python install 3.13

# Create a minimal .zshrc
RUN echo 'eval "$(just --completions zsh)"' >> ~/.zshrc
RUN echo 'eval "$(starship init zsh)"' >> ~/.zshrc
RUN echo "alias ls='eza --icons'" >> ~/.zshrc
RUN echo "alias ll='ls -la'" >> ~/.zshrc
RUN echo "alias pn='pnpm'" >> ~/.zshrc

# 11. Final Entrypoint
ENTRYPOINT ["/bin/zsh"]

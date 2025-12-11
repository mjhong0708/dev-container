# Base Image: Debian Trixie (Testing)
FROM debian:trixie

# Arguments for version control
ARG GO_VERSION=1.25.5
ARG USER_NAME=dev
ARG USER_UID=1000
ARG USER_GID=1000

# Set environment variables to non-interactive to avoid prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# 1. System Setup & Common Packages
# We install 'just' here via apt as requested.
# 'locales' is added to prevent locale warnings in the shell.
RUN apt-get update && apt-get install -y --no-install-recommends \
    vim \
    neovim \
    ca-certificates \
    curl \
    wget \
    git \
    build-essential \
    libssl-dev \
    zsh \
    htop \
    sudo \
    unzip \
    locales \
    just \
    lazygit \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# 2. Install Golang (System-wide from go.dev)
# We install to /usr/local/go
ARG TARGETARCH
RUN wget -q https://go.dev/dl/go${GO_VERSION}.linux-${TARGETARCH}.tar.gz \
    && tar -C /usr/local -xzf go${GO_VERSION}.linux-${TARGETARCH}.tar.gz \
    && rm go${GO_VERSION}.linux-${TARGETARCH}.tar.gz

# 3. Install Starship (System-wide)
RUN curl -sS https://starship.rs/install.sh | sh -s -- -y

# 4. Create Non-Root User 'dev'
# -s /bin/zsh: Sets default shell to Zsh
# -G sudo: Adds to sudo group
# We also configure sudo to not ask for password for convenience in a dev container
RUN groupadd --gid $USER_GID $USER_NAME \
    && useradd --uid $USER_UID --gid $USER_GID -m -s /bin/zsh -G sudo $USER_NAME \
    && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# --- SWITCH TO USER CONTEXT ---
USER $USER_NAME
WORKDIR /home/$USER_NAME

# 5. Install Rust (rustup)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y

# 6. Install uv (Python tool)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh

# 7. Install Deno
RUN curl -fsSL https://deno.land/install.sh | sh

# 8. Install Bun
RUN curl -fsSL https://bun.sh/install | bash

# 9. Install pnpm (Standalone)
# Setting SHELL allows the script to detect zsh config, though we set ENV manually below
ENV SHELL=/bin/zsh
RUN curl -fsSL https://get.pnpm.io/install.sh | sh -

# 10. Configure Zsh and Environment Variables
# We construct the PATH explicitly so all tools are available immediately
ENV PNPM_HOME="/home/$USER_NAME/.local/share/pnpm"
ENV DENO_INSTALL="/home/$USER_NAME/.deno"
ENV BUN_INSTALL="/home/$USER_NAME/.bun"
ENV GOROOT="/usr/local/go"
ENV GOPATH="/home/$USER_NAME/go"

# Combine PATHs: pnpm, bun, deno, cargo, uv, go, system
ENV PATH="$PNPM_HOME:$BUN_INSTALL/bin:$DENO_INSTALL/bin:/home/$USER_NAME/.cargo/bin:/home/$USER_NAME/.local/bin:$GOROOT/bin:$GOPATH/bin:$PATH"

# Create a minimal .zshrc
# - Initialize starship
# - Alias for convenience
RUN echo 'eval "$(starship init zsh)"' > ~/.zshrc && \
    echo '# Load pnpm configuration' >> ~/.zshrc && \
    echo 'export PNPM_HOME="'$PNPM_HOME'"' >> ~/.zshrc && \
    echo 'export PATH="'$PATH'"' >> ~/.zshrc && \
    echo 'alias ll="ls -hl"' >> ~/.zshrc && \
    echo 'alias lg="lazygit"' >> ~/.zshrc

# 11. Final Entrypoint
ENTRYPOINT ["/bin/zsh"]

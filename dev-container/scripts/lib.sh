find_version() {
    local REPO=$1
    curl -s "https://api.github.com/repos/${REPO}/releases/latest" | grep -Po '"tag_name": "v\K[^"]*'
}
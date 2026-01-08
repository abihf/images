
env_file="$(dirname "$0")/../.env"
[ -f "$env_file" ] && source "$env_file"

function get_latest_github_commit() {
  local repo="$1"
  local branch="${2:-main}"

  curl -sL \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/${repo}/commits?per_page=1&sha=${branch}" | \
    jq -r '.[0].sha'
}

function get_latest_github_release_tag() {
  local repo="$1"

  curl -sL \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/${repo}/releases?per_page=1" | \
    jq -r '.[0].tag_name'
}

function get_number_of_commits() {
  local repo="$1"
  local branch="${2:-main}"

  curl -sIL \
    -H "Accept: application/vnd.github+json" \
    -H "X-GitHub-Api-Version: 2022-11-28" \
    "https://api.github.com/repos/${repo}/commits?per_page=1&sha=${branch}" | grep -i '^Link:' | sed -E 's/^.*&page=([0-9]+)>; rel="last".*$/\1/'
}

function update_docker_arg() {
  local arg_name="$1"
  local new_value="$2"
  local dockerfile="$(dirname "$0")/Dockerfile"

  sed -i -E "s|^(ARG ${arg_name}=).*|\1${new_value}|" "$dockerfile"
}
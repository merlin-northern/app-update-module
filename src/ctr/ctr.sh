
# image functions
function ctr_get_image() {
  local -r url="$1"
  local -r dst_dir="$2"
  local sha256

  echo "url: $url dst: $dst_dir."

  ctr image pull "$url"
  sha256=$(ctr image ls name=="${url}" | sed -n -e 's/.*\(sha256:[a-zA-Z0-9]*\).*/\1/p')
  ctr image export "${dst_dir}/${sha256}" "$url" --platform "${PLATFORM}"
  # ctr image export /tmp/d.img docker.io/library/debian:latest --platform linux/amd64
}

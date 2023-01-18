
. ctr/ctr.sh
. docker/docker.sh

set -x

xdelta3_cmd="xdelta3 -d -s"
tar_decompress_cmd="tar -xzvf"

function get_image() {
  if [[ "$USE_DOCKER" != "" ]]; then
    docker_get_image "$@"
  else
    ctr_get_image "$@"
  fi
}

function parse_metadata() {
  platform=`cat "$1" | jq -r .platform`
  orchestrator=`cat "$1" | jq -r .orchestrator`
  version=`cat "$1" | jq -r .version`
  app_sub_module="${app_module_dir}/${orchestrator}"
  if test ! -f "${app_sub_module}"; then
    echo "ERROR: ${app_sub_module} not found. exiting."
    return 1
  fi
}

function decompress_artifact() {
  local temp_dir=`mktemp -d`
  local image_dir
  local image
  local url_new
  local url_current
  local sha_new
  local sha_current
  local current_image
  local new_image

  if test "$temp_dir" = ""; then
    return 1
  fi

  $tar_decompress_cmd "$1"/images.tar.gz -C "$temp_dir"
  $tar_decompress_cmd "$1"/manifests.tar.gz -C "$temp_dir"

  for image_dir in "${temp_dir}/images/"*; do
    url_new=`cat "${image_dir}/url-new.txt"`
    url_current=`cat "${image_dir}/url-current.txt"`
    sha_new=`cat "${image_dir}/sums-new.txt"`
    sha_current=`cat "${image_dir}/sums-current.txt"`
    if test "$url_new" != "$url_current"; then
      current_image="${temp_dir}/current.${sha_current}.img"
      new_image="${temp_dir}/new.${sha_new}.img"
      $app_sub_module export "$url_current" "$current_image"
      $xdelta3_cmd "$current_image" "${image_dir}/image.img" "${new_image}"
      mv -v "${new_image}" "${image_dir}/image.img"
    fi
  done
  for image_dir in "${temp_dir}/images/"*; do
    url_new=`cat "${image_dir}/url-new.txt"`
    sha_new=`cat "${image_dir}/sums-new.txt"`
    $app_sub_module import "${url_new}" "${image_dir}/image.img"
  done
  $app_sub_module rollout "$temp_dir/manifests"
}

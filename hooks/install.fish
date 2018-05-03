set -l required_version 2.3.0

set -l installed_version 1
if set -q FISH_VERSION
  set installed_version $FISH_VERSION
else if set -q version
  set installed_version $version
end

set -l latest_version (echo -e "$required_version\\n$installed_version" | command sort -r -n -t '.' -k 1,1 -k 2,2 -k 3,3 -k 4,4 | command head -n 1)

if [ "$installed_version" != "$latest_version" ]
  set_color red 2>/dev/null
  echo "Fish $required_version or greater is required for bobthefish."
  echo
  echo "To use bobthefish with Fish $installed_version, checkout the `support/fish-2.2.x` branch"
  echo "in $OMF_PATH/themes/bobthefish/"
  set color normal 2>/dev/null
end

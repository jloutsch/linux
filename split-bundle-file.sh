#!/bin/bash
if [[ "$#" -ne 2 ]]; then
  echo "$0: bundle-file output-dir"
  exit 1
fi

# Get the full path of the bundle file
BUNDLE_FILE="$(readlink -f $1)"
OUTPUT_DIR="${2}"

# Make the output directory if it doesn't exist
if ! mkdir -p "${OUTPUT_DIR}"; then
  echo "Unable to create output directory"
  exit 1
 fi
 
# For each certificate in the bundle, split the bundle into a new file in the output directory
cd "${OUTPUT_DIR}"
if ! csplit --silent -k "${BUNDLE_FILE}" '/END CERTIFICATE/+1' {*}; then
  exit 1
fi

# Remove new lines from the bundle file, and rename the certificate files appropriately
for _file in *; do
  SUBJECT=$(grep '^subject' "${_file}")
  if [[ -n "${SUBJECT}" ]]; then
    # Delete empty lines in the file
    sed -i '/^$/d' "${_file}"
    
    # Rename the file by extracting the CN information from the certificate
    NEW_NAME=$(echo "${SUBJECT##*=}.pem" | tr '\ ' '-')
    if [[ "${_file}" != "${NEW_NAME}" ]]; then
      mv "${_file}" "${NEW_NAME}"
    fi
    
  # Remove any files created that contain nothing
  elif [[ -z $(cat "${_file}") ]]; then
    rm "${_file}"
  fi
done

# Move back to the original directory
cd "${OLDPWD}"

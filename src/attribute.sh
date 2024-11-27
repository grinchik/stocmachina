#!/usr/bin/env bash

set -o errexit;
set -o nounset;
set -o xtrace;

export LANG=C
export LC_ALL=C

readonly CONFIG_DIR="config";
readonly WORKSPACE_DIR="workspace";

readonly RESIZED_SUFFIX=".resized.png";
readonly BASE64_SUFFIX=".base64.txt";
readonly REQUEST_SUFFIX=".request.json";
readonly RESPONSE_SUFFIX=".response.json";
readonly METADATA_SUFFIX=".metadata.txt";
readonly CONVERTED_SUFFIX=".converted.jpg";
readonly ATTRIBUTED_SUFFIX=".attributed.jpg";

readonly INPUT_FILEPATH="$1";
readonly SOURCE_FILEPATH="${WORKSPACE_DIR}/$(basename "${INPUT_FILEPATH}")";
readonly RESIZED_FILEPATH="${SOURCE_FILEPATH}${RESIZED_SUFFIX}";
readonly BASE64_FILEPATH="${RESIZED_FILEPATH}${BASE64_SUFFIX}";
readonly REQUEST_FILEPATH="${BASE64_FILEPATH}${REQUEST_SUFFIX}";
readonly RESPONSE_FILEPATH="${REQUEST_FILEPATH}${RESPONSE_SUFFIX}";
readonly METADATA_FILEPATH="${RESPONSE_FILEPATH}${METADATA_SUFFIX}";
readonly CONVERTED_FILEPATH="${SOURCE_FILEPATH}${CONVERTED_SUFFIX}";
readonly ATTRIBUTED_FILEPATH="${SOURCE_FILEPATH}${ATTRIBUTED_SUFFIX}";
readonly OUTPUT_FILEPATH="$2";

# ==============================================================================

mkdir --parents "${WORKSPACE_DIR}";

# ==============================================================================
# INPUT_FILEPATH -> SOURCE_FILEPATH
# ==============================================================================
rm "${SOURCE_FILEPATH}" || true;
cp \
    --verbose \
    "${INPUT_FILEPATH}" \
    "${SOURCE_FILEPATH}" \
    ;

# ==============================================================================
# INPUT_FILEPATH -> RESIZED_FILEPATH
# ==============================================================================
rm "${RESIZED_FILEPATH}" || true;
convert \
    "${INPUT_FILEPATH}" \
    -resize x512 \
    "${RESIZED_FILEPATH}" \
    ;

# ==============================================================================
# RESIZED_FILEPATH -> BASE64_FILEPATH
# ==============================================================================
rm "${BASE64_FILEPATH}" || true;
base64 \
    --wrap=0 \
    "${RESIZED_FILEPATH}" \
        > \
            "${BASE64_FILEPATH}" \
    ;

# ==============================================================================
# BASE64_FILEPATH -> REQUEST_FILEPATH
# ==============================================================================
rm "${REQUEST_FILEPATH}" || true;
node \
    src/helpers/request.js \
        "${CONFIG_DIR}/SYSTEM_PROMPT.md" \
        "${CONFIG_DIR}/USER_PROMPT.md" \
        "${BASE64_FILEPATH}" \
        "$(basename "${INPUT_FILEPATH}")" \
            > \
                "${REQUEST_FILEPATH}" \
    ;

# ==============================================================================
# REQUEST_FILEPATH -> RESPONSE_FILEPATH
# ==============================================================================
readonly OPENAI_API_KEY=$(cat "${CONFIG_DIR}/OPENAI_API_KEY");

if [[ -z "${OPENAI_API_KEY}" ]]; then
    echo "Error: OPENAI_API_KEY is missing";
    exit 1;
fi

rm "${RESPONSE_FILEPATH}" || true;
curl \
    --request POST \
    --header "Content-Type: application/json" \
    --header "Authorization: ${OPENAI_API_KEY}" \
    --data @"${REQUEST_FILEPATH}"\
    --output "${RESPONSE_FILEPATH}" \
    --verbose \
    --fail \
    https://api.openai.com/v1/chat/completions \
    ;

# ==============================================================================
# RESPONSE_FILEPATH -> METADATA_FILEPATH
# ==============================================================================
rm "${METADATA_FILEPATH}" || true;
node \
    src/helpers/metadata.js \
        "${RESPONSE_FILEPATH}" \
            > \
                "${METADATA_FILEPATH}" \
    ;

# ==============================================================================
# INPUT_FILEPATH -> CONVERTED_FILEPATH
# ==============================================================================
rm "${CONVERTED_FILEPATH}" || true;
convert \
    "${INPUT_FILEPATH}" \
    "${CONVERTED_FILEPATH}" \
    ;

# ==============================================================================
# CONVERTED_FILEPATH -> ATTRIBUTED_FILEPATH
# ==============================================================================
rm "${ATTRIBUTED_FILEPATH}" || true;
exiftool \
    -all= \
    -@ "${METADATA_FILEPATH}" \
    -out "${ATTRIBUTED_FILEPATH}" \
    "${CONVERTED_FILEPATH}" \
    ;

# ==============================================================================
# ATTRIBUTED_FILEPATH -> OUTPUT_FILEPATH
# ==============================================================================
cp \
    --verbose \
    "${ATTRIBUTED_FILEPATH}" \
    "${OUTPUT_FILEPATH}" \
    ;

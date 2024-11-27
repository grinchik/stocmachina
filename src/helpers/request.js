'use strict';

const fs = require('fs');

const SYSTEM_PROMPT_FILE_PATH = process.argv[2];
const SYSTEM_PROMPT = fs.readFileSync(SYSTEM_PROMPT_FILE_PATH, 'utf-8');

const USER_PROMPT_FILE_PATH = process.argv[3];
const USER_PROMPT = fs.readFileSync(USER_PROMPT_FILE_PATH, 'utf-8');

const RESIZED_FILE_PATH = process.argv[4];
const RESIZED_FILE = fs.readFileSync(RESIZED_FILE_PATH);

const MIME_TYPE = process.argv[5];

const IMAGE_FILE_NAME = process.argv[6];

const SUPPORTED_MIME_TYPE_SET = new Set([
  'image/png',
  'image/jpeg',
]);

if (!SUPPORTED_MIME_TYPE_SET.has(MIME_TYPE)) {
  throw new Error(`MIME type "${MIME_TYPE}" is not supported.`);
}

function substituted (string) {
    return string
        .replaceAll('%IMAGE_FILE_NAME%', IMAGE_FILE_NAME)
        ;
}

// https://platform.openai.com/docs/guides/chat-completions/overview
const REQUEST = {
  model: "gpt-4o-mini",
  messages: [
    {
      "role": "system",
      "content": substituted(SYSTEM_PROMPT),
    },
    {
      role: "user",
      content: [
        {
          type: "text",
          text: substituted(USER_PROMPT),
        },
        // https://platform.openai.com/docs/guides/vision
        {
          type: "image_url",
          image_url: {
            url: `data:${MIME_TYPE};base64,` + RESIZED_FILE.toString('base64'),
            detail: "low"
          },
        },
      ],
    },
  ]
};

console
    .log(
        JSON
            .stringify(
                REQUEST,
                null,
                4,
            ),
    )
  ;

'use strict';

const fs = require('fs');

const SYSTEM_PROMPT_FILE_PATH = process.argv[2];
const SYSTEM_PROMPT = fs.readFileSync(SYSTEM_PROMPT_FILE_PATH, 'utf-8');

const USER_PROMPT_FILE_PATH = process.argv[3];
const USER_PROMPT = fs.readFileSync(USER_PROMPT_FILE_PATH, 'utf-8');

const IMAGE_BASE64_FILE_PATH = process.argv[4];
const IMAGE_BASE64 = fs.readFileSync(IMAGE_BASE64_FILE_PATH, 'utf-8');

// https://platform.openai.com/docs/guides/chat-completions/overview
const REQUEST = {
  model: "gpt-4o-mini",
  messages: [
    {
      "role": "system",
      "content": SYSTEM_PROMPT,
    },
    {
      role: "user",
      content: [
        {
          type: "text",
          text: USER_PROMPT,
        },
        // https://platform.openai.com/docs/guides/vision
        {
          type: "image_url",
          image_url: {
            url: "data:image/png;base64," + IMAGE_BASE64,
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

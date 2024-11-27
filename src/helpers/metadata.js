'use strict';

const fs = require('fs');

const RESPONSE_FILE_PATH = process.argv[2];
const RESPONSE_JSON = fs.readFileSync(RESPONSE_FILE_PATH, 'utf-8');
const RESPONSE = JSON.parse(RESPONSE_JSON);

const CONTENT = RESPONSE.choices[0].message.content.split("\n\n");

const TITLE = CONTENT[0].trim().replaceAll('"', '\\"').replaceAll('\n', ' ').replace(/\s+/g, ' ');
const KEYWORDS = CONTENT[1].trim().replaceAll('"', '\\"').replaceAll('\n', ' ').replace(/\s+/g, ' ');

console
    .log(
        [
            `-title=${TITLE}`,
            KEYWORDS.split(', ').map((kw) => `-keywords=${kw}`).join('\n'),
        ].join('\n')
    )
;

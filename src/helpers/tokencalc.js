'use strict';

const fs = require('fs');

// https://openai.com/api/pricing/
// Pricing for gpt-4o-mini
const INPUT_PRICE_PER_TOKEN = 0.150 / 1000_000;
const OUTPUT_PRICE_PER_TOKEN = 0.600 / 1000_000;

const RESPONSE_LIST_FILE_PATH = process.argv[2];

const RESPONSE_LIST = JSON.parse(
    fs.readFileSync(RESPONSE_LIST_FILE_PATH, 'utf-8'),
);

const TOTAL_PROMPT_TOKENS =
    RESPONSE_LIST
        .map((reponse) => reponse.usage.prompt_tokens)
        .reduce((sum, prompt_tokens) => sum + prompt_tokens, 0);

const TOTAL_COMPLETION_TOKENS =
    RESPONSE_LIST
        .map((reponse) => reponse.usage.completion_tokens)
        .reduce((sum, completion_tokens) => sum + completion_tokens, 0);

const INPUT_COST = TOTAL_PROMPT_TOKENS * INPUT_PRICE_PER_TOKEN;
const OUTPUT_COST = TOTAL_COMPLETION_TOKENS * OUTPUT_PRICE_PER_TOKEN;

console.log('TOTAL COST:', '$' + (INPUT_COST + OUTPUT_COST).toFixed(2));

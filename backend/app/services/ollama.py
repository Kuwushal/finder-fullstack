import ollama
import json

SYSTEM_PROMPT= """You are a helper that extracts item and location information from natural language.
For adding/moving items, respond with JSON only:
{"action": "save", "item": "<item name>", "location": "<location>"}

For questions about where something is, respond with JSON only:
{"action": "find", "item": "<item name>"}

No explanation, no markdown, just raw JSON."""

def parse_message(message: str) -> dict:

    response = ollama.chat(
        model="llama3",
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": message}
        ]
    )
    
    return json.loads(response['message']['content'])


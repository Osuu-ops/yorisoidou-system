# compiler_engine.py
# Stage 1: Load files
# Stage 2: GPT-5.2 API connection test

import os
from openai import OpenAI

SPEC_PATH = "spec/master_spec.txt"
BOOT_PATH = "boot/boot_file.txt"

def load_file(path):
    if not os.path.exists(path):
        return f"[ERROR] File not found: {path}"
    with open(path, "r", encoding="utf-8") as f:
        return f.read()

def test_gpt_connection():
    print("\n=== Stage 2: GPT-5.2 connection test ===")

    client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))

    response = client.chat.completions.create(
        model="gpt-5.2",
        messages=[
            {"role": "system", "content": "You are a test assistant."},
            {"role": "user", "content": "これはコンパイラ接続テストです。応答してください。"}
        ]
    )

    print("--- GPT Response ---")
    print(response.choices[0].message["content"])

def main():
    print("=== compiler_engine.py: Stage 1 START ===")

    print("\n--- Loading master_spec.txt ---")
    spec_text = load_file(SPEC_PATH)
    print(spec_text[:300])

    print("\n--- Loading boot_file.txt ---")
    boot_text = load_file(BOOT_PATH)
    print(boot_text[:300])

    print("\n=== Stage 1 END ===")

    # Stage 2: GPT-5.2 test
    test_gpt_connection()

if __name__ == "__main__":
    main()

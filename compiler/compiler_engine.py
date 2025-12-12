# compiler_engine.py
# Stage 1: File load
# Stage 2: GPT-5.2 connection test

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
            {"role": "user", "content": "これはコンパイラ接続テストです。短く応答してください。"}
        ]
    )

    print("--- GPT Response ---")
    print(response.choices[0].message.content)  # ←ここが修正版

def main():
    print("=== compiler_engine.py: Stage 1 START ===")

    print("\n--- Loading master_spec.txt ---")
    print(load_file(SPEC_PATH)[:300])

    print("\n--- Loading boot_file.txt ---")
    print(load_file(BOOT_PATH)[:300])

    print("\n=== Stage 1 END ===")

    test_gpt_connection()

if __name__ == "__main__":
    main()

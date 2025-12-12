# compiler_engine.py
# Stage 1: File load
# Stage 2: GPT-5.2 connection test
# Stage 3: Generate UI questions
# Stage 4: Load UI feedback (input.json)

import os
import json
from openai import OpenAI

SPEC_PATH = "spec/master_spec.txt"
BOOT_PATH = "boot/boot_file.txt"


def load_file(path: str) -> str:
    if not os.path.exists(path):
        return f"[ERROR] File not found: {path}"
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def test_gpt_connection() -> None:
    print("\n=== Stage 2: GPT-5.2 connection test ===")

    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        print("[ERROR] OPENAI_API_KEY is not set.")
        return

    client = OpenAI(api_key=api_key)

    response = client.chat.completions.create(
        model="gpt-5.2",
        messages=[
            {
                "role": "user",
                "content": "これはAPIコンパイラとGPT-5.2の接続テストです。短く応答してください。",
            }
        ],
    )

    print("--- GPT Response ---")
    print(response.choices[0].message.content)


def generate_questions_for_ui(spec_text: str) -> list:
    """
    UI が判断すべきポイント（暫定版）
    """
    return [
        "この master_spec に変更点はありますか？",
        "この仕様の中で矛盾している可能性がある箇所はどこですか？",
        "仕様統合を行う場合、どの方針が最も正しいと思いますか？",
    ]


def write_questions_file(questions: list):
    with open("questions.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(questions))
    print("\n=== questions.txt を生成しました ===")


# ================================
# Stage 4：UIの返答取り込み部
# ================================
def load_ui_feedback():
    """
    UI の判断結果を input.json から読み取る
    """
    if not os.path.exists("input.json"):
        print("[INFO] input.json が存在しません（UI判断なし）")
        return None

    with open("input.json", "r", encoding="utf-8") as f:
        data = json.load(f)

    print("\n=== Loaded UI Feedback ===")
    print(data)
    return data


def main():
    print("=== compiler_engine.py START ===")

    print("\n--- Loading master_spec.txt ---")
    spec_text = load_file(SPEC_PATH)
    print(spec_text[:300])

    print("\n--- Loading boot_file.txt ---")
    boot_text = load_file(BOOT_PATH)
    print(boot_text[:300])

    # Stage 2
    test_gpt_connection()

    # Stage 3
    print("\n=== Stage 3: Generate UI questions ===")
    questions = generate_questions_for_ui(spec_text)
    write_questions_file(questions)

    # Stage 4
    print("\n=== Stage 4: Load UI feedback ===")
    ui_data = load_ui_feedback()

    print("\n=== compiler_engine.py END ===")


if __name__ == "__main__":
    main()

# compiler_engine.py
# Stage 1: File load
# Stage 2: GPT-5.2 connection test
# Stage 3: Generate UI questions for human judgment

import os
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


# =========================================================
# Stage 3：UIに投げるための「質問リスト」を生成する機能
# =========================================================
def generate_questions_for_ui(spec_text: str) -> list:
    """
    master_spec から「UIが判断すべきポイント」を抽出する仮実装。
    今は固定3問だが、後で GPT を使って自動生成に拡張する。
    """
    questions = []
    questions.append("この master_spec に変更点はありますか？")
    questions.append("この仕様の中で矛盾している可能性がある箇所はどこですか？")
    questions.append("仕様統合を行う場合、どの方針が最も正しいと思いますか？")
    return questions


def write_questions_file(questions: list):
    """
    UI に渡す questions.txt を生成
    """
    with open("questions.txt", "w", encoding="utf-8") as f:
        f.write("\n".join(questions))
    print("\n=== questions.txt を生成しました ===")


# =========================================================
# Main routine
# =========================================================
def main() -> None:
    print("=== compiler_engine.py START ===")

    # Stage 1 → spec / boot load
    print("\n--- Loading master_spec.txt ---")
    spec_text = load_file(SPEC_PATH)
    print(spec_text[:300])

    print("\n--- Loading boot_file.txt ---")
    boot_text = load_file(BOOT_PATH)
    print(boot_text[:300])

    # Stage 2 → GPT接続テスト
    test_gpt_connection()

    # Stage 3 → UI質問生成
    print("\n=== Stage 3: Generate UI questions ===")
    questions = generate_questions_for_ui(spec_text)
    write_questions_file(questions)

    print("\n=== compiler_engine.py END ===")


if __name__ == "__main__":
    main()

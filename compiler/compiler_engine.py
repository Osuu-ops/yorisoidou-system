# compiler_engine.py
# 完成版（コード生成プロンプト強化）

import os
import json
from openai import OpenAI

SPEC_PATH = "spec/master_spec.txt"
BOOT_PATH = "boot/boot_file.txt"

QUESTIONS_PATH = "questions.txt"
UI_FEEDBACK_PATH = "input.json"
GENERATED_CODE_PATH = "generated_code.txt"


# --------------------------
# Utility
# --------------------------
def load_file(path: str) -> str:
    if not os.path.exists(path):
        return f"[ERROR] File not found: {path}"
    with open(path, "r", encoding="utf-8") as f:
        return f.read()


def get_client() -> OpenAI | None:
    api_key = os.environ.get("OPENAI_API_KEY")
    if not api_key:
        print("[ERROR] OPENAI_API_KEY is not set.")
        return None
    return OpenAI(api_key=api_key)


# --------------------------
# Stage 2: GPT connection test
# --------------------------
def test_gpt_connection() -> None:
    print("\n=== Stage 2: GPT-5.2 connection test ===")
    client = get_client()
    if client is None:
        return

    response = client.chat.completions.create(
        model="gpt-5.2",
        messages=[
            {"role": "user", "content": "これはAPIコンパイラとGPT-5.2の接続テストです。短く応答してください。"}
        ],
    )

    print("--- GPT Response ---")
    print(response.choices[0].message.content)


# --------------------------
# Stage 3: UI questions
# --------------------------
def generate_questions_for_ui(spec_text: str) -> list[str]:
    return [
        "1. 今回の master_spec の変更点を、あなたの言葉で要約してください。",
        "2. この master_spec 内で、矛盾や危険な仕様になっている可能性が高い箇所はどこですか？理由も教えてください。",
        "3. 仕様統合（A）とコード生成（C）を行うときに、必ず守るべき方針・優先順位を具体的に書いてください。"
    ]


def write_questions_file(questions: list[str]) -> None:
    with open(QUESTIONS_PATH, "w", encoding="utf-8") as f:
        f.write("\n".join(questions))
    print(f"\n=== {QUESTIONS_PATH} を生成しました ===")


# --------------------------
# Stage 4: load UI feedback
# --------------------------
def load_ui_feedback():
    if not os.path.exists(UI_FEEDBACK_PATH):
        print(f"[INFO] {UI_FEEDBACK_PATH} が存在しません（UI判断なし）")
        return None

    with open(UI_FEEDBACK_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)

    print("\n=== Loaded UI Feedback ===")
    print(json.dumps(data, ensure_ascii=False, indent=2))
    return data


# --------------------------
# Stage 5: code generation (強化プロンプト)
# --------------------------
def generate_code_from_spec(spec_text: str, ui_data) -> str | None:
    if ui_data is None:
        print("[INFO] UI判断が無いためコード生成はスキップします。")
        return None

    client = get_client()
    if client is None:
        return None

    spec_snippet = spec_text[:30000]

    system_prompt = (
        "あなたは Google Apps Script と HTML/CSS を用いたフォーム生成の専門家です。"
        "以下の絶対条件を厳守してコードを生成してください："
        "\n\n"
        "【絶対条件】\n"
        "・master_spec に反する判断は禁止。\n"
        "・UI判断（input.json）を必ず反映。\n"
        "・住所/区分/ID体系など業務ロジックを勝手に変更しない。\n"
        "・記述の追加・削除・変形は master_spec に準拠。\n"
        "・コードブロック（```）は禁止。純テキストで返す。\n"
        "・実行可能性よりも整合性と仕様順守を優先。\n"
        "・曖昧な箇所は推測しない。\n"
    )

    user_prompt = (
        "【master_spec 抜粋（先頭〜3万文字）】\n"
        f"{spec_snippet}\n\n"
        "【UI判断 input.json】\n"
        f"{json.dumps(ui_data, ensure_ascii=False, indent=2)}\n\n"
        "上記を踏まえ、CONFIG.gs または main.gs または HTML のうち必要なものを1つ生成してください。\n"
        "形式は純テキスト（コードブロック無し）。"
    )

    print("\n=== Stage 5: Generating code with GPT-5.2 ===")

    response = client.chat.completions.create(
        model="gpt-5.2",
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ],
    )

    code_text = response.choices[0].message.content
    print("--- Code Generation (first 500 chars) ---")
    print(code_text[:500])

    return code_text


def write_generated_code(code_text: str) -> None:
    with open(GENERATED_CODE_PATH, "w", encoding="utf-8") as f:
        f.write(code_text)
    print(f"\n=== {GENERATED_CODE_PATH} を書き出しました ===")


# --------------------------
# Main
# --------------------------
def main():
    print("=== compiler_engine.py START ===")

    spec_text = load_file(SPEC_PATH)
    print("\n--- Loaded master_spec snippet ---")
    print(spec_text[:300])

    boot_text = load_file(BOOT_PATH)
    print("\n--- Loaded boot_file snippet ---")
    print(boot_text[:300])

    test_gpt_connection()

    print("\n=== Stage 3: Questions ===")
    questions = generate_questions_for_ui(spec_text)
    write_questions_file(questions)

    print("\n=== Stage 4: Load UI Feedback ===")
    ui_data = load_ui_feedback()

    if ui_data is not None:
        code_text = generate_code_from_spec(spec_text, ui_data)
        if code_text:
            write_generated_code(code_text)
    else:
        print("[INFO] UI判断なしのためコード生成はスキップされました。")

    print("\n=== compiler_engine.py END ===")


if __name__ == "__main__":
    main()

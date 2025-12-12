# compiler_engine.py
# 完成版（2025-02 時点）
#
# Stage 1: master_spec / boot_file ロード
# Stage 2: GPT-5.2 接続テスト
# Stage 3: UI 向け質問生成（questions.txt）
# Stage 4: UI 判断結果 input.json 取り込み
# Stage 5: GPT-5.2 によるコード生成（generated_code.txt 出力）

import os
import json
from openai import OpenAI

SPEC_PATH = "spec/master_spec.txt"
BOOT_PATH = "boot/boot_file.txt"

QUESTIONS_PATH = "questions.txt"
UI_FEEDBACK_PATH = "input.json"
GENERATED_CODE_PATH = "generated_code.txt"


# ================================
# 共通ユーティリティ
# ================================
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


# ================================
# Stage 2: GPT 接続テスト
# ================================
def test_gpt_connection() -> None:
    print("\n=== Stage 2: GPT-5.2 connection test ===")

    client = get_client()
    if client is None:
        return

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


# ================================
# Stage 3: UI 向け質問生成
# ================================
def generate_questions_for_ui(spec_text: str) -> list[str]:
    """
    暫定版：固定3問。
    後で GPT を使って自動生成に差し替え可能。
    """
    return [
        "1. 今回の master_spec の変更点を、あなたの言葉で要約してください。",
        "2. この master_spec 内で、矛盾や危険な仕様になっている可能性が高い箇所はどこですか？理由も教えてください。",
        "3. 仕様統合（A）とコード生成（C）を行うときに、必ず守るべき方針・優先順位を具体的に書いてください。",
    ]


def write_questions_file(questions: list[str]) -> None:
    with open(QUESTIONS_PATH, "w", encoding="utf-8") as f:
        f.write("\n".join(questions))
    print(f"\n=== {QUESTIONS_PATH} を生成しました ===")


# ================================
# Stage 4: UI 判断結果 input.json 読み込み
# ================================
def load_ui_feedback():
    """
    UI 側で作った input.json を読み込む。
    例：

    {
      "summary": "仕様変更の概要...",
      "risks": "リスクと注意点...",
      "policy": "統合・コード生成の方針..."
    }
    """
    if not os.path.exists(UI_FEEDBACK_PATH):
        print(f"[INFO] {UI_FEEDBACK_PATH} が存在しません（UI判断なし）")
        return None

    with open(UI_FEEDBACK_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)

    print(f"\n=== Loaded UI Feedback from {UI_FEEDBACK_PATH} ===")
    print(json.dumps(data, ensure_ascii=False, indent=2))
    return data


# ================================
# Stage 5: コード生成
# ================================
def generate_code_from_spec(spec_text: str, ui_data) -> str | None:
    """
    GPT-5.2 に master_spec と UI 判断結果を渡して、
    まとめてコード（GAS/HTMLなど）を生成する。
    とりあえず１ファイル分を generated_code.txt に出す方針。
    """
    if ui_data is None:
        print("[INFO] UI 判断結果が無いため、コード生成はスキップします。")
        return None

    client = get_client()
    if client is None:
        return None

    # spec は長いので、まずは先頭3万文字程度に制限
    spec_snippet = spec_text[:30000]

    system_msg = (
        "あなたは Google Apps Script と HTML フォームを生成するエキスパートです。"
        "与えられた業務仕様（master_spec）と人間の判断結果（UIフィードバック）だけを根拠に、"
        "一貫性のあるコードを生成してください。"
    )

    user_msg = (
        "【業務仕様（master_spec 抜粋）】\n"
        f"{spec_snippet}\n\n"
        "【人間（UI）による判断結果 input.json】\n"
        f"{json.dumps(ui_data, ensure_ascii=False, indent=2)}\n\n"
        "上記を踏まえ、現時点で必要な Google Apps Script（CONFIG.gs / main.gs 等）"
        "または HTML フォームコードを1つのテキストとして出力してください。"
        "コードブロック（```）は付けず、プレーンテキストのみで出力してください。"
    )

    print("\n=== Stage 5: Generating code with GPT-5.2 ===")

    response = client.chat.completions.create(
        model="gpt-5.2",
        messages=[
            {"role": "system", "content": system_msg},
            {"role": "user", "content": user_msg},
        ],
    )

    code_text = response.choices[0].message.content
    print("--- Code generation finished (first 500 chars) ---")
    print(code_text[:500])
    return code_text


def write_generated_code(code_text: str) -> None:
    with open(GENERATED_CODE_PATH, "w", encoding="utf-8") as f:
        f.write(code_text)
    print(f"\n=== {GENERATED_CODE_PATH} にコードを書き出しました ===")


# ================================
# Main
# ================================
def main() -> None:
    print("=== compiler_engine.py START ===")

    # Stage 1: spec / boot load
    print("\n--- Loading master_spec.txt ---")
    spec_text = load_file(SPEC_PATH)
    print(spec_text[:300])

    print("\n--- Loading boot_file.txt ---")
    boot_text = load_file(BOOT_PATH)
    print(boot_text[:300])

    # Stage 2: GPT接続テスト
    test_gpt_connection()

    # Stage 3: UI 質問生成
    print("\n=== Stage 3: Generate UI questions ===")
    questions = generate_questions_for_ui(spec_text)
    write_questions_file(questions)

    # Stage 4: UI 判断の読み込み
    print("\n=== Stage 4: Load UI feedback ===")
    ui_data = load_ui_feedback()

    # Stage 5: コード生成
    if ui_data is not None:
        code_text = generate_code_from_spec(spec_text, ui_data)
        if code_text:
            write_generated_code(code_text)
    else:
        print("[INFO] UI判断なしのため、コード生成フェーズはスキップされました。")

    print("\n=== compiler_engine.py END ===")


if __name__ == "__main__":
    main()

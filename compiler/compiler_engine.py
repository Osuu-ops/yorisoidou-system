# compiler_engine.py
# 第二世代・仕様厳守型コンパイラ（Stability Model）
#
# Stage 1: master_spec / boot_file 読み込み
# Stage 2: GPT 接続検証
# Stage 3: UI質問生成
# Stage 4: UI判断取り込み（input.json）
# Stage 5: 仕様 + UI判断 に基づく安定コード生成（MULTI-FILE対応）

import os
import json
from openai import OpenAI

SPEC_PATH = "spec/master_spec.txt"
BOOT_PATH = "boot/boot_file.txt"

QUESTIONS_PATH = "questions.txt"
UI_FEEDBACK_PATH = "input.json"
GENERATED_DIR = "generated_output"

os.makedirs(GENERATED_DIR, exist_ok=True)


# ------------------------------
# Utility
# ------------------------------
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


# ------------------------------
# Stage 2: GPT connection test
# ------------------------------
def test_gpt_connection():
    print("\n=== Stage 2: GPT-5.2 connection test ===")
    client = get_client()
    if client is None:
        return

    res = client.chat.completions.create(
        model="gpt-5.2",
        messages=[
            {
                "role": "user",
                "content": "APIコンパイラとGPT通信テスト。ひと言返してください。"
            }
        ],
    )
    print("GPT:", res.choices[0].message.content)


# ------------------------------
# Stage 3: UI questions
# ------------------------------
def generate_questions_for_ui(spec_text: str) -> list[str]:
    return [
        "1. master_spec の今回の変更点をあなたの言葉で要約してください。",
        "2. master_spec 内で矛盾または危険な仕様はどこですか？理由も書いてください。",
        "3. 統合（A）およびコード生成（C）で守るべき優先方針を具体的に示してください。"
    ]


def write_questions_file(questions: list[str]):
    with open(QUESTIONS_PATH, "w", encoding="utf-8") as f:
        f.write("\n".join(questions))
    print("\n=== questions.txt を生成しました ===")


# ------------------------------
# Stage 4: load UI feedback
# ------------------------------
def load_ui_feedback():
    if not os.path.exists(UI_FEEDBACK_PATH):
        print("[INFO] input.json が存在しません（UI判断なし）")
        return None

    with open(UI_FEEDBACK_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)

    print("\n=== Loaded UI Feedback ===")
    print(json.dumps(data, ensure_ascii=False, indent=2))
    return data


# ------------------------------
# Stage 5: Stability Code Generator
# ------------------------------
def stability_code_generator(spec_text: str, ui_data):
    """
    第二世代コード生成器：
    - master_spec 全文＋UI判断を基に
    - CONFIG.gs / main.gs / HTML の中から必要なファイルを複数生成可能
    - 仕様外の改変を禁止
    - 出力をプレーンテキストのみで返す
    """

    if ui_data is None:
        print("[INFO] UI判断なし → コード生成は実行されません")
        return {}

    client = get_client()
    if client is None:
        return {}

    system_prompt = (
        "あなたは Google Apps Script(GAS) と HTML/CSS による業務アプリ開発の専門家です。\n"
        "以下を厳守してコードを生成してください：\n"
        "・master_spec を唯一の正として扱う\n"
        "・UI判断（input.json）を必ず反映する\n"
        "・ロジック・データ構造・ID体系を勝手に変えない\n"
        "・仕様変更はUI判断に基づき、推測で勝手に追加しない\n"
        "・コードブロック（```）は使わない\n"
        "・複数ファイル生成が必要な場合は JSON 形式で返す\n"
        "  例：{ \"CONFIG.gs\": \"...\", \"main.gs\": \"...\", \"form.html\": \"...\" }\n"
        "・出力JSON以外の文章を返さない\n"
    )

    user_prompt = (
        "【master_spec 全文】\n"
        f"{spec_text}\n\n"
        "【UI判断（input.json）】\n"
        f"{json.dumps(ui_data, ensure_ascii=False, indent=2)}\n\n"
        "上記を踏まえ、必要なコードファイルを JSON 形式で生成してください。\n"
        "JSON キーがファイル名、値がファイル内容となるようにしてください。\n"
    )

    print("\n=== Stage 5: Stability Code Generation ===")

    res = client.chat.completions.create(
        model="gpt-5.2",
        messages=[
            {"role": "system", "content": system_prompt},
            {"role": "user", "content": user_prompt}
        ],
    )

    raw = res.choices[0].message.content
    print("\n--- GPT Raw Output (first 300 chars) ---")
    print(raw[:300])

    # GPT の出力は JSON の想定
    try:
        files = json.loads(raw)
    except Exception as e:
        print("[ERROR] GPT の出力が JSON として解析できません:", e)
        return {}

    return files


def write_generated_files(files: dict):
    if not files:
        print("[INFO] 生成ファイルがありません")
        return

    for filename, content in files.items():
        outpath = os.path.join(GENERATED_DIR, filename)
        with open(outpath, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"[WRITE] {outpath} を生成しました")


# ------------------------------
# Main
# ------------------------------
def main():
    print("=== compiler_engine.py START ===")

    # Stage 1
    spec_text = load_file(SPEC_PATH)
    print("\n--- master_spec snippet ---")
    print(spec_text[:300])

    boot_text = load_file(BOOT_PATH)
    print("\n--- boot_file snippet ---")
    print(boot_text[:300])

    # Stage 2
    test_gpt_connection()

    # Stage 3
    questions = generate_questions_for_ui(spec_text)
    write_questions_file(questions)

    # Stage 4
    ui_data = load_ui_feedback()

    # Stage 5
    if ui_data:
        files = stability_code_generator(spec_text, ui_data)
        write_generated_files(files)
    else:
        print("[INFO] UI判断なし → コード生成スキップ")

    print("\n=== compiler_engine.py END ===")


if __name__ == "__main__":
    main()

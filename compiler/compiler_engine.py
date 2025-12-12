# compiler_engine.py
# 第2世代 + 実行モード切り替え版（fast / full）

import os
import json
from openai import OpenAI

SPEC_PATH = "spec/master_spec.txt"
BOOT_PATH = "boot/boot_file.txt"

QUESTIONS_PATH = "questions.txt"
UI_FEEDBACK_PATH = "input.json"
GENERATED_DIR = "generated_output"

os.makedirs(GENERATED_DIR, exist_ok=True)


# =============================
# Utility
# =============================
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


# =============================
# Stage 2: GPT connection test
# =============================
def test_gpt_connection():
    print("\n=== Stage 2: GPT-5.2 connection test ===")
    client = get_client()
    if client is None:
        return

    res = client.chat.completions.create(
        model="gpt-5.2",
        messages=[
            {"role": "user", "content": "APIコンパイラとの接続テスト。短く返答。"}
        ],
    )

    print("GPT:", res.choices[0].message.content)


# =============================
# Stage 3: Questions for UI
# =============================
def generate_questions_for_ui(spec_text: str) -> list[str]:
    return [
        "1. master_spec の今回変更点の要約を記述せよ。",
        "2. master_spec 内で矛盾または危険な仕様箇所と理由を述べよ。",
        "3. 統合（A）および生成（C）で守るべき優先ルールを示せ。"
    ]


def write_questions_file(questions: list[str]):
    with open(QUESTIONS_PATH, "w", encoding="utf-8") as f:
        f.write("\n".join(questions))
    print("\n=== questions.txt を生成しました ===")


# =============================
# Stage 4: Load UI feedback
# =============================
def load_ui_feedback():
    if not os.path.exists(UI_FEEDBACK_PATH):
        print("[INFO] input.json が存在しません（UI判断なし）")
        return None

    with open(UI_FEEDBACK_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)

    print("\n=== Loaded UI Feedback ===")
    print(json.dumps(data, ensure_ascii=False, indent=2))
    return data


# =============================
# Stage 5: Code generation (full-mode)
# =============================
def stability_code_generator(spec_text: str, ui_data, mode="fast"):
    """
    fast → コード生成スキップ（高速）
    full → コード生成あり
    """

    if mode == "fast":
        print("[MODE] fast：コード生成はスキップされます")
        return {}

    if ui_data is None:
        print("[INFO] UI判断なし → full モードでもコード生成不可")
        return {}

    client = get_client()
    if client is None:
        return {}

    system_prompt = (
        "あなたは GAS/HTML/CSS の業務システム生成AIです。\n"
        "以下の条件を厳守してコードを生成してください：\n"
        "・master_spec を唯一の正として扱う\n"
        "・UI判断（input.json）を必ず反映\n"
        "・仕様外の推測追加は禁止\n"
        "・住所/区分/ID体系を勝手に変えない\n"
        "・コードブロック禁止\n"
        "・生成物は JSON 形式（キー＝ファイル名、値＝内容）で返す\n"
    )

    user_prompt = (
        "【master_spec 全文】\n"
        f"{spec_text}\n\n"
        "【UI判断 input.json】\n"
        f"{json.dumps(ui_data, ensure_ascii=False, indent=2)}\n\n"
        "必要なコードファイルを JSON 形式で返してください。\n"
    )

    print("\n=== Stage 5: Stability Code Generation (full mode) ===")

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

    try:
        files = json.loads(raw)
    except Exception as e:
        print("[ERROR] GPT出力がJSONとして解析できません:", e)
        return {}

    return files


def write_generated_files(files: dict):
    if not files:
        print("[INFO] 生成ファイルなし")
        return

    for filename, content in files.items():
        outpath = os.path.join(GENERATED_DIR, filename)
        with open(outpath, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"[WRITE] {outpath} を生成しました")


# =============================
# Main
# =============================
def main():
    print("=== compiler_engine.py START ===")

    mode = os.environ.get("MODE", "fast")
    print(f"[MODE] 現在の実行モード: {mode}")

    # Stage 1
    spec_text = load_file(SPEC_PATH)
    boot_text = load_file(BOOT_PATH)

    # Stage 2
    test_gpt_connection()

    # Stage 3
    questions = generate_questions_for_ui(spec_text)
    write_questions_file(questions)

    # Stage 4
    ui_data = load_ui_feedback()

    # Stage 5（fast/full の切り替え）
    files = stability_code_generator(spec_text, ui_data, mode=mode)
    write_generated_files(files)

    print("\n=== compiler_engine.py END ===")


if __name__ == "__main__":
    main()

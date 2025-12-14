# compiler_engine.py
# full専用版（毎回コード生成）

import os
import json
from openai import OpenAI

SPEC_PATH = "spec/master_spec.txt"
BOOT_PATH = "boot/boot_file.txt"

QUESTIONS_PATH = "questions.txt"
UI_FEEDBACK_PATH = "input.json"
GENERATED_DIR = "generated_output"

os.makedirs(GENERATED_DIR, exist_ok=True)


# Utility
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


# Stage 2: GPT test
def test_gpt_connection():
    print("\n=== Stage 2: GPT-5.2 connection test ===")
    client = get_client()
    if client is None:
        return

    res = client.chat.completions.create(
        model="gpt-5.2",
        messages=[
            {"role": "user", "content": "API接続テスト。短く応答してください。"}
        ],
    )
    print("GPT:", res.choices[0].message.content)


# Stage 3: Questions
def generate_questions_for_ui(spec_text: str):
    return [
        "1. master_spec の今回変更点の要約を書いてください。",
        "2. master_spec 内で矛盾・危険な仕様がある部分と理由を書いてください。",
        "3. 統合（A）と生成（C）で守るべき優先ルールを書いてください。"
    ]


def write_questions_file(questions):
    with open(QUESTIONS_PATH, "w", encoding="utf-8") as f:
        f.write("\n".join(questions))
    print("\n=== questions.txt を生成 ===")


# Stage 4: Load UI feedback
def load_ui_feedback():
    if not os.path.exists(UI_FEEDBACK_PATH):
        print("[INFO] input.json が存在しません → コード生成不能")
        return None
    with open(UI_FEEDBACK_PATH, "r", encoding="utf-8") as f:
        data = json.load(f)
    print("\n=== Loaded UI Feedback ===")
    print(json.dumps(data, ensure_ascii=False, indent=2))
    return data


# Stage 5: Text Audit (T-phase)
def run_text_audit(spec_text: str, ui_data):
    print("\n=== Stage 5: Text Audit (T-phase) ===")

    client = get_client()
    if client is None:
        return

    # ui_data が None の場合は空オブジェクトとして扱う
    ui_json = "{}" if ui_data is None else json.dumps(ui_data, ensure_ascii=False, indent=2)

    audit_prompt = (
        "あなたは Tチャット（文章監査専用）です。\n"
        "master_spec と UI判断(input.json)を監査し、"
        "不足前提・危険な仕様・あいまいな部分を洗い出してください。\n"
        "AIが勝手に補完すべきでない項目はすべて指摘してください。\n"
        "\n"
        "出力形式は必ず次のフォーマットにしてください：\n"
        "===== ERROR.txt =====\n"
        "[不足前提]\n"
        "- 箇条書きで列挙\n"
        "\n"
        "[危険な仕様・あいまいな仕様]\n"
        "- 箇条書きで列挙\n"
        "\n"
        "[Aで統合すべき追加仕様案]\n"
        "- 箇条書きで列挙\n"
        "===== END =====\n"
    )

    user_content = (
        f"[master_spec]\n{spec_text}\n\n"
        f"[UI判断(input.json)]\n{ui_json}\n"
    )

    res = client.chat.completions.create(
        model="gpt-5.2",
        messages=[
            {"role": "system", "content": "You are T-phase text auditor."},
            {"role": "user", "content": audit_prompt},
            {"role": "user", "content": user_content},
        ],
    )

    error_text = res.choices[0].message.content

    # ログ出力
    print("\n--- ERROR.txt (T-phase output) ---")
    print(error_text)

    # ファイル保存（generated_output/ERROR.txt に保存）
    error_path = os.path.join(GENERATED_DIR, "ERROR.txt")
    with open(error_path, "w", encoding="utf-8") as f:
        f.write(error_text)
    print(f"[WRITE] {error_path} を生成")


# Stage 6: Code generation
def generate_code(spec_text, ui_data):
    if ui_data is None:
        print("[INFO] UI判断なし → 生成スキップ")
        return {}

    client = get_client()
    if client is None:
        return {}

    system_prompt = (
        "あなたはGAS/HTML生成の専門家です。以下を厳守：\n"
        "・master_specに従う\n"
        "・UI判断(input.json)を必ず反映\n"
        "・仕様外の推測はしない\n"
        "・JSON形式（キー＝ファイル名、値＝内容）で返す\n"
        "・コードブロック禁止\n"
    )

    user_prompt = (
        f"[master_spec]\n{spec_text}\n\n"
        f"[UI判断]\n{json.dumps(ui_data, ensure_ascii=False, indent=2)}\n\n"
        "必要なコードをJSONで返してください"
    )

    print("\n=== Stage 6: Code Generation ===")

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
        return json.loads(raw)
    except Exception:
        print("[ERROR] JSON解析に失敗")
        return {}


def write_files(files):
    if not files:
        print("[INFO] 出力なし")
        return

    for name, content in files.items():
        path = os.path.join(GENERATED_DIR, name)
        with open(path, "w", encoding="utf-8") as f:
            f.write(content)
        print(f"[WRITE] {path} を生成")


# Main
def main():
    print("=== compiler_engine.py START ===")

    spec_text = load_file(SPEC_PATH)
    boot_text = load_file(BOOT_PATH)

    test_gpt_connection()

    write_questions_file(generate_questions_for_ui(spec_text))

    ui_data = load_ui_feedback()

    # T-phase 実行（ERROR.txt を生成）
    run_text_audit(spec_text, ui_data)

    files = generate_code(spec_text, ui_data)
    write_files(files)

    print("\n=== END ===")


if __name__ == "__main__":
    main()

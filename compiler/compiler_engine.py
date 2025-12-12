# compiler_engine.py
# Stage 1: File loading test (no GPT yet)

import os

SPEC_PATH = "spec/master_spec.txt"
BOOT_PATH = "boot/boot_file.txt"

def load_file(path):
    if not os.path.exists(path):
        return f"[ERROR] File not found: {path}"
    with open(path, "r", encoding="utf-8") as f:
        return f.read()

def main():
    print("=== compiler_engine.py: Stage 1 START ===")

    print("\n--- Loading master_spec.txt ---")
    spec_text = load_file(SPEC_PATH)
    print(spec_text[:500])  # 最初の500文字だけ出力

    print("\n--- Loading boot_file.txt ---")
    boot_text = load_file(BOOT_PATH)
    print(boot_text[:500])  # 最初の500文字

    print("\n=== compiler_engine.py: Stage 1 END ===")

if __name__ == "__main__":
    main()


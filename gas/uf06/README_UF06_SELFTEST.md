# UF06_QUEUE SelfTest (Phase-1)

目的：
- UF06_QUEUE が Active Spreadsheet に「作成/追記」できること
- idempotencyKey により重複登録が抑止されること（duplicated=true）

実行（Apps Script 上）：
- UF06_SELFTEST_ORDER()
- UF06_SELFTEST_DELIVER()
- UF06_SELFTEST_IDEMPOTENCY_ORDER()

注意：
- Parts_Master 等へは一切書き込みません（UF06_QUEUE のみ）。
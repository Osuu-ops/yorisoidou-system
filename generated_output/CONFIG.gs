function CONF() {
  return {
    systemName: "業務自動化システム",
    timezone: "Asia/Tokyo",
    maintenanceMode: false,
    testModeRuntime: false,
    forms: [
      { code: "UF01", kind: "受注フォーム", enabled: true },
      { code: "UF06", kind: "発注／納品フォーム", enabled: true },
      { code: "UF07", kind: "価格入力フォーム", enabled: true },
      { code: "UF08", kind: "追加報告フォーム", enabled: true },
      { code: "FIX", kind: "修正フォーム", enabled: true },
      { code: "DOC", kind: "書類フォーム", enabled: true },
      { code: "OV01", kind: "閲覧フォーム", enabled: true },
      { code: "OV02", kind: "全文検索フォーム", enabled: true }
    ]
  };
}

function applyActiveBrand() {
  return CONF();
}

function CONF() {
  return {
    systemName: "業務自動化システム",
    timezone: "Asia/Tokyo",
    defaultYear: null,
    fiscalYear: null,
    fiscalStart: "04-01",

    maintenanceMode: false,
    testModeRuntime: false,

    activeBrand: "",
    brandProfiles: [],

    roles: [
      "guest",
      "viewer",
      "operator",
      "staff",
      "manager",
      "admin",
      "config-admin-primary",
      "config-admin-secondary"
    ],

    forms: {
      UF01: { code: "UF01", kind: "受注フォーム", enabled: true, title: "UF01（受注）" },
      UF06: { code: "UF06", kind: "発注／納品フォーム", enabled: true, title: "UF06（発注／納品）" },
      UF07: { code: "UF07", kind: "価格入力フォーム", enabled: true, title: "UF07（価格入力）" },
      UF08: { code: "UF08", kind: "追加報告フォーム", enabled: true, title: "UF08（追加報告）" },
      FIX:  { code: "FIX",  kind: "修正フォーム", enabled: true, title: "FIX（修正申請）" },
      DOC:  { code: "DOC",  kind: "書類フォーム", enabled: true, title: "DOC（書類リクエスト）" },
      OV01: { code: "OV01", kind: "閲覧フォーム", enabled: true, title: "OV01（カルテ閲覧）" },
      OV02: { code: "OV02", kind: "全文検索フォーム", enabled: true, title: "OV02（全文検索）" }
    }
  };
}

function applyActiveBrand() {
  // master_spec: brandProfiles 構造は継承するが、ここでは推測実装しない（仕様外の推測追加禁止）。
  return CONF();
}

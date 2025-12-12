function onOpen() {
  var ui = SpreadsheetApp.getUi();
  var conf = applyActiveBrand();
  var menuName = conf.systemName || "業務メニュー";
  var menu = ui.createMenu(menuName);
  (conf.forms || []).forEach(function (f) {
    if (f && f.enabled) {
      menu.addItem((f.kind || f.code) + "（" + f.code + "）", "menuOpen_" + f.code);
    }
  });
  menu.addSeparator();
  menu.addItem("Runtimeテスト", "runRuntimeSelfTest");
  menu.addToUi();
}

function menuOpen_UF01() { showDynamicForm("UF01"); }
function menuOpen_UF06() { showDynamicForm("UF06"); }
function menuOpen_UF07() { showDynamicForm("UF07"); }
function menuOpen_UF08() { showDynamicForm("UF08"); }
function menuOpen_FIX() { showDynamicForm("FIX"); }
function menuOpen_DOC() { showDynamicForm("DOC"); }
function menuOpen_OV01() { showDynamicForm("OV01"); }
function menuOpen_OV02() { showDynamicForm("OV02"); }

function showDynamicForm(code) {
  var conf = applyActiveBrand();
  var form = (conf.forms || []).filter(function (f) { return f.code === code; })[0];
  if (!form || !form.enabled) throw new Error("Form disabled: " + code);

  if (conf.maintenanceMode) {
    var allow = (code === "OV01" || code === "OV02");
    if (!allow) {
      logSystem({
        action: "MAINTENANCE_BLOCK",
        targetId: code,
        input: { code: code },
        gasSummary: { blocked: true }
      });
      SpreadsheetApp.getUi().alert("maintenanceMode 中のため、このフォームは利用できません。\n閲覧（OV01/OV02）のみ許可されています。");
      return;
    }
  }

  var html = HtmlService.createTemplateFromFile(code).evaluate()
    .setTitle(form.kind || code)
    .setWidth(1100)
    .setHeight(780);
  SpreadsheetApp.getUi().showModalDialog(html, (form.kind || code) + "（" + code + "）");
}

function doGet(e) {
  var conf = applyActiveBrand();
  var code = (e && e.parameter && e.parameter.form) ? e.parameter.form : "OV01";
  var form = (conf.forms || []).filter(function (f) { return f.code === code; })[0];
  if (!form || !form.enabled) {
    return HtmlService.createHtmlOutput("Disabled");
  }
  if (conf.maintenanceMode && !(code === "OV01" || code === "OV02")) {
    return HtmlService.createHtmlOutput("maintenanceMode");
  }
  return HtmlService.createTemplateFromFile(code).evaluate();
}

function include(filename) {
  return HtmlService.createHtmlOutputFromFile(filename).getContent();
}

function ensureBusinessSheets() {
  // placeholder: 本来はシート存在確認などを行う
  return true;
}

function logSystem(obj) {
  // master_spec: logs/system へ保存（ここでは最低限のスプレッドシート記録のみ）
  var ss = SpreadsheetApp.getActive();
  var sh = ss.getSheetByName("logs_system");
  if (!sh) {
    sh = ss.insertSheet("logs_system");
    sh.appendRow(["Timestamp", "Action", "TargetID", "InputJSON", "GASSummaryJSON", "AIFlagsJSON", "RuntimeJSON", "EnvJSON"]);
  }
  var ts = new Date();
  var action = (obj && obj.action) ? obj.action : "UNKNOWN";
  var targetId = (obj && obj.targetId) ? obj.targetId : "";
  var inputJson = JSON.stringify((obj && obj.input) ? obj.input : {});
  var gasSummaryJson = JSON.stringify((obj && obj.gasSummary) ? obj.gasSummary : {});
  var aiFlagsJson = JSON.stringify((obj && obj.aiFlags) ? obj.aiFlags : {});
  var runtimeJson = JSON.stringify((obj && obj.runtime) ? obj.runtime : {});
  var envJson = JSON.stringify((obj && obj.env) ? obj.env : {});
  sh.appendRow([ts, action, targetId, inputJson, gasSummaryJson, aiFlagsJson, runtimeJson, envJson]);
}

function runtimeCheckExpectedUnexpected_(result) {
  // placeholder: expected/unexpected effect の監査フレーム
  return { ok: true, expected: result && result.expected ? result.expected : [], unexpected: [] };
}

function onUF01Submit(payload) {
  var conf = applyActiveBrand();
  if (conf.maintenanceMode) {
    logSystem({ action: "MAINTENANCE_BLOCK", targetId: "UF01", input: payload, gasSummary: { blocked: true } });
    throw new Error("maintenanceMode");
  }

  ensureBusinessSheets();

  // ① AI一次解析（素材抽出）: 本実装では素材抽出は行わず空で保持（判断禁止、かつ外部推測禁止）
  var ai1 = { aiStatus: "ERROR", candidates: {} };

  // ② GAS決定（normalize）: 本実装は最小の正当化のみ
  var norm = normalizeUF01FromForm(payload, ai1);

  // ③ AI監査（重大矛盾のみ）: 本実装では矛盾判定ロジックなし
  var aiAudit = { warnings: [] };

  // ④ logs/system
  var runtime = runtimeCheckExpectedUnexpected_({ expected: ["UF01:Order_YYYY add (not implemented in this minimal skeleton)"] });
  logSystem({
    action: "UF01_SUBMIT",
    targetId: norm.orderId || "",
    input: payload,
    gasSummary: norm,
    aiFlags: { ai1: ai1, aiAudit: aiAudit },
    runtime: runtime,
    env: { ok: true }
  });

  // ⑤ ClickUp 初回通知（任意）: 未実装

  return { ok: true, normalized: norm, ai: { ai1: ai1, audit: aiAudit }, runtime: runtime };
}

function normalizeUF01FromForm(payload, ai1) {
  // master_spec: addressCityTown は GAS専権。ここでは生成ロジック未実装のため空。
  var rawText = payload && payload.raw ? String(payload.raw) : "";
  var name = payload && payload.name ? String(payload.name) : "";
  var phone = payload && payload.phone ? String(payload.phone) : "";
  var addressFull = payload && payload.addressFull ? String(payload.addressFull) : "";
  var preferred1 = payload && payload.preferred1 ? String(payload.preferred1) : "";
  var preferred2 = payload && payload.preferred2 ? String(payload.preferred2) : "";
  var price = payload && payload.price ? String(payload.price) : "";

  return {
    rawText: rawText,
    name: name,
    phone: phone,
    addressFull: addressFull,
    addressCityTown: "", // GAS生成（未実装）
    preferred1: preferred1,
    preferred2: preferred2,
    priceTotal: price,
    summary: payload && payload.summary ? String(payload.summary) : "",
    mediaCode: payload && payload.mediaCode ? String(payload.mediaCode) : "unknown",
    orderId: "" // Order_ID 採番は本来 writeOrderFromUF01 で実施（未実装）
  };
}

function formSubmitUF06(payload) {
  var conf = applyActiveBrand();
  if (conf.maintenanceMode) {
    logSystem({ action: "MAINTENANCE_BLOCK", targetId: "UF06", input: payload, gasSummary: { blocked: true } });
    throw new Error("maintenanceMode");
  }
  ensureBusinessSheets();
  var runtime = runtimeCheckExpectedUnexpected_({ expected: ["UF06:Parts_Master add/update (not implemented in this minimal skeleton)"] });
  logSystem({ action: "UF06_SUBMIT", targetId: (payload && payload.orderId) ? payload.orderId : "", input: payload, gasSummary: { ok: true }, runtime: runtime, env: { ok: true } });
  return { ok: true, runtime: runtime };
}

function formSubmitUF07(payload) {
  var conf = applyActiveBrand();
  if (conf.maintenanceMode) {
    logSystem({ action: "MAINTENANCE_BLOCK", targetId: "UF07", input: payload, gasSummary: { blocked: true } });
    throw new Error("maintenanceMode");
  }
  ensureBusinessSheets();
  var runtime = runtimeCheckExpectedUnexpected_({ expected: ["UF07:PRICE update (not implemented in this minimal skeleton)"] });
  logSystem({ action: "UF07_SUBMIT", targetId: (payload && payload.orderId) ? payload.orderId : "", input: payload, gasSummary: { ok: true }, runtime: runtime, env: { ok: true } });
  return { ok: true, runtime: runtime };
}

function formSubmitUF08(payload) {
  var conf = applyActiveBrand();
  if (conf.maintenanceMode) {
    logSystem({ action: "MAINTENANCE_BLOCK", targetId: "UF08", input: payload, gasSummary: { blocked: true } });
    throw new Error("maintenanceMode");
  }
  ensureBusinessSheets();
  var runtime = runtimeCheckExpectedUnexpected_({ expected: ["UF08:logs/system UF08_SUBMIT exists"] });
  logSystem({ action: "UF08_SUBMIT", targetId: (payload && payload.orderId) ? payload.orderId : "", input: payload, gasSummary: { ok: true }, runtime: runtime, env: { ok: true } });
  return { ok: true, runtime: runtime };
}

function formSubmitFIX(payload) {
  ensureBusinessSheets();
  var ss = SpreadsheetApp.getActive();
  var sh = ss.getSheetByName("Request");
  if (!sh) {
    sh = ss.insertSheet("Request");
    sh.appendRow(["Timestamp", "Category", "TargetID", "PayloadJSON", "Requester", "Memo"]);
  }
  sh.appendRow([new Date(), (payload && payload.category) ? payload.category : "", "", JSON.stringify(payload || {}), (payload && payload.requester) ? payload.requester : "", (payload && payload.memo) ? payload.memo : ""]); 

  var runtime = runtimeCheckExpectedUnexpected_({ expected: ["FIX:Request FIX_SUBMIT add"] });
  logSystem({ action: "FIX_SUBMIT", targetId: "", input: payload, gasSummary: { ok: true }, runtime: runtime, env: { ok: true } });
  return { ok: true, runtime: runtime };
}

function formSubmitDOC(payload) {
  ensureBusinessSheets();
  var ss = SpreadsheetApp.getActive();
  var sh = ss.getSheetByName("Request");
  if (!sh) {
    sh = ss.insertSheet("Request");
    sh.appendRow(["Timestamp", "Category", "TargetID", "PayloadJSON", "Requester", "Memo"]);
  }
  sh.appendRow([new Date(), "DOC_SUBMIT", (payload && payload.orderId) ? payload.orderId : "", JSON.stringify(payload || {}), (payload && payload.requester) ? payload.requester : "", (payload && payload.docMemo) ? payload.docMemo : ""]);

  var runtime = runtimeCheckExpectedUnexpected_({ expected: ["DOC:Request DOC_SUBMIT add"] });
  logSystem({ action: "DOC_SUBMIT", targetId: (payload && payload.orderId) ? payload.orderId : "", input: payload, gasSummary: { ok: true }, runtime: runtime, env: { ok: true } });
  return { ok: true, runtime: runtime };
}

function getOV01Data(params) {
  ensureBusinessSheets();
  // カルテ表示用: 本来は Order_YYYY/各台帳/Drive を統合。ここでは最低限。
  var orderId = params && params.orderId ? String(params.orderId) : "";
  logSystem({ action: "OV01_VIEW", targetId: orderId, input: params, gasSummary: { ok: true }, env: { ok: true } });
  return {
    orderId: orderId,
    healthyScore: null,
    aiWarnings: [],
    order: null,
    customer: null,
    property: null,
    parts: [],
    ex: [],
    exp: [],
    historyNotes: "",
    media: "",
    photos: { before: [], after: [], parts: [], extra: [] },
    videos: { inspection: [] },
    logs: []
  };
}

function searchOV02(params) {
  ensureBusinessSheets();
  var q = params && params.query ? String(params.query) : "";
  logSystem({ action: "OV02_SEARCH", targetId: "", input: params, gasSummary: { ok: true }, env: { ok: true } });
  return { query: q, results: [] };
}

function completeOrderFromTodoist(orderId, completedAt, commentText) {
  var conf = applyActiveBrand();
  if (conf.maintenanceMode) {
    logSystem({ action: "MAINTENANCE_BLOCK", targetId: orderId, input: { orderId: orderId, completedAt: completedAt, commentText: commentText }, gasSummary: { blocked: true } });
    throw new Error("maintenanceMode");
  }

  ensureBusinessSheets();

  // 本来の expected effect 一式は未実装（最小スケルトン）
  var runtime = runtimeCheckExpectedUnexpected_({
    expected: [
      "COMPLETE:Order STATUS/LastSyncedAt update",
      "COMPLETE:DELIVERED->USED",
      "COMPLETE:EXP add",
      "COMPLETE:STOCK return if unused"
    ]
  });

  logSystem({
    action: "TODOIST_COMPLETE",
    targetId: orderId,
    input: { orderId: orderId, completedAt: completedAt, commentText: commentText },
    gasSummary: { ok: true },
    aiFlags: { warnings: [] },
    runtime: runtime,
    env: { ok: true }
  });

  return { ok: true, runtime: runtime };
}

function runRuntimeSelfTest() {
  var conf = applyActiveBrand();
  if (!conf.testModeRuntime) {
    SpreadsheetApp.getUi().alert("CONFIG.testModeRuntime = true の場合のみ実行できます。");
    return;
  }

  // master_spec: テストID強制・isTest=true を本来付与。
  // 本スケルトンでは expected effect のログを残すのみ。
  logSystem({ action: "RUNTIME_SELFTEST_START", targetId: "", input: { testModeRuntime: true }, gasSummary: { ok: true }, env: { ok: true } });

  onUF01Submit({ raw: "test-order", name: "", phone: "", addressFull: "", preferred1: "", preferred2: "", price: "", summary: "", mediaCode: "unknown" });
  formSubmitUF06({ orderId: "", mode: "order" });
  formSubmitUF06({ orderId: "", mode: "deliver" });
  formSubmitUF07({ orderId: "", items: [] });
  formSubmitUF08({ orderId: "", memo: "test" });
  formSubmitFIX({ category: "入り値修正", content: "test", requester: "test", memo: "" });
  formSubmitDOC({ orderId: "", docType: "見積書", docName: "test", docDesc: "", docPrice: "", docMemo: "", requester: "test" });
  completeOrderFromTodoist("", new Date().toISOString(), "未使用：BP-YYYYMM-AA00-PA00");

  logSystem({ action: "RUNTIME_SELFTEST_END", targetId: "", input: {}, gasSummary: { ok: true }, env: { ok: true } });
  SpreadsheetApp.getUi().alert("RuntimeSelfTest を実行しました（最小スケルトン）。\nlogs_system を確認してください。");
}

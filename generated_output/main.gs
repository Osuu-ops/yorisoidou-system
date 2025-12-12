function onOpen() {
  var ui = SpreadsheetApp.getUi();
  var conf = CONF();

  var menuName = "業務メニュー";
  if (conf && conf.systemName) menuName = conf.systemName;

  var menu = ui.createMenu(menuName);
  var forms = conf.forms || {};
  Object.keys(forms).forEach(function(k) {
    var f = forms[k];
    if (f && f.enabled) {
      menu.addItem((f.kind || k) + "（" + f.code + "）", "show_" + f.code);
    }
  });
  menu.addSeparator();
  menu.addItem("Runtimeテスト", "runRuntimeSelfTest");
  menu.addToUi();
}

function showDynamicForm(code) {
  var conf = CONF();
  var f = (conf.forms || {})[code];
  if (!f || !f.enabled) throw new Error("Form disabled: " + code);

  if (conf.maintenanceMode === true) {
    // master_spec: maintenanceMode 中は閲覧系のみ許可
    if (code !== "OV01" && code !== "OV02") {
      logSystem_("MAINTENANCE_BLOCK", "", { form: code }, { blocked: true });
      throw new Error("maintenanceMode 中は閲覧（OV01/OV02）のみ許可されています。");
    }
  }

  var htmlName = code + ".html";
  var html = HtmlService.createHtmlOutputFromFile(htmlName)
    .setTitle(f.title || code)
    .setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL);

  SpreadsheetApp.getUi().showModalDialog(html, f.title || code);
}

function doGet(e) {
  var conf = CONF();
  var form = (e && e.parameter && e.parameter.form) ? String(e.parameter.form) : "";
  if (!form) form = "OV01";

  var f = (conf.forms || {})[form];
  if (!f || !f.enabled) {
    return HtmlService.createHtmlOutput("Form disabled");
  }

  if (conf.maintenanceMode === true) {
    if (form !== "OV01" && form !== "OV02") {
      logSystem_("MAINTENANCE_BLOCK", "", { form: form }, { blocked: true });
      return HtmlService.createHtmlOutput("maintenanceMode 中は閲覧（OV01/OV02）のみ許可されています。");
    }
  }

  return HtmlService.createHtmlOutputFromFile(form + ".html")
    .setTitle(f.title || form)
    .setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL);
}

function show_UF01(){ showDynamicForm("UF01"); }
function show_UF06(){ showDynamicForm("UF06"); }
function show_UF07(){ showDynamicForm("UF07"); }
function show_UF08(){ showDynamicForm("UF08"); }
function show_FIX(){  showDynamicForm("FIX"); }
function show_DOC(){  showDynamicForm("DOC"); }
function show_OV01(){ showDynamicForm("OV01"); }
function show_OV02(){ showDynamicForm("OV02"); }

// ---- RuntimeSelfTest（C の test-framework 導入）----
function runRuntimeSelfTest() {
  // master_spec: テストは formalize されているが、業務台帳・ID採番・Drive 構造などの実装はこの指示に含まれないため、
  // ここでは「起動ログ」を残し、未実装であることを明示する（推測実装禁止）。
  var conf = CONF();
  if (conf.testModeRuntime !== true) {
    throw new Error("CONFIG.testModeRuntime = true にしてから実行してください。");
  }
  logSystem_("RUNTIME_SELF_TEST_START", "", { testModeRuntime: true }, { ok: false, reason: "Not implemented in this output" });
  return { ok: false, message: "RuntimeSelfTest は master_spec に定義されていますが、この出力には業務ロジック未同梱のため未実装です。" };
}

// ---- logs/system 記録（統合）----
function logSystem_(actionType, targetId, input, result) {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getSheetByName("logs_system");
  if (!sheet) {
    sheet = ss.insertSheet("logs_system");
    sheet.appendRow(["Timestamp","操作種別","対象ID","入力内容","GAS決定値サマリ","AI違和感候補","Runtime監査結果","実行環境チェック結果"]);
  }

  var ts = new Date();
  var row = [
    ts,
    actionType || "",
    targetId || "",
    safeJson_(input),
    safeJson_((result && result.gasSummary) ? result.gasSummary : ""),
    safeJson_((result && result.aiWarnings) ? result.aiWarnings : ""),
    safeJson_((result && result.runtime) ? result.runtime : result || ""),
    safeJson_((result && result.env) ? result.env : "")
  ];
  sheet.appendRow(row);
}

function safeJson_(v) {
  try {
    if (v === null || typeof v === "undefined") return "";
    if (typeof v === "string") return v;
    return JSON.stringify(v);
  } catch (e) {
    return String(v);
  }
}

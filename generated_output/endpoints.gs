function onUF01Submit(payload) {
  // master_spec: UF01 の正式処理（AI一次解析→GAS決定→AI監査→logs/system→ClickUp通知）は GAS 実装。
  // この出力では、仕様外の推測実装を禁止するため、受信ログのみ残す。
  logSystem_("UF01_SUBMIT", "", { payload: payload }, { runtime: { ok: false, reason: "Not implemented" } });
  return { ok: false, message: "UF01 受信のみ（業務ロジック未実装）" };
}

function onUF06Submit(payload) {
  logSystem_("UF06_SUBMIT", "", { payload: payload }, { runtime: { ok: false, reason: "Not implemented" } });
  return { ok: false, message: "UF06 受信のみ（業務ロジック未実装）" };
}

function onUF07Submit(payload) {
  logSystem_("UF07_SUBMIT", "", { payload: payload }, { runtime: { ok: false, reason: "Not implemented" } });
  return { ok: false, message: "UF07 受信のみ（業務ロジック未実装）" };
}

function onUF08Submit(payload) {
  // master_spec: UF08_SUBMIT は Runtime監査 expected effect 対象（logs/system に存在すること）
  logSystem_("UF08_SUBMIT", payload && payload.orderId ? payload.orderId : "", { payload: payload }, { runtime: { ok: false, reason: "Not implemented" } });
  return { ok: false, message: "UF08 受信のみ（業務ロジック未実装）" };
}

function formSubmitFIX(payload) {
  // master_spec: Request シートへ記録（FIX_SUBMIT expected effect）
  // 推測実装を避け、Request シートの最小箱だけ作成し JSON 記録する。
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getSheetByName("Request");
  if (!sheet) {
    sheet = ss.insertSheet("Request");
    sheet.appendRow(["Timestamp","Category","TargetID","PayloadJSON","Requester","Memo"]);
  }
  sheet.appendRow([new Date(), "FIX_SUBMIT", "", safeJson_(payload), Session.getActiveUser().getEmail() || "", ""]);
  logSystem_("FIX_SUBMIT", "", { payload: payload }, { runtime: { ok: true } });
  return { ok: true };
}

function formSubmitDOC(payload) {
  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getSheetByName("Request");
  if (!sheet) {
    sheet = ss.insertSheet("Request");
    sheet.appendRow(["Timestamp","Category","TargetID","PayloadJSON","Requester","Memo"]);
  }
  sheet.appendRow([new Date(), "DOC_SUBMIT", payload && payload.orderId ? payload.orderId : "", safeJson_(payload), Session.getActiveUser().getEmail() || "", ""]);
  logSystem_("DOC_SUBMIT", payload && payload.orderId ? payload.orderId : "", { payload: payload }, { runtime: { ok: true } });
  return { ok: true };
}

function getOV01Card(req) {
  // 推測実装禁止のため、最小のビュー返却。
  var orderId = (req && req.orderId) ? String(req.orderId) : "";
  logSystem_("OV01_VIEW", orderId, { req: req }, { runtime: { ok: true } });
  return {
    orderId: orderId,
    healthyScore: null,
    aiWarnings: [],
    basicText: orderId ? ("OrderID: " + orderId + "\n（この出力では台帳検索ロジック未実装）") : "OrderID を入力してください",
    historyNotes: "",
    partsText: "",
    logsText: ""
  };
}

function searchOV02(req) {
  // 推測実装禁止のため、logs_system からの簡易検索のみ（仕様内：logs/system は検索対象）。
  var q = (req && req.query) ? String(req.query) : "";
  logSystem_("OV02_SEARCH", "", { req: req }, { runtime: { ok: true } });

  var ss = SpreadsheetApp.getActiveSpreadsheet();
  var sheet = ss.getSheetByName("logs_system");
  if (!sheet) return [];

  var values = sheet.getDataRange().getValues();
  if (values.length <= 1) return [];

  var out = [];
  for (var i = 1; i < values.length; i++) {
    var row = values[i];
    var joined = row.map(function(x){ return (x === null || typeof x === 'undefined') ? '' : String(x); }).join(' ');
    if (!q || joined.indexOf(q) !== -1) {
      out.push({
        title: String(row[1] || "") + " / " + String(row[2] || ""),
        snippet: joined.slice(0, 180),
        orderId: String(row[2] || "")
      });
      if (out.length >= 50) break;
    }
  }
  return out;
}

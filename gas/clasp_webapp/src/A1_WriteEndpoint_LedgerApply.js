/** A1: apply ledger mapping (Request / Recovery_Queue) */
function ApplyWriteEvent_(evt) {
  if (!evt) throw new Error("A1 ApplyWriteEvent_: payload is empty");
  var eventName = _a1_normStr_(evt.eventName || evt.type || evt.name);
  if (!eventName) throw new Error("A1 ApplyWriteEvent_: missing eventName/type/name");
  var allowed = { "DELETE":1,"RESTORE":1,"FREEZE":1,"RELEASE":1,"RECLAIM":1,"FIX_OPEN":1,"FIX_APPLIED":1 };
  if (!allowed[eventName]) return;
  var eventAt = _a1_normStr_(evt.eventAt || evt.occurredAt || evt.at);
  if (!eventAt) throw new Error("A1 ApplyWriteEvent_: missing eventAt/occurredAt/at");
  var idemRaw = _a1_normStr_(evt.idempotencyKey || evt.idempotency_key || evt.idempotency);
  if (!idemRaw) throw new Error("A1 ApplyWriteEvent_: missing idempotencyKey");
  var logRef = _a1_normStr_(evt.logRef || evt.log_ref || evt.log);
  if (!logRef) throw new Error("A1 ApplyWriteEvent_: missing logRef (A1 strict)");
  var idem = eventName + ":" + idemRaw;

  var requestKey = _a1_normStr_(evt.requestKey || evt.request_key);
  var rqKey      = _a1_normStr_(evt.rqKey || evt.recoveryRqKey || evt.recovery_rq_key);
  if (!requestKey && !rqKey) throw new Error("A1 ApplyWriteEvent_: missing requestKey and rqKey");

  if (requestKey) _a1_applyToLedger_({ sheetName:"Request", keyCandidates:["requestKey","request_key","RequestKey","REQUEST_KEY"], keyValue:requestKey, eventName:eventName, idempotency:idem, eventAt:eventAt, logRef:logRef });
  if (rqKey)      _a1_applyToLedger_({ sheetName:"Recovery_Queue", keyCandidates:["rqKey","recoveryRqKey","recovery_rq_key","RqKey","RQ_KEY"], keyValue:rqKey, eventName:eventName, idempotency:idem, eventAt:eventAt, logRef:logRef });
}
function _a1_applyToLedger_(ctx) {
  var ss = _a1_openLedgerSpreadsheet_();
  var sh = ss.getSheetByName(ctx.sheetName);
  if (!sh) throw new Error("A1: sheet not found: " + ctx.sheetName);
  var header = _a1_getHeader_(sh);
  var keyCol = _a1_findCol_(header, ctx.keyCandidates);
  if (!keyCol) throw new Error("A1: key column not found in " + ctx.sheetName);
  var colLastEventName = _a1_findCol_(header, ["lastEventName","last_event_name","LastEventName"]);
  var colLastIdem      = _a1_findCol_(header, ["lastIdempotencyKey","last_idempotency_key","LastIdempotencyKey"]);
  var colLastEventAt   = _a1_findCol_(header, ["lastEventAt","last_event_at","LastEventAt"]);
  var colLogRef        = _a1_findCol_(header, ["logRef","log_ref","LogRef"]);
  if (!colLastEventName || !colLastIdem || !colLastEventAt) throw new Error("A1: missing lastEventName/lastIdempotencyKey/lastEventAt in " + ctx.sheetName);
  if (!colLogRef) throw new Error("A1: missing logRef in " + ctx.sheetName);
  var row = _a1_findOrAppendRow_(sh, keyCol, ctx.keyValue);
  var prevEventName = _a1_cell_(sh, row, colLastEventName);
  var prevIdem      = _a1_cell_(sh, row, colLastIdem);
  if (_a1_normStr_(prevEventName) === ctx.eventName && _a1_normStr_(prevIdem) === ctx.idempotency) return;
  _a1_set_(sh, row, colLastEventName, ctx.eventName);
  _a1_set_(sh, row, colLastIdem,      ctx.idempotency);
  _a1_set_(sh, row, colLastEventAt,   ctx.eventAt);
  _a1_set_(sh, row, colLogRef,        ctx.logRef);
}
function _a1_openLedgerSpreadsheet_() {
  var props = PropertiesService.getScriptProperties();
  var keys = ["SPREADSHEET_ID","LEDGER_SPREADSHEET_ID","YORISOIDOU_SPREADSHEET_ID","SHEET_ID","WORKBOOK_ID"];
  var ssId = null;
  for (var i=0; i<keys.length; i++) { var v = props.getProperty(keys[i]); if (v) { ssId = v; break; } }
  if (!ssId) throw new Error("A1: missing Spreadsheet ID in Script Properties");
  return SpreadsheetApp.openById(ssId);
}
function _a1_getHeader_(sh) { var lastCol = sh.getLastColumn(); if (lastCol < 1) throw new Error("A1: no header"); return sh.getRange(1,1,1,lastCol).getValues()[0]; }
function _a1_findCol_(header, candidates) { for (var i=0;i<candidates.length;i++){ var cand=String(candidates[i]).toLowerCase(); for (var c=0;c<header.length;c++){ var h=String(header[c]||"").toLowerCase(); if (h===cand) return c+1; } } return null; }
function _a1_findOrAppendRow_(sh, keyCol, keyValue) { var lastRow=sh.getLastRow(); if (lastRow<2) lastRow=1; if (lastRow>=2){ var rng=sh.getRange(2,keyCol,lastRow-1,1).getValues(); for (var i=0;i<rng.length;i++){ if (_a1_normStr_(rng[i][0])===keyValue) return i+2; } } var newRow=sh.getLastRow()+1; if (newRow<2) newRow=2; sh.getRange(newRow,keyCol,1,1).setValue(keyValue); return newRow; }
function _a1_cell_(sh,row,col){ return sh.getRange(row,col,1,1).getValue(); }
function _a1_set_(sh,row,col,v){ sh.getRange(row,col,1,1).setValue(v); }
function _a1_normStr_(v){ if (v===null||v===undefined) return ""; return String(v).trim(); }

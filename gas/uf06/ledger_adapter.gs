/**
 * Ledger Adapter（最小）
 * - Active Spreadsheet を前提に、UF06_QUEUE（受付キュー）へ追記する。
 * - 既存台帳（Parts_Master 等）へ直接書き込まない（安全：Orchestrator に委譲）。
 */
function Ledger_getActiveSs_() {
  return SpreadsheetApp.getActiveSpreadsheet();
}
function Ledger_getSheet_(ss, name) {
  return ss.getSheetByName(name);
}
function Ledger_ensureSheetWithHeader_(ss, name, headers) {
  var sh = ss.getSheetByName(name);
  if (!sh) sh = ss.insertSheet(name);
  var lastCol = sh.getLastColumn();
  if (lastCol === 0) {
    sh.getRange(1, 1, 1, headers.length).setValues([headers]);
    return sh;
  }
  var cur = sh.getRange(1, 1, 1, Math.max(lastCol, headers.length)).getValues()[0];
  var ok = true;
  for (var i=0;i<headers.length;i++){
    if (String(cur[i]||'') !== String(headers[i])) { ok = false; break; }
  }
  if (!ok) {
    // ヘッダ不一致は破壊しない：別シートへ退避
    var alt = name + '_ALT';
    var altSh = ss.getSheetByName(alt) || ss.insertSheet(alt);
    if (altSh.getLastColumn() === 0) {
      altSh.getRange(1,1,1,headers.length).setValues([headers]);
    }
    return altSh;
  }
  return sh;
}
function Ledger_appendRow_(sh, row) {
  sh.appendRow(row);
}
function Ledger_nowIso_() {
  return new Date().toISOString();
}
function Ledger_sha1_(s) {
  var b = Utilities.computeDigest(Utilities.DigestAlgorithm.SHA_1, s, Utilities.Charset.UTF_8);
  return b.map(function(x){ var v=(x<0?x+256:x).toString(16); return (v.length===1?'0'+v:v); }).join('');
}
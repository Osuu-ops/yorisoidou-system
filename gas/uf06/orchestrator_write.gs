/**
 * Orchestrator (WRITE ON) — Phase-1 minimal
 * - 対象：UF06_QUEUE の OPEN のうち UF06_ORDER のみ
 * - 動作：OPEN -> ACCEPTED (lock) -> Parts_Master へ追記 -> PROCESSED
 * - 安全：既存ヘッダ不一致なら Parts_Master_ALT に退避（破壊しない）
 *
 * 重要：
 * - 本実装は「最小の確定書込」までを通すための第一歩。
 * - UF06_DELIVER（納品）処理は次段で実装。
 *
 * 使い方（Apps Script）：
 * - ORCH_WO_PROCESS_UF06_ORDER({limit: 20})
 */

var ORCH_WO_PARTS_SHEET_ = 'Parts_Master';

function ORCH_WO_PARTS_headers_() {
  return [
    'PART_ID',
    'Order_ID',
    'OD_ID',
    'AA',
    'mode',
    'partType',
    'partStatus',
    'maker',
    'modelNumber',
    'quantity',
    'PRICE',
    'LOCATION',
    'DELIVERED_AT',
    'CREATED_AT',
    'MEMO'
  ];
}

function ORCH_WO_nowIso_() { return new Date().toISOString(); }

function ORCH_WO_makeOrderId_() {
  var d = new Date();
  var y = d.getFullYear();
  var m = ('0' + (d.getMonth()+1)).slice(-2);
  var dd = ('0' + d.getDate()).slice(-2);
  var hh = ('0' + d.getHours()).slice(-2);
  var mm = ('0' + d.getMinutes()).slice(-2);
  var ss = ('0' + d.getSeconds()).slice(-2);
  var rnd = Ledger_sha1_(String(Math.random())).slice(0, 6);
  return 'OD-' + y + m + dd + '-' + hh + mm + ss + '-' + rnd;
}

function ORCH_WO_makePartId_() {
  var d = new Date();
  var y = d.getFullYear();
  var m = ('0' + (d.getMonth()+1)).slice(-2);
  var dd = ('0' + d.getDate()).slice(-2);
  var rnd = Ledger_sha1_(String(Math.random())).slice(0, 8);
  return 'PART-' + y + m + dd + '-' + rnd;
}

function ORCH_WO_getQueueSheet_() {
  var ss = Ledger_getActiveSs_();
  if (!ss) throw new Error('ActiveSpreadsheet is null. Use container-bound script.');
  var qHeaders = UF06_QUEUE_headers_();
  return Ledger_ensureSheetWithHeader_(ss, UF06_QUEUE_SHEET_NAME_, qHeaders);
}

function ORCH_WO_getPartsSheet_() {
  var ss = Ledger_getActiveSs_();
  if (!ss) throw new Error('ActiveSpreadsheet is null. Use container-bound script.');
  return Ledger_ensureSheetWithHeader_(ss, ORCH_WO_PARTS_SHEET_, ORCH_WO_PARTS_headers_());
}

function ORCH_WO_PROCESS_UF06_ORDER(options) {
  options = options || {};
  var limit = Number(options.limit || 20);
  if (!isFinite(limit) || limit <= 0) limit = 20;
  if (limit > 200) limit = 200;

  var q = ORCH_WO_getQueueSheet_();
  var p = ORCH_WO_getPartsSheet_();

  // queue headers and indexes
  var qh = UF06_QUEUE_headers_();
  var qi = {};
  qh.forEach(function(h, idx){ qi[h] = idx; });

  var lastRow = q.getLastRow();
  if (lastRow < 2) {
    return { ok:true, processed:0, skipped:0, reason:'QUEUE_EMPTY' };
  }

  // read all queue rows
  var values = q.getRange(2, 1, lastRow - 1, qh.length).getValues();

  var processed = 0;
  var skipped = 0;
  var details = [];

  // iterate oldest-first to keep deterministic
  for (var i=0; i<values.length && processed < limit; i++) {
    var row = values[i];
    var kind = String(row[qi.kind] || '').trim();
    var status = String(row[qi.status] || '').trim().toUpperCase();
    var payloadJson = String(row[qi.payloadJson] || '');

    if (kind !== 'UF06_ORDER') { continue; }
    if (status !== 'OPEN') { skipped++; continue; }

    // lock: OPEN -> ACCEPTED
    q.getRange(2 + i, 4).setValue('ACCEPTED'); // status col=4

    var normalized;
    try {
      normalized = JSON.parse(payloadJson);
    } catch (e) {
      // unlock decision: set REJECTED (input broken)
      q.getRange(2 + i, 4).setValue('REJECTED');
      details.push({ row: (2+i), kind: kind, status: 'REJECTED', error: 'BAD_JSON' });
      processed++;
      continue;
    }

    // one UF06_ORDER event => one Order_ID for all parts
    var orderId = ORCH_WO_makeOrderId_();
    var createdAt = ORCH_WO_nowIso_();

    var rows = Array.isArray(normalized.rows) ? normalized.rows : [];
    var totalParts = 0;

    rows.forEach(function(r){
      r = r || {};
      var parts = Array.isArray(r.parts) ? r.parts : [];
      parts.forEach(function(part){
        part = part || {};
        var mode = String(part.mode || 'NEW').toUpperCase() === 'STOCK' ? 'STOCK' : 'NEW';
        var maker = String(part.maker || '').trim();
        var modelNumber = String(part.modelNumber || '').trim();
        var qty = part.quantity == null || part.quantity === '' ? 1 : Number(part.quantity);
        if (!isFinite(qty) || qty <= 0) qty = 1;

        var partStatus = (mode === 'STOCK') ? 'DELIVERED' : 'ORDERED';
        var deliveredAt = (mode === 'STOCK') ? createdAt : '';
        var partType = 'BP'; // Phase-1最小：既定BP（BM分岐は次段）
        var price = '';
        var location = '';
        var memo = String(part.note || '').trim();
        var odId = ''; // 次段で採番統合（今は空）

        p.appendRow([
          ORCH_WO_makePartId_(),
          orderId,
          odId,
          '',             // AA（次段で採番）
          mode,
          partType,
          partStatus,
          maker,
          modelNumber,
          qty,
          price,
          location,
          deliveredAt,
          createdAt,
          memo
        ]);

        totalParts++;
      });
    });

    // finalize: ACCEPTED -> PROCESSED
    q.getRange(2 + i, 4).setValue('PROCESSED');

    details.push({ row:(2+i), orderId:orderId, parts:totalParts, status:'PROCESSED' });
    processed++;
  }

  return {
    ok: true,
    processed: processed,
    skipped: skipped,
    limit: limit,
    partsSheet: p.getName(),
    queueSheet: q.getName(),
    details: details
  };
}
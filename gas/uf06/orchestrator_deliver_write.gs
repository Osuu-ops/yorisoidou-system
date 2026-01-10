/**
 * Orchestrator (WRITE ON) — UF06_DELIVER (Phase-1 minimal)
 * - 対象：UF06_QUEUE の OPEN のうち UF06_DELIVER のみ
 * - 動作：OPEN -> ACCEPTED (lock) -> Parts_Master 更新 -> PROCESSED
 *
 * 現状の制約：
 * - selftest は partKey と Parts_Master が接続されていないため、
 *   Phase-1 は「modelNumber一致の最初の候補」を更新する（安全優先で最小）。
 *
 * 使い方（Apps Script）：
 * - ORCH_WD_PROCESS_UF06_DELIVER()
 * - ORCH_WD_PROCESS_UF06_DELIVER_LOG()（ログ出力）
 */

var ORCH_WD_PARTS_SHEET_ = 'Parts_Master';

function ORCH_WD_PROCESS_UF06_DELIVER(options) {
  options = options || {};
  var limit = Number(options.limit || 20);
  if (!isFinite(limit) || limit <= 0) limit = 20;
  if (limit > 200) limit = 200;

  var ss = Ledger_getActiveSs_();
  if (!ss) throw new Error('ActiveSpreadsheet is null. Use container-bound script.');

  var qh = UF06_QUEUE_headers_();
  var q = Ledger_ensureSheetWithHeader_(ss, UF06_QUEUE_SHEET_NAME_, qh);

  // Parts_Master: headerは orchestrator_write.gs の定義に従う（ヘッダ不一致は *_ALT に退避される）
  var ph = [
    'PART_ID','Order_ID','OD_ID','AA','mode','partType','partStatus','maker','modelNumber','quantity',
    'PRICE','LOCATION','DELIVERED_AT','CREATED_AT','MEMO'
  ];
  var p = Ledger_ensureSheetWithHeader_(ss, ORCH_WD_PARTS_SHEET_, ph);

  // indexes
  var qi = {}; qh.forEach(function(h, idx){ qi[h] = idx; });
  var pi = {}; ph.forEach(function(h, idx){ pi[h] = idx; });

  var qLast = q.getLastRow();
  if (qLast < 2) return { ok:true, processed:0, skipped:0, reason:'QUEUE_EMPTY' };

  var qVals = q.getRange(2, 1, qLast - 1, qh.length).getValues();

  // load parts (for matching)
  var pLast = p.getLastRow();
  var pVals = (pLast >= 2) ? p.getRange(2, 1, pLast - 1, ph.length).getValues() : [];

  function s(v){ return String(v == null ? '' : v).trim(); }

  var processed = 0;
  var skipped = 0;
  var details = [];

  for (var i=0; i<qVals.length && processed < limit; i++) {
    var row = qVals[i];
    var kind = s(row[qi.kind]);
    var status = s(row[qi.status]).toUpperCase();
    var payloadJson = String(row[qi.payloadJson] || '');

    if (kind !== 'UF06_DELIVER') continue;
    if (status !== 'OPEN') { skipped++; continue; }

    // lock OPEN -> ACCEPTED
    q.getRange(2 + i, 4).setValue('ACCEPTED');

    var normalized;
    try { normalized = JSON.parse(payloadJson); } catch (e) {
      // irrecoverable input broken -> REJECTED
      q.getRange(2 + i, 4).setValue('REJECTED');
      details.push({ row:(2+i), kind:kind, status:'REJECTED', error:'BAD_JSON' });
      processed++;
      continue;
    }

    var items = Array.isArray(normalized.items) ? normalized.items : [];
    var updated = 0;
    var notFound = 0;

    items.forEach(function(it){
      it = it || {};
      if (!it.checked) return; // checkedのみ処理
      var model = s(it.modelNumber);
      var deliveredAt = s(it.deliveredAt) || (new Date()).toISOString();

      // Phase-1 match: first Parts_Master row where modelNumber matches and partStatus is not DELIVERED/USED
      var hitIdx = -1;
      for (var r=0; r<pVals.length; r++) {
        var pr = pVals[r];
        var pm = s(pr[pi.modelNumber]);
        var ps = s(pr[pi.partStatus]).toUpperCase();
        if (pm && model && pm === model && ps !== 'DELIVERED' && ps !== 'USED') { hitIdx = r; break; }
      }

      if (hitIdx < 0) { notFound++; return; }

      var sheetRow = 2 + hitIdx; // because pVals starts at row2
      // Update in sheet (not only in cached pVals)
      p.getRange(sheetRow, 7).setValue('DELIVERED');         // partStatus col 7
      p.getRange(sheetRow, 13).setValue(deliveredAt);        // DELIVERED_AT col 13
      // reflect cache so subsequent items don't hit same row
      pVals[hitIdx][pi.partStatus] = 'DELIVERED';
      pVals[hitIdx][pi.DELIVERED_AT] = deliveredAt;

      updated++;
    });

    if (notFound > 0) {
      // safe behavior: unlock back to OPEN (so it can be retried after mapping improvements)
      q.getRange(2 + i, 4).setValue('OPEN');
      details.push({ row:(2+i), kind:kind, status:'OPEN', updated:updated, notFound:notFound, note:'kept OPEN (no destructive reject)' });
      processed++;
      continue;
    }

    // success: ACCEPTED -> PROCESSED
    q.getRange(2 + i, 4).setValue('PROCESSED');
    details.push({ row:(2+i), kind:kind, status:'PROCESSED', updated:updated, notFound:notFound });
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

function ORCH_WD_PROCESS_UF06_DELIVER_LOG() {
  var res = ORCH_WD_PROCESS_UF06_DELIVER({ limit: 20 });
  Logger.log(JSON.stringify(res, null, 2));
  return res;
}
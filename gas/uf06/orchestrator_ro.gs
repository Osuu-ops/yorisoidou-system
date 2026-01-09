/**
 * Orchestrator (Read-Only) for UF06_QUEUE
 * - 読み取り専用：UF06_QUEUE を集計してサマリを返す（台帳確定の書込はしない）
 * - 目的：OPEN 行の規模・偏り・直近イベントを把握して「次の確定実装」の入力にする
 *
 * 依存：
 * - Ledger_getActiveSs_ / Ledger_ensureSheetWithHeader_（ledger_adapter.gs）
 * - UF06_QUEUE_headers_ / UF06_QUEUE_SHEET_NAME_（uf06_queue.gs）
 *
 * 使い方（Apps Script）:
 * - ORCH_RO_UF06_QUEUE_SUMMARY()
 */

function ORCH_RO_UF06_QUEUE_SUMMARY(options) {
  options = options || {};
  var limit = Number(options.limit || 20);
  if (!isFinite(limit) || limit <= 0) limit = 20;
  if (limit > 200) limit = 200;

  var ss = Ledger_getActiveSs_();
  if (!ss) throw new Error('ActiveSpreadsheet is null. Run in container-bound script, or set adapter to openById.');

  var headers = UF06_QUEUE_headers_();
  var sh = Ledger_ensureSheetWithHeader_(ss, UF06_QUEUE_SHEET_NAME_, headers);

  var lastRow = sh.getLastRow();
  if (lastRow < 2) {
    return {
      ok: true,
      sheet: sh.getName(),
      rows: 0,
      counts: { OPEN:0, ACCEPTED:0, REJECTED:0, PROCESSED:0 },
      kinds: {},
      latest: []
    };
  }

  // read all data
  var values = sh.getRange(2, 1, lastRow - 1, headers.length).getValues();

  var idx = {};
  headers.forEach(function(h, i){ idx[h] = i; });

  function s(v){ return String(v == null ? '' : v); }

  var counts = { OPEN:0, ACCEPTED:0, REJECTED:0, PROCESSED:0, OTHER:0 };
  var kinds = {}; // kind -> count
  var openKinds = {}; // kind -> OPEN count

  var latest = [];
  // collect latest by receivedAt (as string, ISO preferred)
  // We'll just take last N rows by sheet order (append-only assumption).
  var start = Math.max(0, values.length - limit);
  for (var i=start;i<values.length;i++){
    var row = values[i];
    var kind = s(row[idx.kind]).trim();
    var status = s(row[idx.status]).trim().toUpperCase();
    var receivedAt = s(row[idx.receivedAt]).trim();
    var idk = s(row[idx.idempotencyKey]).trim();
    var cid = s(row[idx.customerId]).trim();
    var cname = s(row[idx.customerName]).trim();
    var city = s(row[idx.cityTown]).trim();

    if (!kinds[kind]) kinds[kind] = 0;
    kinds[kind]++;

    if (status === 'OPEN' || status === 'ACCEPTED' || status === 'REJECTED' || status === 'PROCESSED') {
      counts[status] = (counts[status] || 0) + 1;
    } else {
      counts.OTHER++;
    }

    if (status === 'OPEN') {
      if (!openKinds[kind]) openKinds[kind] = 0;
      openKinds[kind]++;
    }

    latest.push({
      receivedAt: receivedAt,
      kind: kind,
      status: status,
      idempotencyKey: idk,
      customerId: cid,
      customerName: cname,
      cityTown: city
    });
  }

  // sort latest by receivedAt desc if looks like ISO; else keep as is
  latest.sort(function(a,b){
    var ax = a.receivedAt, bx = b.receivedAt;
    // descending
    if (ax === bx) return 0;
    return (ax < bx) ? 1 : -1;
  });

  return {
    ok: true,
    sheet: sh.getName(),
    rows: values.length,
    counts: counts,
    kinds: kinds,
    openKinds: openKinds,
    latest: latest
  };
}
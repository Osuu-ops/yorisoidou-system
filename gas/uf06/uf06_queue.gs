/**
 * UF06 → Ledger 接続（安全な受付キュー方式）
 * - UF06_ORDER_normalize / UF06_DELIVER_normalize の出力を「UF06_QUEUE」へ入れる。
 * - 冪等キー（idempotencyKey）で重複を抑止（同一キーは二重追加しない）。
 *
 * NOTE:
 * - ここでは Parts_Master へ直書きしない（破壊防止）。Orchestrator がキューを消化して確定する。
 */

var UF06_QUEUE_SHEET_NAME_ = 'UF06_QUEUE';

function UF06_QUEUE_headers_() {
  return [
    'receivedAt',
    'kind',
    'idempotencyKey',
    'status',          // OPEN / ACCEPTED / REJECTED / PROCESSED（更新は後続）
    'customerId',
    'customerName',
    'cityTown',
    'payloadJson'
  ];
}

function UF06_QUEUE_submit_ORDER(normalized) {
  if (!normalized || normalized.kind !== 'UF06_ORDER_NORMALIZED') {
    return { ok:false, error:'INVALID_KIND', expected:'UF06_ORDER_NORMALIZED' };
  }
  return UF06_QUEUE_submit_('UF06_ORDER', normalized);
}

function UF06_QUEUE_submit_DELIVER(normalized) {
  if (!normalized || normalized.kind !== 'UF06_DELIVER_NORMALIZED') {
    return { ok:false, error:'INVALID_KIND', expected:'UF06_DELIVER_NORMALIZED' };
  }
  return UF06_QUEUE_submit_('UF06_DELIVER', normalized);
}

function UF06_QUEUE_submit_(eventType, normalized) {
  var ss = Ledger_getActiveSs_();
  var sh = Ledger_ensureSheetWithHeader_(ss, UF06_QUEUE_SHEET_NAME_, UF06_QUEUE_headers_());

  var receivedAt = Ledger_nowIso_();
  var payloadJson = JSON.stringify(normalized);

  // idempotencyKey: eventType + sha1(payloadJson)（順序依存を避けるため、正規化済みpayloadを使う）
  var idk = eventType + ':' + Ledger_sha1_(payloadJson);

  // 既存重複チェック（軽量：idempotencyKey列を検索）
  var lastRow = sh.getLastRow();
  if (lastRow >= 2) {
    var range = sh.getRange(2, 3, lastRow - 1, 1).getValues(); // col=3 idempotencyKey
    for (var i=0;i<range.length;i++){
      if (String(range[i][0]||'') === idk) {
        return { ok:true, duplicated:true, idempotencyKey:idk, sheet:sh.getName() };
      }
    }
  }

  // customer info（ORDERはrows[0].customer、DELIVERは無し）
  var cid = '';
  var cname = '';
  var city = '';
  try {
    if (normalized.rows && normalized.rows[0] && normalized.rows[0].customer) {
      cid = String(normalized.rows[0].customer.customerId || '');
      cname = String(normalized.rows[0].customer.name || '');
      city = String(normalized.rows[0].customer.cityTown || '');
    }
  } catch (e) {}

  Ledger_appendRow_(sh, [
    receivedAt,
    eventType,
    idk,
    'OPEN',
    cid,
    cname,
    city,
    payloadJson
  ]);

  return { ok:true, duplicated:false, idempotencyKey:idk, sheet:sh.getName() };
}
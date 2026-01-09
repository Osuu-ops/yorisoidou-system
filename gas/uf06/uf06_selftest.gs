/**
 * UF06_QUEUE SelfTest（Phase-1）
 * - 目的：Apps Script 上で UF06_QUEUE の「シート作成/追記/冪等」を最小で確認する。
 * - 破壊しない：Parts_Master 等へは一切書かない。UF06_QUEUE にのみ追記。
 *
 * 使い方：
 * - Apps Script で UF06_SELFTEST_ORDER() を実行 → UF06_QUEUE に1行入る（or duplicated=true）
 * - Apps Script で UF06_SELFTEST_DELIVER() を実行 → UF06_QUEUE に1行入る（or duplicated=true）
 */

function UF06_SELFTEST_ORDER() {
  var payload = {
    rows: [{
      customer: { name:'SELFTEST', cityTown:'TEST', customerId:'CU-TEST', section:'3' },
      parts: [
        { mode:'NEW', maker:'TOTO', modelNumber:'TKS05301J', quantity:1, aa:'', note:'selftest' }
      ]
    }]
  };
  var normalized = UF06_ORDER_normalize(payload);
  return UF06_QUEUE_submit_ORDER(normalized);
}

function UF06_SELFTEST_DELIVER() {
  var payload = {
    items: [{
      partKey:'PARTKEY-SELFTEST',
      modelNumber:'TKS05301J',
      deliveredAt:(new Date()).toISOString(),
      checked:true,
      note:'selftest'
    }]
  };
  var normalized = UF06_DELIVER_normalize(payload);
  return UF06_QUEUE_submit_DELIVER(normalized);
}

function UF06_SELFTEST_IDEMPOTENCY_ORDER() {
  var payload = {
    rows: [{
      customer: { name:'SELFTEST', cityTown:'TEST', customerId:'CU-TEST', section:'3' },
      parts: [
        { mode:'NEW', maker:'TOTO', modelNumber:'TKS05301J', quantity:1, aa:'', note:'selftest' }
      ]
    }]
  };
  var normalized = UF06_ORDER_normalize(payload);
  var r1 = UF06_QUEUE_submit_ORDER(normalized);
  var r2 = UF06_QUEUE_submit_ORDER(normalized);
  return { first:r1, second:r2 };
}
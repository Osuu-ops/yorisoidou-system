/**
 * UF06 実装（発注/納品）— Phase-1
 * - 既存の業務ロジック（台帳確定/採番/冪等/回収）へ接続するための「入口」を提供する。
 * - ここでは UI 受信と正規化のみを定義し、確定判断は Orchestrator（別層）へ委譲する。
 *
 * FIXATE（採用済み）に従う：
 * - 発注UI: 左=顧客、右=部品、複数行、一括登録
 * - 納品UI: 発注日時順、チェックで一括納品
 * - タスク名: AA最大5、超過は x/y、自由文スロットは非干渉
 */

/** UF06-ORDER: 発注（入力を受け取り、正規化して返す） */
function UF06_ORDER_normalize(payload) {
  payload = payload || {};
  var rows = Array.isArray(payload.rows) ? payload.rows : [];
  // 1行 = { customer: {...}, parts: [{...},{...} ...] } を想定（UIは自由に複数行）
  var out = rows.map(function(r){
    var c = r && r.customer ? r.customer : {};
    var parts = Array.isArray(r && r.parts) ? r.parts : [];
    return {
      customer: {
        // UI検索結果から持つ：name + cityTown + customerId（末尾）
        name: String(c.name || '').trim(),
        cityTown: String(c.cityTown || '').trim(),
        customerId: String(c.customerId || '').trim(),
        // section filter (1-5) を保持（絞り込み条件の監査用）
        section: String(c.section || '').trim()
      },
      parts: parts.map(function(p){
        p = p || {};
        return {
          mode: (String(p.mode || 'NEW').toUpperCase() === 'STOCK') ? 'STOCK' : 'NEW', // NEW or STOCK
          maker: String(p.maker || '').trim(),
          modelNumber: String(p.modelNumber || '').trim(),
          quantity: (p.quantity == null || p.quantity === '') ? 1 : Number(p.quantity),
          aa: String(p.aa || '').trim(), // STOCK選択時に AA+品番 を渡せる
          note: String(p.note || '').trim()
        };
      })
    };
  });

  return { ok:true, kind:'UF06_ORDER_NORMALIZED', rows: out };
}

/** UF06-DELIVER: 納品（対象PART候補のチェック結果を受け取り、正規化して返す） */
function UF06_DELIVER_normalize(payload) {
  payload = payload || {};
  var items = Array.isArray(payload.items) ? payload.items : [];
  // 1item = { partKey, modelNumber, deliveredAt, checked } を想定（partKeyは実装層で PART_ID 等へ解決）
  var out = items.map(function(x){
    x = x || {};
    return {
      partKey: String(x.partKey || '').trim(),
      modelNumber: String(x.modelNumber || '').trim(),
      checked: !!x.checked,
      deliveredAt: String(x.deliveredAt || '').trim(), // UI側で日時確定（空は拒否扱いはOrchestrator）
      note: String(x.note || '').trim()
    };
  });

  return { ok:true, kind:'UF06_DELIVER_NORMALIZED', items: out };
}

/** HtmlService: 発注フォーム（最低限の雛形） */
function UF06_UI_order() {
  return HtmlService.createTemplateFromFile('ui/uf06_order').evaluate().setTitle('UF06 発注');
}

/** HtmlService: 納品フォーム（最低限の雛形） */
function UF06_UI_deliver() {
  return HtmlService.createTemplateFromFile('ui/uf06_deliver').evaluate().setTitle('UF06 納品');
}

/** HtmlService include helper */
function include(filename) {
  return HtmlService.createHtmlOutputFromFile(filename).getContent();
}
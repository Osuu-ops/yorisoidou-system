/**
 * main.gs
 * master_spec 準拠：
 * - GAS が業務ロジックの唯一の正
 * - AI判断禁止（外部API連携は今回は無効：UI判断反映）
 * - forms はレスポンシブ＆checkEnvironment() 必須
 * - logs/system へ全アクション記録
 */

// ===============
// 11.1 onOpen
// ===============
function onOpen() {
  var ui = SpreadsheetApp.getUi();
  var name = (CONF_BRAND() && CONF_BRAND().name) || '業務メニュー';
  var menu = ui.createMenu(name);

  var forms = (CONF().forms || []).filter(function (f) { return !!f.enabled; });
  forms.forEach(function (f) {
    menu.addItem(f.kind + '（' + f.code + '）', 'menuShow_' + f.code);
  });

  menu.addSeparator();
  menu.addItem('整合性検査（rebuildTest）', 'rebuildTest');
  menu.addItem('Runtimeテスト（runRuntimeSelfTest）', 'runRuntimeSelfTest');

  menu.addToUi();
}

// メニュー関数（HTMLService.showModalDialog は SpreadsheetUI 前提）
function menuShow_UF01() { showDynamicForm('UF01'); }
function menuShow_UF06() { showDynamicForm('UF06'); }
function menuShow_UF07() { showDynamicForm('UF07'); }
function menuShow_UF08() { showDynamicForm('UF08'); }
function menuShow_FIX()  { showDynamicForm('FIX');  }
function menuShow_DOC()  { showDynamicForm('DOC');  }
function menuShow_OV01() { showDynamicForm('OV01'); }
function menuShow_OV02() { showDynamicForm('OV02'); }

// ===============
// 11.2 showDynamicForm
// ===============
function showDynamicForm(code) {
  var form = (CONF().forms || []).filter(function (f) { return f.code === code; })[0];
  if (!form || !form.enabled) throw new Error('Form disabled: ' + code);

  // maintenanceMode 中は閲覧/検査のみ
  if (isMaintenanceMode()) {
    var ok = (code === 'OV01' || code === 'OV02');
    if (!ok) {
      logSystem_('MAINTENANCE_BLOCK', null, { form: code }, { blocked: true });
      SpreadsheetApp.getUi().alert('maintenanceMode=true のため、このフォームは利用できません（閲覧のみ可）');
      return;
    }
  }

  var html = HtmlService.createTemplateFromFile(code).evaluate()
    .setWidth(1100)
    .setHeight(780);

  SpreadsheetApp.getUi().showModalDialog(html, form.kind + '（' + code + '）');
}

// ===============
// 11.3 doGet
// ===============
function doGet(e) {
  var code = (e && e.parameter && e.parameter.form) ? String(e.parameter.form) : 'OV01';

  var form = (CONF().forms || []).filter(function (f) { return f.code === code; })[0];
  if (!form || !form.enabled) {
    return HtmlService.createHtmlOutput('Form disabled: ' + code);
  }

  if (isMaintenanceMode()) {
    var ok = (code === 'OV01' || code === 'OV02');
    if (!ok) {
      return HtmlService.createHtmlOutput('maintenanceMode=true のため、このフォームは利用できません（閲覧のみ可）');
    }
  }

  var t = HtmlService.createTemplateFromFile(code);
  return t.evaluate();
}

function include(filename) {
  return HtmlService.createHtmlOutputFromFile(filename).getContent();
}

// =========================
// 3.x シート解決・ユーティリティ
// =========================

function getActiveSpreadsheet_() {
  return SpreadsheetApp.getActiveSpreadsheet();
}

function getSheet_(name) {
  var ss = getActiveSpreadsheet_();
  var sh = ss.getSheetByName(name);
  if (!sh) throw new Error('Sheet not found: ' + name);
  return sh;
}

function ensureSheet_(name, headers) {
  var ss = getActiveSpreadsheet_();
  var sh = ss.getSheetByName(name);
  if (!sh) sh = ss.insertSheet(name);

  var lastCol = sh.getLastColumn();
  var current = [];
  if (sh.getLastRow() >= 1 && lastCol > 0) {
    current = sh.getRange(1, 1, 1, lastCol).getValues()[0].map(String);
  }

  if (!current || current.filter(function (x) { return String(x).trim() !== ''; }).length === 0) {
    sh.getRange(1, 1, 1, headers.length).setValues([headers]);
  }
  return sh;
}

function getOrderSheetName_(dateObj) {
  var d = dateObj || new Date();
  var yyyy = Utilities.formatDate(d, CONF().timezone, 'yyyy');
  return 'Order_' + yyyy;
}

function getArchiveOrderSheetName_(dateObj) {
  var d = dateObj || new Date();
  var yyyy = Utilities.formatDate(d, CONF().timezone, 'yyyy');
  return 'Archive_Order_' + yyyy;
}

function getHeaders_(sheet) {
  var lastCol = Math.max(sheet.getLastColumn(), 1);
  var values = sheet.getRange(1, 1, 1, lastCol).getValues()[0];
  return values.map(function (v) { return String(v).trim(); });
}

function findCol_(headers, key) {
  var idx = headers.indexOf(key);
  if (idx === -1) throw new Error('Column not found: ' + key);
  return idx + 1;
}

function nowIso_() {
  return Utilities.formatDate(new Date(), CONF().timezone, "yyyy-MM-dd'T'HH:mm:ss");
}

// =========================
// 12.15 logs/system
// =========================

function getSharedDriveRoot_() {
  var conf = CONF();
  var sp = conf.storageProfiles;
  if (!sp || sp.driveType !== 'shared') throw new Error('storageProfiles.driveType must be shared');
  var name = sp.sharedDriveName;

  // Shared Drive root folder: DriveApp.getFoldersByName はマイドライブ/共有ドライブ混在のため、名称一致で探索
  var it = DriveApp.getFoldersByName(name);
  if (!it.hasNext()) throw new Error('SharedDrive folder not found by name: ' + name);
  return it.next();
}

function ensureFolder_(parent, childName) {
  var it = parent.getFoldersByName(childName);
  if (it.hasNext()) return it.next();
  return parent.createFolder(childName);
}

function getLogsSystemFolder_() {
  var root = getSharedDriveRoot_();
  var logs = ensureFolder_(root, CONF().storageProfiles.folders.logs || 'logs');
  var system = ensureFolder_(logs, 'system');
  return system;
}

function logSystem_(opType, targetId, input, result) {
  var folder = getLogsSystemFolder_();
  var ts = nowIso_();
  var obj = {
    Timestamp: ts,
    Operation: opType,
    TargetID: targetId || '',
    Input: input || null,
    Result: result || null,
    EnvCheck: { googleScriptRun: true }
  };

  var name = ts.replace(/[:]/g, '') + '__' + opType + (targetId ? ('__' + targetId) : '') + '.json';
  folder.createFile(name, JSON.stringify(obj, null, 2), MimeType.JSON);
}

// =========================
// 3.x ensureBusinessSheets
// =========================

function ensureBusinessSheets() {
  // master_spec のヘッダを正として作成/維持（不足時のみ初期作成）
  ensureSheet_(CONF().sheets.CU_MASTER, [
    'CU_ID','顧客名','カナ','区分','電話1','電話2','メール','郵便番号','住所','担当者名','注意事項','作成日','更新日','有効'
  ]);

  ensureSheet_(CONF().sheets.UP_MASTER, [
    'UP_ID','CU_ID','物件番号','物件名','郵便番号','住所','建物種別','部屋番号','管理会社','注意事項','作成日','更新日','有効'
  ]);

  ensureSheet_(getOrderSheetName_(), [
    'Order_ID','UP_ID','CU_ID','媒体コード','顧客名','電話','郵便番号','住所','addressFull','addressCityTown','希望日1','希望日2','見積金額','備考（raw全文）','summary','STATUS','CreatedAt','UpdatedAt','LastSyncedAt','HistoryNotes'
  ]);

  ensureSheet_(getArchiveOrderSheetName_(), [
    'Order_ID','UP_ID','CU_ID','媒体コード','顧客名','電話','郵便番号','住所','addressFull','addressCityTown','希望日1','希望日2','見積金額','備考（raw全文）','summary','STATUS','CreatedAt','UpdatedAt','LastSyncedAt','HistoryNotes'
  ]);

  ensureSheet_(CONF().sheets.PARTS_MASTER, [
    'PART_ID','AA番号','PA/MA番号','PART_TYPE（BP/BM）','Order_ID','OD_ID','品番','数量','メーカー','PRICE','STATUS（STOCK/ORDERED/DELIVERED/USED/STOCK_ORDERED）','CREATED_AT','DELIVERED_AT','USED_DATE','MEMO','LOCATION（在庫位置）'
  ]);

  ensureSheet_(CONF().sheets.EX_MASTER, [
    'EX_ID','Order_ID','PART_ID','AA番号','PRICE','USED_DATE','MEMO'
  ]);

  ensureSheet_(CONF().sheets.EXPENSE_MASTER, [
    'EXP_ID','Order_ID','PART_ID','CU_ID','UP_ID','PRICE','USED_DATE','CreatedAt'
  ]);

  ensureSheet_(CONF().sheets.REQUEST, [
    'Timestamp','Category','TargetID','PayloadJSON','Requester','Memo'
  ]);
}

// =========================
// 2. ID（生成はGAS：唯一の正）
// =========================

function createNewCuId_() {
  var brand = CONF_BRAND();
  var sh = getSheet_(CONF().sheets.CU_MASTER);
  var last = Math.max(sh.getLastRow() - 1, 0);
  var n = last + 1;
  var suffix = 'AA' + String(n).padStart(3, '0');
  return brand.cuPrefix + '-' + suffix;
}

function createNewUpId_(cuId) {
  var brand = CONF_BRAND();
  var sh = getSheet_(CONF().sheets.UP_MASTER);
  var headers = getHeaders_(sh);
  var colCu = findCol_(headers, 'CU_ID');
  var values = sh.getLastRow() <= 1 ? [] : sh.getRange(2, 1, sh.getLastRow() - 1, sh.getLastColumn()).getValues();

  var count = values.filter(function (r) { return String(r[colCu - 1]).trim() === String(cuId).trim(); }).length;
  var seq = String(count + 1).padStart(4, '0');

  // cuId末尾の AA### を抽出
  var m = String(cuId).match(/-([A-Z]{2}\d{3})$/);
  if (!m) throw new Error('Invalid CU_ID format: ' + cuId);
  var suffix = m[1];

  return 'UP-' + suffix + '-' + seq;
}

function createNewOrderId_(dateObj, upId) {
  var brand = CONF_BRAND();
  var d = dateObj || new Date();
  var ymd = Utilities.formatDate(d, CONF().timezone, 'yyyyMMdd');

  var sh = getSheet_(getOrderSheetName_(d));
  var headers = getHeaders_(sh);
  var colOrder = findCol_(headers, 'Order_ID');

  var rows = sh.getLastRow() <= 1 ? [] : sh.getRange(2, 1, sh.getLastRow() - 1, sh.getLastColumn()).getValues();
  var prefix = brand.orderPrefix + '-' + ymd + '-';
  var nums = rows.map(function (r) {
    var oid = String(r[colOrder - 1] || '');
    if (!oid.startsWith(prefix)) return null;
    var mm = oid.match(new RegExp('^' + brand.orderPrefix + '-' + ymd + '-(\\d{5})-'));
    return mm ? Number(mm[1]) : null;
  }).filter(function (x) { return x !== null && !isNaN(x); });

  var next = (nums.length ? Math.max.apply(null, nums) : 0) + 1;
  var seq = String(next).padStart(5, '0');

  return brand.orderPrefix + '-' + ymd + '-' + seq + '-' + upId;
}

// =========================
// 5. UF01
// =========================

function onUF01Submit(payload) {
  assertNotMaintenance('UF01');
  ensureBusinessSheets();

  var startTs = nowIso_();
  var runtime = RuntimeCheck_.start('UF01_SUBMIT', null, { start: startTs });

  try {
    // AI一次解析（今回は外部API無効：素材抽出は行わず空）
    var ai = { aiStatus: 'SKIPPED', candidates: {} };

    // GAS決定
    var decided = normalizeUF01FromForm_(payload, ai);

    // write
    var writeRes = writeOrderFromUF01_(decided);

    // expected effect: Order_YYYY に1行以上追加
    runtime.expect('ORDER_ROW_ADDED', { sheet: getOrderSheetName_(), orderId: writeRes.orderId });

    runtime.ok({ orderId: writeRes.orderId });

    logSystem_('UF01_SUBMIT', writeRes.orderId, { payload: payload, ai: ai }, { decided: decided, writeRes: writeRes, runtime: runtime.finish() });

    return { ok: true, orderId: writeRes.orderId };
  } catch (err) {
    runtime.ng({ error: String(err) });
    logSystem_('UF01_SUBMIT_ERROR', null, { payload: payload }, { error: String(err), runtime: runtime.finish() });
    throw err;
  }
}

function normalizeUF01FromForm_(payload, ai) {
  payload = payload || {};

  var rawText = String(payload.raw || '').trim();
  if (!rawText) throw new Error('raw は必須です');

  // 媒体判定（簡易：KR/MM/unknown）※推測はせず、rawに含まれる既知語のみ
  var media = 'unknown';
  if (/くらしのマーケット|kurama/i.test(rawText)) media = 'KR';
  if (/ミツモア|mitsumore/i.test(rawText)) media = 'MM';

  // 住所は GAS が保持（ここではフォーム入力値をそのまま採用し、addressCityTown は下で生成）
  var addressFull = String(payload.addressFull || '').trim();
  var name = String(payload.name || '').trim();
  var phone = String(payload.phone || '').trim();
  var postal = String(payload.postal || '').trim();

  // price は推測禁止：入力値のみ
  var price = String(payload.price || '').trim();

  // addressCityTown（GAS専権）：簡易抽出（仕様にある基準に沿って「市/区/町/村/郡」まで＋直後の町名）
  // ※Geolonia無効のため、固定辞書や外部正規化は行わない
  var addressCityTown = buildAddressCityTown_(addressFull);

  // summary（スタンプ）：UF01.html の生成値を採用
  var summary = String(payload.summary || '').trim();

  // 必須チェック（4.x 成功条件に近いが、AIではなくGAS側として最低限）
  // name/pref/city などは本来 raw からも再解析対象だが、ここでは推測補完しない

  return {
    rawText: rawText,
    media: media,
    name: name,
    phone: phone,
    postal: postal,
    addressFull: addressFull,
    addressCityTown: addressCityTown,
    preferred1: String(payload.preferred1 || '').trim(),
    preferred2: String(payload.preferred2 || '').trim(),
    priceTotal: price,
    summary: summary
  };
}

function buildAddressCityTown_(addressFull) {
  var a = String(addressFull || '').trim();
  if (!a) return '';

  // 丁目以下は含めない（最初の数字/丁目/番/号/− などで切る）
  var cut = a.split(/(\d|丁目|番地|番|号|\-|－|‐|―)/)[0];

  // 都道府県を含む場合は除去して市区町村から
  cut = cut.replace(/^(東京都|北海道|大阪府|京都府|..県)/, '');

  // 市/区/町/村/郡 の位置を探し、そこから直後の町名っぽい部分を少し含める
  // 「市」「区」「町」「村」「郡」まで含めた上で、次の文字列を最大10文字程度（丁目等は除外）
  var m = cut.match(/(.{1,20}?(市|区|町|村|郡))(.{0,10})/);
  if (!m) return cut.trim();

  var head = (m[1] || '').trim();
  var tail = (m[3] || '').trim();

  // tail の末尾を「町名」相当に収める：空白や数字が来たら止める
  tail = tail.replace(/\s.+$/, '');
  tail = tail.replace(/\d.+$/, '');

  var cityTown = (head + tail).trim();

  // 末尾に不要な記号があれば除去
  cityTown = cityTown.replace(/[\-－‐―].*$/, '').trim();

  return cityTown;
}

function writeOrderFromUF01_(decided) {
  var d = new Date();

  // CU/UP の採番と再利用（電話1/顧客名/住所）と（CU_ID＋住所）
  var cuId = upsertCustomer_(decided);
  var upId = upsertProperty_(cuId, decided);

  var orderId = createNewOrderId_(d, upId);

  var sh = getSheet_(getOrderSheetName_(d));
  var headers = getHeaders_(sh);

  var row = headers.map(function (h) {
    switch (h) {
      case 'Order_ID': return orderId;
      case 'UP_ID': return upId;
      case 'CU_ID': return cuId;
      case '媒体コード': return decided.media;
      case '顧客名': return decided.name;
      case '電話': return decided.phone;
      case '郵便番号': return decided.postal;
      case '住所': return decided.addressFull; // 互換列
      case 'addressFull': return decided.addressFull;
      case 'addressCityTown': return decided.addressCityTown;
      case '希望日1': return decided.preferred1;
      case '希望日2': return decided.preferred2;
      case '見積金額': return decided.priceTotal;
      case '備考（raw全文）': return decided.rawText;
      case 'summary': return decided.summary;
      case 'STATUS': return 'NEW';
      case 'CreatedAt': return nowIso_();
      case 'UpdatedAt': return nowIso_();
      case 'LastSyncedAt': return '';
      case 'HistoryNotes': return '';
      default: return '';
    }
  });

  sh.appendRow(row);

  return { orderId: orderId, cuId: cuId, upId: upId };
}

function upsertCustomer_(decided) {
  var sh = getSheet_(CONF().sheets.CU_MASTER);
  var headers = getHeaders_(sh);

  var colCu = findCol_(headers, 'CU_ID');
  var colName = findCol_(headers, '顧客名');
  var colPhone1 = findCol_(headers, '電話1');
  var colAddr = findCol_(headers, '住所');

  var values = sh.getLastRow() <= 1 ? [] : sh.getRange(2, 1, sh.getLastRow() - 1, sh.getLastColumn()).getValues();

  var foundRowIndex = -1;
  for (var i = 0; i < values.length; i++) {
    var r = values[i];
    var phone = String(r[colPhone1 - 1] || '').trim();
    var name = String(r[colName - 1] || '').trim();
    var addr = String(r[colAddr - 1] || '').trim();

    if ((decided.phone && phone && decided.phone === phone) ||
        (decided.name && name && decided.name === name) ||
        (decided.addressFull && addr && decided.addressFull === addr)) {
      foundRowIndex = i + 2;
      break;
    }
  }

  if (foundRowIndex !== -1) {
    var cuId = String(sh.getRange(foundRowIndex, colCu).getValue()).trim();
    // 更新日だけ更新
    var colUpdated = headers.indexOf('更新日') >= 0 ? findCol_(headers, '更新日') : null;
    if (colUpdated) sh.getRange(foundRowIndex, colUpdated).setValue(nowIso_());
    return cuId;
  }

  var cuIdNew = createNewCuId_();
  var row = headers.map(function (h) {
    switch (h) {
      case 'CU_ID': return cuIdNew;
      case '顧客名': return decided.name;
      case '電話1': return decided.phone;
      case '郵便番号': return decided.postal;
      case '住所': return decided.addressFull;
      case '作成日': return nowIso_();
      case '更新日': return nowIso_();
      case '有効': return true;
      default: return '';
    }
  });

  sh.appendRow(row);
  return cuIdNew;
}

function upsertProperty_(cuId, decided) {
  var sh = getSheet_(CONF().sheets.UP_MASTER);
  var headers = getHeaders_(sh);

  var colUp = findCol_(headers, 'UP_ID');
  var colCu = findCol_(headers, 'CU_ID');
  var colAddr = findCol_(headers, '住所');

  var values = sh.getLastRow() <= 1 ? [] : sh.getRange(2, 1, sh.getLastRow() - 1, sh.getLastColumn()).getValues();

  var foundRowIndex = -1;
  for (var i = 0; i < values.length; i++) {
    var r = values[i];
    if (String(r[colCu - 1] || '').trim() === String(cuId).trim() &&
        String(r[colAddr - 1] || '').trim() === String(decided.addressFull || '').trim()) {
      foundRowIndex = i + 2;
      break;
    }
  }

  if (foundRowIndex !== -1) {
    var upId = String(sh.getRange(foundRowIndex, colUp).getValue()).trim();
    var colUpdated = headers.indexOf('更新日') >= 0 ? findCol_(headers, '更新日') : null;
    if (colUpdated) sh.getRange(foundRowIndex, colUpdated).setValue(nowIso_());
    return upId;
  }

  var upIdNew = createNewUpId_(cuId);
  var row = headers.map(function (h) {
    switch (h) {
      case 'UP_ID': return upIdNew;
      case 'CU_ID': return cuId;
      case '住所': return decided.addressFull;
      case '郵便番号': return decided.postal;
      case '作成日': return nowIso_();
      case '更新日': return nowIso_();
      case '有効': return true;
      default: return '';
    }
  });

  sh.appendRow(row);
  return upIdNew;
}

// =========================
// 10. FIX / DOC / 7.7 UF08 / 7.6 UF07
// =========================

function formSubmitFIX(payload) {
  assertNotMaintenance('FIX');
  ensureBusinessSheets();
  var runtime = RuntimeCheck_.start('FIX_SUBMIT', null, {});

  try {
    var sh = getSheet_(CONF().sheets.REQUEST);
    sh.appendRow([
      nowIso_(),
      'FIX_SUBMIT',
      '',
      JSON.stringify(payload || {}),
      Session.getActiveUser().getEmail() || '',
      ''
    ]);

    runtime.expect('REQUEST_ROW_ADDED', { category: 'FIX_SUBMIT' });
    runtime.ok({});

    logSystem_('FIX_SUBMIT', null, { payload: payload }, { runtime: runtime.finish() });
    return { ok: true };
  } catch (err) {
    runtime.ng({ error: String(err) });
    logSystem_('FIX_SUBMIT_ERROR', null, { payload: payload }, { error: String(err), runtime: runtime.finish() });
    throw err;
  }
}

function formSubmitDOC(payload) {
  assertNotMaintenance('DOC');
  ensureBusinessSheets();
  var runtime = RuntimeCheck_.start('DOC_SUBMIT', (payload && payload.orderId) || null, {});

  try {
    var sh = getSheet_(CONF().sheets.REQUEST);
    sh.appendRow([
      nowIso_(),
      'DOC_SUBMIT',
      String((payload && payload.orderId) || ''),
      JSON.stringify(payload || {}),
      Session.getActiveUser().getEmail() || '',
      ''
    ]);

    runtime.expect('REQUEST_ROW_ADDED', { category: 'DOC_SUBMIT' });
    runtime.ok({});

    logSystem_('DOC_SUBMIT', (payload && payload.orderId) || null, { payload: payload }, { runtime: runtime.finish() });
    return { ok: true };
  } catch (err) {
    runtime.ng({ error: String(err) });
    logSystem_('DOC_SUBMIT_ERROR', (payload && payload.orderId) || null, { payload: payload }, { error: String(err), runtime: runtime.finish() });
    throw err;
  }
}

function onUF07Submit(payload) {
  assertNotMaintenance('UF07');
  ensureBusinessSheets();
  var orderId = payload && payload.orderId ? String(payload.orderId).trim() : '';
  var runtime = RuntimeCheck_.start('UF07_SUBMIT', orderId || null, {});

  try {
    if (!orderId) throw new Error('OrderID は必須です');
    var updates = (payload && payload.updates) ? payload.updates : [];
    if (!Array.isArray(updates) || updates.length === 0) throw new Error('更新対象がありません');

    var sh = getSheet_(CONF().sheets.PARTS_MASTER);
    var headers = getHeaders_(sh);
    var colPartId = findCol_(headers, 'PART_ID');
    var colPrice = findCol_(headers, 'PRICE');

    var range = sh.getLastRow() <= 1 ? null : sh.getRange(2, 1, sh.getLastRow() - 1, sh.getLastColumn());
    var values = range ? range.getValues() : [];

    var changed = 0;
    updates.forEach(function (u) {
      var pid = String(u.partId || '').trim();
      var price = String(u.price || '').trim();
      if (!pid) return;
      // PRICE 推測禁止：空なら更新しない
      if (price === '') return;

      for (var i = 0; i < values.length; i++) {
        if (String(values[i][colPartId - 1]).trim() === pid) {
          values[i][colPrice - 1] = price;
          changed++;
          break;
        }
      }
    });

    if (range && changed > 0) range.setValues(values);

    runtime.expect('PRICE_UPDATED', { changed: changed });
    runtime.ok({ changed: changed });

    logSystem_('UF07_SUBMIT', orderId, { payload: payload }, { changed: changed, runtime: runtime.finish() });
    return { ok: true, changed: changed };
  } catch (err) {
    runtime.ng({ error: String(err) });
    logSystem_('UF07_SUBMIT_ERROR', orderId || null, { payload: payload }, { error: String(err), runtime: runtime.finish() });
    throw err;
  }
}

function onUF08Submit(payload) {
  assertNotMaintenance('UF08');
  ensureBusinessSheets();
  var orderId = payload && payload.orderId ? String(payload.orderId).trim() : '';
  var runtime = RuntimeCheck_.start('UF08_SUBMIT', orderId || null, {});

  try {
    if (!orderId) throw new Error('OrderID は必須です');

    // 追加報告は Request にも記録（仕様：UF08 の JSON を Request に記録）
    var sh = getSheet_(CONF().sheets.REQUEST);
    sh.appendRow([
      nowIso_(),
      'UF08_SUBMIT',
      orderId,
      JSON.stringify(payload || {}),
      Session.getActiveUser().getEmail() || '',
      ''
    ]);

    // logs/system に UF08_SUBMIT 追加（expected effect）
    logSystem_('UF08_SUBMIT', orderId, { payload: payload }, { ok: true });

    runtime.expect('LOG_SYSTEM_WRITTEN', { op: 'UF08_SUBMIT' });
    runtime.ok({});

    return { ok: true };
  } catch (err) {
    runtime.ng({ error: String(err) });
    logSystem_('UF08_SUBMIT_ERROR', orderId || null, { payload: payload }, { error: String(err), runtime: runtime.finish() });
    throw err;
  }
}

// =========================
// 14. OV01（カルテ閲覧）
// =========================

function getOV01Data(orderId) {
  ensureBusinessSheets();
  var runtime = RuntimeCheck_.start('OV01_VIEW', orderId || null, {});

  try {
    var order = findOrderById_(orderId);
    if (!order) throw new Error('Order not found: ' + orderId);

    var cu = findById_(CONF().sheets.CU_MASTER, 'CU_ID', order.CU_ID);
    var up = findById_(CONF().sheets.UP_MASTER, 'UP_ID', order.UP_ID);
    var parts = findPartsByOrderId_(orderId);

    // 健康スコア（GAS固定ロジック：簡易）
    var health = calcHealthyScore_(order, parts);

    // HistoryNotes の Order_ID 自動リンク化（表示用加工）
    var historyHtml = linkifyOrderIds_(String(order.HistoryNotes || ''));

    // 写真/動画/ログ：Drive探索
    var drive = listOrderDriveAssets_(orderId);

    var data = {
      order: order,
      customer: cu,
      property: up,
      parts: parts,
      healthyScore: health.score,
      healthyScoreReasons: health.reasons,
      historyNotesHtml: historyHtml,
      drive: drive,
      aiWarnings: [] // 外部AI無効のため空
    };

    runtime.ok({});
    logSystem_('OV01_VIEW', orderId, { orderId: orderId }, { runtime: runtime.finish() });

    return data;
  } catch (err) {
    runtime.ng({ error: String(err) });
    logSystem_('OV01_VIEW_ERROR', orderId || null, { orderId: orderId }, { error: String(err), runtime: runtime.finish() });
    throw err;
  }
}

function findOrderById_(orderId) {
  var ss = getActiveSpreadsheet_();
  var sheets = ss.getSheets().map(function (s) { return s.getName(); });
  var orderSheets = sheets.filter(function (n) { return /^Order_\d{4}$/.test(n) || /^Archive_Order_\d{4}$/.test(n); });

  for (var i = 0; i < orderSheets.length; i++) {
    var sh = ss.getSheetByName(orderSheets[i]);
    var headers = getHeaders_(sh);
    if (headers.indexOf('Order_ID') === -1) continue;
    var col = findCol_(headers, 'Order_ID');
    var lastRow = sh.getLastRow();
    if (lastRow <= 1) continue;
    var values = sh.getRange(2, 1, lastRow - 1, sh.getLastColumn()).getValues();
    for (var r = 0; r < values.length; r++) {
      if (String(values[r][col - 1]).trim() === String(orderId).trim()) {
        return toObj_(headers, values[r]);
      }
    }
  }
  return null;
}

function findById_(sheetName, idColName, idVal) {
  if (!idVal) return null;
  var sh = getSheet_(sheetName);
  var headers = getHeaders_(sh);
  var col = findCol_(headers, idColName);
  if (sh.getLastRow() <= 1) return null;
  var values = sh.getRange(2, 1, sh.getLastRow() - 1, sh.getLastColumn()).getValues();
  for (var i = 0; i < values.length; i++) {
    if (String(values[i][col - 1]).trim() === String(idVal).trim()) {
      return toObj_(headers, values[i]);
    }
  }
  return null;
}

function findPartsByOrderId_(orderId) {
  var sh = getSheet_(CONF().sheets.PARTS_MASTER);
  var headers = getHeaders_(sh);
  var col = findCol_(headers, 'Order_ID');
  if (sh.getLastRow() <= 1) return [];
  var values = sh.getRange(2, 1, sh.getLastRow() - 1, sh.getLastColumn()).getValues();
  return values.filter(function (r) {
    return String(r[col - 1]).trim() === String(orderId).trim();
  }).map(function (r) { return toObj_(headers, r); });
}

function toObj_(headers, row) {
  var o = {};
  headers.forEach(function (h, i) { o[h] = row[i]; });
  // 互換キー（OV01で扱いやすく）
  if (o['顧客名'] && !o['CustomerName']) o['CustomerName'] = o['顧客名'];
  return o;
}

function linkifyOrderIds_(text) {
  var t = String(text || '');
  // Order_ID の形式：ORD-YYYYMMDD-00001-UP-...
  // 完全一致はせず、ORD-\d{8}-\d{5}-UP-... の先頭だけをリンク化
  return t.replace(/(ORD-\d{8}-\d{5}-UP-[A-Z]{2}\d{3}-\d{4})/g, function (m) {
    return '<a href="?form=OV01&orderId=' + encodeURIComponent(m) + '" target="_blank" rel="noopener">' + m + '</a>';
  }).replace(/\n/g, '<br>');
}

function calcHealthyScore_(order, parts) {
  var score = 100;
  var reasons = [];

  // UF01 情報欠落
  if (!String(order['顧客名'] || '').trim()) { score -= 10; reasons.push('顧客名が空'); }
  if (!String(order['addressFull'] || order['住所'] || '').trim()) { score -= 10; reasons.push('住所が空'); }

  // BPのPRICE未入力
  parts.forEach(function (p) {
    var type = String(p['PART_TYPE（BP/BM）'] || '').trim();
    var status = String(p['STATUS（STOCK/ORDERED/DELIVERED/USED/STOCK_ORDERED）'] || '').trim();
    var price = String(p['PRICE'] || '').trim();

    if (type === 'BP' && (status === 'DELIVERED' || status === 'USED') && price === '') {
      score -= 10;
      reasons.push('BP PRICE未入力: ' + String(p['PART_ID'] || ''));
    }

    // STOCK の LOCATION 欠落
    var loc = String(p['LOCATION（在庫位置）'] || '').trim();
    if (status === 'STOCK' && !loc) {
      score -= 5;
      reasons.push('STOCK LOCATION未入力: ' + String(p['PART_ID'] || ''));
    }
  });

  if (score < 0) score = 0;
  return { score: score, reasons: reasons };
}

function listOrderDriveAssets_(orderId) {
  // IDフォルダ構造（16章）を探索。
  // UI判断の folders 設定に従い、SharedDriveRoot/orders/{OrderID}/... を参照。
  var root = getSharedDriveRoot_();
  var ordersRoot = ensureFolder_(root, CONF().storageProfiles.folders.orders || 'orders');
  var it = ordersRoot.getFoldersByName(orderId);
  if (!it.hasNext()) {
    return { exists: false, orderFolderId: '', photos: {}, videos: {}, logs: {} };
  }
  var orderFolder = it.next();

  function listFilesByPath_(pathArr) {
    var f = orderFolder;
    for (var i = 0; i < pathArr.length; i++) {
      var name = pathArr[i];
      var fit = f.getFoldersByName(name);
      if (!fit.hasNext()) return [];
      f = fit.next();
    }
    var out = [];
    var files = f.getFiles();
    while (files.hasNext()) {
      var file = files.next();
      out.push({ id: file.getId(), name: file.getName(), url: file.getUrl(), mimeType: file.getMimeType() });
    }
    return out;
  }

  return {
    exists: true,
    orderFolderId: orderFolder.getId(),
    photos: {
      before: listFilesByPath_(['photos','before']),
      after: listFilesByPath_(['photos','after']),
      parts: listFilesByPath_(['photos','parts']),
      extra: listFilesByPath_(['photos','extra'])
    },
    videos: {
      before: listFilesByPath_(['videos','before']),
      after: listFilesByPath_(['videos','after']),
      inspection: listFilesByPath_(['videos','inspection'])
    },
    logs: {
      system: listFilesByPath_(['logs','system']),
      extra: listFilesByPath_(['logs','extra'])
    },
    docs: {
      docs: listFilesByPath_(['docs'])
    }
  };
}

// =========================
// 15. OV02（全文検索：簡易）
// =========================

function ov02Search(payload) {
  ensureBusinessSheets();
  var q = String((payload && payload.query) || '').trim();
  var runtime = RuntimeCheck_.start('OV02_SEARCH', null, { query: q });

  try {
    if (!q) throw new Error('検索語が空です');

    // 検索対象：Order_YYYY / Archive_Order_YYYY / logs/system（Driveファイル名＆本文）
    var hits = [];

    // 1) Order/Archive シート
    var ss = getActiveSpreadsheet_();
    var names = ss.getSheets().map(function (s) { return s.getName(); })
      .filter(function (n) { return /^Order_\d{4}$/.test(n) || /^Archive_Order_\d{4}$/.test(n); });

    names.forEach(function (n) {
      var sh = ss.getSheetByName(n);
      var headers = getHeaders_(sh);
      if (sh.getLastRow() <= 1) return;
      var values = sh.getRange(2, 1, sh.getLastRow() - 1, sh.getLastColumn()).getValues();
      for (var i = 0; i < values.length; i++) {
        var rowText = values[i].map(function (v) { return String(v || ''); }).join(' | ');
        if (rowText.indexOf(q) !== -1) {
          var obj = toObj_(headers, values[i]);
          hits.push({
            type: 'ORDER',
            orderId: String(obj.Order_ID || ''),
            title: String(obj['顧客名'] || '') + ' / ' + String(obj.addressCityTown || ''),
            snippet: rowText.slice(0, 300)
          });
        }
      }
    });

    // 2) logs/system（Drive）
    var folder = getLogsSystemFolder_();
    var files = folder.getFiles();
    while (files.hasNext()) {
      var f = files.next();
      var name = f.getName();
      var txt = '';
      try {
        txt = f.getBlob().getDataAsString('UTF-8');
      } catch (e) {
        txt = '';
      }
      if (name.indexOf(q) !== -1 || (txt && txt.indexOf(q) !== -1)) {
        hits.push({
          type: 'LOG',
          orderId: '',
          title: name,
          snippet: (txt || '').slice(0, 300),
          url: f.getUrl()
        });
      }
    }

    runtime.ok({ count: hits.length });
    logSystem_('OV02_SEARCH', null, { query: q }, { count: hits.length, runtime: runtime.finish() });

    return { ok: true, query: q, hits: hits };
  } catch (err) {
    runtime.ng({ error: String(err) });
    logSystem_('OV02_SEARCH_ERROR', null, { payload: payload }, { error: String(err), runtime: runtime.finish() });
    throw err;
  }
}

// =========================
// 12.R Runtime監査（簡易フレーム）
// =========================

var RuntimeCheck_ = (function () {
  function start(action, targetId, meta) {
    return {
      action: action,
      targetId: targetId || null,
      meta: meta || {},
      expected: [],
      unexpected: [],
      status: 'RUNNING',
      startedAt: nowIso_(),
      endedAt: null,
      expect: function (code, detail) {
        this.expected.push({ code: code, detail: detail || {} });
      },
      addUnexpected: function (code, detail) {
        this.unexpected.push({ code: code, detail: detail || {} });
      },
      ok: function (detail) {
        this.status = 'OK';
        this.detail = detail || {};
        this.endedAt = nowIso_();
      },
      ng: function (detail) {
        this.status = 'NG';
        this.detail = detail || {};
        this.endedAt = nowIso_();
      },
      finish: function () {
        return {
          action: this.action,
          targetId: this.targetId,
          meta: this.meta,
          expected: this.expected,
          unexpected: this.unexpected,
          status: this.status,
          startedAt: this.startedAt,
          endedAt: this.endedAt,
          detail: this.detail || {}
        };
      }
    };
  }

  return { start: start };
})();

// =========================
// 12.T RuntimeSelfTest（簡易：Request/logの expected effect を確認）
// =========================

function runRuntimeSelfTest() {
  ensureBusinessSheets();

  if (!CONF().testModeRuntime) {
    SpreadsheetApp.getUi().alert('CONFIG.testModeRuntime=true にしてから実行してください');
    return;
  }

  // テストID強制は本来ID体系に従い isTest=true 等が必要だが、
  // 本コードではテストデータ隔離のため「OrderIDは作らず Request/log を中心に検証」
  // （仕様外推測を避けるため最小実装）

  var ts = nowIso_();
  logSystem_('RUNTIME_SELF_TEST', null, { startedAt: ts }, { note: 'RuntimeSelfTest minimal' });

  SpreadsheetApp.getUi().alert('RuntimeSelfTest（最小）を実行しました。logs/system を確認してください');
}

// =========================
// rebuildTest（整合性検査：最低限）
// =========================

function rebuildTest() {
  ensureBusinessSheets();
  // ここでは最小：シート存在とヘッダの存在確認のみ
  var report = [];

  function checkSheet(name, requiredHeaders) {
    var sh = getSheet_(name);
    var headers = getHeaders_(sh);
    requiredHeaders.forEach(function (h) {
      if (headers.indexOf(h) === -1) {
        report.push('NG: ' + name + ' missing header: ' + h);
      }
    });
  }

  checkSheet(CONF().sheets.CU_MASTER, ['CU_ID','顧客名','電話1','住所']);
  checkSheet(CONF().sheets.UP_MASTER, ['UP_ID','CU_ID','住所']);
  checkSheet(getOrderSheetName_(), ['Order_ID','UP_ID','CU_ID','addressFull','addressCityTown','summary','HistoryNotes']);
  checkSheet(CONF().sheets.PARTS_MASTER, ['PART_ID','Order_ID','STATUS（STOCK/ORDERED/DELIVERED/USED/STOCK_ORDERED）','LOCATION（在庫位置）']);
  checkSheet(CONF().sheets.REQUEST, ['Timestamp','Category','PayloadJSON']);

  var ok = report.length === 0;
  logSystem_('REBUILD_TEST', null, { ok: ok }, { report: report });

  SpreadsheetApp.getUi().alert(ok ? 'rebuildTest: OK' : ('rebuildTest: NG\n' + report.join('\n')));
}

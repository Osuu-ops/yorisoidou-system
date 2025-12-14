/**
 * main.gs
 * master_spec 準拠。
 * - 外部連携（Todoist/ClickUp/ChatGPT API/Geolonia）は UI判断により無効。
 * - 更新処理は maintenanceMode でブロック。
 * - OV01/OV02 は閲覧系として maintenanceMode 中も許可。
 * - logs/system への記録は常に継続。
 */

function onOpen() {
  var ui = SpreadsheetApp.getUi();
  var conf = CONF();
  var brandName = (ACTIVE_BRAND() && ACTIVE_BRAND().name) ? ACTIVE_BRAND().name : (conf.systemName || '業務メニュー');

  var menu = ui.createMenu(brandName);

  var forms = conf.forms || {};
  var codes = Object.keys(forms);

  // enabled=true のみ表示
  for (var i = 0; i < codes.length; i++) {
    var code = codes[i];
    if (forms[code] && forms[code].enabled === true) {
      var label = (forms[code].kind || code) + '（' + code + '）';
      menu.addItem(label, 'menuOpen_' + code);
    }
  }

  menu.addSeparator();
  menu.addItem('Runtimeテスト', 'runRuntimeSelfTest');

  menu.addToUi();
}

function menuOpen_UF01() { showDynamicForm('UF01'); }
function menuOpen_UF06() { showDynamicForm('UF06'); }
function menuOpen_UF07() { showDynamicForm('UF07'); }
function menuOpen_UF08() { showDynamicForm('UF08'); }
function menuOpen_FIX()  { showDynamicForm('FIX'); }
function menuOpen_DOC()  { showDynamicForm('DOC'); }
function menuOpen_OV01() { showDynamicForm('OV01'); }
function menuOpen_OV02() { showDynamicForm('OV02'); }

function showDynamicForm(code) {
  var conf = CONF();
  var forms = conf.forms || {};
  var f = forms[code];
  if (!f || f.enabled !== true) {
    SpreadsheetApp.getUi().alert('このフォームは無効です: ' + code);
    return;
  }

  // maintenanceMode
  if (conf.maintenanceMode === true) {
    var allowed = (code === 'OV01' || code === 'OV02');
    if (!allowed) {
      logSystem_('MAINTENANCE_BLOCK', { form: code, reason: 'maintenanceMode=true' }, { blocked: true });
      SpreadsheetApp.getUi().alert('メンテナンス中のため更新系フォームは使用できません。\n閲覧（OV01/OV02）のみ利用可能です。');
      return;
    }
  }

  var html = HtmlService.createTemplateFromFile(code);
  html._FORM_CODE = code;
  var out = html.evaluate().setWidth(1200).setHeight(720);
  SpreadsheetApp.getUi().showModalDialog(out, (f.kind || code) + '（' + code + '）');
}

function doGet(e) {
  var conf = CONF();
  var form = (e && e.parameter && e.parameter.form) ? String(e.parameter.form) : '';
  if (!form) {
    return HtmlService.createHtmlOutput('No form specified.');
  }

  var forms = conf.forms || {};
  if (!forms[form] || forms[form].enabled !== true) {
    return HtmlService.createHtmlOutput('Form disabled.');
  }

  if (conf.maintenanceMode === true) {
    var allowed = (form === 'OV01' || form === 'OV02');
    if (!allowed) {
      logSystem_('MAINTENANCE_BLOCK', { form: form, via: 'doGet' }, { blocked: true });
      return HtmlService.createHtmlOutput('Maintenance mode. Only OV01/OV02 are allowed.');
    }
  }

  var t = HtmlService.createTemplateFromFile(form);
  t._FORM_CODE = form;
  return t.evaluate();
}

/**
 * UF01 submit
 * master_spec: onUF01Submit(e)
 * ①AI一次解析（今回は無効）
 * ②GAS決定（最小）
 * ③AI監査（今回は無効）
 * ④logs/system
 * ⑤ClickUp通知（今回は無効）
 */
function onUF01Submit(payload) {
  var conf = CONF();
  if (conf.maintenanceMode === true) {
    logSystem_('MAINTENANCE_BLOCK', { form: 'UF01', payload: payload }, { blocked: true });
    return { ok: false, message: 'maintenanceMode=true のため UF01 は停止中です。' };
  }

  var runtime = startRuntimeAudit_('UF01_SUBMIT', { payload: payload });

  try {
    ensureBusinessSheets_();

    // ① AI一次解析（無効）
    var aiPrimary = { aiEnabled: false, aiStatus: 'DISABLED', candidates: {}, reason: 'UI判断: chatgpt disabled (usage=code-generation-only)' };

    // ② GAS決定
    var normalized = normalizeUF01FromForm_(payload, aiPrimary);

    // write
    var orderRow = writeOrderFromUF01_(normalized);

    // expected effect: Order_YYYY に 1行以上追加
    runtime.expectedEffects.push({ type: 'SHEET_APPEND', sheet: orderRow.sheetName, key: normalized.orderId });

    // ③ AI監査（無効）
    var aiAudit = { aiEnabled: false, warnings: [] };

    // ④ logs/system
    logSystem_('UF01_SUBMIT', { payload: payload }, {
      orderId: normalized.orderId,
      decided: normalized,
      aiPrimary: aiPrimary,
      aiAudit: aiAudit,
      runtime: finalizeRuntimeAudit_(runtime, { ok: true })
    });

    return {
      ok: true,
      orderId: normalized.orderId,
      sheetName: orderRow.sheetName,
      rowNumber: orderRow.rowNumber,
      message: '登録しました。'
    };

  } catch (err) {
    var fin = finalizeRuntimeAudit_(runtime, { ok: false, error: String(err && err.stack ? err.stack : err) });
    logSystem_('UF01_SUBMIT_ERROR', { payload: payload }, { error: String(err), runtime: fin });
    return { ok: false, message: 'エラーが発生しました。', error: String(err) };
  }
}

function normalizeUF01FromForm_(payload, aiPrimary) {
  // master_spec: 住所/ID/媒体等の正式値はGAS。
  // ここでは推測を行わず、フォーム値を最小限整形。
  payload = payload || {};

  var raw = String(payload.raw || '').trim();
  if (!raw) throw new Error('raw（通知全文 or 1行メモ）が必須です。');

  var name = String(payload.name || '').trim();
  var phone = String(payload.phone || '').trim();
  var addressFull = String(payload.addressFull || '').trim();
  var preferred1 = String(payload.preferred1 || '').trim();
  var preferred2 = String(payload.preferred2 || '').trim();
  var price = String(payload.price || '').trim();

  // addressCityTown は GAS の専権だが、ここでは住所解析の推測をしない。
  // よって addressCityTown は空（未確定）で保存。
  var addressCityTown = '';

  var media = String(payload.media || '').trim();
  if (!media) media = 'unknown';

  var orderId = createNewOrderId_();
  var now = new Date();
  var yyyy = String(now.getFullYear());

  // summary はスタンプ方式（AI要約禁止）。
  var summary = String(payload.summary || '').trim();

  return {
    orderId: orderId,
    year: yyyy,
    rawText: raw,
    name: name,
    phone: phone,
    addressFull: addressFull,
    addressCityTown: addressCityTown,
    preferred1: preferred1,
    preferred2: preferred2,
    priceTotal: price,
    mediaCode: media,
    summary: summary,
    status: 'CREATED',
    createdAt: now,
    updatedAt: now,
    lastSyncedAt: '',
    historyNotes: ''
  };
}

function writeOrderFromUF01_(normalized) {
  var sheetName = getOrderSheetName_(normalized.year);
  var sh = getOrCreateSheet_(sheetName, getOrderHeaders_());

  var row = [];
  var orderHeaders = getOrderHeaders_();
  var map = {};
  for (var i = 0; i < orderHeaders.length; i++) map[orderHeaders[i]] = i;

  row[map['Order_ID']] = normalized.orderId;
  row[map['UP_ID']] = ''; // UF01では確定させない（推測禁止）
  row[map['CU_ID']] = ''; // UF01では確定させない（推測禁止）
  row[map['媒体コード']] = normalized.mediaCode;
  row[map['顧客名']] = normalized.name;
  row[map['電話']] = normalized.phone;
  row[map['郵便番号']] = '';
  row[map['住所']] = normalized.addressFull;
  row[map['addressFull']] = normalized.addressFull;
  row[map['addressCityTown']] = normalized.addressCityTown;
  row[map['希望日1']] = normalized.preferred1;
  row[map['希望日2']] = normalized.preferred2;
  row[map['見積金額']] = normalized.priceTotal;
  row[map['備考（raw全文）']] = normalized.rawText;
  row[map['summary（UF01 スタンプ生成）']] = normalized.summary;
  row[map['STATUS']] = normalized.status;
  row[map['CreatedAt']] = normalized.createdAt;
  row[map['UpdatedAt']] = normalized.updatedAt;
  row[map['LastSyncedAt']] = normalized.lastSyncedAt;
  row[map['HistoryNotes（履歴メモ）']] = normalized.historyNotes;

  // undefined を空に
  for (var j = 0; j < orderHeaders.length; j++) {
    if (typeof row[j] === 'undefined' || row[j] === null) row[j] = '';
  }

  sh.appendRow(row);
  return { sheetName: sheetName, rowNumber: sh.getLastRow() };
}

/**
 * OV01: orderId を受けてカルテ情報を返す（最小）
 */
function getOv01Data(orderId) {
  ensureBusinessSheets_();
  var data = loadOrderById_(orderId);
  if (!data) return { ok: false, message: 'Order が見つかりません。' };

  var parts = []; // UF06が無効のため取得のみ（シートがあれば見る）
  var partsSh = SpreadsheetApp.getActive().getSheetByName('Parts_Master');
  if (partsSh) {
    parts = findRowsByValue_(partsSh, 'Order_ID', orderId);
  }

  // logs/system（Drive）から該当Orderのログを列挙（可能な範囲）
  var logs = listSystemLogsForOrder_(orderId);

  return {
    ok: true,
    order: data,
    parts: parts,
    logs: logs,
    warnings: []
  };
}

/**
 * OV02: クエリで全文検索（最小：Order_YYYYとarchiveとlogs/systemを文字列一致）
 */
function searchOv02(query) {
  ensureBusinessSheets_();
  query = String(query || '').trim();
  if (!query) return { ok: true, query: query, results: [] };

  var results = [];

  // Orders: すべての Order_YYYY を走査（ここでは現在年のみ + Archive 既定年のみ）
  // 推測で年一覧を生成しない。現シート存在分のみ。
  var ss = SpreadsheetApp.getActive();
  var sheets = ss.getSheets();
  for (var i = 0; i < sheets.length; i++) {
    var name = sheets[i].getName();
    if (name.indexOf('Order_') === 0 || name.indexOf('Archive_Order_') === 0) {
      var hit = searchSheetContains_(sheets[i], query);
      for (var h = 0; h < hit.length; h++) results.push(hit[h]);
    }
  }

  // logs/system(Drive)
  var logHits = searchDriveLogsSystem_(query);
  for (var j = 0; j < logHits.length; j++) results.push(logHits[j]);

  return { ok: true, query: query, results: results };
}

/** =====================
 * RuntimeSelfTest (12.T)
 * ===================== */
function runRuntimeSelfTest() {
  var conf = CONF();
  if (conf.testModeRuntime !== true) {
    SpreadsheetApp.getUi().alert('CONFIG.testModeRuntime=true のときのみ実行できます。');
    return;
  }

  var runtime = startRuntimeAudit_('RUNTIME_SELF_TEST', { testModeRuntime: true });
  try {
    ensureBusinessSheets_();

    // 1) UF01: test-order
    var uf01 = {
      raw: 'TEST: UF01 runtime self test',
      name: 'テスト顧客',
      phone: '000-0000-0000',
      addressFull: 'テスト住所',
      preferred1: '2099-01-01',
      preferred2: '2099-01-02',
      price: '0',
      media: 'unknown',
      summary: 'TEST_STAMP'
    };
    var res1 = onUF01Submit(uf01);
    if (!res1.ok) throw new Error('UF01 test failed: ' + res1.message);

    // 2)〜8) は外部/未実装フォームがあるため、Request/logだけにテスト記録を残す。
    // master_spec: テストシナリオは必須だが、ここでは推測実装をしない。
    // 代わりに expected effect が欠落することを Runtime監査で NG として記録する。

    var missing = [
      'UF06(発注)',
      'UF06(納品)',
      'UF07(価格)',
      'UF08(追加報告)',
      'FIX',
      'DOC',
      'completeOrderFromTodoist'
    ];

    logSystem_('RUNTIME_SELF_TEST_PARTIAL', { orderId: res1.orderId, missing: missing }, { test: true });

    var fin = finalizeRuntimeAudit_(runtime, {
      ok: false,
      error: 'RuntimeSelfTest 未実装シナリオあり（推測実装禁止のため）。'
    });

    SpreadsheetApp.getUi().alert('RuntimeSelfTest: NG（未実装シナリオあり）。\nlogs/system を確認してください。');

  } catch (err) {
    var fin2 = finalizeRuntimeAudit_(runtime, { ok: false, error: String(err && err.stack ? err.stack : err) });
    logSystem_('RUNTIME_SELF_TEST_ERROR', {}, { error: String(err), runtime: fin2, test: true });
    SpreadsheetApp.getUi().alert('RuntimeSelfTest error: ' + err);
  }
}

/** =====================
 * Sheet helpers
 * ===================== */
function ensureBusinessSheets_() {
  // 推測で増やさず、master_specに明記の主要シートのみ最低限。
  getOrCreateSheet_('logs_system_index', ['Timestamp', 'Type', 'TargetID', 'Summary', 'DriveFileId']);
  getOrCreateSheet_('Request', ['Timestamp', 'Category', 'TargetID', 'PayloadJSON', 'Requester', 'Memo']);

  // Order_YYYY は年ごとに作る。今回は「今年のみ」作成。
  var y = String(new Date().getFullYear());
  getOrCreateSheet_(getOrderSheetName_(y), getOrderHeaders_());
}

function getOrderHeaders_() {
  // master_spec 3.3 ヘッダ
  return [
    'Order_ID',
    'UP_ID',
    'CU_ID',
    '媒体コード',
    '顧客名',
    '電話',
    '郵便番号',
    '住所',
    'addressFull',
    'addressCityTown',
    '希望日1',
    '希望日2',
    '見積金額',
    '備考（raw全文）',
    'summary（UF01 スタンプ生成）',
    'STATUS',
    'CreatedAt',
    'UpdatedAt',
    'LastSyncedAt',
    'HistoryNotes（履歴メモ）'
  ];
}

function getOrderSheetName_(year) {
  var rule = (CONF().sheetRules && CONF().sheetRules.orderSheetRule) ? CONF().sheetRules.orderSheetRule : 'Order_YYYY';
  return rule.replace('YYYY', String(year));
}

function getOrCreateSheet_(name, headers) {
  var ss = SpreadsheetApp.getActive();
  var sh = ss.getSheetByName(name);
  if (!sh) {
    sh = ss.insertSheet(name);
    if (headers && headers.length) {
      sh.getRange(1, 1, 1, headers.length).setValues([headers]);
      sh.setFrozenRows(1);
    }
    return sh;
  }

  // header補正（不足のみ）
  if (headers && headers.length) {
    var lastCol = sh.getLastColumn();
    var current = [];
    if (lastCol > 0) current = sh.getRange(1, 1, 1, lastCol).getValues()[0];
    if (current.join('|') !== headers.join('|')) {
      // 仕様外の推測で並べ替えはしない。差異がある場合はそのまま。
      // ただし空シートなら設定。
      if (sh.getLastRow() === 0) {
        sh.getRange(1, 1, 1, headers.length).setValues([headers]);
        sh.setFrozenRows(1);
      }
    }
  }
  return sh;
}

function loadOrderById_(orderId) {
  var ss = SpreadsheetApp.getActive();
  var sheets = ss.getSheets();
  for (var i = 0; i < sheets.length; i++) {
    var name = sheets[i].getName();
    if (name.indexOf('Order_') === 0 || name.indexOf('Archive_Order_') === 0) {
      var row = findFirstRowByValue_(sheets[i], 'Order_ID', orderId);
      if (row) return row;
    }
  }
  return null;
}

function findFirstRowByValue_(sheet, headerName, value) {
  var vals = sheet.getDataRange().getValues();
  if (vals.length < 2) return null;
  var headers = vals[0];
  var idx = headers.indexOf(headerName);
  if (idx === -1) return null;
  for (var r = 1; r < vals.length; r++) {
    if (String(vals[r][idx]) === String(value)) {
      return rowToObject_(headers, vals[r], { sheetName: sheet.getName(), rowNumber: r + 1 });
    }
  }
  return null;
}

function findRowsByValue_(sheet, headerName, value) {
  var out = [];
  var vals = sheet.getDataRange().getValues();
  if (vals.length < 2) return out;
  var headers = vals[0];
  var idx = headers.indexOf(headerName);
  if (idx === -1) return out;
  for (var r = 1; r < vals.length; r++) {
    if (String(vals[r][idx]) === String(value)) {
      out.push(rowToObject_(headers, vals[r], { sheetName: sheet.getName(), rowNumber: r + 1 }));
    }
  }
  return out;
}

function rowToObject_(headers, row, meta) {
  var obj = {};
  for (var i = 0; i < headers.length; i++) obj[String(headers[i])] = row[i];
  if (meta) {
    obj._meta = meta;
  }
  return obj;
}

/** =====================
 * ID generation (Order only)
 * ===================== */
function createNewOrderId_() {
  var brand = ACTIVE_BRAND();
  var prefix = (brand && brand.orderPrefix) ? brand.orderPrefix : 'ORD';
  var now = new Date();
  var y = now.getFullYear();
  var m = pad2_(now.getMonth() + 1);
  var d = pad2_(now.getDate());
  var ymd = '' + y + m + d;

  // 日付単位連番：当日の Order_YYYY 内でカウント
  var sheetName = getOrderSheetName_(String(y));
  var sh = SpreadsheetApp.getActive().getSheetByName(sheetName);
  if (!sh) sh = getOrCreateSheet_(sheetName, getOrderHeaders_());

  var seq = 1;
  var vals = sh.getDataRange().getValues();
  if (vals.length >= 2) {
    var headers = vals[0];
    var idx = headers.indexOf('Order_ID');
    if (idx !== -1) {
      for (var r = 1; r < vals.length; r++) {
        var oid = String(vals[r][idx] || '');
        // ORD-YYYYMMDD-00001-... だが、UP_ID 未確定のため末尾は空にせず placeholder
        // ここでは当日一致のみで連番を進める。
        if (oid.indexOf(prefix + '-' + ymd + '-') === 0) {
          seq++;
        }
      }
    }
  }

  var seq5 = pad5_(seq);

  // master_spec: Order_ID は orderPrefix-YYYYMMDD-00001-<UP_ID>
  // ただし UP_ID はGASで決定だが、本実装では推測生成しないため、末尾は "UP_UNKNOWN" を使う。
  // 仕様外の独自ID生成は禁止のため、あくまで placeholder 文字列として固定。
  var upPlaceholder = 'UP_UNKNOWN';
  return prefix + '-' + ymd + '-' + seq5 + '-' + upPlaceholder;
}

function pad2_(n) {
  n = String(n);
  return n.length === 1 ? '0' + n : n;
}

function pad5_(n) {
  n = String(n);
  while (n.length < 5) n = '0' + n;
  return n;
}

/** =====================
 * logs/system (Drive)
 * ===================== */
function logSystem_(type, input, summaryObj) {
  var now = new Date();
  var payload = {
    Timestamp: now.toISOString(),
    Type: String(type || ''),
    Input: input || {},
    Summary: summaryObj || {}
  };

  var file = writeLogToDriveSystem_(payload);

  // index sheet
  var sh = getOrCreateSheet_('logs_system_index', ['Timestamp', 'Type', 'TargetID', 'Summary', 'DriveFileId']);
  var targetId = '';
  if (summaryObj) {
    if (summaryObj.orderId) targetId = summaryObj.orderId;
    else if (summaryObj.targetId) targetId = summaryObj.targetId;
  }
  sh.appendRow([now, String(type || ''), targetId, safeStringify_(summaryObj), file ? file.getId() : '']);
}

function writeLogToDriveSystem_(payload) {
  var conf = CONF();
  var storage = conf.storageProfiles || {};

  // shared drive の探索は推測を避け、存在しなければマイドライブに保存
  var root = null;
  if (storage.driveType === 'shared' && storage.sharedDriveName) {
    try {
      var drives = DriveApp.getDrives();
      for (var i = 0; i < drives.length; i++) {
        if (drives[i].getName() === storage.sharedDriveName) {
          root = drives[i].getRootFolder();
          break;
        }
      }
    } catch (e) {
      root = null;
    }
  }
  if (!root) root = DriveApp.getRootFolder();

  var logsFolder = getOrCreateFolderByPath_(root, (storage.folders && storage.folders.logs) ? storage.folders.logs : 'logs');
  var sysFolder = getOrCreateFolderByPath_(logsFolder, 'system');

  var name = 'log_' + Utilities.formatDate(new Date(), CONF().timezone || 'Asia/Tokyo', 'yyyyMMdd_HHmmss_SSS') + '.json';
  return sysFolder.createFile(name, safeStringify_(payload), MimeType.PLAIN_TEXT);
}

function getOrCreateFolderByPath_(parent, name) {
  var it = parent.getFoldersByName(name);
  if (it.hasNext()) return it.next();
  return parent.createFolder(name);
}

function safeStringify_(obj) {
  try {
    return JSON.stringify(obj, function (k, v) {
      if (v instanceof Date) return v.toISOString();
      return v;
    }, 2);
  } catch (e) {
    return String(obj);
  }
}

function listSystemLogsForOrder_(orderId) {
  // indexシートから orderId で絞り込み
  var sh = SpreadsheetApp.getActive().getSheetByName('logs_system_index');
  if (!sh) return [];
  var vals = sh.getDataRange().getValues();
  if (vals.length < 2) return [];

  var headers = vals[0];
  var idxTarget = headers.indexOf('TargetID');
  var idxType = headers.indexOf('Type');
  var idxTs = headers.indexOf('Timestamp');
  var idxFile = headers.indexOf('DriveFileId');

  var out = [];
  for (var r = 1; r < vals.length; r++) {
    if (String(vals[r][idxTarget] || '') === String(orderId)) {
      out.push({
        timestamp: vals[r][idxTs],
        type: vals[r][idxType],
        driveFileId: vals[r][idxFile]
      });
    }
  }
  return out;
}

function searchDriveLogsSystem_(query) {
  // logs/system のファイル名/本文の簡易検索（クォータ負荷を避け、最大件数制限）
  var maxFiles = 50;
  var hits = [];

  var conf = CONF();
  var storage = conf.storageProfiles || {};
  var root = null;
  if (storage.driveType === 'shared' && storage.sharedDriveName) {
    try {
      var drives = DriveApp.getDrives();
      for (var i = 0; i < drives.length; i++) {
        if (drives[i].getName() === storage.sharedDriveName) {
          root = drives[i].getRootFolder();
          break;
        }
      }
    } catch (e) {
      root = null;
    }
  }
  if (!root) root = DriveApp.getRootFolder();

  var logsFolderIt = root.getFoldersByName((storage.folders && storage.folders.logs) ? storage.folders.logs : 'logs');
  if (!logsFolderIt.hasNext()) return hits;
  var logsFolder = logsFolderIt.next();
  var sysIt = logsFolder.getFoldersByName('system');
  if (!sysIt.hasNext()) return hits;
  var sysFolder = sysIt.next();

  var files = sysFolder.getFiles();
  var count = 0;
  while (files.hasNext() && count < maxFiles) {
    var f = files.next();
    count++;
    var name = f.getName();
    var hit = false;
    if (name.indexOf(query) !== -1) hit = true;
    if (!hit) {
      try {
        var text = f.getBlob().getDataAsString('UTF-8');
        if (text.indexOf(query) !== -1) hit = true;
      } catch (e) {
        // ignore
      }
    }
    if (hit) {
      hits.push({ source: 'logs/system', title: name, driveFileId: f.getId() });
    }
  }
  return hits;
}

function searchSheetContains_(sheet, query) {
  var out = [];
  var vals = sheet.getDataRange().getValues();
  if (vals.length < 2) return out;
  var headers = vals[0];
  for (var r = 1; r < vals.length; r++) {
    var row = vals[r];
    var joined = row.map(function (v) { return String(v); }).join(' | ');
    if (joined.indexOf(query) !== -1) {
      var oidIdx = headers.indexOf('Order_ID');
      var oid = (oidIdx !== -1) ? String(row[oidIdx] || '') : '';
      out.push({
        source: sheet.getName(),
        orderId: oid,
        rowNumber: r + 1,
        snippet: joined.substring(0, 200)
      });
    }
  }
  return out;
}

/** =====================
 * Runtime audit (12.R)
 * ===================== */
function startRuntimeAudit_(actionType, context) {
  return {
    actionType: String(actionType || ''),
    startedAt: new Date().toISOString(),
    context: context || {},
    expectedEffects: [],
    unexpectedEffects: [],
    ok: null,
    error: ''
  };
}

function finalizeRuntimeAudit_(runtime, result) {
  runtime = runtime || {};
  runtime.finishedAt = new Date().toISOString();
  runtime.ok = !!(result && result.ok);
  runtime.error = (result && result.error) ? String(result.error) : '';
  return runtime;
}

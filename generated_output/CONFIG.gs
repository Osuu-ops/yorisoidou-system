/**
 * CONFIG.gs
 * master_spec 準拠。推測禁止。
 * ※UI判断により外部連携（Todoist/ClickUp/Geolonia）は今回は無効。
 */

function CONF() {
  return getConfig_();
}

function getConfig_() {
  var ui = {
    mode: 'full',
    assumptions: {
      brandProfiles: {
        activeBrand: 'default',
        brands: [
          {
            id: 'default',
            name: 'よりそい堂',
            orderPrefix: 'ORD',
            customerPrefix: 'CUS',
            expensePrefix: 'EXP',
            sheetMapping: {
              orders: 'Order_YYYY',
              customers: 'Customer_Master',
              expenses: 'Expense_Master'
            }
          }
        ]
      },
      storageProfiles: {
        driveType: 'shared',
        sharedDriveName: 'Yorisoidou_Main_Drive',
        folders: {
          orders: 'orders',
          archive: 'archive',
          logs: 'logs',
          photos: 'photos'
        }
      },
      externalIntegrations: {
        todoist: { enabled: false, note: '将来統合予定。今回は無効' },
        clickup: { enabled: false, note: '将来統合予定。今回は無効' },
        chatgpt: { model: 'gpt-5.2', usage: 'code-generation-only' },
        gelonia: { enabled: false }
      },
      spreadsheetStructure: {
        orderSheetRule: 'Order_YYYY',
        archiveSheetRule: 'Archive_Order_YYYY',
        logStorage: 'Drive'
      },
      webConfiguration: {
        webAppMode: 'doGet',
        uiType: 'SpreadsheetUI',
        executionUser: 'access-user'
      }
    },
    integrationPolicy: {
      masterSpecPriority: true,
      doNotOverwriteMaster: true,
      allowTemporaryAssumptions: true
    },
    note: 'ERROR.txt の T 監査指摘に基づく暫定 input。全項目は full 生成を止めないための仮定値。'
  };

  return {
    systemName: 'よりそい堂 業務自動化システム',
    timezone: 'Asia/Tokyo',

    // master_spec: maintenanceMode
    maintenanceMode: false,

    // Runtimeテスト
    testModeRuntime: false,

    // 役割（簡易）
    roles: [
      'guest',
      'viewer',
      'operator',
      'staff',
      'manager',
      'admin',
      'config-admin-primary',
      'config-admin-secondary'
    ],

    // UI判断を格納（仕様に反しない範囲で参照する）
    uiJudgement: ui,

    // ブランド（暫定：UI判断の activeBrand を反映）
    activeBrand: ui.assumptions.brandProfiles.activeBrand,

    // フォーム（enabled 管理）
    forms: {
      UF01: { code: 'UF01', kind: '受注フォーム', enabled: true },
      UF06: { code: 'UF06', kind: '発注／納品フォーム', enabled: false },
      UF07: { code: 'UF07', kind: '価格入力フォーム', enabled: false },
      UF08: { code: 'UF08', kind: '追加報告フォーム', enabled: false },
      FIX: { code: 'FIX', kind: '修正フォーム', enabled: false },
      DOC: { code: 'DOC', kind: '書類フォーム', enabled: false },
      OV01: { code: 'OV01', kind: '閲覧フォーム', enabled: true },
      OV02: { code: 'OV02', kind: '全文検索フォーム', enabled: true }
    },

    // シート名ルール（UI判断を反映）
    sheetRules: {
      orderSheetRule: ui.assumptions.spreadsheetStructure.orderSheetRule,
      archiveSheetRule: ui.assumptions.spreadsheetStructure.archiveSheetRule
    },

    // Drive（UI判断を反映）
    storageProfiles: ui.assumptions.storageProfiles,

    // 外部連携（UI判断を反映：今回は無効）
    externalIntegrations: ui.assumptions.externalIntegrations
  };
}

function applyActiveBrand_() {
  // master_spec: applyActiveBrand() により CONF() 経由で利用される。
  // ただし UI判断は暫定値のため、ここでは最小限。
  var conf = getConfig_();
  var brands = conf.uiJudgement.assumptions.brandProfiles.brands || [];
  var activeId = conf.activeBrand;
  var active = null;
  for (var i = 0; i < brands.length; i++) {
    if (brands[i].id === activeId) active = brands[i];
  }
  if (!active) {
    active = brands[0] || { id: 'default', name: 'よりそい堂', orderPrefix: 'ORD', customerPrefix: 'CUS', expensePrefix: 'EXP', sheetMapping: {} };
  }
  conf.brandProfiles = {
    active: active
  };
  return conf;
}

function ACTIVE_BRAND() {
  return applyActiveBrand_().brandProfiles.active;
}

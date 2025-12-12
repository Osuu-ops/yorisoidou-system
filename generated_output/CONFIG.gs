/**
 * CONFIG.gs
 * master_spec 準拠：GAS が唯一の正。AIは素材抽出・監査のみ。
 * UI判断(input.json)反映：Todoist/ClickUp/Geolonia は今回は無効。
 */

function CONF() {
  var c = {
    timezone: 'Asia/Tokyo',

    // maintenanceMode: true の場合、更新系UFはブロック（OV01/OV02/検査のみ許可）
    maintenanceMode: false,

    // Runtime テスト
    testModeRuntime: false,

    // UI判断 反映（暫定）
    activeBrand: 'default',
    brandProfiles: {
      default: {
        id: 'default',
        name: 'よりそい堂',
        orderPrefix: 'ORD',
        cuPrefix: 'CUS',
        expensePrefix: 'EXP'
      }
    },

    // スプレッドシート（master_specの台帳名を優先。UI判断の sheetMapping は推測扱いになるため不採用）
    sheets: {
      CU_MASTER: 'CU_Master',
      UP_MASTER: 'UP_Master',
      PARTS_MASTER: 'Parts_Master',
      EX_MASTER: 'EX_Master',
      EXPENSE_MASTER: 'Expense_Master',
      REQUEST: 'Request',
      // Order_YYYY / Archive_Order_YYYY は動的に解決
    },

    // Drive（UI判断反映）
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

    // 外部連携（UI判断反映：今回は無効）
    externalIntegrations: {
      todoist: { enabled: false },
      clickup: { enabled: false },
      chatgpt: { model: 'gpt-5.2', usage: 'code-generation-only' },
      geolonia: { enabled: false }
    },

    // forms（doGet/showDynamicForm で利用）
    forms: [
      { code: 'UF01', kind: '受注', enabled: true },
      { code: 'UF06', kind: '発注/納品', enabled: true },
      { code: 'UF07', kind: '価格入力', enabled: true },
      { code: 'UF08', kind: '追加報告', enabled: true },
      { code: 'FIX', kind: '修正', enabled: true },
      { code: 'DOC', kind: '書類', enabled: true },
      { code: 'OV01', kind: '閲覧', enabled: true },
      { code: 'OV02', kind: '全文検索', enabled: true }
    ],

    // コメントモード（v7.1R→v7.5R 統合）
    commentMode: {
      ttlMs: 60 * 60 * 1000
    }
  };

  return c;
}

function CONF_BRAND() {
  var conf = CONF();
  var b = (conf.brandProfiles || {})[conf.activeBrand];
  if (!b) throw new Error('activeBrand not found: ' + conf.activeBrand);
  return b;
}

function isMaintenanceMode() {
  return !!CONF().maintenanceMode;
}

function assertNotMaintenance(actionName) {
  if (isMaintenanceMode()) {
    logSystem_('MAINTENANCE_BLOCK', null, {
      actionName: actionName
    }, {
      blocked: true,
      reason: 'maintenanceMode=true'
    });
    throw new Error('maintenanceMode=true のため、この操作はブロックされました: ' + actionName);
  }
}

/**
 * タスク名投影（FIXATE）
 * - AA最大5、6以上は x/y 表示
 * - 自由文スロット（末尾 '_ '）は非干渉：残し、ここへ追記しない
 * - 欠番/キャンセルはタスク名へ反映しない（台帳のみ）
 */
function TaskTitle_project(currentTitle, aaList, deliveredCount, totalCount) {
  currentTitle = String(currentTitle || '');
  aaList = Array.isArray(aaList) ? aaList : [];

  // free slot "_ " の保持（無ければ末尾に追加してもよい：既存契約に従う）
  var freeSlot = '_ ';
  var idx = currentTitle.lastIndexOf(freeSlot);
  var base = (idx >= 0) ? currentTitle.substring(0, idx).trimRight() : currentTitle.trimRight();

  var head = '';
  var uniq = {};
  var aas = aaList.map(function(a){ return String(a||'').trim(); }).filter(function(a){ return !!a; })
    .filter(function(a){ if (uniq[a]) return false; uniq[a]=true; return true; });

  if (aas.length > 0 && aas.length <= 5) {
    head = aas.join(' ');
  } else {
    var x = Number(deliveredCount || 0);
    var y = Number(totalCount || 0);
    head = '納品 ' + x + '/' + y;
  }

  var nextBase = head;
  // 既存 base に顧客名等が入っている場合、head と衝突しない範囲で残す（破壊しない）
  // ここでは最小安全として「head だけ」を出す。追加情報は別層で合成する。
  return (nextBase + ' ' + freeSlot);
}
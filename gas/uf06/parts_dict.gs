/**
 * Parts_Dict（設計→実装の入口）
 * - 採用(adopted=true)のみ確定扱い
 * - AI提案はここでは扱わない（提案は別層）
 */
function PartsDict_normalizeRecord(rec) {
  rec = rec || {};
  var legacy = String(rec.legacyStatus || '').toUpperCase();
  if (legacy !== 'CURRENT' && legacy !== 'OLD' && legacy !== 'UNKNOWN') legacy = 'UNKNOWN';

  var mark = String(rec.discontinuedMark || '');
  if (mark !== '◇' && mark !== '◆') mark = '';

  var tags = rec.tags;
  if (!Array.isArray(tags)) tags = [];
  tags = tags.map(function(t){ return String(t||'').trim(); }).filter(function(t){ return !!t; });

  return {
    dictId: String(rec.dictId || '').trim(),
    maker: String(rec.maker || '').trim(),
    modelNumber: String(rec.modelNumber || '').trim(),
    tags: tags,
    legacyStatus: legacy,
    legacyModelNumber: String(rec.legacyModelNumber || '').trim(),
    replacementModelNumber: String(rec.replacementModelNumber || '').trim(),
    discontinuedMark: mark,
    adopted: !!rec.adopted,
    adoptedAt: String(rec.adoptedAt || '').trim(),
    adoptedBy: String(rec.adoptedBy || '').trim(),
    note: String(rec.note || '').trim()
  };
}

/**
 * 検索（設計レベル）
 * - modelNumber 部分一致
 * - tags は maker 同格で検索対象
 */
function PartsDict_search(records, query) {
  records = Array.isArray(records) ? records : [];
  query = String(query || '').trim();
  if (!query) return [];

  var terms = query.split(/\s+/).filter(function(x){ return !!x; });
  return records.filter(function(r){
    r = PartsDict_normalizeRecord(r);
    var hay = [r.maker, r.modelNumber, r.legacyModelNumber, r.replacementModelNumber].join(' ') + ' ' + (r.tags||[]).join(' ');
    return terms.every(function(t){ return hay.indexOf(t) >= 0; });
  });
}
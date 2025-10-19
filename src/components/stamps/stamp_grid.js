
import { format_db_date } from '@/lib/date';
import itemTypeMap from '@/lib/item_type_map';
import StampItem from './stamp_item';
import styles from './stamp_grid.module.css';

export default function StampGrid({ stamps, groupBy = 'issue' }) {
  if (!stamps || stamps.length === 0) return <div>No stamps found.</div>;

  // Helper: group stamps by issue, with extra info for sorting and display
  const groupByIssue = (stamps, year) => {
    const groups = {};
    stamps.forEach(stamp => {
      const issueId = stamp.issue_id || 'unknown';
      if (!groups[issueId]) {
        groups[issueId] = {
          issue_id: issueId,
          issue_name: stamp.issue_name_base || 'Unknown Issue',
          series_name: stamp.series_name_base || '',
          issue_release_date: stamp.issue_release_date || '',
          issue_release_type: stamp.issue_release_type || '',
          stamps: [],
        };
      }
      groups[issueId].stamps.push(stamp);
    });
    // Convert to array
    let arr = Object.values(groups);
    // Separate single_series
    const singles = arr.filter(g => g.issue_release_type === 'single_series');
    const others = arr.filter(g => g.issue_release_type !== 'single_series');
    // Sort others by issue_release_date desc (newest first)
    others.sort((a, b) => {
      if (!a.issue_release_date && !b.issue_release_date) return 0;
      if (!a.issue_release_date) return 1;
      if (!b.issue_release_date) return -1;
      return b.issue_release_date.localeCompare(a.issue_release_date);
    });
    // Single Issues group: merge all singles into one group
    let singleGroup = null;
    if (singles.length > 0) {
      let allStamps = singles.flatMap(g => g.stamps);
      singleGroup = {
        issue_id: 'single_issues',
        issue_name: `Single Issues (${year})`,
        series_name: '',
        issue_release_date: '',
        issue_release_type: 'single_series',
        stamps: allStamps,
      };
    }
    // Return [...others, singleGroup]
    return singleGroup ? [...others, singleGroup] : others;
  };

  // Helper: group stamps by series
  const groupBySeries = (stamps) => {
    const groups = {};
    stamps.forEach(stamp => {
      const seriesId = stamp.series_id || 'unknown';
      if (!groups[seriesId]) {
        groups[seriesId] = {
          series_id: seriesId,
          series_name: stamp.series_name_base || 'Unknown Series',
          start_year: stamp.start_year || null,
          end_year: stamp.end_year || null,
          series_total_stamps: stamp.series_total_stamps || null,
          special_type: stamp.series_special_type || null, // lấy đúng từ bảng series
          stamps: [],
        };
      }
      groups[seriesId].stamps.push(stamp);
    });
    // Đưa nhóm Single Issues (special_type='single_series') xuống cuối
    const arr = Object.values(groups);
    const singles = arr.filter(g => g.special_type === 'single_series');
    const others = arr.filter(g => g.special_type !== 'single_series');
    // Sắp xếp others theo start_year giảm dần (nếu có)
    others.sort((a, b) => {
      if (!a.start_year && !b.start_year) return 0;
      if (!a.start_year) return 1;
      if (!b.start_year) return -1;
      return b.start_year < b.start_year ? 1 : -1;
    });
    return [...others, ...singles];
  };

  if (groupBy === 'issue') {
    // Lấy năm từ props nếu có, fallback từ tem đầu tiên
    const year = stamps && stamps.length > 0 && stamps[0].release_date ? stamps[0].release_date.substring(0, 4) : '';
    const issueGroups = groupByIssue(stamps, year);
    return (
      <div>
        {issueGroups.map(group => {
          // Tiêu đề: Issue/Series logic
          let title = '';
          if (group.issue_id === 'single_issues') {
            title = group.issue_name;
          } else if (group.issue_name && group.series_name) {
            if (group.issue_name === group.series_name) {
              title = `Issue/Series: ${group.issue_name}`;
            } else {
              title = `Issue: ${group.issue_name} / Series: ${group.series_name}`;
            }
          } else if (group.issue_name) {
            title = `Issue: ${group.issue_name}`;
          }
          // Ngày phát hành
          let dateStr = '';
          if (group.issue_id === 'single_issues') {
            // Lấy năm từ tên nhóm
            const match = group.issue_name.match(/\((\d{4})\)/);
            if (match) dateStr = match[1];
          } else if (group.issue_release_date) {
            // Lấy kiểu ngày phát hành
            let type = group.issue_release_type || 'exact';
            if (group.issue_release_type === 'month') type = 'month';
            else if (group.issue_release_type === 'year') type = 'year';
            else if (group.issue_release_type === 'exact') type = 'day';
            else type = 'day';
            dateStr = format_db_date(group.issue_release_date, type);
          }
          // Tổng số tem trong issue (lấy từ tem đầu tiên của group)
          const totalStamps = group.stamps[0]?.issue_total_stamps;
          // Philatelic items liên quan đến issue (lấy từ tem đầu tiên của group)
          const philatelicItems = group.stamps[0]?.philatelic_items || [];
          return (
            <div key={group.issue_id} style={{ marginBottom: 24 }}>
              {title && <h3 style={{ margin: '8px 0' }}>{title}</h3>}
              {(dateStr || totalStamps) && (
                <div style={{ marginBottom: 8, color: '#888', display: 'flex', gap: 16, alignItems: 'center' }}>
                  {dateStr && <span>Issue date: {dateStr}</span>}
                  {totalStamps && <span>Total stamps in issue: {totalStamps}</span>}
                </div>
              )}
              <div className={styles.grid}>
                {group.stamps.map(stamp => (
                  <StampItem key={stamp.id} stamp={stamp} />
                ))}
              </div>
              {philatelicItems.length > 0 && (
                <div style={{ marginBottom: 8, color: '#888' }}>
                  There {philatelicItems.length === 1 ? 'is' : 'are'} {philatelicItems.length} philatelic item{philatelicItems.length > 1 ? 's' : ''} in this issue.
                  <ul style={{ margin: '4px 0 0 16px', padding: 0 }}>
                    {philatelicItems.map(item => (
                      <li key={item.id} style={{ fontSize: 13 }}>
                        {item.name_base} <span style={{ color: '#555' }}>({itemTypeMap[item.item_type] || item.item_type})</span>
                      </li>
                    ))}
                  </ul>
                </div>
              )}
            </div>
          );
        })}
      </div>
    );
  }

  if (groupBy === 'series') {
    const seriesGroups = groupBySeries(stamps);
    return (
      <div>
        {seriesGroups.map(group => {
          // Series title
          let title = `Series: ${group.series_name}`;
          if (group.start_year && group.end_year) {
            title += ` (${group.start_year}–${group.end_year})`;
          }
          const yearCount = group.stamps.length;
          const isSingleIssues = group.special_type === 'single_series';
          const totalCount = group.series_total_stamps;
          // Gom tất cả philatelic items của series (từ tất cả stamps trong group)
          const allPhilatelicItems = [];
          const seenIds = new Set();
          group.stamps.forEach(stamp => {
            if (stamp.philatelic_items && Array.isArray(stamp.philatelic_items)) {
              stamp.philatelic_items.forEach(item => {
                if (!seenIds.has(item.id)) {
                  allPhilatelicItems.push(item);
                  seenIds.add(item.id);
                }
              });
            }
          });
          const philatelicItemsCount = allPhilatelicItems.length;
          return (
            <div key={group.series_id} style={{ marginBottom: 24 }}>
              <h3 style={{ margin: '8px 0' }}>{title}</h3>
              <div style={{ marginBottom: 8, color: '#888' }}>
                {isSingleIssues
                  ? `Stamps this year: ${yearCount}`
                  : `Stamps this year: ${yearCount} / Total in series: ${totalCount}`}
              </div>
              <div className={styles.grid}>
                {group.stamps.map(stamp => (
                  <StampItem key={stamp.id} stamp={stamp} />
                ))}
              </div>
              {philatelicItemsCount > 0 && (
                <div style={{ marginBottom: 8, color: '#888' }}>
                  There {philatelicItemsCount === 1 ? 'is' : 'are'} {philatelicItemsCount} philatelic item{philatelicItemsCount > 1 ? 's' : ''} in this series.
                  <ul style={{ margin: '4px 0 0 16px', padding: 0 }}>
                    {allPhilatelicItems.map(item => (
                      <li key={item.id} style={{ fontSize: 13 }}>
                        {item.name_base} <span style={{ color: '#555' }}>({itemTypeMap[item.item_type] || item.item_type})</span>
                      </li>
                    ))}
                  </ul>
                </div>
              )}
            </div>
          );
        })}
      </div>
    );
  }

  // Flat list (All)
  return (
    <div className={styles.grid}>
      {stamps.map(stamp => (
        <StampItem key={stamp.id} stamp={stamp} />
      ))}
    </div>
  );
}

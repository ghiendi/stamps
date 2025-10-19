import React from 'react';
import styles from './stamp_grid.module.css';
import StampItem from './stamp_item';

export default function StampGrid({ stamps, groupBy = 'issue' }) {
  if (!stamps || stamps.length === 0) return <div>No stamps found.</div>;

  // Helper: group stamps by issue
  const groupByIssue = (stamps) => {
    const groups = {};
    stamps.forEach(stamp => {
      const issueId = stamp.issue_id || 'unknown';
      if (!groups[issueId]) {
        groups[issueId] = {
          issue_id: issueId,
          issue_name: stamp.issue_name_base || 'Unknown Issue',
          stamps: [],
        };
      }
      groups[issueId].stamps.push(stamp);
    });
    return Object.values(groups);
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
          stamps: [],
        };
      }
      groups[seriesId].stamps.push(stamp);
    });
    return Object.values(groups);
  };

  if (groupBy === 'issue') {
    const issueGroups = groupByIssue(stamps);
    return (
      <div>
        {issueGroups.map(group => (
          <div key={group.issue_id} style={{ marginBottom: 24 }}>
            {group.issue_name !== 'Unknown Issue' && (
              <h3 style={{ margin: '8px 0' }}>Issue: {group.issue_name}</h3>
            )}
            <div className={styles.grid}>
              {group.stamps.map(stamp => (
                <StampItem key={stamp.id} stamp={stamp} />
              ))}
            </div>
          </div>
        ))}
      </div>
    );
  }

  if (groupBy === 'series') {
    const seriesGroups = groupBySeries(stamps);
    return (
      <div>
        {seriesGroups.map(group => (
          <div key={group.series_id} style={{ marginBottom: 24 }}>
            {group.series_name !== 'Unknown Series' && (
              <h3 style={{ margin: '8px 0' }}>Series: {group.series_name}</h3>
            )}
            <div className={styles.grid}>
              {group.stamps.map(stamp => (
                <StampItem key={stamp.id} stamp={stamp} />
              ))}
            </div>
          </div>
        ))}
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

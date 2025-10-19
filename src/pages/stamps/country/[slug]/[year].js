
import React from 'react';
import { Breadcrumb } from 'antd';
import StampGrid from '@/components/stamps/stamp_grid';

export async function getServerSideProps({ params }) {
  const { slug, year } = params;
  const api_url = process.env.NEXT_PUBLIC_API_URL;
  const res = await fetch(`${api_url}/stamps/country/${slug}/${year}`);
  const data = await res.json();
  return { props: { slug, year, stamps: data.stamps } };
}

export default function StampsByCountryYear({ slug, year, stamps }) {
  // Lấy issuing_authority_base từ tem đầu tiên nếu có, fallback về slug
  const country_name = stamps && stamps.length > 0 && stamps[0].issuing_authority_base ? stamps[0].issuing_authority_base : slug;
  const breadcrumb_items = [
    {
      title: 'Stamps',
      href: '/stamps',
    },
    {
      title: country_name,
    },
    {
      title: year,
    },
  ];

  // UI: Segmented control for display mode
  const [groupBy, setGroupBy] = React.useState('issue');
  const handleGroupByChange = (val) => setGroupBy(val);
  // Ant Design Segmented
  // import Segmented
  const Segmented = require('antd').Segmented;

  return (
    <div>
      <Breadcrumb items={breadcrumb_items} />
      <div style={{ margin: '8px 0' }}>
        <span style={{ fontWeight: 500, marginRight: 8 }}>Display mode:</span>
        <Segmented
          options={[
            { label: 'Group by Issue', value: 'issue' },
            { label: 'Group by Series', value: 'series' },
            { label: 'All (Flat)', value: 'all' },
          ]}
          value={groupBy}
          onChange={handleGroupByChange}
          size="middle"
        />
      </div>
      <StampGrid stamps={stamps} groupBy={groupBy} />
    </div>
  );
}

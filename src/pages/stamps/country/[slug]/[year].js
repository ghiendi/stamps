import React from 'react';

import StampGrid from '@/components/stamps/stamp_grid';

export async function getServerSideProps({ params }) {
  const { slug, year } = params;
  const api_url = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000/api';
  const res = await fetch(`${api_url}/stamps/country/${slug}/${year}`);
  const data = await res.json();
  return { props: { slug, year, stamps: data.stamps } };
}

export default function StampsByCountryYear({ slug, year, stamps }) {
  return (
    <div>
      <h2>Stamps for {slug} in {year}</h2>
      <StampGrid stamps={stamps} country_slug={slug} year={year} />
    </div>
  );
}

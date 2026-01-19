export default async function Home() {
  // Fetch data from the Rails API (running in 'web' container)
  let data: any = null;
  let error = null;

  try {
    const res = await fetch('http://web:3000/dashboards/world_data.json', {
      cache: 'no-store',
    });

    if (!res.ok) {
      error = `Error: ${res.status} ${res.statusText}`;
    } else {
      data = await res.json();
    }
  } catch (e: any) {
    error = e.toString();
  }

  const generalStats = data?.general_data || {};
  // Handle if general_data is array or object, based on API response it seems to be an object
  const statsEntries = typeof generalStats === 'object' && !Array.isArray(generalStats)
    ? Object.entries(generalStats)
    : [];

  // world_data might be the array of countries
  const countries = Array.isArray(data?.world_data) ? data.world_data : [];

  return (
    <main className="min-h-screen p-8 bg-slate-50">
      <div className="max-w-6xl mx-auto">
        <h1 className="text-3xl font-bold mb-6 text-slate-800 flex items-center gap-2">
          COVID-19 Dashboard
          <span className="text-sm font-normal text-slate-500 bg-slate-200 px-2 py-1 rounded">Next.js + Rails API</span>
        </h1>

        {error ? (
          <div className="p-4 bg-red-50 text-red-700 border border-red-200 rounded mb-6">
            <h3 className="font-bold">Connection Error</h3>
            <p>{error}</p>
            <p className="text-sm mt-2 text-gray-600">Ensure the backend is running and reachable at http://web:3000</p>
          </div>
        ) : (
          <div className="grid gap-8">
            {/* General Stats */}
            <section className="bg-white p-6 rounded-lg shadow-sm border border-slate-200">
              <h2 className="text-xl font-semibold mb-4 text-slate-700">Global Statistics</h2>
              <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-6 gap-4">
                {statsEntries.map(([key, value]: [string, any]) => (
                  <div key={key} className="bg-slate-50 p-3 rounded border border-slate-100">
                    <p className="text-xs text-slate-500 uppercase tracking-wide mb-1">
                      {key.replace(/([A-Z])/g, ' $1').trim()}
                    </p>
                    <p className="text-lg font-bold text-slate-800 truncate" title={value?.toString()}>
                      {value?.toLocaleString ? value.toLocaleString() : value}
                    </p>
                  </div>
                ))}
                {statsEntries.length === 0 && <p className="text-gray-500 col-span-full">No global data available</p>}
              </div>
            </section>

            {/* Countries Table */}
            <section className="bg-white p-6 rounded-lg shadow-sm border border-slate-200">
              <h2 className="text-xl font-semibold mb-4 text-slate-700 flex justify-between">
                <span>Countries Data</span>
                <span className="text-sm font-normal text-gray-500 my-auto">Top 20</span>
              </h2>

              {countries.length > 0 ? (
                <div className="overflow-x-auto">
                  <table className="w-full text-sm text-left">
                    <thead className="bg-slate-50 text-slate-500 font-medium">
                      <tr>
                        <th className="p-3">Country</th>
                        <th className="p-3 text-right">Cases</th>
                        <th className="p-3 text-right">Deaths</th>
                        <th className="p-3 text-right">Recovered</th>
                        <th className="p-3 text-right">Active</th>
                      </tr>
                    </thead>
                    <tbody className="divide-y divide-slate-100">
                      {countries.slice(0, 20).map((c: any, i: number) => (
                        <tr key={i} className="hover:bg-slate-50">
                          <td className="p-3 font-medium text-slate-700">{c.country || c.countryInfo?.iso2 || 'Unknown'}</td>
                          <td className="p-3 text-right text-slate-600">{c.cases?.toLocaleString()}</td>
                          <td className="p-3 text-right text-red-600">{c.deaths?.toLocaleString()}</td>
                          <td className="p-3 text-right text-green-600">{c.recovered?.toLocaleString()}</td>
                          <td className="p-3 text-right text-orange-600">{c.active?.toLocaleString()}</td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              ) : (
                <div className="p-8 text-center text-gray-500 bg-slate-50 rounded">
                  No country data available.
                </div>
              )}
            </section>

            {/* Debug Info */}
            <details className="bg-gray-50 p-4 rounded text-xs text-gray-500">
              <summary className="cursor-pointer font-medium mb-2">Debug Response</summary>
              <pre className="overflow-auto max-h-40">{JSON.stringify(data, null, 2)}</pre>
            </details>
          </div>
        )}
      </div>
    </main>
  );
}

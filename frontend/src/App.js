import React, { useEffect, useState } from 'react';
import { Line } from 'react-chartjs-2';
import 'chart.js/auto';

const API_BACKEND = process.env.REACT_APP_API_BASE || 'http://localhost:8080';

export default function App() {
  const [city, setCity] = useState('Japan');
  const [graphCity, setGraphCity] = useState('Japan');
  const [year, setYear] = useState(new Date().getFullYear());
  const [data, setData] = useState([]);
  const [loading, setLoading] = useState(false);

  const loadData = async () => {
    try {
      setData([]); // reset existing data
      setLoading(true); // start loading
      setGraphCity(city);

      const res = await fetch(`${API_BACKEND}/api/monthly/${encodeURIComponent(city)}/${year}`);
      const json = await res.json();
      // console.log(`city: ${city}`)
      // console.log(`graphCity: ${graphCity}`)
      // console.log(`data: ${json}`);
      // console.log(`type of data: ${typeof json}`);
      setData(json);
      // console.log('json data set')
    } catch (e) {
      console.error(e);
      setData({error: e.message});
    } finally {
    setLoading(false); // stop loading
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const monthName = (monthNum) => {
    const months = {
      1: "January",
      2: "February",
      3: "March",
      4: "April",
      5: "May",
      6: "June",
      7: "July",
      8: "August",
      9: "September",
      10: "October",
      11: "November",
      12: "December"
    }
    return months[monthNum]
  }

  const chartData = (data.error) ? {
    labels: [],
    datasets: []
  } : {
    labels: data.map(d => `${monthName(d.month)} ${d.year}`),
    datasets: [{ label: `${graphCity} temp (°C)`, data: data.map(d => d.average_temp), fill: false }]
  };

  return (
    <div style={{ width: '80%', margin: 'auto', padding: '2rem' }}>
      <h1>Temperature History</h1>

      <div style={{ marginBottom: 12 }}>
        City: <input value={city} onChange={e => setCity(e.target.value)} />
        Year: <input type="number" value={year} onChange={e => setYear(e.target.value)} />
        <button onClick={loadData} disabled={loading}>Load</button>
      </div>

      {(data.error) && <p>{data.error}</p>}

      {loading ? (
        <div style={{ textAlign: 'center', margin: '2rem 0' }}>
          <p>Loading data…</p>
          {/* Optional: add a logo or spinner */}
          <img src="/loading-spinner.gif" alt="Loading..." width={50} />
        </div>
      ) : (
        <Line data={chartData} />
      )}
    </div>
  );
}

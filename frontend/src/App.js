import React, { useEffect, useState } from 'react';
import { Line } from 'react-chartjs-2';
import 'chart.js/auto';

const API = process.env.REACT_APP_API_BASE || 'http://localhost:8080';

export default function App() {
  const [city, setCity] = useState('Tokyo');
  const [year, setYear] = useState(new Date().getFullYear());
  const [data, setData] = useState([]);

  const loadData = async () => {
    console.log("loadData called")
    try {
      const res = await fetch(`${API}/api/monthly/${encodeURIComponent(city)}/${year}`);
      const json = await res.json();
      console.log(json)
      setData(json);
    } catch (e) {
      console.error(e);
      setData([]);
    }
  };

  useEffect(() => {
    loadData();
  }, []);

  const chartData = {
    labels: data.map(d => `Month ${d.month}`),
    datasets: [{ label: `${city} temp (°C)`, data: data.map(d => d.average_temp), fill: false }]
  };

  return (
    <div style={{ width: '80%', margin: 'auto', padding: '2rem' }}>
      <h1>Temperature History</h1>

      <div style={{ marginBottom: 12 }}>
        City: <input value={city} onChange={e => setCity(e.target.value)} />
        Year: <input type="number" value={year} onChange={e => setYear(e.target.value)} />
        <button onClick={loadData}>Load</button>
      </div>

      <Line data={chartData} />
    </div>
  );
}

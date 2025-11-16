const express = require('express');
const axios = require('axios');
const mysql = require('mysql2/promise');

const app = express();
app.use(express.json());

const cors = require('cors');
// app.use(cors({
//   origin: 'http://localhost:3000'
// }));
app.use(cors());

const API_OPENWEATHER_HISTORY = process.env.OPENWEATHER_HISTORY_API_BASE;

const {
  MYSQL_HOST,
  MYSQL_USER,
  MYSQL_PASSWORD,
  MYSQL_DB,
  OPENWEATHER_KEY
} = process.env;

// Validate environment
['MYSQL_HOST', 'MYSQL_USER', 'MYSQL_PASSWORD', 'MYSQL_DB', 'OPENWEATHER_KEY'].forEach(key => {
  if (!process.env[key]) {
    console.error(`Missing env: ${key}`);
    process.exit(1);
  }
});

// MySQL pool
const pool = mysql.createPool({
  host: MYSQL_HOST,
  user: MYSQL_USER,
  password: MYSQL_PASSWORD,
  database: MYSQL_DB,
  waitForConnections: true,
  connectionLimit: 10
});

// Get city by id from cities table
async function getCityIdByName(cityName) {
  const [rows] = await pool.execute('SELECT id FROM cities WHERE name = ?', [cityName]);
  return rows.length > 0 ? rows[0].id : null;
}

// // Optional: Insert a new city that did not exist in the cities table
// async function ensureCityExists(cityName, country = null, lat = null, lon = null) {
//   let cityId = await getCityIdByName(cityName);
//   if (!cityId) {
//     const [result] = await pool.execute(
//       'INSERT INTO cities (name, country, latitude, longitude) VALUES (?, ?, ?, ?)',
//       [cityName, country, lat, lon]
//     );
//     cityId = result.insertId;
//   }
//   return cityId;
// }

// Upsert monthly average
async function upsertMonthlyTemp(city_id, year, month, avgTemp) {
  const sql = `
    INSERT INTO monthly_avg_temp (city_id, year, month, average_temp)
    VALUES (?, ?, ?, ?)
    ON DUPLICATE KEY UPDATE average_temp = VALUES(average_temp)
  `;
  await pool.execute(sql, [city_id, year, month, avgTemp]);
}

// API endpoint
app.get('/api/monthly/:city/:year', async (req, res) => {
  const city = req.params.city;
//   const year = parseInt(req.params.year, 10);
  var year = new Date().getFullYear();
  const currentYear = year;

  const currentMonth = new Date().getMonth() + 1; // 0-11 -> 1-12

  try {
    // get city id
    let cityId = await getCityIdByName(city);

    if (!cityId) {
      // Optional: Create record if not exists (or you can just return 404)
      // console.log(`City ${cityName} not found, creating record...`);
      // cityId = await ensureCityExists(cityName);
      return res.status(400).json({ error: "No data on the specified city" });
    }

    // if the data is already stored in the database, return the data
    const [rows_pre] = await pool.query(
    'SELECT year, month, average_temp FROM monthly_avg_temp WHERE city_id = ? ORDER BY year ASC, month ASC',
      [cityId]
    );
    if (rows_pre.length >= 12) {
      return res.json(rows_pre);
    }

    // fetch data for 12 months each and insert received data into the database
    for (let month = 1; month <= 12; month++) {
      if (month >= currentMonth) {year = currentYear - 1;} // last year's data
      const response = await axios.get(`${API_OPENWEATHER_HISTORY}/aggregated/month`, {
        params: {
        //   city_id: city, // or q: city // use id
          id: cityId,
          month: month,
        //   year: year, // year is not needed to call this API
          appid: OPENWEATHER_KEY
        }
      });

      const meanTempKelvin = response.data.result.temp.mean;
      const meanTempCelsius = meanTempKelvin - 273.15;

      await upsertMonthlyTemp(cityId, year, month, meanTempCelsius);
    }

    // retrieve data from the database
    const [rows] = await pool.query(
    'SELECT year, month, average_temp FROM monthly_avg_temp WHERE city_id = ? ORDER BY year ASC, month ASC',
      [cityId]
    );

    // return
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

app.listen(8080, () => console.log('Backend listening on port 8080'));

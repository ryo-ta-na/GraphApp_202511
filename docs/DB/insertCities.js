const mysql = require('mysql2/promise');
const cities = require('../OpenWeather/history.city.list.json');

function extractNumber(field) {
  // If it's a simple number
  if (typeof field === 'number') {
    return field;
  }

  // If it's an object with $numberLong
  if (typeof field === 'object' && field !== null && field.$numberLong) {
    return parseInt(field.$numberLong);
  }

  // If it's already a string number
  if (typeof field === 'string' && !isNaN(field)) {
    return parseInt(field);
  }

  // Return null for undefined/unparseable values
  return null;
}

async function insertCities() {
  const connection = await mysql.createConnection({
    host: 'localhost',
    user: 'graphapiuser',
    password: '9k#j1Df2]kKd',
    database: 'GraphAPI'
  });

  try {
    await connection.execute(`
      CREATE TABLE IF NOT EXISTS cities2 (
        id BIGINT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        findname VARCHAR(255),
        country CHAR(2),
        longitude DECIMAL(10,6),
        latitude DECIMAL(10,6),
        zoom INT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);

    const query = `
      INSERT INTO cities2 (id, name, findname, country, longitude, latitude, zoom)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `;

    let insertedCount = 0;

    for (let i = 0; i < cities.length; i++) {
      try {
        const city = cities[i];

        // Use the same function for both id and zoom
        const cityId = extractNumber(city.id);
        const zoomValue = extractNumber(city.city.zoom);
        const lonValue = extractNumber(city.city.coord.lon);
        const latValue = extractNumber(city.city.coord.lat);

        await connection.execute(query, [
          cityId,
          city.city.name,
          city.city.findname,
          city.city.country,
          lonValue,
          latValue,
          zoomValue
        ]);

        insertedCount++;

        if (insertedCount % 1000 === 0) {
          console.log(`Inserted ${insertedCount} cities...`);
        }
      } catch (error) {
        if (error.code === 'ER_DUP_ENTRY') {
          continue;
        }
        console.error(`Error at index ${i} (${cities[i].city.name}):`, error.message);
      }
    }

    console.log(`✅ Successfully inserted ${insertedCount} out of ${cities.length} cities`);
  } catch (error) {
    console.error('Error:', error);
  } finally {
    await connection.end();
  }
}

insertCities();
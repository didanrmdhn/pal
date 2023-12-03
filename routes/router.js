const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const uuid = require('uuid');
const app = express();
const db = require('../lib/db.js');
const userMiddleware = require('../middleware/users.js');
const historyMiddleware = require('../middleware/history.js');

// http://localhost:3000/api/sign-up
router.post('/sign-up', userMiddleware.validateRegister, (req, res, next) => {
  db.query(
    'SELECT id FROM users WHERE LOWER(username) = LOWER(?) OR LOWER(email) = LOWER(?)',
    [req.body.username, req.body.email],
    (err, result) => {
      if (result && result.length) {
        // error
        return res.status(409).send({
          message: 'This username or email is already in use!',
        });
      } else {
        // username and email not in use
        bcrypt.hash(req.body.password, 10, (err, hash) => {
          if (err) {
            return res.status(500).send({
              message: err,
            });
          } else {
            db.query(
              'INSERT INTO users (id, username, email, password, registered, gender) VALUES (?, ?, ?, ?, now(), ?);',
              [uuid.v4(), req.body.username, req.body.email, hash, req.body.gender],
              (err, result) => {
                if (err) {
                  return res.status(400).send({
                    message: err,
                  });
                }
                return res.status(201).send({
                  message: 'Registered!',
                });
              }
            );
          }
        });
      }
    }
  );
});


// http://localhost:3000/api/login
router.post('/login', (req, res, next) => {
  const loginIdentifier = req.body.usernameOrEmail; // Add a field in your login form to input either username or email

  db.query(
    `SELECT * FROM users WHERE username = ? OR email = ?;`,
    [loginIdentifier, loginIdentifier],
    (err, result) => {
      if (err) {
        return res.status(400).send({
          message: err,
        });
      }
      if (!result.length) {
        return res.status(400).send({
          message: 'Username or email or password incorrect!',
        });
      }

      bcrypt.compare(
        req.body.password,
        result[0]['password'],
        (bErr, bResult) => {
          if (bErr) {
            return res.status(400).send({
              message: 'Username or email or password incorrect!',
            });
          }
          if (bResult) {
            // password match
            const token = jwt.sign(
              {
                username: result[0].username,
                userId: result[0].id,
              },
              'SECRETKEY',
              { expiresIn: '7d' }
            );
            db.query(`UPDATE users SET last_login = now() WHERE id = ?;`, [
              result[0].id,
            ]);
            return res.status(200).send({
              message: 'Logged in!',
              token,
              user: result[0],
            });
          }
          return res.status(400).send({
            message: 'Username or email or password incorrect!',
          });
        }
      );
    }
  );
});


// http://localhost:3000/api/secret-route
router.get('/secret-route', userMiddleware.isLoggedIn, (req, res, next) => {
  console.log(req.userData);
  res.send('This is secret content!');
});

// http://localhost:3000/api/change-username
app.post('/api/change-username', userMiddleware.isLoggedIn, (req, res) => {
  const userId = req.userData.userId;
  const newUsername = req.body.newUsername;

  // Lakukan validasi dan perubahan nama pengguna di dalam database
  if (newUsername.length < 3) {
    return res.status(400).json({ message: 'New username must be at least 3 characters long' });
  }

  db.query('UPDATE users SET username = ? WHERE id = ?', [newUsername, userId], (err, result) => {
    if (err) {
      console.error('Error:', err);
      return res.status(500).json({ message: 'Internal Server Error' });
    }

    if (result.affectedRows > 0) {
      return res.status(200).json({ message: 'Username changed successfully' });
    } else {
      return res.status(400).json({ message: 'Failed to change username' });
    }
  });

  return res.status(200).json({ message: 'Username changed successfully' });
});

// Endpoint untuk mendapatkan history makanan pengguna yang sudah login
router.get('/history', historyMiddleware.validateHistoryAccess, async (req, res) => {
  const userId = req.userData.userId;

  try {
    // Ambil data history makanan pengguna dari database
    const historyQuery = `
      SELECT h.timestamp, fc.name_food_category, fc.GI_food_category, g.name AS classification_name
      FROM history h
      INNER JOIN gl_result gr ON h.id_result = gr.id_result
      INNER JOIN gl_classification g ON gr.id_classification = g.id_classification
      INNER JOIN data_nf dn ON gr.id_nf = dn.id_datanf
      INNER JOIN food f ON dn.id_food = f.id_food
      INNER JOIN food_category fc ON f.id_food_category = fc.id_food_category
      WHERE h.id_user = ?;
    `;

    const historyResults = await db.query(historyQuery, [userId], (err, result, fields) => {
      const formattedHistory = result.map((result) => {
        return {
          timestamp: result.timestamp,
          name_food_category: result.name_food_category,
          GI_food_category: result.GI_food_category,
          classification_name: result.classification_name,
        };
      });

      res.status(200).json(formattedHistory);
    });

  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});


// Endpoint untuk menambahkan entri baru ke tabel history untuk pengetesan
router.post('/history/test', historyMiddleware.validateHistoryAccess, async (req, res) => {
  const userId = req.userData.userId;

  try {
    // Ambil contoh ID result dari database (gantilah dengan yang sesuai)
    const exampleResultId = 1;

    // Simpan entri baru ke tabel history
    const insertHistoryQuery = `
      INSERT INTO history (id_user, id_result, timestamp) VALUES (?, ?, CURRENT_TIMESTAMP());
    `;

    await db.query(insertHistoryQuery, [userId, exampleResultId]);

    res.status(200).json({ message: 'Test history entry added successfully' });
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

// Endpoint untuk mendapatkan seluruh informasi dalam suatu history berdasarkan id_history
router.get('/history/:id_history', historyMiddleware.validateHistoryAccess, async (req, res) => {
  const userId = req.userData.userId;
  const id_history = req.params.id_history;
  console.log(id_history)

  try {
    // Ambil seluruh informasi dalam suatu history berdasarkan id_history
    const historyDetailQuery = `SELECT h.id_history, fc.name_food_category, fc.GI_food_category, g.name AS classification_name, f.name AS food_name, dn.carbo, dn.protein, dn.lemak, dn.calorie, dn.serving_size FROM history h INNER JOIN gl_result gr ON h.id_result = gr.id_result INNER JOIN gl_classification g ON gr.id_classification = g.id_classification INNER JOIN data_nf dn ON gr.id_nf = dn.id_datanf INNER JOIN food f ON dn.id_food = f.id_food INNER JOIN food_category fc ON f.id_food_category = fc.id_food_category WHERE h.id_user = ? AND h.id_history = ?;`;
    // console.log(historyDetailQuery);

    const historyDetail =  db.query(historyDetailQuery, [userId, id_history], (err, result, fields) => {
      if (!result || result.length === 0) {
        return res.status(404).json({ message: 'History not found' });
      }
      const formattedHistoryDetail = {
        id_history: result[0].id_history,
        name_food_category: result[0].name_food_category,
        GI_food_category: result[0].GI_food_category,
        classification_name: result[0].classification_name,
        food_name: result[0].food_name,
        nutrition_fact: {
          carbo: result[0].carbo,
          protein: result[0].protein,
          lemak: result[0].lemak,
          calorie: result[0].calorie,
          serving_size: result[0].serving_size,
        },
      };
  
      res.status(200).json(formattedHistoryDetail);
    });

    
  } catch (error) {
    console.error('Error:', error);
    res.status(500).json({ message: 'Internal Server Error' });
  }
});

module.exports = router;
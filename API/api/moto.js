const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');

const router = express.Router();
const connection = mysql.createConnection({
  host: 'localhost',
  user: 'root',
  password: '',
  database: 'motoconnect_alpha'
});

connection.connect(err => {
  if (err) {
    console.error('Error de conexión a la base de datos:', err);
  } else {
    console.log('Conexión exitosa a la base de datos');
  }
});

router.use(bodyParser.json());

router.get('/motos', (req, res) => {
  connection.query('SELECT * FROM Moto', (error, results) => {
    if (error) {
      console.error('Error al obtener motos:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    } else {
      res.json(results);
    }
  });
});

router.get('/types', (req, res) => {
  connection.query('SELECT DISTINCT type FROM Moto', (error, results) => {
    if (error) {
      console.error('Error al obtener los tipos de moto:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    } else {
      const types = results.map(row => row.type);
      res.json(types);
    }
  });
});

router.get('/buscar-moto', (req, res) => {
  const { make, model, displacement, type, year } = req.query;

  if (!make || !model || !displacement || !type || !year) {
    return res.status(400).json({ error: 'Por favor, proporciona todos los campos requeridos' });
  }

  connection.query(
    'SELECT * FROM Moto WHERE make = ? AND model = ? AND displacement = ? AND type = ? AND year = ?',
    [make, model, displacement, type, year],
    (error, results) => {
      if (error) {
        console.error('Error al buscar moto:', error);
        res.status(500).json({ error: 'Error interno del servidor' });
      } else {
        if (results.length === 0) {
          res.status(404).json({ message: 'No se encontró ninguna moto con los detalles proporcionados' });
        } else {
          res.json(results[0]);
        }
      }
    }
  );
});

router.get('/motoByUserEmail/:userEmail', (req, res) => {
  const userEmail = req.params.userEmail;
  connection.query('SELECT idMoto FROM Usuario WHERE email = ?', [userEmail], (error, results) => {
    if (error) {
      console.error('Error al obtener el ID de la moto del usuario:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    } else {
      if (results.length === 0 || !results[0].idMoto) {
        res.status(404).json({ message: 'No se encontró ninguna moto asociada al usuario' });
      } else {
        const motoId = results[0].idMoto;
        connection.query('SELECT * FROM Moto WHERE id = ?', [motoId], (error, motoResult) => {
          if (error) {
            console.error('Error al obtener las características de la moto:', error);
            res.status(500).json({ error: 'Error interno del servidor' });
          } else {
            if (motoResult.length === 0) {
              res.status(404).json({ message: 'No se encontró ninguna moto con el ID asociado al usuario' });
            } else {
              res.json(motoResult[0]);
            }
          }
        });
      }
    }
  });
});

router.post('/motos', (req, res) => {
  const { make, model, displacement,type,year } = req.body;

  if (!make || !model || !displacement || !type || !year) {
    return res.status(400).json({ error: 'Por favor, proporciona todos los campos requeridos' });
  }

  connection.query('INSERT INTO Moto (make, model, displacement,type, year) VALUES (?, ?, ?, ?, ?)', [make, model, displacement,type,year], (error, result) => {
    if (error) {
      console.error('Error al crear moto:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    } else {
      res.status(201).json({ message: 'Moto creada exitosamente', id: result.insertId });
    }
  });
});

router.put('/motos/:id', (req, res) => {
  const { make, model, displacement,type,year } = req.body;
  const idMoto = req.params.id;
  
  connection.query('UPDATE Moto SET make=?, model=?, displacement=?,type=? ,year=? WHERE id=?', [make, model, displacement,type,year, idMoto], (error, result) => {
    if (error) {
      console.error('Error al actualizar moto:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    } else {
      res.json({ message: 'Moto actualizada exitosamente' });
    }
  });
});

router.delete('/motos/:id', (req, res) => {
  const idMoto = req.params.id;
  
  connection.query('DELETE FROM Moto WHERE id=?', [idMoto], (error, result) => {
    if (error) {
      console.error('Error al eliminar moto:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    } else {
      res.json({ message: 'Moto eliminada exitosamente' });
    }
  });
});

module.exports = router;

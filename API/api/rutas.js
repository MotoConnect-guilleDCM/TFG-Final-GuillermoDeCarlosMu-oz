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

router.get('/rutas', (req, res) => {
  connection.query('SELECT * FROM Ruta', (error, results) => {
    if (error) {
      console.error('Error al obtener rutas:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    } else {
      res.json(results);
    }
  });
});

router.post('/rutas', (req, res) => {
  const { nombre, descripcion, tipoMoto, userId, coordenadas } = req.body;

  if (!nombre || !userId || !coordenadas || coordenadas.length === 0) {
    return res.status(400).json({ error: 'Por favor, proporciona todos los campos requeridos incluyendo coordenadas' });
  }

  connection.query(
    'INSERT INTO Ruta (NombreRuta, descripcion, tipoMoto, userId) VALUES (?, ?, ?, ?)',
    [nombre, descripcion, tipoMoto, userId],
    (error, result) => {
      if (error) {
        console.error('Error al crear ruta:', error);
        res.status(500).json({ error: 'Error interno del servidor' });
      } else {
        const rutaID = result.insertId;
        const coordenadasValues = coordenadas.map(coord => [rutaID, coord.latitude, coord.longitude]);

        connection.query('INSERT INTO CoordenadaRuta (rutaID, Latitud, Longitud) VALUES ?', [coordenadasValues], (error, result) => {
          if (error) {
            console.error('Error al insertar coordenadas de ruta:', error);
            res.status(500).json({ error: 'Error interno del servidor' });
          } else {
            res.status(201).json({ message: 'Ruta creada exitosamente', id: rutaID });
          }
        });
      }
    }
  );
});



router.put('/rutas/:id', (req, res) => {
  const { nombre, userId } = req.body;
  const idRuta = req.params.id;
  
  connection.query('UPDATE Ruta SET NombreRuta=?, userId=? WHERE id=?', [nombre, userId, idRuta], (error, result) => {
    if (error) {
      console.error('Error al actualizar ruta:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    } else {
      res.json({ message: 'Ruta actualizada exitosamente' });
    }
  });
});

router.delete('/rutas/:id', (req, res) => {
  const idRuta = req.params.id;
  
  connection.query('DELETE FROM Ruta WHERE id=?', [idRuta], (error, result) => {
    if (error) {
      console.error('Error al eliminar ruta:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    } else {
      res.json({ message: 'Ruta eliminada exitosamente' });
    }
  });
});

router.get('/rutas/:id', (req, res) => {
  const idRuta = req.params.id;

  connection.query('SELECT * FROM Ruta WHERE id = ?', [idRuta], (error, results) => {
    if (error) {
      console.error('Error al obtener ruta por ID:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    } else {
      if (results.length === 0) {
        res.status(404).json({ error: 'Ruta no encontrada' });
      } else {
        res.json(results[0]);
      }
    }
  });
});

router.get('/rutas/:id/coordenadas', (req, res) => {
  const idRuta = req.params.id;

  connection.query('SELECT * FROM CoordenadaRuta WHERE rutaID = ?', [idRuta], (error, results) => {
    if (error) {
      console.error('Error al obtener coordenadas de la ruta:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    } else {
      res.json(results);
    }
  });
});

router.delete('/rutas/:id/coordenadas', (req, res) => {
  const idRuta = req.params.id;

  connection.query('DELETE FROM CoordenadaRuta WHERE rutaID = ?', [idRuta], (error, result) => {
    if (error) {
      console.error('Error al eliminar coordenadas de la ruta:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    } else {
      res.json({ message: 'Todas las coordenadas de la ruta fueron eliminadas exitosamente' });
    }
  });
});

module.exports = router;

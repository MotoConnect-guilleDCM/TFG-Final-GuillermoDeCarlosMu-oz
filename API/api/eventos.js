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


// Endpoint para obtener todos los eventos
router.get('/eventos', (req, res) => {
  const query = `
    SELECT Evento.*, Usuario.username, 
    (SELECT COUNT(*) FROM UserEvent WHERE UserEvent.eventId = Evento.id) AS inscritos
    FROM Evento 
    JOIN Usuario ON Evento.idCreador = Usuario.id
  `;
  connection.query(query, (error, results) => {
    if (error) {
      console.error('Error al obtener eventos:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    } else {
      res.json(results);
    }
  });
});

// Endpoint para obtener los nombres de usuarios inscritos en un evento específico
router.get('/nombresInscritos/:idEvento', (req, res) => {
  const idEvento = req.params.idEvento;
  const query = `
    SELECT Usuario.username
    FROM Usuario
    JOIN UserEvent ON Usuario.id = UserEvent.userId
    WHERE UserEvent.eventId = ?
  `;
  connection.query(query, [idEvento], (error, results) => {
    if (error) {
      console.error('Error al obtener nombres de usuarios inscritos:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    } else {
      const nombresInscritos = results.map(result => result.username);
      res.json(nombresInscritos);
    }
  });
});

// Endpoint para verificar si un usuario está inscrito en un evento
router.get('/usuario-inscrito/:userId/:eventId', (req, res) => {
  const { userId, eventId } = req.params;

  if (!userId || !eventId) {
    return res.status(400).json({ error: 'Por favor, proporciona los IDs de usuario y evento' });
  }

  connection.query('SELECT * FROM UserEvent WHERE userId = ? AND eventId = ?', 
    [userId, eventId], 
    (error, results) => {
      if (error) {
        console.error('Error al verificar la inscripción del usuario en el evento:', error);
        res.status(500).json({ error: 'Error interno del servidor' });
      } else {
        if (results.length > 0) {
          // El usuario está inscrito en el evento
          res.status(200).json({ inscrito: true });
        } else {
          // El usuario no está inscrito en el evento
          res.status(200).json({ inscrito: false });
        }
      }
  });
});

// Endpoint para crear un evento
router.post('/eventos/:idCreador', (req, res) => {
  const { nombreEvento, descripcion, tipoMoto, fechaEvento } = req.body;
  const { idCreador } = req.params;

  if (!nombreEvento || !descripcion || !tipoMoto || !fechaEvento || !idCreador) {
    return res.status(400).json({ error: 'Por favor, proporciona todos los campos requeridos' });
  }

  connection.query('INSERT INTO Evento (nombreEvento, descripcion, tipoMoto, fechaEvento, idCreador) VALUES (?, ?, ?, ?,?)', 
    [nombreEvento, descripcion, tipoMoto, fechaEvento, idCreador], 
    (error, result) => {
      if (error) {
        console.error('Error al crear evento:', error);
        res.status(500).json({ error: 'Error interno del servidor' });
      } else {
        res.status(201).json({ message: 'Evento creado exitosamente', id: result.insertId });
      }
  });
});

// Endpoint para inscribir un usuario en un evento
router.post('/inscribirse/:userId/:eventId', (req, res) => {
  const { userId, eventId } = req.params;

  if (!userId || !eventId) {
    return res.status(400).json({ error: 'Por favor, proporciona los IDs de usuario y evento' });
  }

  connection.query('INSERT INTO UserEvent (userId, eventId) VALUES (?, ?)', 
    [userId, eventId], 
    (error, result) => {
      if (error) {
        console.error('Error al inscribir usuario al evento:', error);
        res.status(500).json({ error: 'Error interno del servidor' });
      } else {
        res.status(201).json({ message: 'Usuario inscrito al evento exitosamente' });
      }
  });
});

// Endpoint para eliminar un evento
router.delete('/eventos/:idEvento', (req, res) => {
  const { idEvento } = req.params;

  if (!idEvento) {
    return res.status(400).json({ error: 'Proporciona el ID del evento' });
  }

  connection.query('DELETE FROM Evento WHERE id = ?', idEvento, (error, result) => {
    if (error) {
      console.error('Error al eliminar el evento:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    } else {
      res.status(200).json({ message: 'Evento eliminado exitosamente' });
    }
  });
});

router.delete('/desinscribirse/:userId/:eventId', (req, res) => {
  const { userId, eventId } = req.params;

  if (!userId || !eventId) {
    return res.status(400).json({ error: 'Por favor, proporciona los IDs de usuario y evento' });
  }

  connection.query('DELETE FROM UserEvent WHERE userId = ? AND eventId = ?', 
    [userId, eventId], 
    (error, result) => {
      if (error) {
        console.error('Error al desinscribir usuario del evento:', error);
        res.status(500).json({ error: 'Error interno del servidor' });
      } else {
        res.status(200).json({ message: 'Usuario desinscrito del evento exitosamente' });
      }
  });
});


module.exports = router;

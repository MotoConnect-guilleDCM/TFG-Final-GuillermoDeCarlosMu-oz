const express = require('express');
const router = express.Router();
const mysql = require('mysql');
const bodyParser = require('body-parser');

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

// Obtener todos los chats
router.get('/chats', (req, res) => {
  connection.query('SELECT * FROM chat', (error, results) => {
    if (error) {
      console.error('Error al obtener los chats:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    } else {
      res.status(200).json(results);
    }
  });
});

router.post('/chats/:userCreator', (req, res) => {
  const { nombreChat, tipoMoto } = req.body;
  const { userCreator } = req.params;

  if (!nombreChat || !tipoMoto || !userCreator) {
    return res.status(400).json({ error: 'Por favor, proporciona todos los campos requeridos' });
  }

  connection.query('INSERT INTO chat (nombreChat, tipoMoto, userCreator) VALUES (?, ?, ?)', 
    [nombreChat, tipoMoto, userCreator], 
    (error, result) => {
      if (error) {
        console.error('Error al crear chat:', error);
        res.status(500).json({ error: 'Error interno del servidor' });
      } else {
        res.status(201).json({ message: 'Chat creado exitosamente', id: result.insertId });
      }
  });
});

// Obtener mensajes de un chat
router.get('/chats/:groupId/mensajes', (req, res) => {
  const { groupId } = req.params;

  connection.query('SELECT * FROM mensajesChat WHERE groupId = ?', [groupId], (error, results) => {
    if (error) {
      console.error('Error al obtener los mensajes:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    } else {
      res.status(200).json(results);
    }
  });
});

// Obtener ID del chat por nombre
router.get('/chats/nombre/:nombreChat', (req, res) => {
  const { nombreChat } = req.params;

  if (!nombreChat) {
    return res.status(400).json({ error: 'Por favor, proporciona el nombre del chat' });
  }

  connection.query('SELECT id FROM chat WHERE nombreChat = ?', [nombreChat], (error, results) => {
    if (error) {
      console.error('Error al obtener el ID del chat por nombre:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    } else {
      if (results.length === 0) {
        res.status(404).json({ error: 'No se encontró ningún chat con el nombre proporcionado' });
      } else {
        res.status(200).json({ id: results[0].id });
      }
    }
  });
});


// Enviar un mensaje en un chat
router.post('/chats/:groupId/mensajes', (req, res) => {
  const { groupId } = req.params;
  const { userId, mensaje } = req.body;

  if (!userId || !mensaje) {
    return res.status(400).json({ error: 'Por favor, proporciona todos los campos requeridos' });
  }

  connection.query('INSERT INTO mensajesChat (userId, groupId, mensaje) VALUES (?, ?, ?)', 
    [userId, groupId, mensaje], 
    (error, result) => {
      if (error) {
        console.error('Error al enviar mensaje:', error);
        res.status(500).json({ error: 'Error interno del servidor' });
      } else {
        res.status(201).json({ message: 'Mensaje enviado exitosamente', id: result.insertId });
      }
  });
});


// Agregar un usuario a un chat
router.post('/chats/:chatId/usuarios/:userId', (req, res) => {
  const { chatId, userId } = req.params;

  if (!chatId || !userId) {
    return res.status(400).json({ error: 'Por favor, proporciona los IDs de chat y usuario' });
  }

  connection.query('INSERT INTO chatuser (chatId, userId) VALUES (?, ?)', 
    [chatId, userId], 
    (error, result) => {
      if (error) {
        console.error('Error al agregar usuario al chat:', error);
        res.status(500).json({ error: 'Error interno del servidor' });
      } else {
        res.status(201).json({ message: 'Usuario agregado al chat exitosamente' });
      }
  });
});

module.exports = router;

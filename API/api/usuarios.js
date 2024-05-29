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

router.get('/usuarios', (req, res) => {
  connection.query('SELECT * FROM usuario', (error, results) => {
    if (error) {
      console.error('Error al obtener usuarios:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    } else {
      res.json(results);
    }
  });
});

router.get('/usuarios/obtener-id', (req, res) => {
  const email = req.query.email; 

  connection.query('SELECT id FROM Usuario WHERE email = ?', [email], (error, results) => {
    if (error) {
      console.error('Error al obtener ID de usuario por email:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    } else {
      if (results.length > 0) {
        res.json({ id: results[0].id });
      } else {
        res.status(404).json({ error: 'No se encontró ningún usuario con ese email' });
      }
    }
  });
});

router.get('/usuarios/obtener-username/:id', (req, res) => {
  const id = req.params.id; 

  connection.query('SELECT username FROM Usuario WHERE id = ?', [id], (error, results) => {
    if (error) {
      console.error('Error al obtener nombre de usuario por ID de usuario:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    } else {
      if (results.length > 0) {
        res.json({ username: results[0].username });
      } else {
        res.status(404).json({ error: 'No se encontró ningún usuario con ese ID' });
      }
    }
  });
});


router.get('/usuarios/obtener-username', (req, res) => {
  const email = req.query.email; 

  connection.query('SELECT username FROM Usuario WHERE email = ?', [email], (error, results) => {
    if (error) {
      console.error('Error al obtener ID de usuario por email:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    } else {
      if (results.length > 0) {
        res.json({ id: results[0].id });
      } else {
        res.status(404).json({ error: 'No se encontró ningún usuario con ese email' });
      }
    }
  });
});



router.post('/usuarios', (req, res) => {
  const { username, email, idMoto } = req.body;
  connection.query('INSERT INTO Usuario (username, email) VALUES (?, ?)', [username, email], (error, result) => {
    if (error) {
      console.error('Error al crear usuario:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    } else {
      res.status(201).json({ message: 'Usuario creado exitosamente', id: result.insertId });
    }
  });
});

router.put('/usuarios/:id', (req, res) => {
  const { username, email, idMoto } = req.body;
  const idUsuario = req.params.id;
  connection.query('UPDATE Usuario SET username=?, email=?, idMoto=? WHERE id=?', [username, email, idMoto, idUsuario], (error, result) => {
    if (error) {
      console.error('Error al actualizar usuario:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    } else {
      res.json({ message: 'Usuario actualizado exitosamente' });
    }
  });
});

router.put('/usuarios/:idUsuario/asignar-moto/:idMoto', async (req, res) => {
  try {
    const idUsuario = req.params.idUsuario;
    const idMoto = req.params.idMoto;

    connection.query('UPDATE Usuario SET idMoto=? WHERE id=?', [idMoto, idUsuario], (error, result) => {
      if (error) {
        console.error('Error al asignar la moto al usuario:', error);
        res.status(500).json({ error: 'Error interno del servidor' });
      } else {
        res.status(200).json({ message: 'Moto asignada exitosamente al usuario' });
      }
    });
  } catch (error) {
    console.error('Error al asignar la moto al usuario:', error);
    res.status(500).json({ error: 'Hubo un problema al asignar la moto al usuario' });
  }
});


router.delete('/usuarios/:id', (req, res) => {
  const idUsuario = req.params.id;
  connection.query('DELETE FROM Usuario WHERE id=?', [idUsuario], (error, result) => {
    if (error) {a
      console.error('Error al eliminar usuario:', error);
      res.status(500).json({ error: 'Error interno del servidor' });
    } else {
      res.json({ message: 'Usuario eliminado exitosamente' });
    }
  });
});

module.exports = router;

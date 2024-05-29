const express = require('express');
const bodyParser = require('body-parser');

const usuariosRouter = require('./api/usuarios');
const eventosRouter = require('./api/eventos');
const motoRouter = require('./api/moto');
const chatRouter = require('./api/chat');
const rutasRouter = require('./api/rutas');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(bodyParser.json()); 

app.use('/api/usuarios', usuariosRouter);
app.use('/api/eventos', eventosRouter);
app.use('/api/moto', motoRouter);
app.use('/api/chat', chatRouter);
app.use('/api/rutas', rutasRouter);

app.listen(PORT, () => {
  console.log(`Servidor escuchando en el puerto ${PORT}`);
});

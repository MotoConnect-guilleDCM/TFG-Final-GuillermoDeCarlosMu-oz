-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 29-05-2024 a las 16:01:27
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `motoconnect_alpha`
--

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `chat`
--

CREATE TABLE `chat` (
  `id` int(11) NOT NULL,
  `nombreChat` text DEFAULT NULL,
  `tipoMoto` text DEFAULT NULL,
  `userCreator` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `chat`
--

INSERT INTO `chat` (`id`, `nombreChat`, `tipoMoto`, `userCreator`) VALUES
(15, 'ChatEndureros', 'Enduro / offroad', 1),
(16, 'DaniChat', 'Super motard', 17),
(18, 'Prueba', 'Enduro / offroad', 1),
(19, 'Gabri', 'Sport', 19);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `coordenadaruta`
--

CREATE TABLE `coordenadaruta` (
  `CoordenadaID` int(11) NOT NULL,
  `rutaID` int(11) DEFAULT NULL,
  `Latitud` decimal(10,8) DEFAULT NULL,
  `Longitud` decimal(11,8) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `coordenadaruta`
--

INSERT INTO `coordenadaruta` (`CoordenadaID`, `rutaID`, `Latitud`, `Longitud`) VALUES
(65, 5, 42.46980422, -2.42924593),
(66, 5, 42.46526779, -2.43314177),
(67, 5, 42.46421614, -2.43366111),
(68, 5, 42.46487627, -2.43636511),
(69, 5, 42.46545304, -2.43881196),
(70, 5, 42.46602931, -2.44141135),
(71, 5, 42.46628035, -2.44236454),
(72, 5, 42.46626452, -2.44341429),
(73, 5, 42.46554208, -2.44378913),
(74, 6, 42.46980422, -2.42924593),
(75, 6, 42.47768865, -2.42729690),
(76, 6, 42.47922547, -2.42974710),
(77, 6, 42.47996185, -2.43244506),
(78, 6, 42.47976675, -2.43577670),
(79, 6, 42.48263850, -2.43400577),
(80, 6, 42.48513726, -2.43052125),
(81, 6, 42.48647684, -2.42648184),
(82, 6, 42.48736272, -2.42482759),
(83, 6, 42.48805326, -2.42325917),
(84, 7, 42.46980422, -2.42924593),
(85, 7, 42.46524578, -2.43300665),
(86, 7, 42.46633056, -2.43251514),
(87, 7, 42.46751919, -2.43195321),
(88, 7, 42.46838430, -2.43161928),
(89, 7, 42.46814218, -2.43042536),
(90, 7, 42.46742199, -2.42826786),
(91, 7, 42.46713287, -2.42695559),
(92, 8, 42.46980422, -2.42924593),
(93, 8, 42.46388348, -2.43946943),
(94, 8, 42.46297106, -2.43989456),
(95, 8, 42.46223423, -2.44017150),
(96, 8, 42.46098738, -2.44081959),
(97, 8, 42.45973975, -2.44130876),
(98, 8, 42.46010237, -2.44282991),
(99, 8, 42.46034328, -2.44395912),
(100, 8, 42.46078406, -2.44581521),
(101, 8, 42.45824771, -2.44538505),
(102, 8, 42.48452852, -2.44619071),
(103, 8, 42.48706306, -2.44514499),
(104, 8, 42.48988008, -2.44212080),
(105, 9, 42.46980422, -2.42924593),
(106, 9, 39.59147870, -3.25955316),
(107, 9, 39.59587984, -3.25881992),
(108, 9, 39.58494353, -3.26133415),
(109, 9, 39.57947292, -3.26701406);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `evento`
--

CREATE TABLE `evento` (
  `id` int(11) NOT NULL,
  `nombreEvento` varchar(255) DEFAULT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `tipoMoto` varchar(255) DEFAULT NULL,
  `fechaEvento` date DEFAULT NULL,
  `idCreador` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `evento`
--

INSERT INTO `evento` (`id`, `nombreEvento`, `descripcion`, `tipoMoto`, `fechaEvento`, `idCreador`) VALUES
(1, 'Quedada endureros', 'Nos juntaremos todos en el monte Corvo de logrono.\nHabra merienda y todo patrocinado por RedBull', 'Enduro / offroad', '2024-06-03', 1),
(3, 'Nakeds no es mi tipo', 'Hola soy jose que tal teachers, estoy en mi absoluto prime', 'Naked bike', '2024-10-18', 3),
(5, 'HolaPruebaId', 'asfuabslfasofnasiubfasihfboasfibasfiasobfasifbasifobasfbiasbf', 'Sport', '2024-05-28', 1),
(6, 'Rellenandoeventos', 'lfiasufbasofiabsfiasobasiobfoashofbasifbasifabsfoasiasifbasifbas', 'Cross / motocross', '2024-05-30', 1),
(7, 'SigueEvento', 'asgasgbaslgahsgiashgasphgaspghas', 'Naked bike', '2024-05-29', 18),
(8, 'GabriEvent', 'Evento para los amantes de las R1, jaajajjajajaja hola ana mondongo', 'Sport', '2024-05-31', 19);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mensajeschat`
--

CREATE TABLE `mensajeschat` (
  `id` bigint(20) UNSIGNED NOT NULL,
  `userId` int(11) DEFAULT NULL,
  `groupId` int(11) DEFAULT NULL,
  `mensaje` text DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `mensajeschat`
--

INSERT INTO `mensajeschat` (`id`, `userId`, `groupId`, `mensaje`, `timestamp`) VALUES
(5, 1, 15, 'hola primera prueba', '2024-05-26 14:27:32'),
(11, 1, 15, 'asf', '2024-05-26 14:35:41'),
(12, 1, 15, 'hola me ves?', '2024-05-26 14:36:28'),
(13, 3, 15, 'si bro', '2024-05-26 14:37:21'),
(14, 1, 15, 'diooooos joder que contento estoy de que vaya', '2024-05-26 14:40:53'),
(18, 1, 15, 'd', '2024-05-26 15:33:45'),
(19, 1, 15, 'hola', '2024-05-26 15:46:31'),
(20, 1, 15, 'va todo no?', '2024-05-26 15:50:10'),
(21, 1, 15, 'vava', '2024-05-26 15:53:36'),
(22, 16, 15, 'va si no?', '2024-05-26 16:19:34'),
(23, 1, 15, 'hola?', '2024-05-26 16:38:54'),
(24, 1, 15, 'sd', '2024-05-27 14:41:41'),
(25, 17, 15, 'hola soy un pelele', '2024-05-27 18:13:52'),
(26, 17, 16, 'HOla bienvenidos a mi chat de gays', '2024-05-27 18:14:34'),
(27, 1, 16, 'holaaa', '2024-05-28 15:35:33'),
(28, 18, 15, 'hola que tal soy nuevo', '2024-05-28 16:04:57'),
(29, 18, 16, 'asfs', '2024-05-28 16:05:38'),
(30, 1, 18, 'holaaa', '2024-05-28 16:18:27'),
(31, 19, 19, 'hola', '2024-05-28 16:22:08');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `moto`
--

CREATE TABLE `moto` (
  `id` int(11) NOT NULL,
  `make` varchar(255) DEFAULT NULL,
  `model` varchar(255) DEFAULT NULL,
  `displacement` varchar(255) DEFAULT NULL,
  `type` varchar(255) DEFAULT NULL,
  `year` varchar(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `moto`
--

INSERT INTO `moto` (`id`, `make`, `model`, `displacement`, `type`, `year`) VALUES
(1, 'KTM', '250 EXC TPI', '249.0 ccm (15.19 cubic inches)', 'Enduro / offroad', '2022'),
(2, 'Derbi', 'Senda X-treme 50 SM', '50.0 ccm (3.05 cubic inches)', 'Super motard', '2022'),
(3, 'KTM', '790 Duke', '799.0 ccm (48.75 cubic inches)', 'Naked bike', '2020'),
(4, 'Benelli', '502C', '500.0 ccm (30.51 cubic inches)', 'Allround', '2021'),
(5, 'Sherco', '125 SE Racing', '124.8 ccm (7.62 cubic inches)', 'Enduro / offroad', '2021'),
(6, 'Sherco', '125 SE Racing', '124.8 ccm (7.62 cubic inches)', 'Enduro / offroad', '2021'),
(7, 'Sherco', '125 SE Racing', '124.8 ccm (7.62 cubic inches)', 'Enduro / offroad', '2021'),
(8, 'Sherco', '125 SE Racing', '124.8 ccm (7.62 cubic inches)', 'Enduro / offroad', '2021'),
(9, 'Sherco', '450 SEF Factory', '449.4 ccm (27.42 cubic inches)', 'Enduro / offroad', '2022'),
(10, 'Sherco', '450 SEF Factory', '449.4 ccm (27.42 cubic inches)', 'Enduro / offroad', '2022'),
(11, 'Sherco', '300 SEF Factory', '303.7 ccm (18.53 cubic inches)', 'Enduro / offroad', '2022'),
(12, 'Sherco', '300 SEF Factory', '303.7 ccm (18.53 cubic inches)', 'Enduro / offroad', '2022'),
(13, 'Sherco', '300 SEF Factory', '303.7 ccm (18.53 cubic inches)', 'Enduro / offroad', '2022'),
(14, 'Sherco', '250 SEF Factory', '248.4 ccm (15.16 cubic inches)', 'Enduro / offroad', '2022'),
(15, 'Sherco', '250 SEF Factory', '248.4 ccm (15.16 cubic inches)', 'Enduro / offroad', '2022'),
(16, 'Yamaha', 'R1', '998.0 ccm (60.90 cubic inches)', 'Sport', '2022'),
(17, 'Sherco', '250 SE Factory', '249.3 ccm (15.21 cubic inches)', 'Enduro / offroad', '2021'),
(18, 'KTM', '300 EXC TPI Six Days', '293.0 ccm (17.88 cubic inches)', 'Enduro / offroad', '2022'),
(19, 'Honda', 'CB500X', '471.0 ccm (28.74 cubic inches)', 'Sport', '2022'),
(20, 'Aprilia', 'RS 660', '659.0 ccm (40.21 cubic inches)', 'Sport', '2022'),
(21, 'Honda', 'CB150F                                           ', '149.2 ccm (9.10 cubic inches)', 'Allround', '2022'),
(22, 'KTM', '150 SX', '144.0 ccm (8.79 cubic inches)', 'Cross / motocross', '2022'),
(23, 'Aprilia', 'RS 660', '659.0 ccm (40.21 cubic inches)', 'Sport', '2022'),
(24, 'KTM', '125 Duke', '125.0 ccm (7.63 cubic inches)', 'Naked bike', '2021'),
(25, 'Yamaha', 'R1', '998.0 ccm (60.90 cubic inches)', 'Sport', '2022');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ruta`
--

CREATE TABLE `ruta` (
  `id` int(11) NOT NULL,
  `userId` int(11) DEFAULT NULL,
  `NombreRuta` varchar(100) DEFAULT NULL,
  `descripcion` varchar(255) NOT NULL,
  `tipoMoto` varchar(255) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `ruta`
--

INSERT INTO `ruta` (`id`, `userId`, `NombreRuta`, `descripcion`, `tipoMoto`) VALUES
(5, 1, 'PruebaV2', 'sagsagasgg', 'Naked bike'),
(6, 1, 'GuilleRuta', 'Ruta de prueba para recomendedRoutes', 'Enduro / offroad'),
(7, 18, 'SiguRuta', 'asfgasfbasf', 'Naked bike'),
(8, 19, 'GabriRuta', 'RutaPruebaGabri', 'Sport'),
(9, 19, 'RutaVillacanas', 'asfasgas', 'Enduro / offroad');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `userevent`
--

CREATE TABLE `userevent` (
  `id` int(11) NOT NULL,
  `userId` int(11) DEFAULT NULL,
  `eventId` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `userevent`
--

INSERT INTO `userevent` (`id`, `userId`, `eventId`) VALUES
(4, 3, 3),
(5, 1, 3),
(10, 1, 1),
(12, 1, 5),
(13, 1, 6),
(16, 18, 7),
(17, 19, 8);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuario`
--

CREATE TABLE `usuario` (
  `id` int(11) NOT NULL,
  `username` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `idMoto` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuario`
--

INSERT INTO `usuario` (`id`, `username`, `email`, `idMoto`) VALUES
(1, 'guilleDCM', 'decarlosguille@gmail.com', 1),
(2, 'ana', 'aperez@iescomercio.com', 2),
(3, 'jose23gp', 'jose23gp@gmail.com', 3),
(15, 'hola', 'hola@gmail.com', NULL),
(16, 'guillerrerr', 'dcm@gmail.com', 22),
(17, 'daniAnglada', 'daniaadc@gmail.com', 20),
(18, 'sigu', 'davidSigu@gmail.com', 24),
(19, 'gabrielOcatvian', 'octavian@gmail.com', 16);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `chat`
--
ALTER TABLE `chat`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `coordenadaruta`
--
ALTER TABLE `coordenadaruta`
  ADD PRIMARY KEY (`CoordenadaID`),
  ADD KEY `rutaID` (`rutaID`);

--
-- Indices de la tabla `evento`
--
ALTER TABLE `evento`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idCreador` (`idCreador`);

--
-- Indices de la tabla `mensajeschat`
--
ALTER TABLE `mensajeschat`
  ADD PRIMARY KEY (`id`),
  ADD KEY `userId` (`userId`),
  ADD KEY `groupId` (`groupId`);

--
-- Indices de la tabla `moto`
--
ALTER TABLE `moto`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `ruta`
--
ALTER TABLE `ruta`
  ADD PRIMARY KEY (`id`),
  ADD KEY `userId` (`userId`);

--
-- Indices de la tabla `userevent`
--
ALTER TABLE `userevent`
  ADD PRIMARY KEY (`id`),
  ADD KEY `userId` (`userId`),
  ADD KEY `eventId` (`eventId`);

--
-- Indices de la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idMoto` (`idMoto`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `chat`
--
ALTER TABLE `chat`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT de la tabla `coordenadaruta`
--
ALTER TABLE `coordenadaruta`
  MODIFY `CoordenadaID` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=110;

--
-- AUTO_INCREMENT de la tabla `evento`
--
ALTER TABLE `evento`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `mensajeschat`
--
ALTER TABLE `mensajeschat`
  MODIFY `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=32;

--
-- AUTO_INCREMENT de la tabla `moto`
--
ALTER TABLE `moto`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- AUTO_INCREMENT de la tabla `ruta`
--
ALTER TABLE `ruta`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `userevent`
--
ALTER TABLE `userevent`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `usuario`
--
ALTER TABLE `usuario`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `coordenadaruta`
--
ALTER TABLE `coordenadaruta`
  ADD CONSTRAINT `coordenadaruta_ibfk_1` FOREIGN KEY (`rutaID`) REFERENCES `ruta` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `evento`
--
ALTER TABLE `evento`
  ADD CONSTRAINT `evento_ibfk_1` FOREIGN KEY (`idCreador`) REFERENCES `usuario` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `mensajeschat`
--
ALTER TABLE `mensajeschat`
  ADD CONSTRAINT `mensajeschat_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `usuario` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `mensajeschat_ibfk_2` FOREIGN KEY (`groupId`) REFERENCES `chat` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `ruta`
--
ALTER TABLE `ruta`
  ADD CONSTRAINT `ruta_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `usuario` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `userevent`
--
ALTER TABLE `userevent`
  ADD CONSTRAINT `userevent_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `usuario` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `userevent_ibfk_2` FOREIGN KEY (`eventId`) REFERENCES `evento` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `usuario`
--
ALTER TABLE `usuario`
  ADD CONSTRAINT `usuario_ibfk_1` FOREIGN KEY (`idMoto`) REFERENCES `moto` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

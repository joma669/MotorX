-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 09-09-2024 a las 22:39:59
-- Versión del servidor: 10.4.32-MariaDB
-- Versión de PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `concesionario`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `AjustarInventario` ()   BEGIN
    UPDATE vehiculos v
    JOIN (
        SELECT vehiculo_id, SUM(CASE WHEN tipo_transaccion = 'entrada' THEN cantidad ELSE -cantidad END) AS ajuste
        FROM transacciones
        GROUP BY vehiculo_id
    ) t ON v.vehiculo_id = t.vehiculo_id
    SET v.cantidad_disponible = COALESCE(v.cantidad_disponible, 0) + t.ajuste;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultaInventario` ()   BEGIN
    SELECT marca, modelo, SUM(disponible) AS saldo_inventario
    FROM vehiculos
    GROUP BY marca, modelo;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `ConsultarTransacciones` (IN `p_vehiculo_id` INT)   BEGIN
    SELECT * FROM transacciones
    WHERE vehiculo_id = p_vehiculo_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `LimpiarTransacciones` ()   BEGIN
    DELETE FROM transacciones
    WHERE fecha < NOW() - INTERVAL 1 YEAR;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `RegistrarEntrada` (IN `p_vehiculo_id` INT, IN `p_cantidad` INT)   BEGIN
    INSERT INTO transacciones (vehiculo_id, tipo_transaccion, cantidad)
    VALUES (p_vehiculo_id, 'entrada', p_cantidad);

    UPDATE vehiculos
    SET cantidad_disponible = cantidad_disponible + p_cantidad
    WHERE vehiculo_id = p_vehiculo_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `RegistrarSalida` (IN `p_vehiculo_id` INT, IN `p_cantidad` INT)   BEGIN
    INSERT INTO transacciones (vehiculo_id, tipo_transaccion, cantidad)
    VALUES (p_vehiculo_id, 'salida', p_cantidad);

    UPDATE vehiculos
    SET cantidad_disponible = cantidad_disponible - p_cantidad
    WHERE vehiculo_id = p_vehiculo_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `RegistrarTransaccion` (IN `p_vehiculo_id` INT, IN `p_tipo_transaccion` ENUM('entrada','salida'), IN `p_cantidad` INT)   BEGIN
    INSERT INTO transacciones (vehiculo_id, tipo_transaccion, cantidad)
    VALUES (p_vehiculo_id, p_tipo_transaccion, p_cantidad);

    UPDATE vehiculos
    SET cantidad_disponible = cantidad_disponible + 
        (CASE WHEN p_tipo_transaccion = 'entrada' THEN p_cantidad ELSE -p_cantidad END)
    WHERE vehiculo_id = p_vehiculo_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `VerInventario` ()   BEGIN
    SELECT v.vehiculo_id, v.marca, v.modelo, COALESCE(v.cantidad_disponible, 0) AS saldo_actual
    FROM vehiculos v;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `clientes`
--

CREATE TABLE `clientes` (
  `cliente_id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `telefono` varchar(15) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `direccion` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `clientes`
--

INSERT INTO `clientes` (`cliente_id`, `nombre`, `telefono`, `email`, `direccion`) VALUES
(1, 'Juan Pérez', '555-1234', 'juan.perez@email.com', 'Calle Falsa 123');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `empleados`
--

CREATE TABLE `empleados` (
  `empleado_id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `puesto` varchar(50) DEFAULT NULL,
  `telefono` varchar(15) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `numero_contacto` varchar(15) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `empleados`
--

INSERT INTO `empleados` (`empleado_id`, `nombre`, `puesto`, `telefono`, `email`, `numero_contacto`) VALUES
(1, 'Ana Gómez', 'Vendedora', '555-5678', 'ana.gomez@email.com', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `proveedores`
--

CREATE TABLE `proveedores` (
  `id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `direccion` varchar(255) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `fecha_registro` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `proveedores`
--

INSERT INTO `proveedores` (`id`, `nombre`, `direccion`, `telefono`, `email`, `fecha_registro`) VALUES
(1, 'Proveedor Ejemplo', '123 Calle Principal', '555-1234', 'contacto@ejemplo.com', '2024-08-27');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `transacciones`
--

CREATE TABLE `transacciones` (
  `transaccion_id` int(11) NOT NULL,
  `vehiculo_id` int(11) DEFAULT NULL,
  `tipo_transaccion` enum('entrada','salida') DEFAULT NULL,
  `cantidad` int(11) DEFAULT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `transacciones`
--

INSERT INTO `transacciones` (`transaccion_id`, `vehiculo_id`, `tipo_transaccion`, `cantidad`, `fecha`) VALUES
(1, 1, 'entrada', 10, '2024-09-09 20:29:52'),
(2, 1, 'salida', 5, '2024-09-09 20:29:56'),
(3, 1, 'entrada', 10, '2024-09-09 20:32:25'),
(4, 1, 'salida', 5, '2024-09-09 20:32:25');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vehiculos`
--

CREATE TABLE `vehiculos` (
  `vehiculo_id` int(11) NOT NULL,
  `marca` varchar(50) NOT NULL,
  `modelo` varchar(50) NOT NULL,
  `año` int(11) DEFAULT NULL,
  `precio` decimal(10,2) DEFAULT NULL,
  `tipo_de_carro` varchar(50) DEFAULT NULL,
  `disponible` tinyint(1) DEFAULT 1,
  `color` varchar(30) DEFAULT NULL,
  `cantidad_disponible` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `vehiculos`
--

INSERT INTO `vehiculos` (`vehiculo_id`, `marca`, `modelo`, `año`, `precio`, `tipo_de_carro`, `disponible`, `color`, `cantidad_disponible`) VALUES
(1, 'Toyota', 'Corolla', 2020, 18000.00, 'Sedán', 1, 'Blanco', 10),
(2, 'Ford', 'F-150', 2019, 25000.00, 'Camioneta', 1, 'Negro', 0),
(3, 'Chevrolet', 'Spark', 2021, 12000.00, 'Hatchback', 1, 'Rojo', 0),
(4, 'Honda', 'Civic', 2018, 17000.00, 'Sedán', 1, 'Azul', 0),
(5, 'Jeep', 'Wrangler', 2022, 30000.00, 'SUV', 1, 'Verde', 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas`
--

CREATE TABLE `ventas` (
  `venta_id` int(11) NOT NULL,
  `cliente_id` int(11) DEFAULT NULL,
  `vehiculo_id` int(11) DEFAULT NULL,
  `empleado_id` int(11) DEFAULT NULL,
  `fecha` date DEFAULT NULL,
  `tipo_de_pago` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `ventas`
--

INSERT INTO `ventas` (`venta_id`, `cliente_id`, `vehiculo_id`, `empleado_id`, `fecha`, `tipo_de_pago`) VALUES
(1, 101, 501, 301, '2024-08-15', 'Tarjeta de crédito'),
(2, 102, 502, 302, '2024-08-16', 'Efectivo'),
(3, 103, 503, 303, '2024-08-17', 'Transferencia bancaria'),
(4, 104, 504, 304, '2024-08-18', 'Tarjeta de débito'),
(5, 105, 505, 305, '2024-08-19', 'Efectivo');

--
-- Disparadores `ventas`
--
DELIMITER $$
CREATE TRIGGER `actualizar_inventario` AFTER INSERT ON `ventas` FOR EACH ROW BEGIN
  UPDATE inventario
  SET cantidad_disponible = cantidad_disponible - 1
  WHERE vehiculo_id = NEW.vehiculo_id;
END
$$
DELIMITER ;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `clientes`
--
ALTER TABLE `clientes`
  ADD PRIMARY KEY (`cliente_id`);

--
-- Indices de la tabla `empleados`
--
ALTER TABLE `empleados`
  ADD PRIMARY KEY (`empleado_id`);

--
-- Indices de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `transacciones`
--
ALTER TABLE `transacciones`
  ADD PRIMARY KEY (`transaccion_id`),
  ADD KEY `vehiculo_id` (`vehiculo_id`);

--
-- Indices de la tabla `vehiculos`
--
ALTER TABLE `vehiculos`
  ADD PRIMARY KEY (`vehiculo_id`);

--
-- Indices de la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD PRIMARY KEY (`venta_id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `transacciones`
--
ALTER TABLE `transacciones`
  MODIFY `transaccion_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `transacciones`
--
ALTER TABLE `transacciones`
  ADD CONSTRAINT `transacciones_ibfk_1` FOREIGN KEY (`vehiculo_id`) REFERENCES `vehiculos` (`vehiculo_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

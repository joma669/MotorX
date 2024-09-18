-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 17-09-2024 a las 00:20:26
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

CREATE DEFINER=`root`@`localhost` PROCEDURE `RegistrarTransaccion` (IN `p_vehiculo_id` INT, IN `p_tipo_transaccion` ENUM('entrada','salida'), IN `p_cantidad` INT)   BEGIN
    INSERT INTO transacciones (vehiculo_id, tipo_transaccion, cantidad)
    VALUES (p_vehiculo_id, p_tipo_transaccion, p_cantidad);

    UPDATE vehiculos
    SET cantidad_disponible = cantidad_disponible + 
        (CASE WHEN p_tipo_transaccion = 'entrada' THEN p_cantidad ELSE -p_cantidad END)
    WHERE vehiculo_id = p_vehiculo_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SalidaVehiculo` (IN `p_vehiculo_id` INT, IN `p_cantidad` INT)   BEGIN
    INSERT INTO transacciones (vehiculo_id, tipo_transaccion, cantidad)
    VALUES (p_vehiculo_id, 'salida', p_cantidad);

    UPDATE vehiculos
    SET cantidad_disponible = cantidad_disponible - p_cantidad
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
(1, 'Juan Pérez', '3203345698', 'juan.perez@email.com', 'Calle Falsa 123'),
(2, 'Carlos Martínez', '3201234567', 'carlos.martinez@gmail.com', 'Calle 123 #45-67, Bogotá'),
(3, 'Laura Rodríguez', '3119876543', 'laura.rodriguez@hotmail.com', 'Carrera 10 #20-30, Medellín'),
(4, 'Andrés Gómez', '3007654321', 'andres.gomez@yahoo.com', 'Avenida Siempre Viva 742, Cali'),
(5, 'María Pérez', '3132468090', 'maria.perez@gmail.com', 'Calle 50 #30-15, Barranquilla'),
(6, 'Jorge Sánchez', '3169087654', 'jorge.sanchez@outlook.com', 'Carrera 80 #50-20, Cartagena'),
(7, 'Sofía Ramírez', '3185432198', 'sofia.ramirez@hotmail.com', 'Calle 60 #40-25, Bucaramanga'),
(8, 'Pedro González', '3194321098', 'pedro.gonzalez@gmail.com', 'Carrera 25 #70-45, Manizales'),
(9, 'Lucía Torres', '3123456789', 'lucia.torres@yahoo.com', 'Calle 15 #10-10, Cúcuta'),
(10, 'Diego Vargas', '3156781234', 'diego.vargas@gmail.com', 'Avenida 3 #45-67, Santa Marta'),
(11, 'Ana Fernández', '3178901234', 'ana.fernandez@gmail.com', 'Carrera 55 #80-30, Pereira');

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
(1, 'Ana Gómez', 'Vendedora', '555-5678', 'ana.gomez@email.com', '3135669874'),
(2, 'Alejandro Ruiz', 'Gerente', '3101234567', 'alejandro.ruiz@empresa.com', '3107654321'),
(3, 'Camila Pérez', 'Vendedor', '3119876543', 'camila.perez@empresa.com', '3111234567'),
(4, 'Javier Gómez', 'Mecánico', '3207654321', 'javier.gomez@empresa.com', '3201234567'),
(5, 'Lucía Ramírez', 'Vendedor', '3229876543', 'lucia.ramirez@empresa.com', '3227654321'),
(6, 'Andrés Torres', 'Contador', '3132468090', 'andres.torres@empresa.com', '3137654321'),
(7, 'Sofía Gutiérrez', 'Auxiliar Administrativo', '3169087654', 'sofia.gutierrez@empresa.com', '3165432109'),
(8, 'Diego Herrera', 'Jefe de Taller', '3185432198', 'diego.herrera@empresa.com', '3181234567'),
(9, 'Paola Vargas', 'Vendedor', '3194321098', 'paola.vargas@empresa.com', '3199876543'),
(10, 'Carlos López', 'Recepcionista', '3123456789', 'carlos.lopez@empresa.com', '3129876543'),
(11, 'Ana Morales', 'Secretaria', '3178901234', 'ana.morales@empresa.com', '3177654321');

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
(1, 'Proveedor Ejemplo', '123 Calle Principal', '555-1234', 'contacto@ejemplo.com', '2024-08-27'),
(2, 'Distribuidora Chevrolet', 'Calle 100 #50-30, Bogotá', '3201234567', 'chevrolet@distribuidora.com', '2023-01-15'),
(3, 'Autopartes Mazda', 'Carrera 20 #15-25, Medellín', '3119876543', 'contacto@mazdaautopartes.com', '2023-02-20'),
(4, 'Proveedores Renault', 'Avenida 80 #60-50, Cali', '3123456789', 'renault@proveedores.com', '2023-03-10'),
(5, 'Repuestos Toyota', 'Calle 50 #30-10, Barranquilla', '3132468090', 'info@toyotarepuestos.com', '2023-04-05'),
(6, 'Suministros Ford', 'Carrera 30 #40-25, Cartagena', '3145678901', 'suministros@ford.com', '2023-05-12'),
(7, 'Distribuidora Kia', 'Avenida Siempre Viva 123, Bucaramanga', '3156789012', 'contacto@kiadistribuidora.com', '2023-06-01'),
(8, 'Repuestos Nissan', 'Carrera 45 #50-30, Manizales', '3167890123', 'ventas@nissanrepuestos.com', '2023-07-15'),
(9, 'Proveedor Hyundai', 'Calle 20 #30-40, Cúcuta', '3178901234', 'hyundai@proveedor.com', '2023-08-10'),
(10, 'Suministros Volkswagen', 'Carrera 10 #60-50, Santa Marta', '3189012345', 'ventas@vw-suministros.com', '2023-09-01'),
(11, 'Autopartes Honda', 'Avenida 70 #50-20, Pereira', '3190123456', 'honda@autopartes.com', '2023-09-25');

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
(35, 1, 'entrada', 12, '2024-09-16 18:16:20'),
(36, 1, 'salida', 2, '2024-09-16 18:17:26'),
(37, 4, 'entrada', 20, '2024-09-16 18:18:04'),
(38, 2, 'salida', 2, '2024-09-16 20:02:25'),
(39, 1, 'entrada', 50, '2024-09-16 22:17:53'),
(40, 1, 'salida', 65, '2024-09-16 22:18:13'),
(41, 1, 'salida', 20, '2024-09-16 22:18:43');

--
-- Disparadores `transacciones`
--
DELIMITER $$
CREATE TRIGGER `actualizar_cantidad_transaccion` AFTER INSERT ON `transacciones` FOR EACH ROW BEGIN
  
  IF NEW.tipo_transaccion = 'entrada' THEN
    UPDATE vehiculos
    SET cantidad_disponible = cantidad_disponible + NEW.cantidad
    WHERE vehiculo_id = NEW.vehiculo_id;
  ELSEIF NEW.tipo_transaccion = 'salida' THEN
    UPDATE vehiculos
    SET cantidad_disponible = cantidad_disponible - NEW.cantidad
    WHERE vehiculo_id = NEW.vehiculo_id;
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `transacciones_detalladas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `transacciones_detalladas` (
`transaccion_id` int(11)
,`marca` varchar(50)
,`modelo` varchar(50)
,`tipo_transaccion` enum('entrada','salida')
,`cantidad` int(11)
,`fecha` timestamp
);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vehiculos`
--

CREATE TABLE `vehiculos` (
  `vehiculo_id` int(11) NOT NULL,
  `marca` varchar(50) NOT NULL,
  `modelo` varchar(50) NOT NULL,
  `año` int(11) DEFAULT NULL,
  `precio` decimal(12,2) DEFAULT NULL,
  `tipo_de_carro` varchar(50) DEFAULT NULL,
  `color` varchar(30) DEFAULT NULL,
  `cantidad_disponible` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `vehiculos`
--

INSERT INTO `vehiculos` (`vehiculo_id`, `marca`, `modelo`, `año`, `precio`, `tipo_de_carro`, `color`, `cantidad_disponible`) VALUES
(1, 'Toyota', 'Corolla', 2020, 25.00, 'Sedán híbrido', 'Verde', -5),
(2, 'Ford', 'Focus', 2021, 22000.00, 'Compacto', 'Azul', 92),
(3, 'Honda', 'Civic', 2022, 24000.00, 'Compacto', 'Pupura', 33),
(4, 'Chevrolet', 'Malibu', 2023, 26000.00, 'Sedán', 'Rojo', 175),
(5, 'Nissan', 'Altima', 2024, 28000.00, 'Sedán', 'Amarillo', 28),
(6, 'BMW', '320i', 2020, 35000.00, 'Sedán', 'Negro', 74),
(7, 'Mercedes', 'C-Class', 2021, 37000.00, 'Sedán de lujo', 'Gris', 64),
(8, 'Audi', 'A4', 2022, 39000.00, 'Sedán híbrido', 'Gris', 39),
(9, 'Volkswagen', 'Passat', 2023, 41000.00, 'Turismo', 'Dorado', 25),
(10, 'Subaru', 'Legacy', 2024, 43000.00, 'Sedán', 'Vino tinto', 67);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vehiculos_disponibles`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vehiculos_disponibles` (
`vehiculo_id` int(11)
,`marca` varchar(50)
,`modelo` varchar(50)
,`año` int(11)
,`precio` decimal(12,2)
,`cantidad_disponible` int(11)
);

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
CREATE TRIGGER `actualizar_cantidad_venta` AFTER INSERT ON `ventas` FOR EACH ROW BEGIN
  
  UPDATE vehiculos
  SET cantidad_disponible = cantidad_disponible - 1
  WHERE vehiculo_id = NEW.vehiculo_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `actualizar_inventario` AFTER INSERT ON `ventas` FOR EACH ROW BEGIN
  UPDATE inventario
  SET cantidad_disponible = cantidad_disponible - 1
  WHERE vehiculo_id = NEW.vehiculo_id;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `verificar_disponibilidad_venta` BEFORE INSERT ON `ventas` FOR EACH ROW BEGIN
  
  IF (SELECT cantidad_disponible 
      FROM vehiculos 
      WHERE vehiculo_id = NEW.vehiculo_id) <= 0 THEN
    
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'No hay disponibilidad para el vehículo seleccionado.';
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura para la vista `transacciones_detalladas`
--
DROP TABLE IF EXISTS `transacciones_detalladas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `transacciones_detalladas`  AS SELECT `t`.`transaccion_id` AS `transaccion_id`, `vh`.`marca` AS `marca`, `vh`.`modelo` AS `modelo`, `t`.`tipo_transaccion` AS `tipo_transaccion`, `t`.`cantidad` AS `cantidad`, `t`.`fecha` AS `fecha` FROM (`transacciones` `t` join `vehiculos` `vh` on(`t`.`vehiculo_id` = `vh`.`vehiculo_id`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vehiculos_disponibles`
--
DROP TABLE IF EXISTS `vehiculos_disponibles`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vehiculos_disponibles`  AS SELECT `vehiculos`.`vehiculo_id` AS `vehiculo_id`, `vehiculos`.`marca` AS `marca`, `vehiculos`.`modelo` AS `modelo`, `vehiculos`.`año` AS `año`, `vehiculos`.`precio` AS `precio`, `vehiculos`.`cantidad_disponible` AS `cantidad_disponible` FROM `vehiculos` WHERE `vehiculos`.`cantidad_disponible` > 0 ;

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
  ADD KEY `transacciones_ibfk_1` (`vehiculo_id`);

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
  MODIFY `transaccion_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `transacciones`
--
ALTER TABLE `transacciones`
  ADD CONSTRAINT `transacciones_ibfk_1` FOREIGN KEY (`vehiculo_id`) REFERENCES `vehiculos` (`vehiculo_id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 17-09-2024 a las 22:13:28
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
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_cliente` (IN `p_cliente_id` INT, IN `p_nombre` VARCHAR(100), IN `p_telefono` VARCHAR(15), IN `p_email` VARCHAR(100), IN `p_direccion` TEXT)   BEGIN
    
    IF (SELECT COUNT(*) FROM clientes WHERE cliente_id = p_cliente_id) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cliente no encontrado';
    ELSE
        
        UPDATE clientes
        SET nombre = p_nombre, telefono = p_telefono, email = p_email, direccion = p_direccion
        WHERE cliente_id = p_cliente_id;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_precio_vehiculo` (IN `p_vehiculo_id` INT, IN `p_nuevo_precio` DECIMAL(10,2))   BEGIN
    
    IF (SELECT COUNT(*) FROM vehiculos WHERE vehiculo_id = p_vehiculo_id) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vehículo no encontrado';
    ELSE
        
        UPDATE vehiculos
        SET precio = p_nuevo_precio
        WHERE vehiculo_id = p_vehiculo_id;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `consultar_ventas_empleado` (IN `p_empleado_id` INT)   BEGIN
    
    SELECT 
        v.venta_id,
        c.nombre AS cliente_nombre,
        v.fecha,
        ve.marca,
        ve.modelo,
        v.precio
    FROM 
        ventas v
    JOIN 
        clientes c ON v.cliente_id = c.cliente_id
    JOIN 
        vehiculos ve ON v.vehiculo_id = ve.vehiculo_id
    WHERE 
        v.empleado_id = p_empleado_id
    ORDER BY 
        v.fecha DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminar_vehiculo` (IN `p_vehiculo_id` INT)   BEGIN
    
    IF (SELECT COUNT(*) FROM transacciones WHERE vehiculo_id = p_vehiculo_id) > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se puede eliminar el vehículo porque tiene transacciones asociadas';
    ELSE
        
        DELETE FROM vehiculos
        WHERE vehiculo_id = p_vehiculo_id;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `gestionar_inventario` (IN `p_vehiculo_id` INT, IN `p_tipo_transaccion` ENUM('entrada','salida'), IN `p_cantidad` INT)   BEGIN
    DECLARE v_cantidad_actual INT;

    
    SELECT cantidad INTO v_cantidad_actual
    FROM vehiculos
    WHERE vehiculo_id = p_vehiculo_id;

    
    IF v_cantidad_actual IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Vehículo no encontrado';
    ELSE
        
        IF p_tipo_transaccion = 'entrada' THEN
            
            UPDATE vehiculos
            SET cantidad = v_cantidad_actual + p_cantidad
            WHERE vehiculo_id = p_vehiculo_id;

            
            INSERT INTO transacciones (vehiculo_id, tipo_transaccion, cantidad)
            VALUES (p_vehiculo_id, p_tipo_transaccion, p_cantidad);
        ELSEIF p_tipo_transaccion = 'salida' THEN
            
            IF v_cantidad_actual < p_cantidad THEN
                SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No hay suficiente inventario';
            ELSE
                
                UPDATE vehiculos
                SET cantidad = v_cantidad_actual - p_cantidad
                WHERE vehiculo_id = p_vehiculo_id;

                
                INSERT INTO transacciones (vehiculo_id, tipo_transaccion, cantidad)
                VALUES (p_vehiculo_id, p_tipo_transaccion, p_cantidad);
            END IF;
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tipo de transacción inválido';
        END IF;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrar_cliente` (IN `p_nombre` VARCHAR(100), IN `p_telefono` VARCHAR(15), IN `p_email` VARCHAR(100), IN `p_direccion` TEXT)   BEGIN
    
    INSERT INTO clientes (nombre, telefono, email, direccion)
    VALUES (p_nombre, p_telefono, p_email, p_direccion);
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
(1, 'Juan Pérez', '321-555-1234', 'juan.perez@example.com', 'Calle 123, Bogotá'),
(2, 'Ana Gómez', '321-555-5678', 'ana.gomez@example.com', 'Avenida 456, Medellín'),
(3, 'Luis Martínez', '321-555-9101', 'luis.martinez@example.com', 'Carrera 789, Cali'),
(4, 'Marta Rodríguez', '321-555-1122', 'marta.rodriguez@example.com', 'Calle 234, Barranquilla'),
(5, 'Pedro Fernández', '321-555-3344', 'pedro.fernandez@example.com', 'Avenida 567, Cartagena'),
(6, 'Sofía Morales', '321-555-5566', 'sofia.morales@example.com', 'Carrera 890, Bucaramanga'),
(7, 'Carlos Ramírez', '321-555-7788', 'carlos.ramirez@example.com', 'Calle 345, Pereira'),
(8, 'Valeria Jiménez', '321-555-9900', 'valeria.jimenez@example.com', 'Avenida 678, Manizales'),
(9, 'Jorge Díaz', '321-555-2233', 'jorge.diaz@example.com', 'Carrera 456, Pasto'),
(10, 'Laura Silva', '321-555-4455', 'laura.silva@example.com', 'Calle 678, Santa Marta');

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
(1, 'Pedro Gómez', 'Gerente', '311-555-1111', 'pedro.gomez@example.com', '300-123-4567'),
(2, 'Laura Sánchez', 'Vendedor', '311-555-2222', 'laura.sanchez@example.com', '300-234-5678'),
(3, 'Ricardo Torres', 'Mecánico', '311-555-3333', 'ricardo.torres@example.com', '300-345-6789'),
(4, 'Claudia Romero', 'Asesor de ventas', '311-555-4444', 'claudia.romero@example.com', '300-456-7890'),
(5, 'Andrés Moreno', 'Contador', '311-555-5555', 'andres.moreno@example.com', '300-567-8901'),
(6, 'Isabel López', 'Secretaria', '311-555-6666', 'isabel.lopez@example.com', '300-678-9012'),
(7, 'David Pérez', 'Jefe de Taller', '311-555-7777', 'david.perez@example.com', '300-789-0123'),
(8, 'Natalia Ruiz', 'Recepcionista', '311-555-8888', 'natalia.ruiz@example.com', '300-890-1234'),
(9, 'Felipe Castro', 'Asesor de Finanzas', '311-555-9999', 'felipe.castro@example.com', '300-901-2345'),
(10, 'Julián Gómez', 'Auxiliar Administrativo', '311-555-0000', 'julian.gomez@example.com', '300-012-3456');

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
(1, 'Proveedora Autos S.A.', 'Calle Principal 123, Bogotá', '320-555-1111', 'contacto@proveedoraautos.com', '2024-01-15'),
(2, 'AutoPartes Ltda.', 'Avenida Secundaria 456, Medellín', '320-555-2222', 'info@autopartesltda.com', '2024-02-20'),
(3, 'Carros y Más', 'Carrera Tercera 789, Cali', '320-555-3333', 'ventas@carrosymas.com', '2024-03-10'),
(4, 'Importadora de Autos', 'Calle Cuarta 234, Barranquilla', '320-555-4444', 'compras@importadoraautos.com', '2024-04-05'),
(5, 'Vehículos del Norte', 'Avenida Quinta 567, Cartagena', '320-555-5555', 'soporte@vehiculosnorte.com', '2024-05-12'),
(6, 'AutoComercial', 'Carrera Sexta 890, Bucaramanga', '320-555-6666', 'servicio@autocomercial.com', '2024-06-18'),
(7, 'Distribuidora de Autos', 'Calle Séptima 345, Pereira', '320-555-7777', 'contacto@distribuidoraautos.com', '2024-07-22'),
(8, 'Comercializadora de Vehículos', 'Avenida Octava 678, Manizales', '320-555-8888', 'ventas@comercializadora.com', '2024-08-30'),
(9, 'Proveedores de Motores', 'Carrera Novena 456, Pasto', '320-555-9999', 'info@proveedoresmotores.com', '2024-09-10'),
(10, 'Venta de Repuestos', 'Calle Décima 678, Santa Marta', '320-555-0000', 'contacto@ventarepuestos.com', '2024-10-01');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `transacciones`
--

CREATE TABLE `transacciones` (
  `transaccion_id` int(11) NOT NULL,
  `vehiculo_id` int(11) DEFAULT NULL,
  `tipo_transaccion` enum('entrada','salida') NOT NULL,
  `cantidad` int(11) NOT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `transacciones`
--

INSERT INTO `transacciones` (`transaccion_id`, `vehiculo_id`, `tipo_transaccion`, `cantidad`, `fecha`) VALUES
(1, 1, 'entrada', 5, '2024-09-17 19:33:02'),
(2, 2, 'entrada', 4, '2024-09-17 19:33:02'),
(3, 3, 'salida', 2, '2024-09-17 19:33:02'),
(4, 4, 'entrada', 6, '2024-09-17 19:33:02'),
(5, 5, 'salida', 3, '2024-09-17 19:33:02'),
(6, 6, 'entrada', 7, '2024-09-17 19:33:02'),
(7, 7, 'salida', 1, '2024-09-17 19:33:02'),
(8, 8, 'entrada', 8, '2024-09-17 19:33:02'),
(9, 9, 'salida', 4, '2024-09-17 19:33:02'),
(10, 10, 'entrada', 3, '2024-09-17 19:33:02'),
(11, 1, 'entrada', 5, '2024-09-17 19:37:18'),
(12, 2, 'salida', 3, '2024-09-17 19:37:22'),
(13, 1, 'salida', 10, '2024-09-17 19:38:35'),
(14, 1, 'entrada', 10, '2024-09-17 19:52:26'),
(15, 1, 'salida', 10, '2024-09-17 19:52:48'),
(16, 2, 'entrada', 20, '2024-09-17 19:57:36'),
(17, 2, 'salida', 10, '2024-09-17 19:58:06');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `vehiculos`
--

CREATE TABLE `vehiculos` (
  `vehiculo_id` int(11) NOT NULL,
  `marca` varchar(50) NOT NULL,
  `modelo` varchar(50) NOT NULL,
  `anio` int(4) NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `cantidad` int(11) NOT NULL,
  `descripcion` text DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `vehiculos`
--

INSERT INTO `vehiculos` (`vehiculo_id`, `marca`, `modelo`, `anio`, `precio`, `cantidad`, `descripcion`) VALUES
(1, 'Toyota', 'Corolla', 2023, 25000.00, 5, 'Sedán compacto con excelente eficiencia de combustible.'),
(2, 'Honda', 'Civic', 2022, 28000.00, 15, 'Sedán deportivo con tecnología avanzada y gran confort.'),
(3, 'Ford', 'Mustang', 2024, 35000.00, 5, 'Coupé deportivo con motor potente y diseño icónico.'),
(4, 'Chevrolet', 'Tracker', 2023, 22000.00, 12, 'SUV compacta con características modernas y espacio versátil.'),
(5, 'Nissan', 'Rogue', 2022, 30000.00, 7, 'SUV mediana con capacidad para toda la familia.'),
(6, 'Hyundai', 'Elantra', 2023, 24000.00, 9, 'Sedán con un diseño elegante y características de seguridad avanzadas.'),
(7, 'Kia', 'Sportage', 2024, 32000.00, 6, 'SUV con interior espacioso y tecnología de última generación.'),
(8, 'Volkswagen', 'Jetta', 2023, 26000.00, 11, 'Sedán con gran manejo y eficiencia de combustible.'),
(9, 'Mazda', 'CX-5', 2022, 29000.00, 10, 'SUV con manejo dinámico y diseño sofisticado.'),
(10, 'Subaru', 'Outback', 2023, 31000.00, 8, 'SUV con tracción integral y capacidades todoterreno.');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `ventas`
--

CREATE TABLE `ventas` (
  `venta_id` int(11) NOT NULL,
  `cliente_id` int(11) DEFAULT NULL,
  `vehiculo_id` int(11) DEFAULT NULL,
  `empleado_id` int(11) DEFAULT NULL,
  `fecha` timestamp NOT NULL DEFAULT current_timestamp(),
  `precio` decimal(10,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `ventas`
--

INSERT INTO `ventas` (`venta_id`, `cliente_id`, `vehiculo_id`, `empleado_id`, `fecha`, `precio`) VALUES
(1, 1, 1, 2, '2024-09-17 19:33:10', 25000.00),
(2, 2, 2, 4, '2024-09-17 19:33:10', 28000.00),
(3, 3, 3, 5, '2024-09-17 19:33:10', 35000.00),
(4, 4, 4, 6, '2024-09-17 19:33:10', 22000.00),
(5, 5, 5, 7, '2024-09-17 19:33:10', 30000.00),
(6, 6, 6, 8, '2024-09-17 19:33:10', 24000.00),
(7, 7, 7, 9, '2024-09-17 19:33:10', 32000.00),
(8, 8, 8, 10, '2024-09-17 19:33:10', 26000.00),
(9, 9, 9, 2, '2024-09-17 19:33:10', 29000.00),
(10, 10, 10, 3, '2024-09-17 19:33:10', 31000.00);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_historial_compras_clientes`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_historial_compras_clientes` (
`cliente_id` int(11)
,`cliente_nombre` varchar(100)
,`cliente_telefono` varchar(15)
,`marca` varchar(50)
,`modelo` varchar(50)
,`anio` int(4)
,`fecha_compra` timestamp
,`precio_compra` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_ingresos_mensuales`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_ingresos_mensuales` (
`mes` varchar(7)
,`total_ingresos` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_inventario`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_inventario` (
`vehiculo_id` int(11)
,`marca` varchar(50)
,`modelo` varchar(50)
,`anio` int(4)
,`precio` decimal(10,2)
,`cantidad` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_inventario_bajo`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_inventario_bajo` (
`vehiculo_id` int(11)
,`marca` varchar(50)
,`modelo` varchar(50)
,`anio` int(4)
,`precio` decimal(10,2)
,`cantidad` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_proveedores_vehiculos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_proveedores_vehiculos` (
`proveedor_id` int(11)
,`proveedor_nombre` varchar(100)
,`proveedor_telefono` varchar(20)
,`marca` varchar(50)
,`modelo` varchar(50)
,`anio` int(4)
,`precio` decimal(10,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_transacciones_detalladas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_transacciones_detalladas` (
`transaccion_id` int(11)
,`vehiculo_id` int(11)
,`marca` varchar(50)
,`modelo` varchar(50)
,`anio` int(4)
,`precio` decimal(10,2)
,`tipo_transaccion` enum('entrada','salida')
,`cantidad` int(11)
,`fecha` timestamp
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_transacciones_por_fecha`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_transacciones_por_fecha` (
`transaccion_id` int(11)
,`marca` varchar(50)
,`modelo` varchar(50)
,`tipo_transaccion` enum('entrada','salida')
,`cantidad` int(11)
,`fecha` timestamp
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_vehiculos_no_vendidos`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_vehiculos_no_vendidos` (
`vehiculo_id` int(11)
,`marca` varchar(50)
,`modelo` varchar(50)
,`anio` int(4)
,`precio` decimal(10,2)
,`cantidad` int(11)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_ventas_detalladas`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_ventas_detalladas` (
`venta_id` int(11)
,`cliente_nombre` varchar(100)
,`cliente_telefono` varchar(15)
,`marca` varchar(50)
,`modelo` varchar(50)
,`anio` int(4)
,`precio_vehiculo` decimal(10,2)
,`precio_venta` decimal(10,2)
,`empleado_nombre` varchar(100)
,`empleado_puesto` varchar(50)
,`fecha` timestamp
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_ventas_por_empleado`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_ventas_por_empleado` (
`empleado_id` int(11)
,`empleado_nombre` varchar(100)
,`puesto` varchar(50)
,`total_ventas` bigint(21)
,`total_valor_vendido` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_ventas_por_mes_y_empleado`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_ventas_por_mes_y_empleado` (
`empleado_id` int(11)
,`empleado_nombre` varchar(100)
,`mes` varchar(7)
,`total_ventas` bigint(21)
,`total_valor_vendido` decimal(32,2)
);

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_historial_compras_clientes`
--
DROP TABLE IF EXISTS `vista_historial_compras_clientes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_historial_compras_clientes`  AS SELECT `c`.`cliente_id` AS `cliente_id`, `c`.`nombre` AS `cliente_nombre`, `c`.`telefono` AS `cliente_telefono`, `v`.`marca` AS `marca`, `v`.`modelo` AS `modelo`, `v`.`anio` AS `anio`, `ve`.`fecha` AS `fecha_compra`, `ve`.`precio` AS `precio_compra` FROM ((`ventas` `ve` join `clientes` `c` on(`ve`.`cliente_id` = `c`.`cliente_id`)) join `vehiculos` `v` on(`ve`.`vehiculo_id` = `v`.`vehiculo_id`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_ingresos_mensuales`
--
DROP TABLE IF EXISTS `vista_ingresos_mensuales`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_ingresos_mensuales`  AS SELECT date_format(`ventas`.`fecha`,'%Y-%m') AS `mes`, sum(`ventas`.`precio`) AS `total_ingresos` FROM `ventas` GROUP BY date_format(`ventas`.`fecha`,'%Y-%m') ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_inventario`
--
DROP TABLE IF EXISTS `vista_inventario`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_inventario`  AS SELECT `vehiculos`.`vehiculo_id` AS `vehiculo_id`, `vehiculos`.`marca` AS `marca`, `vehiculos`.`modelo` AS `modelo`, `vehiculos`.`anio` AS `anio`, `vehiculos`.`precio` AS `precio`, `vehiculos`.`cantidad` AS `cantidad` FROM `vehiculos` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_inventario_bajo`
--
DROP TABLE IF EXISTS `vista_inventario_bajo`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_inventario_bajo`  AS SELECT `vehiculos`.`vehiculo_id` AS `vehiculo_id`, `vehiculos`.`marca` AS `marca`, `vehiculos`.`modelo` AS `modelo`, `vehiculos`.`anio` AS `anio`, `vehiculos`.`precio` AS `precio`, `vehiculos`.`cantidad` AS `cantidad` FROM `vehiculos` WHERE `vehiculos`.`cantidad` < 5 ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_proveedores_vehiculos`
--
DROP TABLE IF EXISTS `vista_proveedores_vehiculos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_proveedores_vehiculos`  AS SELECT `p`.`id` AS `proveedor_id`, `p`.`nombre` AS `proveedor_nombre`, `p`.`telefono` AS `proveedor_telefono`, `v`.`marca` AS `marca`, `v`.`modelo` AS `modelo`, `v`.`anio` AS `anio`, `v`.`precio` AS `precio` FROM (`proveedores` `p` join `vehiculos` `v` on(`p`.`id` = `v`.`vehiculo_id`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_transacciones_detalladas`
--
DROP TABLE IF EXISTS `vista_transacciones_detalladas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_transacciones_detalladas`  AS SELECT `t`.`transaccion_id` AS `transaccion_id`, `v`.`vehiculo_id` AS `vehiculo_id`, `v`.`marca` AS `marca`, `v`.`modelo` AS `modelo`, `v`.`anio` AS `anio`, `v`.`precio` AS `precio`, `t`.`tipo_transaccion` AS `tipo_transaccion`, `t`.`cantidad` AS `cantidad`, `t`.`fecha` AS `fecha` FROM (`transacciones` `t` join `vehiculos` `v` on(`t`.`vehiculo_id` = `v`.`vehiculo_id`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_transacciones_por_fecha`
--
DROP TABLE IF EXISTS `vista_transacciones_por_fecha`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_transacciones_por_fecha`  AS SELECT `t`.`transaccion_id` AS `transaccion_id`, `v`.`marca` AS `marca`, `v`.`modelo` AS `modelo`, `t`.`tipo_transaccion` AS `tipo_transaccion`, `t`.`cantidad` AS `cantidad`, `t`.`fecha` AS `fecha` FROM (`transacciones` `t` join `vehiculos` `v` on(`t`.`vehiculo_id` = `v`.`vehiculo_id`)) ORDER BY `t`.`fecha` DESC ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_vehiculos_no_vendidos`
--
DROP TABLE IF EXISTS `vista_vehiculos_no_vendidos`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_vehiculos_no_vendidos`  AS SELECT `v`.`vehiculo_id` AS `vehiculo_id`, `v`.`marca` AS `marca`, `v`.`modelo` AS `modelo`, `v`.`anio` AS `anio`, `v`.`precio` AS `precio`, `v`.`cantidad` AS `cantidad` FROM (`vehiculos` `v` left join `ventas` `ve` on(`v`.`vehiculo_id` = `ve`.`vehiculo_id`)) WHERE `ve`.`vehiculo_id` is null ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_ventas_detalladas`
--
DROP TABLE IF EXISTS `vista_ventas_detalladas`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_ventas_detalladas`  AS SELECT `v`.`venta_id` AS `venta_id`, `c`.`nombre` AS `cliente_nombre`, `c`.`telefono` AS `cliente_telefono`, `ve`.`marca` AS `marca`, `ve`.`modelo` AS `modelo`, `ve`.`anio` AS `anio`, `ve`.`precio` AS `precio_vehiculo`, `v`.`precio` AS `precio_venta`, `e`.`nombre` AS `empleado_nombre`, `e`.`puesto` AS `empleado_puesto`, `v`.`fecha` AS `fecha` FROM (((`ventas` `v` join `clientes` `c` on(`v`.`cliente_id` = `c`.`cliente_id`)) join `vehiculos` `ve` on(`v`.`vehiculo_id` = `ve`.`vehiculo_id`)) join `empleados` `e` on(`v`.`empleado_id` = `e`.`empleado_id`)) ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_ventas_por_empleado`
--
DROP TABLE IF EXISTS `vista_ventas_por_empleado`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_ventas_por_empleado`  AS SELECT `e`.`empleado_id` AS `empleado_id`, `e`.`nombre` AS `empleado_nombre`, `e`.`puesto` AS `puesto`, count(`ve`.`venta_id`) AS `total_ventas`, sum(`ve`.`precio`) AS `total_valor_vendido` FROM (`ventas` `ve` join `empleados` `e` on(`ve`.`empleado_id` = `e`.`empleado_id`)) GROUP BY `e`.`empleado_id`, `e`.`nombre`, `e`.`puesto` ;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_ventas_por_mes_y_empleado`
--
DROP TABLE IF EXISTS `vista_ventas_por_mes_y_empleado`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_ventas_por_mes_y_empleado`  AS SELECT `e`.`empleado_id` AS `empleado_id`, `e`.`nombre` AS `empleado_nombre`, date_format(`v`.`fecha`,'%Y-%m') AS `mes`, count(`v`.`venta_id`) AS `total_ventas`, sum(`v`.`precio`) AS `total_valor_vendido` FROM (`ventas` `v` join `empleados` `e` on(`v`.`empleado_id` = `e`.`empleado_id`)) GROUP BY `e`.`empleado_id`, date_format(`v`.`fecha`,'%Y-%m') ;

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
  ADD PRIMARY KEY (`venta_id`),
  ADD KEY `cliente_id` (`cliente_id`),
  ADD KEY `vehiculo_id` (`vehiculo_id`),
  ADD KEY `empleado_id` (`empleado_id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `clientes`
--
ALTER TABLE `clientes`
  MODIFY `cliente_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `empleados`
--
ALTER TABLE `empleados`
  MODIFY `empleado_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `proveedores`
--
ALTER TABLE `proveedores`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `transacciones`
--
ALTER TABLE `transacciones`
  MODIFY `transaccion_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `vehiculos`
--
ALTER TABLE `vehiculos`
  MODIFY `vehiculo_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT de la tabla `ventas`
--
ALTER TABLE `ventas`
  MODIFY `venta_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `transacciones`
--
ALTER TABLE `transacciones`
  ADD CONSTRAINT `transacciones_ibfk_1` FOREIGN KEY (`vehiculo_id`) REFERENCES `vehiculos` (`vehiculo_id`);

--
-- Filtros para la tabla `ventas`
--
ALTER TABLE `ventas`
  ADD CONSTRAINT `ventas_ibfk_1` FOREIGN KEY (`cliente_id`) REFERENCES `clientes` (`cliente_id`),
  ADD CONSTRAINT `ventas_ibfk_2` FOREIGN KEY (`vehiculo_id`) REFERENCES `vehiculos` (`vehiculo_id`),
  ADD CONSTRAINT `ventas_ibfk_3` FOREIGN KEY (`empleado_id`) REFERENCES `empleados` (`empleado_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

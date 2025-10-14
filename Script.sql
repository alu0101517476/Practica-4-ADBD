-- ======================================
-- LIMPIEZA PREVIA (DROP TABLES)
-- ======================================
DROP TABLE IF EXISTS Producto_Pedido CASCADE;
DROP TABLE IF EXISTS Tajinaste_Plus CASCADE;
DROP TABLE IF EXISTS Pedido CASCADE;
DROP TABLE IF EXISTS Zona_Producto CASCADE;
DROP TABLE IF EXISTS Producto CASCADE;
DROP TABLE IF EXISTS Empleado CASCADE;
DROP TABLE IF EXISTS Cliente CASCADE;
DROP TABLE IF EXISTS Zona CASCADE;
DROP TABLE IF EXISTS Vivero CASCADE;

-- ======================================
-- TABLA: VIVERO
-- ======================================
CREATE TABLE Vivero (
    nombre_vivero VARCHAR(50) PRIMARY KEY,
    latitud DECIMAL(8,5) NOT NULL CHECK (latitud BETWEEN -90 AND 90),
    longitud DECIMAL(8,5) NOT NULL CHECK (longitud BETWEEN -180 AND 180),
    ubicacion VARCHAR(200) GENERATED ALWAYS AS (
        'Lat: ' || latitud || ', Lon: ' || longitud
    ) STORED,
    CONSTRAINT uq_vivero_latlon UNIQUE (latitud, longitud)
);

-- ======================================
-- TABLA: ZONA
-- ======================================
CREATE TABLE Zona (
    nombre_zona VARCHAR(50) PRIMARY KEY,
    latitud DECIMAL(8,5) NOT NULL CHECK (latitud BETWEEN -90 AND 90),
    longitud DECIMAL(8,5) NOT NULL CHECK (longitud BETWEEN -180 AND 180),
    nombre_vivero VARCHAR(50) NOT NULL,
    ubicacion VARCHAR(200) GENERATED ALWAYS AS (
        'Lat: ' || latitud || ', Lon: ' || longitud
    ) STORED,
    CONSTRAINT uq_zona_latlon UNIQUE (latitud, longitud),
    FOREIGN KEY (nombre_vivero)
        REFERENCES Vivero(nombre_vivero)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ======================================
-- TABLA: EMPLEADO
-- ======================================
CREATE TABLE Empleado (
    dni CHAR(9) PRIMARY KEY CHECK (dni ~ '^[0-9]{8}[A-Z]$'),
    nombre_empleado VARCHAR(100) NOT NULL,
    puesto_trabajo VARCHAR(50) NOT NULL,
    epoca_anio VARCHAR(20) CHECK (epoca_anio IN ('Primavera','Verano','Otoño','Invierno')),
    fecha_inicio DATE NOT NULL,
    fecha_final DATE,
    CONSTRAINT chk_fechas CHECK (fecha_final IS NULL OR fecha_final >= fecha_inicio),
    nombre_zona VARCHAR(50) NOT NULL,
    FOREIGN KEY (nombre_zona)
        REFERENCES Zona(nombre_zona)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ======================================
-- TABLA: PRODUCTO
-- ======================================
CREATE TABLE Producto (
    codigo_producto VARCHAR(20) PRIMARY KEY,
    nombre_producto VARCHAR(100) NOT NULL,
    precio DECIMAL(8,2) NOT NULL CHECK (precio > 0)
);

-- ======================================
-- TABLA: ZONA_PRODUCTO (relación N:N)
-- ======================================
CREATE TABLE Zona_Producto (
    nombre_zona VARCHAR(50) NOT NULL,
    codigo_producto VARCHAR(20) NOT NULL,
    disponibilidad BOOLEAN DEFAULT TRUE,
    PRIMARY KEY (nombre_zona, codigo_producto),
    FOREIGN KEY (nombre_zona)
        REFERENCES Zona(nombre_zona)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (codigo_producto)
        REFERENCES Producto(codigo_producto)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ======================================
-- TABLA: CLIENTE
-- ======================================
CREATE TABLE Cliente (
    dni CHAR(9) PRIMARY KEY CHECK (dni ~ '^[0-9]{8}[A-Z]$'),
    nombre VARCHAR(100) NOT NULL
);

-- ======================================
-- TABLA: PEDIDO
-- ======================================
CREATE TABLE Pedido (
    id VARCHAR(20) PRIMARY KEY,
    fecha_pedido DATE NOT NULL CHECK (fecha_pedido <= CURRENT_DATE),
    dni_empleado CHAR(9),
    dni_cliente CHAR(9),
    FOREIGN KEY (dni_empleado)
        REFERENCES Empleado(dni)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (dni_cliente)
        REFERENCES Cliente(dni)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ======================================
-- TABLA: PRODUCTO_PEDIDO (relación N:N)
-- ======================================
CREATE TABLE Producto_Pedido (
    id VARCHAR(20) NOT NULL,
    codigo_producto VARCHAR(20) NOT NULL,
    PRIMARY KEY (id, codigo_producto),
    FOREIGN KEY (id)
        REFERENCES Pedido(id)
        ON DELETE CASCADE,
    FOREIGN KEY (codigo_producto)
        REFERENCES Producto(codigo_producto)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- ======================================
-- TABLA: TAJINASTE_PLUS
-- ======================================
CREATE TABLE Tajinaste_Plus (
    id_cliente CHAR(9) PRIMARY KEY,
    bonificaciones VARCHAR(200) NOT NULL,
    fecha_suscripcion DATE NOT NULL,
    FOREIGN KEY (id_cliente)
        REFERENCES Cliente(dni)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);


-- ======================================
-- INSERCIÓN DE DATOS
-- ======================================

-- VIVERO
INSERT INTO Vivero (nombre_vivero, latitud, longitud) VALUES
('Vivero Norte', 28.468, -16.254),
('Vivero Sur', 27.993, -15.422),
('Vivero Este', 28.500, -16.320),
('Vivero Oeste', 28.405, -16.550),
('Vivero Central', 28.450, -16.300);

-- ZONA
INSERT INTO Zona (nombre_zona, latitud, longitud, nombre_vivero) VALUES
('Zona A', 28.470, -16.255, 'Vivero Norte'),
('Zona B', 28.472, -16.258, 'Vivero Norte'),
('Zona C', 27.995, -15.420, 'Vivero Sur'),
('Zona D', 28.452, -16.301, 'Vivero Central'),
('Zona E', 28.403, -16.548, 'Vivero Oeste');

-- EMPLEADO
INSERT INTO Empleado (dni, nombre_empleado, puesto_trabajo, epoca_anio, fecha_inicio, fecha_final, nombre_zona) VALUES
('12345678A','Laura Pérez','Jardinero','Primavera','2023-03-01',NULL,'Zona A'),
('23456789B','Carlos Ruiz','Encargado','Verano','2022-06-01','2023-09-01','Zona B'),
('34567890C','Ana Gómez','Cajero','Otoño','2023-09-01',NULL,'Zona C'),
('45678901D','Luis Torres','Vendedor','Invierno','2023-12-01',NULL,'Zona D'),
('56789012E','María Díaz','Supervisor','Primavera','2021-03-01',NULL,'Zona E');

-- PRODUCTO
INSERT INTO Producto (codigo_producto, nombre_producto, precio) VALUES
('P001','Rosa Roja', 3.50),
('P002','Lavanda', 2.80),
('P003','Cactus', 5.00),
('P004','Orquídea', 8.50),
('P005','Helecho', 4.20);

-- ZONA_PRODUCTO
INSERT INTO Zona_Producto (nombre_zona, codigo_producto, disponibilidad) VALUES
('Zona A', 'P001', TRUE),
('Zona B', 'P002', TRUE),
('Zona C', 'P003', FALSE),
('Zona D', 'P004', TRUE),
('Zona E', 'P005', TRUE);

-- CLIENTE
INSERT INTO Cliente (dni, nombre) VALUES
('11111111A','Miguel Hernández'),
('22222222B','Lucía García'),
('33333333C','Pedro López'),
('44444444D','Sofía Martín'),
('55555555E','Raúl Gómez');

-- PEDIDO
INSERT INTO Pedido (id, fecha_pedido, dni_empleado, dni_cliente) VALUES
('PED001','2024-03-15','12345678A','11111111A'),
('PED002','2024-04-10','23456789B','22222222B'),
('PED003','2024-05-05','34567890C','33333333C'),
('PED004','2024-06-01','45678901D','44444444D'),
('PED005','2024-07-20','56789012E','55555555E');

-- PRODUCTO_PEDIDO
INSERT INTO Producto_Pedido (id, codigo_producto) VALUES
('PED001','P001'),
('PED001','P002'),
('PED002','P003'),
('PED003','P004'),
('PED004','P005');

-- TAJINASTE_PLUS
INSERT INTO Tajinaste_Plus (id_cliente, bonificaciones, fecha_suscripcion) VALUES
('11111111A',10.00,'2024-01-01'),
('22222222B',5.50,'2024-02-15'),
('33333333C',0.00,'2024-03-10'),
('44444444D',7.25,'2024-04-20'),
('55555555E',12.00,'2024-05-25');

-- ======================================
-- EJEMPLOS DE OPERACIONES DELETE
-- ======================================

-- 1. Eliminar un cliente (borra también su pedido y su suscripción)
DELETE FROM Cliente WHERE dni = '11111111A';

-- 2. Eliminar una zona (borra también sus empleados y relaciones con productos)
DELETE FROM Zona WHERE nombre_zona = 'Zona B';

-- 3. Eliminar un pedido (borra también los productos asociados)
DELETE FROM Pedido WHERE id = 3;

-- 4. Intentar eliminar un producto con pedidos asociados (bloqueado por RESTRICT si existe relación activa)
-- DELETE FROM Producto WHERE codigo_producto = 1;

-- 5. Eliminar un vivero (borra en cascada sus zonas y empleados)
DELETE FROM Vivero WHERE nombre_vivero = 'Vivero Oeste';
-- Data for Type Entities
INSERT INTO `type_entities` (`name`, `preffix`, `created_at`, `updated_at`) VALUES 
('Proveedores', 'P', NULL, NULL),
('Accionistas', 'P', NULL, NULL),
('Trabajadores', 'P', NULL, NULL),
('Clientes', 'P', NULL, NULL),
('Jefes de Frente', 'P', NULL, NULL),
('Maestro de Obras', 'P', NULL, NULL);

-- Data for Type of Article
INSERT INTO `type_of_articles` (`name`, `code`, `created_at`, `updated_at`) VALUES 
('Personal', '01', NULL, NULL), 
('Material', '02', NULL, NULL), 
('Equipos', '03', NULL, NULL), 
('Subcontratos', '04', NULL, NULL),
('Servicios', '05', NULL, NULL);

-- Data for Company
INSERT INTO `companies` (`name`, `ruc`, `created_at`, `updated_at`) VALUES 
('ARSAC Contratistas Generales', '12345678978', NULL, NULL), 
('Consorcio Bagua', '20494052513', NULL, NULL),
('Consorcio San Francisco del Oriente', '20567151779', NULL, NULL);

-- Data for Financial Variables
INSERT INTO `financial_variables` (`name`, `value`, `created_at`, `updated_at`) VALUES ('IGV', '0.18', NULL, NULL);
INSERT INTO `financial_variables` (`name`, `value`, `created_at`, `updated_at`) VALUES ('IPC', '114.63', NULL, NULL);

-- Data for Zip code
INSERT INTO `zip_codes` (`name`, `zip_code`, `created_at`, `updated_at`) VALUES 
('Cercado', 'Lima 01', NULL, NULL), 
('Ancon', 'Lima 02', NULL, NULL),
('Ate', 'Lima 03', NULL, NULL),
('Barranco', 'Lima 04', NULL, NULL),
('Breña', 'Lima 05', NULL, NULL),
('Carabayllo', 'Lima 06', NULL, NULL),
('Comas', 'Lima 07', NULL, NULL),
('Chaclacayo', 'Lima 08', NULL, NULL),
('Chorrillos', 'Lima 09', NULL, NULL),
('El Agustino', 'Lima 10', NULL, NULL),
('Jesús María', 'Lima 11', NULL, NULL),
('La Molina', 'Lima 12', NULL, NULL),
('La Victoria', 'Lima 13', NULL, NULL),
('Lince', 'Lima 14', NULL, NULL),
('Lurigancho', 'Lima 15', NULL, NULL),
('Lurín', 'Lima 16', NULL, NULL),
('Magdalena ', 'Lima 17', NULL, NULL),
('Miraflores', 'Lima 18', NULL, NULL),
('Pachacamac', 'Lima 19', NULL, NULL),
('Pucusana', 'Lima 20', NULL, NULL),
('Pueblo Libre', 'Lima 21', NULL, NULL),
('Puente Piedra', 'Lima 22', NULL, NULL),
('Punta Negra', 'Lima 23', NULL, NULL),
('Punta Hermosa', 'Lima 24', NULL, NULL),
('Rimac', 'Lima 25', NULL, NULL),
('San Bartolo', 'Lima 26', NULL, NULL),
('San Isidro', 'Lima 27', NULL, NULL),
('Independencia', 'Lima 28', NULL, NULL),
('San Juan De Miraflores', 'Lima 29', NULL, NULL),
('San Luis', 'Lima 30', NULL, NULL),
('San Martin De Porres', 'Lima 31', NULL, NULL),
('San Miguel', 'Lima 32', NULL, NULL),
('Santiago De Surco', 'Lima 33', NULL, NULL),
('Surquillo', 'Lima 34', NULL, NULL),
('Villa Maria Del Triunfo', 'Lima 35', NULL, NULL),
('San Juan De Lurigancho', 'Lima 36', NULL, NULL),
('Santa Maria Del Mar', 'Lima 37', NULL, NULL),
('Santa Rosa', 'Lima 38', NULL, NULL),
('Los Olivos', 'Lima 39', NULL, NULL),
('Cieneguilla', 'Lima 40', NULL, NULL),
('San Borja', 'Lima 41', NULL, NULL),
('Villa El Salvador', 'Lima 42', NULL, NULL),
('Santa Anita', 'Lima 43', NULL, NULL);
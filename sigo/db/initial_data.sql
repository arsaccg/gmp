-- Data for Type Entities
INSERT INTO `type_entities` (`name`, `preffix`, `created_at`, `updated_at`) VALUES 
('Proveedores', 'P', NOW(), NOW()),
('Accionistas', 'P', NOW(), NOW()),
('Trabajadores', 'P', NOW(), NOW()),
('Clientes', 'P', NOW(), NOW()),
('Jefes de Frente', 'P', NOW(), NOW()),
('Maestro de Obras', 'P', NOW(), NOW());

-- Data for Type of Article
INSERT INTO `type_of_articles` (`name`, `code`, `created_at`, `updated_at`) VALUES 
('Personal', '01', NOW(), NOW()), 
('Material', '02', NOW(), NOW()), 
('Equipos', '03', NOW(), NOW()), 
('Subcontratos', '04', NOW(), NOW()),
('Servicios', '05', NOW(), NOW());

-- Data for Company
INSERT INTO `companies` (`name`, `ruc`, `created_at`, `updated_at`) VALUES 
('ARSAC Contratistas Generales', '12345678978', NOW(), NOW()), 
('Consorcio Bagua', '20494052513', NOW(), NOW()),
('Consorcio San Francisco del Oriente', '20567151779', NOW(), NOW());

INSERT INTO `entities` (`name`, `ruc`, `created_at`, `updated_at`) VALUES 
('ARSAC Contratistas Generales', '12345678978', NOW(), NOW()), 
('Consorcio Bagua', '20494052513', NOW(), NOW()),
('Consorcio San Francisco del Oriente', '20567151779', NOW(), NOW());

INSERT INTO `entities_type_entities` (`entity_id`, `type_entity_id`, `created_at`, `updated_at`) VALUES 
(1, 1, NOW(), NOW()), 
(2, 1, NOW(), NOW()),
(3, 1, NOW(), NOW());

-- Data for Financial Variables
INSERT INTO `financial_variables` (`name`, `value`, `created_at`, `updated_at`) VALUES ('IGV', '0.18', NOW(), NOW());
INSERT INTO `financial_variables` (`name`, `value`, `created_at`, `updated_at`) VALUES ('IPC', '114.63', NOW(), NOW());

-- Data InputCategories
INSERT INTO `inputcategories` (`category_id`, `description`, `created_at`, `updated_at`) VALUES 
(1, 'PERSONAL', NOW(), NOW()), 
(2, 'MATERIAL', NOW(), NOW()), 
(3, 'EQUIPOS', NOW(), NOW()),
(3, 'SUBCONTRATOS Y SERVICIOS', NOW(), NOW());

-- Data for Zip code
INSERT INTO `zip_codes` (`name`, `zip_code`, `created_at`, `updated_at`) VALUES 
('Cercado', 'Lima 01', NOW(), NOW()), 
('Ancon', 'Lima 02', NOW(), NOW()),
('Ate', 'Lima 03', NOW(), NOW()),
('Barranco', 'Lima 04', NOW(), NOW()),
('Breña', 'Lima 05', NOW(), NOW()),
('Carabayllo', 'Lima 06', NOW(), NOW()),
('Comas', 'Lima 07', NOW(), NOW()),
('Chaclacayo', 'Lima 08', NOW(), NOW()),
('Chorrillos', 'Lima 09', NOW(), NOW()),
('El Agustino', 'Lima 10', NOW(), NOW()),
('Jesús María', 'Lima 11', NOW(), NOW()),
('La Molina', 'Lima 12', NOW(), NOW()),
('La Victoria', 'Lima 13', NOW(), NOW()),
('Lince', 'Lima 14', NOW(), NOW()),
('Lurigancho', 'Lima 15', NOW(), NOW()),
('Lurín', 'Lima 16', NOW(), NOW()),
('Magdalena ', 'Lima 17', NOW(), NOW()),
('Miraflores', 'Lima 18', NOW(), NOW()),
('Pachacamac', 'Lima 19', NOW(), NOW()),
('Pucusana', 'Lima 20', NOW(), NOW()),
('Pueblo Libre', 'Lima 21', NOW(), NOW()),
('Puente Piedra', 'Lima 22', NOW(), NOW()),
('Punta Negra', 'Lima 23', NOW(), NOW()),
('Punta Hermosa', 'Lima 24', NOW(), NOW()),
('Rimac', 'Lima 25', NOW(), NOW()),
('San Bartolo', 'Lima 26', NOW(), NOW()),
('San Isidro', 'Lima 27', NOW(), NOW()),
('Independencia', 'Lima 28', NOW(), NOW()),
('San Juan De Miraflores', 'Lima 29', NOW(), NOW()),
('San Luis', 'Lima 30', NOW(), NOW()),
('San Martin De Porres', 'Lima 31', NOW(), NOW()),
('San Miguel', 'Lima 32', NOW(), NOW()),
('Santiago De Surco', 'Lima 33', NOW(), NOW()),
('Surquillo', 'Lima 34', NOW(), NOW()),
('Villa Maria Del Triunfo', 'Lima 35', NOW(), NOW()),
('San Juan De Lurigancho', 'Lima 36', NOW(), NOW()),
('Santa Maria Del Mar', 'Lima 37', NOW(), NOW()),
('Santa Rosa', 'Lima 38', NOW(), NOW()),
('Los Olivos', 'Lima 39', NOW(), NOW()),
('Cieneguilla', 'Lima 40', NOW(), NOW()),
('San Borja', 'Lima 41', NOW(), NOW()),
('Villa El Salvador', 'Lima 42', NOW(), NOW()),
('Santa Anita', 'Lima 43', NOW(), NOW());
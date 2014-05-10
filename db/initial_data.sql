-- Data for Type Entities
INSERT INTO `type_entities` (`name`, `preffix`, `created_at`, `updated_at`) VALUES 
('Proveedores', 'P', NULL, NULL),
('Accionistas', 'P', NULL, NULL),
('Trabajadores', 'P', NULL, NULL);
('Clientes', 'P', NULL, NULL),
('Jefes de Frente', 'P', NULL, NULL),
('Maestro de Obras', 'P', NULL, NULL);

-- Data for Type of Article
INSERT INTO `type_of_articles` (`name`, `code`, `created_at`, `updated_at`) VALUES 
('Personal', '01', NULL, NULL), 
('Material', '02', NULL, NULL), 
('Equipos', '03', NULL, NULL), 
('Servicios', '04', NULL, NULL), 
('SubContratos', '05', NULL, NULL);

-- Data for Company
INSERT INTO `companies` (`name`, `ruc`, `created_at`, `updated_at`) VALUES 
('ARSAC Contratistas Generales', '12345678978', NULL, NULL), 
('Consorcio Bagua', '20494052513', NULL, NULL),
('Consorcio San Francisco del Oriente', '20567151779', NULL, NULL);

-- Data for Financial Variables
INSERT INTO `financial_variables` (`name`, `value`, `created_at`, `updated_at`) VALUES ('IGV', '0.18', NULL, NULL);
INSERT INTO `financial_variables` (`name`, `value`, `created_at`, `updated_at`) VALUES ('IPC', '114.63', NULL, NULL);
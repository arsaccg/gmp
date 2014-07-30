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

-- Data for Health Centers
INSERT INTO `health_centers` (`enterprise`, `id`, `created_at`, `updated_at`) VALUES 
('PERSALUD S.A. EPS', '1', NOW(), NOW()), 
('PACIFICO S.A. EPS', '2', NOW(), NOW()), 
('RIMAC INTERNACIONAL S.A. EPS', '3', NOW(), NOW()), 
('SERVICIOS PROPIOS', '4', NOW(), NOW()),
('MAPFRE PERU S.A. EPS', '5', NOW(), NOW()),
('LA POSITIVA SANITAS S.A. EPS', '6', NOW(), NOW());

-- Data for Position Worker
INSERT INTO `position_workers` (`name`, `id`, `created_at`, `updated_at`) VALUES 
('Jefe de Frente', '1', NOW(), NOW()), 
('Capataz', '2', NOW(), NOW());

-- Data for Type of Workday
INSERT INTO `type_workdays` (`id`, `name`, `created_at`, `updated_at`) VALUES 
('1', 'Jornada de Trabajo Máxima', NOW(), NOW()), 
('2', 'Jornada atípica o acumulativa', NOW(), NOW()), 
('3', 'Trabajo en horario nocturno', NOW(), NOW());

-- Data for Contract Types
INSERT INTO `contract_types` (`id`, `description`, `shortdescription`, `created_at`, `updated_at`) VALUES 
('1', 'A PLAZO INDETERMINADO - D.LEG. 728', 'A PLAZO INDET - D.LEG. 728', NOW(), NOW()), 
('2', 'A TIEMPO PARCIAL', 'A TIEMPO PARCIAL', NOW(), NOW()), 
('3', 'POR INICIO O INCREMENTO DE ACTIVIDAD', 'POR INICIO O ICREM DE ACTIV', NOW(), NOW()), 
('4', 'POR NECESIDADES DEL MERCADO', 'POR NECES DEL MERCADO', NOW(), NOW()), 
('5', 'POR RECONVERSIÓN EMPRESARIAL', 'POR RECONV EMPRESARIAL', NOW(), NOW()), 
('6', 'OCASIONAL', 'OCASIONAL', NOW(), NOW()), 
('7', 'DE SUPLENCIA', 'DE SUPLENCIA', NOW(), NOW()), 
('8', 'DE EMERGENCIA', 'DE EMERGENCIA', NOW(), NOW()), 
('9', 'PARA OBRA DETERMINADA O SERVICIO ESPECÍFICO', 'OBRA DETERM O SERV ESPEC', NOW(), NOW()), 
('10', 'INTERMITENTE', 'INTERMITENTE', NOW(), NOW()), 
('11', 'DE TEMPORADA', 'DE TEMPORADA', NOW(), NOW()), 
('12', 'DE EXPORTACIÓN NO TRADICIONAL D.LEY 22342', 'DE EXPORT. NO TRADIC.', NOW(), NOW()), 
('13', 'DE EXTRANJERO - D.LEG. 689', 'DE EXTRANJERO - D.LEG. 689', NOW(), NOW()), 
('18', 'A DOMICILIO', 'A DOMICILIO', NOW(), NOW()), 
('19', 'FUTBOLISTAS PROFESIONALES', 'FUTBOLISTAS PROFESIONALES', NOW(), NOW()), 
('20', 'AGRARIO - LEY 27360', 'AGRARIO - LEY 27360', NOW(), NOW()), 
('21', 'MIGRANTE ANDINO DECISIÓN 545', 'MIGRANTE ANDINO', NOW(), NOW()), 
('99', 'OTROS NO PREVISTOS', 'OTROS NO PREVISTOS', NOW(), NOW());

-- Data for Company
INSERT INTO `companies` (`name`, `ruc`, `address`, `created_at`, `updated_at`) VALUES 
('ARSAC Contratistas Generales', '12345678978', 'Calle Las Garzas 494 San Isidro', NOW(), NOW());

-- Data for Sector
INSERT INTO `sectors` (`id`, `name`, `code`, `cost_center_id`) VALUES 
(1, 'Sector 0' , '01', 1);

-- Data for Phase
INSERT INTO `phases` (`id`, `name`, `code`, `category`) VALUES 
(1, 'Fase 0' , '01', 'phase');

-- Data for Entity
INSERT INTO `entities` (`name`,`second_name`,`paternal_surname`, `maternal_surname`,`ruc`, `address`, `created_at`, `updated_at`) VALUES 
('Lorem ipsum','dolor sit amet', 'consectetur', 'adipisci velit', '0', '0', NOW(), NOW());
INSERT INTO `entities` (`name`, `ruc`, `address`, `created_at`, `updated_at`) VALUES 
('ARSAC Contratistas Generales', '12345678978', 'Calle Las Garzas 494 San Isidro', NOW(), NOW());

-- Data for worker
INSERT INTO `workers` (`id`, `entity_id`, `cost_center_id`) VALUES 
(1, 1, 1);

-- Data for Entity Type Entity
INSERT INTO `entities_type_entities` (`entity_id`, `type_entity_id`, `created_at`, `updated_at`) VALUES 
(1, 1, NOW(), NOW());

-- Data for Financial Variables
INSERT INTO `financial_variables` (`name`, `value`, `created_at`, `updated_at`) VALUES ('IGV', '0.18', NOW(), NOW());
INSERT INTO `financial_variables` (`name`, `value`, `created_at`, `updated_at`) VALUES ('IPC', '114.63', NOW(), NOW());

INSERT INTO `working_groups` (`id`, `master_builder_id`, `front_chief_id`, `active`, `created_at`, `updated_at`, `executor_id`,  `name`, `cost_center_id`) 
VALUES ('1', '1', '1', '1', NOW(), NOW(), '1', 'Defecto', '1');
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
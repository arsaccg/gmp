-- Data for Type Entities
INSERT INTO `type_entities` (`name`, `preffix`, `created_at`, `updated_at`) VALUES ('Proveedores', 'P', NULL, NULL)
INSERT INTO `type_entities` (`name`, `preffix`, `created_at`, `updated_at`) VALUES ('Accionistas', 'P', NULL, NULL)
INSERT INTO `type_entities` (`name`, `preffix`, `created_at`, `updated_at`) VALUES ('Trabajadores', 'P', NULL, NULL)

-- Data for Type of Article
INSERT INTO `type_of_articles` (`name`, `code`, `created_at`, `updated_at`) VALUES ('Personal', '01', NULL, NULL)
INSERT INTO `type_of_articles` (`name`, `code`, `created_at`, `updated_at`) VALUES ('Material', '02', NULL, NULL)
INSERT INTO `type_of_articles` (`name`, `code`, `created_at`, `updated_at`) VALUES ('Equipos', '03', NULL, NULL)
INSERT INTO `type_of_articles` (`name`, `code`, `created_at`, `updated_at`) VALUES ('Servicios', '04', NULL, NULL)
INSERT INTO `type_of_articles` (`name`, `code`, `created_at`, `updated_at`) VALUES ('SubContratos', '05', NULL, NULL)

-- Data for Company
INSERT INTO `companies` (`name`, `ruc`, `created_at`, `updated_at`) VALUES ('ARSAC Contratistas Generales', '12345678978', NULL, NULL)
INSERT INTO `companies` (`name`, `ruc`, `created_at`, `updated_at`) VALUES ('Consorcio Bagua', '20494052513', NULL, NULL)
INSERT INTO `companies` (`name`, `ruc`, `created_at`, `updated_at`) VALUES ('Consorcio San Francisco del Oriente', '20567151779', NULL, NULL)

-- Data for Financial Variables
INSERT INTO `financial_variables` (`igv`, `value`, `created_at`, `updated_at`) VALUES ('IGV', '0.18', NULL, NULL)
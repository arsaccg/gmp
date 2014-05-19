# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

TypeEntity.create(
  [{ name: 'Proveedores' }, { preffix: 'P' }],
  [{ name: 'Accionistas' }, { preffix: 'AC' }],
  [{ name: 'Trabajadores' }, { preffix: 'T' }],
  [{ name: 'Jefe de Frente' }, { preffix: 'JF' }],
  [{ name: 'Maestro de Obra' }, { preffix: 'MO' }]
)

TypeOfArticle.create(
  [{ name: 'Personal' }, { code: '01' }],
  [{ name: 'Material' }, { code: '02' }],
  [{ name: 'Equipos' }, { code: '03' }],
  [{ name: 'Servicios' }, { code: '04' }],
  [{ name: 'SubContratos' }, { code: '05' }]
)

Company.create(
  [{ name: 'ARSAC Contratistas Generales'}, { ruc: '12345678978' }],
  [{ name: 'Consorcio Bagua'}, { ruc: '20494052513' }],
  [{ name: 'Consorcio San Francisco del Oriente'}, { ruc: '20567151779' }],
)

FinancialVariables.create(
  [{ name: 'igv'}, { value: '0.18' }]
)

Document.create(
  [{ name: 'Ingreso a Almacén'}, { preffix: 'IWH' }],
  [{ name: 'Salida de Almacén'}, { preffix: 'OWH' }]
)
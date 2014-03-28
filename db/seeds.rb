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
  [{ name: 'Trabajadores' }, { preffix: 'T' }]
)

TypeOfArticle.create(
  [{ name: 'Personal' }, { code: '01' }],
  [{ name: 'Material' }, { code: '02' }],
  [{ name: 'Equipos' }, { code: '03' }],
  [{ name: 'Servicios' }, { code: '04' }],
  [{ name: 'SubContratos' }, { code: '05' }]
)
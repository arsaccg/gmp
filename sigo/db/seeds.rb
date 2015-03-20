# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

 
 
Company.create(
  [{ name: 'ARSAC Contratistas Generales', ruc: '12345678978' },
   { name: 'Consorcio Bagua', ruc: '20494052513'},
   { name: 'Consorcio San Francisco del Oriente', ruc: '20567151779' }],
)

#FinancialVariables.create(
#  [{ name: 'igv'}, { value: '0.18' }]
#)

#Document.create(
#  [{ name: 'Ingreso a Almacén', preffix: 'IWH' },
#   { name: 'Salida de Almacén', preffix: 'OWH' }]
#)

@fromDate = Date.parse("01-01-2000")
@toDate = Date.parse("31-12-2030")
@year = @fromDate.strftime("%Y").to_i
@week = 1
@i = 0

# Load Data Link Time
(@fromDate .. @toDate).each do |x|
  @i += 1
  # Year Changed
  if @year != x.strftime("%Y").to_i
    @year = x.strftime("%Y").to_i
    @week = 1
    @i = 1
  end
  LinkTime.create({:date => x, :year => x.strftime("%Y"), :month => x.strftime("%m"), :day => x.strftime("%d"), :week => @week })
  if @i % 7 == 0
    @week += 1
  end
end

Document.create(
  [{ name: 'Ingreso a Almacén',  preffix: 'IWH' },
  { name: 'Salida de Almacén',  preffix: 'OWH' }]
)
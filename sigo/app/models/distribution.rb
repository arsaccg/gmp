require 'roo'
#require 'iconv'

class Distribution < ActiveRecord::Base
  has_many :distribution_items
  
  def self.import_data_from_excel(file, cost_center_id,quantity)
    spreadsheet = open_spreadsheet(file)
    
    header = spreadsheet.row(1)
    
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      puts row["CODIGO"].inspect
      d = Distribution.new
      d.code = row["CODIGO"]
      d.description = row["DESCRIPCION"]
      d.und = row["UND"]
      d.measured = row["METRADO TOTAL"]
      d.cost_center_id = cost_center_id
      d.save
      
      
      items_months = row.keys - ["CODIGO", "DESCRIPCION", "UND", "METRADO TOTAL"]
      items_months.each do |key|
        item=DistributionItem.new
        item.distribution_id = d.id
        item.month = key
        item.value = row[key]
        item.save
      end 
      
      
    end
  end
  
  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Roo::CSV.new(file.path , csv_options: {encoding:Encoding::ISO_8859_1, :col_sep => ";"})
    when ".xls" then Roo::Excel.new(file.path)
    when ".xlsx" then Roo::Excelx.new(file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
  
end

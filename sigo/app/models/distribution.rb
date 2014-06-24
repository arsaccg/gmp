require 'roo'
#require 'iconv'

class Distribution < ActiveRecord::Base
  has_many :distribution_items
  belongs_to :budget
  
  def self.import_data_from_excel(file, cost_center_id,quantity,budget_id)
    spreadsheet = open_spreadsheet(file)
    
    header = spreadsheet.row(1)
    
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      puts row["CODIGO"].inspect
      d = Distribution.new
      d.code = row["CODIGO"]  
      d.cost_center_id = cost_center_id
      d.budget_id = budget_id
      d.save
      
<<<<<<< HEAD
      
=======
>>>>>>> e1e0026167fde6bcf89924db74ac7c604902f9c1
      items_months = row.keys - ["CODIGO"]
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
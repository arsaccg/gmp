class AddColumsToMultipleTable < ActiveRecord::Migration
  def change
  	add_column :book_works, :type_of_book_work_id, :integer
  	add_column :contest_documents, :type_of_contest_document_id, :integer
  	add_column :contractual_documents, :type_of_contractual_document_id, :integer
  	add_column :issued_letters, :type_of_issued_letter_id, :integer
  	add_column :of_companies, :type_of_company_id, :integer
  	add_column :received_letters, :type_of_received_letter_id, :integer
  	add_column :record_of_meetings, :type_of_record_of_meeting_id, :integer
  	add_column :technical_files, :type_of_technical_file_id, :integer
  	add_column :work_reports, :type_of_work_report_id, :integer
  	rename_column :of_companies, :cost_center_id, :company_id
  end
end

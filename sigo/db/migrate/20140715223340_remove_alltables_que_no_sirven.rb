class RemoveAlltablesQueNoSirven < ActiveRecord::Migration
  def change
  	drop_table :book_works_type_of_book_works if table_exists? :book_works_type_of_book_works
  	drop_table :contest_documents_type_of_contest_documents if table_exists? :contest_documents_type_of_contest_documents
  	drop_table :contractual_documents_type_of_contractual_documents if table_exists? :contractual_documents_type_of_contractual_documents
  	drop_table :issued_letters_type_of_issued_letters if table_exists? :issued_letters_type_of_issued_letters
  	drop_table :of_companies_type_of_companies if table_exists? :of_companies_type_of_companies
  	drop_table :received_letters_type_of_received_letters if table_exists? :received_letters_type_of_received_letters
  	drop_table :record_of_meetings_type_of_record_of_meetings if table_exists? :record_of_meetings_type_of_record_of_meetings
  	drop_table :technical_files_type_of_technical_files if table_exists? :technical_files_type_of_technical_files
  	drop_table :type_of_work_reports_work_reports if table_exists? :type_of_work_reports_work_reports
  end
end

class Loan < ActiveRecord::Base
  def self.getWorkers(word)
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT w.id,  e.name, e.paternal_surname, e.maternal_surname, e.dni
      FROM workers w, entities e
      WHERE ( e.name LIKE '%#{word}%' || e.paternal_surname LIKE '%#{word}%' || e.maternal_surname LIKE '%#{word}%' || e.dni LIKE '%#{word}%')
      AND w.entity_id = e.id
      GROUP BY e.id
    ")
    return mysql_result
  end
  has_attached_file :loan_doc
  validates_attachment_content_type :loan_doc, :content_type => ['application/pdf']
  has_attached_file :refund_doc
  validates_attachment_content_type :refund_doc, :content_type => ['application/pdf']
end

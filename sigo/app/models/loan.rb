class Loan < ActiveRecord::Base
    def self.getWorkers(word)
      mysql_result = ActiveRecord::Base.connection.execute("
        SELECT w.id,  e.name, e.paternal_surname, e.maternal_surname
        FROM workers w, entities e
        WHERE ( e.name LIKE '%#{word}%')
        AND w.entity_id = e.id
        GROUP BY e.id
      ")
      return mysql_result
    end
end

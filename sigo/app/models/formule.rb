class Formule < ActiveRecord::Base

  def self.translate_formules(formula,basico)
    str_sentence = formula
    const_variables = formula.scan(/\[.*?\]/)
    const_variables.each do |c|
      concept = Concept.find_by_token(c)
      if concept.id != 1
        str_sentence.gsub! c, concept.amount.to_s
      else
        str_sentence.gsub! c, basico.to_s
      end
    end
    return eval(str_sentence.to_s)
  end

end

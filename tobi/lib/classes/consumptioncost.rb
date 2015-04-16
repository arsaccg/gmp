class ConsumptionCostObj

  attr_accessor :name, :programado, :valorizado, :valorGanado, :real, :meta

  def initialize(metadata, type_amount)
    @name = metadata['str_article']

    if type_amount.include?('specific')
      @programado = (metadata['programado_' + type_amount] rescue '-')
      @valorizado = (metadata['valorizado_' + type_amount] rescue '-')
      @valorGanado = (metadata['valor_ganado_' + type_amount] rescue '-')
      @real = (metadata['real_' + type_amount] rescue '-')
      @meta = (metadata['meta_' + type_amount] rescue '-')
    elsif type_amount.include?('measured')
      @programado = (metadata[type_amount + '_programado'] rescue '-')
      @valorizado = (metadata[type_amount + '_valorizado'] rescue '-')
      @valorGanado = (metadata[type_amount + '_valor_ganado'] rescue '-')
      @real = (metadata[type_amount + '_real'] rescue '-')
      @meta = (metadata[type_amount + '_meta'] rescue '-')
    else
      @programado = '-'
      @valorizado = '-'
      @valorGanado = '-'
      @real = '-'
      @meta = '-'
    end

  end

  def to_s; name.to_s; end
  def to_s; programado.to_s; end
  def to_s; valorizado.to_s; end
  def to_s; valorGanado.to_s; end
  def to_s; real.to_s; end
  def to_s; meta.to_s; end

end
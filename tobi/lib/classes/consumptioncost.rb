class ConsumptionCostObj

  attr_accessor :name, :programado, :valorizado, :valorGanado, :real, :meta, :type

  def initialize(metadata, type_amount,type)
    @name = metadata['str_article']
    @type = type
    if type_amount.include?('specific')
      @programado = (metadata['programado_' + type_amount])
      @valorizado = (metadata['valorizado_' + type_amount])
      @valorGanado = (metadata['valor_ganado_' + type_amount])
      @real = (metadata['real_' + type_amount])
      @meta = (metadata['meta_' + type_amount])
    elsif type_amount.include?('measured')
      @programado = (metadata[type_amount + '_programado'])
      @valorizado = (metadata[type_amount + '_valorizado'])
      @valorGanado = (metadata[type_amount + '_valor_ganado'])
      @real = (metadata[type_amount + '_real'])
      @meta = (metadata[type_amount + '_meta'])
    else
      @programado = '-'
      @valorizado = '-'
      @valorGanado = '-'
      @real = '-'
      @meta = '-'
    end

    if @programado.to_f == 0.0
      @programado = '-'
    end
    if @valorizado.to_f == 0.0
      @valorizado = '-'
    end
    if @valorGanado.to_f == 0.0
      @valorGanado = '-'
    end
    if @real.to_f == 0.0
      @real = '-'
    end
    if @meta.to_f == 0.0
      @meta = '-'
    end

  end

  def to_s; name.to_s; end
  def to_s; programado.to_s; end
  def to_s; valorizado.to_s; end
  def to_s; valorGanado.to_s; end
  def to_s; real.to_s; end
  def to_s; meta.to_s; end
  def to_s; type.to_s; end

end
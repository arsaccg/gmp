class ConsumptionCostTotalObj

  attr_accessor :name, :programado, :valorizado, :valorGanado, :real, :meta, :type

  def initialize(metadata, metadata_sum, type_amount, type)
    if !metadata['str_fase_padre'].nil?
      @name = metadata['str_fase_padre']
    elsif !metadata['str_fase_hijo'].nil?
      @name = metadata['str_fase_hijo']
    elsif !metadata['str_sector_padre'].nil?
      @name = metadata['str_sector_padre']
    elsif !metadata['str_sector_hijo'].nil?
      @name = metadata['str_sector_hijo']
    elsif !metadata['str_article'].nil?
      @name = metadata['str_article']
    elsif !metadata['working_group'].nil?
      @name = metadata['working_group']
    else
      @name = "-"
    end
    @type = type
    if type_amount.include?('specific')
      @programado = (metadata_sum['programado_' + type_amount])
      @valorizado = (metadata_sum['valorizado_' + type_amount])
      @valorGanado = (metadata_sum['valor_ganado_' + type_amount])
      @real = (metadata_sum['real_' + type_amount])
      @meta = (metadata_sum['meta_' + type_amount])
    elsif type_amount.include?('measured')
      @programado = (metadata_sum[type_amount + '_programado'])
      @valorizado = (metadata_sum[type_amount + '_valorizado'])
      @valorGanado = (metadata_sum[type_amount + '_valor_ganado'])
      @real = (metadata_sum[type_amount + '_real'])
      @meta = (metadata_sum[type_amount + '_meta'])
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
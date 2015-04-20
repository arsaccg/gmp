class ConsumptionCostTotalObj

  attr_accessor :name, :programado, :valorizado, :valorGanado, :real, :meta

  def initialize(metadata, metadata_sum, type_amount)
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

    if type_amount.include?('specific')
      @programado = (metadata_sum['programado_' + type_amount] rescue '-')
      @valorizado = (metadata_sum['valorizado_' + type_amount] rescue '-')
      @valorGanado = (metadata_sum['valor_ganado_' + type_amount] rescue '-')
      @real = (metadata_sum['real_' + type_amount] rescue '-')
      @meta = (metadata_sum['meta_' + type_amount] rescue '-')
    elsif type_amount.include?('measured')
      @programado = (metadata_sum[type_amount + '_programado'] rescue '-')
      @valorizado = (metadata_sum[type_amount + '_valorizado'] rescue '-')
      @valorGanado = (metadata_sum[type_amount + '_valor_ganado'] rescue '-')
      @real = (metadata_sum[type_amount + '_real'] rescue '-')
      @meta = (metadata_sum[type_amount + '_meta'] rescue '-')
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
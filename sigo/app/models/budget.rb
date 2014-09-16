# encoding: utf-8
require 'thread'
load 'sqlserver/dbconnector.rb'

class Budget < ActiveRecord::Base

  include DBConnector

  has_many :itembybudgets
  has_many :inputbybudgetanditems
  has_many :itembywbses
  has_many :valorizations
  belongs_to :cost_center
  has_many :distributions

  queue = Queue.new

  def load_dbs
    db_array = Array.new

    str_query = "SELECT name FROM  sysdatabases"

    sysdatabases = do_query(str_query, {db_name: "master"})

        sysdatabases.each do |sysdatabase|
          item_sys = Hash.new
          item_sys[:name] = sysdatabase[0] 
          db_array << item_sys
        end

        return db_array
  end

  def load_bugdets_from_remote(database)
    budget_array = Array.new
    # Cargar Presupuestos desde base de datos remota
    #=================================================
    #
    # SELECT      Presupuesto.CodPresupuesto
        #               Presupuesto.Descripcion 
    # FROM          Presupuesto 
    # ORDER BY    Presupuesto.CodPresupuesto
    str_query = "SELECT Presupuesto.CodPresupuesto, Presupuesto.Descripcion FROM  Presupuesto ORDER BY Presupuesto.CodPresupuesto"
    budgets = do_query(str_query, {db_name: database})
    budgets.each do |item|
      item_budget = Hash.new
      item_budget[:budget_code] = item[0]
      item_budget[:budget_name] = item[1]
      budget_array << item_budget
    end
    return budget_array
  end

  def load_elements(budget_id, cost_center_id, type_of_budget, database, company)
    # ~~~Verificar si los INSUMOS EXISTEN previamente en la base de datos antes de cargarlos~~ (aprox 7 secs)#
    sql = "SELECT DISTINCT SUBSTRING(PresupuestoPartidaDetalle.codInsumo, 3, 9) From PresupuestoPartidaDetalle WHERE PresupuestoPartidaDetalle.codpresupuesto = " + budget_id.to_s #@type.cod_budget[0..6] #+ "0403021"
    qry_arr = do_query(sql,{db_name: database}) #{db_name: "AREQUIPA_BD2014"})

    res_arr = Array.new
    sql = ActiveRecord::Base.send(:sanitize_sql_array,  ["SELECT DISTINCT SUBSTRING(a.code, -8) cod FROM articles a"]) #"1 a"])
    result = ActiveRecord::Base.connection.execute(sql)
    result.each(:as => :hash) do |row| 
      res_arr << [row["cod"]] #"..."
    end

    #intersection = qry_arr & res_arr
    rest = qry_arr - res_arr

    # ~~Verificar si los INSUMOS EXISTEN previamente en la base de datos antes de cargarlos~~ #
    if !rest.empty?
      description_arr = Array.new
      rest.each do |r|
        #sql with limit
        #sql1 = "SELECT * FROM ( SELECT *, ROW_NUMBER() OVER (ORDER BY Insumo.codinsumo) as row FROM Insumo ) a WHERE row > 0 and row <= 1"
        sql1 = "SELECT DISTINCT Insumo.codInsumo, Insumo.descripcion From Insumo WHERE Insumo.codInsumo LIKE '__" + r.first.to_s + "'"
        description_arr << do_query(sql1,{db_name: database}) #{db_name: "AREQUIPA_BD2014"})
      end

      return description_arr
    else
    
      arr_thread = []
      thread_count = 0;
      @cod=""
      # Cargar Presupuestos desde base de datos remota
      #=================================================
      #
      # SELECT        Presupuesto.CodPresupuesto
      #               Presupuesto.Descripcion 
      # FROM          Presupuesto 
      # ORDER BY      Presupuesto.CodPresupuesto
      # WHERE         Presupuesto.CodPresupuesto LIKE '#ID#%'
      array_budgets = do_query("SELECT Presupuesto.CodPresupuesto, Presupuesto.Descripcion FROM  Presupuesto WHERE CodPresupuesto LIKE '" +  budget_id.to_s + "%'  AND Presupuesto.CodPresupuesto <> '9999999' ORDER BY Presupuesto.CodPresupuesto ", {db_name: database})
      count_items = array_budgets.count
      #data_thread = Thread.new do
      array_budgets.each do |budget| 
        # CREAR REGISTRO DE PRESUPUESTO 
        #===============================
        thread_count = thread_count + 1
        
        #arr[i] = Thread.new {
        #cookies[:db_reg_total]  =  count_items
        # Pmicg.counter_global =  thread_count
          #new_budget=Budget.new
          #new_budget.project_id = project_id
          #new_budget.type_of_budget = type_of_budget
          #new_budget.cod_budget = budget[0]  
          #new_budget.description = budget[1]  #Presupuesto.Descripcion
          #new_budget.save
        array_sub_budgets = do_query("SELECT CodPresupuesto, CodSubpresupuesto, Descripcion FROM  Subpresupuesto WHERE CodPresupuesto = '" + budget[0]  + "' AND CodPresupuesto <> '9999999' AND CodSubpresupuesto <> '999'", {db_name: database})
        array_sub_budgets.each do |subbudget|
          if Budget.where("cod_budget = ? AND type_of_budget=?",  subbudget[0].to_s + subbudget[1].to_s, type_of_budget ).first == nil
            new_subbudget=Budget.new
            new_subbudget.cost_center_id = cost_center_id
            new_subbudget.cod_budget = subbudget[0].to_s + subbudget[1].to_s
            @cod = subbudget[0].to_s + subbudget[1].to_s
            new_subbudget.description = subbudget[2].to_s
            new_subbudget.subbudget_code = subbudget[1].to_s
            new_subbudget.type_of_budget = type_of_budget
            new_subbudget.save
            new_item = Item.new                           # Cargar Partidas
            new_item.load_items(cost_center_id, subbudget[0], database)
            new_item_by_budget = Itembybudget.new         #Cargar Generico
            new_item_by_budget.set_data(subbudget[0], database)
          end
        end
        #}
      end
        #end
        #data_thread.join
          #arr.each {|t| t.join }

      if @cod.to_s != ""
        # Poblando Articulos a la tabla especifica.
        if type_of_budget.to_i == 0
          @type = Budget.where("cod_budget LIKE ? AND type_of_budget = 0", @cod)

          #if @type != nil
          cost_center = Budget.find_by_cod_budget(@cod).cost_center_id 
          @type_id = 0
          @match= ActiveRecord::Base.connection.execute("
                  SELECT DISTINCT a.id, a.code, toa.id, c.id, a.name, a.description, u.id, ibi.id
                  FROM inputbybudgetanditems ibi, budgets b, articles a, unit_of_measurements u, type_of_articles toa, categories c
                  WHERE b.id = ibi.budget_id
                  AND b.type_of_budget = 0
                  AND b.cost_center_id = #{cost_center_id}
                  AND ibi.article_id = a.id
                  AND a.unit_of_measurement_id = u.id
                  AND a.category_id = c.id 
                  AND u.id = a.unit_of_measurement_id
                  AND toa.id = a.type_of_article_id
                ")
          
          @match.each do |art|
            if art[5]==nil
              desc="No hay descripción para este artículo"
            else
              desc=art[5]
            end

          	@type.each do |type|
          	  @type_id = type.id
          	end

            sql = ActiveRecord::Base.send(:sanitize_sql_array,  ["INSERT INTO articles_from_cost_center_" + cost_center.to_s + " (article_id, code, type_of_article_id, category_id, name, description, unit_of_measurement_id, cost_center_id, input_by_budget_and_items_id, budget_id) VALUES (?,?,?,?,?,?,?,?,?,?)", art[0].to_i, art[1].to_s, art[2].to_i, art[3].to_i, art[4].to_s, desc.to_s, art[6].to_i, cost_center.to_i, art[7].to_i, @type_id.to_i])
          	result = ActiveRecord::Base.connection.execute(sql)
          end

          com_art= Article.where("code LIKE  '__58______' OR code LIKE '__76______'")
          @cont=0
          com_art.each do |art|
            @cont+=1
            sql = ActiveRecord::Base.send(:sanitize_sql_array,  ["INSERT INTO articles_from_cost_center_" + cost_center.to_s + " (article_id, code, type_of_article_id, category_id, name, description, unit_of_measurement_id, cost_center_id) VALUES (?,?,?,?,?,?,?,?)", art.id.to_i, art.code.to_s, art.type_of_article_id.to_i, art.category_id.to_i, art.name.to_s, art.description.to_s, art.unit_of_measurement_id.to_i, cost_center.to_i])
    	      result = ActiveRecord::Base.connection.execute(sql) 
          end
        end
        #end
      end

      # Importando partidas al subcontrato
      #@itembybudgets = Itembybudget.get_item_by_budget
      #@company_name = company.name rescue " "
      #@entity_id = Entity.find_by_name(@company_name).id rescue nil
      #@subcontract_id = Subcontract.find_by_entity_id(@entity_id) rescue nil
      #@itembybudgets.each do |ibb|
      #  SubcontractDetail.create(article_id: nil, amount: 0, unit_price: 0, partial: 0, description: nil, created_at: DateTime.now, updated_at: DateTime.now, subcontract_id: @subcontract, itembybudget_id: ibb[1],)
      #end
      #Ultimo paso

      #no importar si ya existe articles from cost_center_1
    
      Itembybudget.connection.execute('UPDATE itembybudgets SET subbudgetdetail = (SELECT description FROM items WHERE item_code = itembybudgets.item_code LIMIT 1)  WHERE title="REGISTRO RESTRINGIDO" AND subbudgetdetail = "";')
    
      return true
    end
  
  end

  def self.budget_meta_info_per_article(cod_article, cost_center_id)
    # For Table Meta in Analysis Production
    data_mysql = ActiveRecord::Base.connection.execute("
      SELECT ibbi.cod_input, SUM( ibbi.quantity ) AS quantity, ibbi.price AS price, (ibbi.price * SUM( ibbi.quantity )) AS partial 
      FROM budgets b, inputbybudgetanditems ibbi
      WHERE b.type_of_budget = 0
      AND b.cost_center_id = " + cost_center_id.to_s + " 
      AND ibbi.budget_id = b.id
      AND ibbi.cod_input LIKE '" + cod_article.to_s + "'
      GROUP BY ibbi.cod_input
    ")

    return data_mysql.first
  end

end


# ** Presupuesto x partida
  #   SELECT codpartida,
  #          Orden,
  #          Metrado,
  #          precio1,
  #          Parcial1,
  #          codsubpresupuesto as s,
  #          CodPresupuesto   
  #     FROM SubpresupuestoDetalle
  # where codpresupuesto ='0401010' and  PropioPartida<>'99' and CodSubpresupuesto='001'
  # order by orden asc

  #** Presupuesto partida-insumo
  #   SELECT PresupuestoPartidaDetalle.CodPartida,   
  #          PresupuestoPartidaDetalle.CodPresupuesto,   
  #          PresupuestoPartidaDetalle.PropioPartida,   
  #          PresupuestoPartidaDetalle.CodInsumo,   
  #          PresupuestoPartidaDetalle.Cantidad,   
  #          PresupuestoPartidaDetalle.Precio1,   
  #          PresupuestoPartidaDetalle.Cantidad * PresupuestoPartidaDetalle.Precio1 * isnull(SubpresupuestoDetalle.Metrado,1) as valor,   
  #          SubpresupuestoDetalle.Orden,   
  #          SubpresupuestoDetalle.Metrado,   
  #          SubpresupuestoDetalle.Item  
  #     FROM PresupuestoPartidaDetalle,   
  #          SubpresupuestoDetalle  
  #    WHERE ( PresupuestoPartidaDetalle.CodPresupuesto = SubpresupuestoDetalle.CodPresupuesto    ) and  
  #          ( PresupuestoPartidaDetalle.CodPartida     = SubpresupuestoDetalle.CodPartida        ) and  
  #          ( PresupuestoPartidaDetalle.PropioPartida  = SubpresupuestoDetalle.PropioPartida     ) and  
  #          ( 
  #            ( PresupuestoPartidaDetalle.CodPresupuesto = '0401010' ) AND  
  #            ( SubpresupuestoDetalle.PropioPartida <> '99' ) AND  
  #            ( SubpresupuestoDetalle.CodSubpresupuesto = '001' )
  #          )   
  # ORDER BY SubpresupuestoDetalle.Orden ASC   

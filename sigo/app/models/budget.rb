require 'thread'
load 'sqlserver/dbconnector.rb'

class Budget < ActiveRecord::Base

  include DBConnector

  has_many :itemsbybudgets
  has_many :inputbybudgetanditems
  has_many :itembywbses
  has_many :valorizations
  belongs_to :cost_center

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



  def load_elements(budget_id, cost_center_id, type_of_budget, database)

    arr_thread = []

    thread_count = 0;

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

                new_subbudget=Budget.new
                new_subbudget.cost_center_id = cost_center_id
                new_subbudget.cod_budget = subbudget[0].to_s + subbudget[1].to_s
                new_subbudget.description = subbudget[2].to_s
                new_subbudget.subbudget_code = subbudget[1].to_s
                new_subbudget.type_of_budget = type_of_budget
                new_subbudget.save

                new_item = Item.new                           # Cargar Partidas
                new_item.load_items(cost_center_id, subbudget[0], database)

                new_item_by_budget = Itembybudget.new         #Cargar Generico
                new_item_by_budget.set_data(subbudget[0], database)

            end
            #}

            

        end

      #end
      #data_thread.join
        #arr.each {|t| t.join }
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
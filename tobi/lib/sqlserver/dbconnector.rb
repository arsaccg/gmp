module DBConnector

	mattr_accessor :url_webservice 
	mattr_accessor :server
	mattr_accessor :db_name
	mattr_accessor :user
	mattr_accessor :pass



	def do_query(query, params)
		
		load_params(params)

		puts "QUERY"
		puts query

		query_str = server.to_s + ":" + db_name.to_s + ":" + user.to_s + ":" + pass.to_s + ":" + query.to_s

		client = Savon.client(wsdl: @@url_webservice)
		response = client.call(:execute_query, message: { query: query_str })
		result = response.body[:execute_query_response][:execute_query_result]
		json=JSON.parse(result)
		return json
	end

	def load_params(params)
		
		# ICGSERVER\SQLEXPRESS:s10_db:sa:pass:select * from TABLE

		#@@url_webservice = "http://192.168.1.123/Extractor.asmx?wsdl"
		
		@@url_webservice = params[:url] == nil ? "http://192.168.2.91/Extractor.asmx?wsdl" : "http://#{params[:url]}/Extractor.asmx?wsdl"
		@@server = params[:server] == nil ? "SRV-S10\\S10" : params[:server]
		@@db_name = params[:db_name] == nil ? "master" : params[:db_name]
		@@user = params[:user] == nil ? "sa" : params[:user]
		@@pass = params[:pass] == nil ? "" : params[:pass]	

		#@@server =  "ICGSERVER\\SQLEXPRESS"
		#if params[:server] == nil; "SRV-S10\\S10" else  params[:server] end

		#if params[:db_name] == nil; "master" else params[:server] end
		 
		#@@db_name = "bagua_rev"
		#@@db_name = "s10db"
		#@@user = "sa"
		#@@pass = "r3dc0d3"
		#@@pass = ""
	end



end




import socket  


import pyodbc

class Connector:

	global url
	url = ""
	global database
	database=""
	global user 
	user= ""
	global password
	password=""


	def set_parameters(v_url, v_database, v_user, v_password, da):
		url=v_url
		database=v_database
		user = v_user
		password = v_password

	def do_query(query, ds):
		query=query
		conect_string = 'DRIVER={SQL Server};SERVER="192.168.1.90";DATABASE="bagua";UID="sa";PWD=' + password
		print (conect_string)
		cnxn = pyodbc.connect(conect_string)
		cursor = cnxn.cursor()
		cursor.execute(query)
		rows = cursor.fetchall()
		return rows

class socket_server:
	
	global busy 
	busy = 0

	s = socket.socket()   
	s.bind(("127.0.0.1", 8090))  
	s.listen(1)  
	  
	sc, addr = s.accept()  
	  
	while True:  
		recibido = sc.recv(1024)  
		if busy == 1:
			connector = Connector()
			connector.set_parameters('192.168.1.90', 'bagua', 'sa', 'password')
			result = connector.do_query(str(recibido).replace("\n", ""))
			sc.send(result)  
			busy = 0
		if recibido.decode("utf-8") == 'quit\n':  
			sc.send('bye bye')  
			break        
		if recibido.decode("utf-8") == 'query\n':
			busy = 1 
		sc.send(recibido)
		print (recibido.decode("utf-8"))
	   
	  
	sc.close()  
	s.close()  

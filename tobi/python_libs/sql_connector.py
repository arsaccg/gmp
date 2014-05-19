
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
		conect_string = 'DRIVER={SQL Server};SERVER=' + url + ';DATABASE=' + database + ';UID=' + user + ';PWD=' + password
		cnxn = pyodbc.connect(conect_string)
		cursor = cnxn.cursor()
		cursor.execute(query)
		rows = cursor.fetchall()
		return rows


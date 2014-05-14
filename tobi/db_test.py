import pyodbc
cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER=192.168.1.90;DATABASE=bagua;UID=sa;PWD=')
cursor = cnxn.cursor()
cursor.execute("select *  FROM log_fases")
rows = cursor.fetchall()
for row in rows:
    print row.user_id, row.user_name
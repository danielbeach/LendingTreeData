import os
import csv
import pyodbc

#list files in directory
def listFiles():
	files = os.listdir('C:\\Users\\Daniel.Beach\\Desktop\\LendingCLubData')
	return files

#read a row in a file
def fileToRow(fullfile):
	with open(fullfile, 'r') as f:
		reader = csv.reader(f)
		next(reader) #skip header
		for row in reader:
			yield row

#take a row and put it in SQL Server
def rowToSQL(row):
	cnxn = pyodbc.connect('DRIVER={SQL Server};SERVER=YourServer;DATABASE=YourDatabase;UID=UserName;PWD=Passwpord') #connect
	cursor = cnxn.cursor() #open cursor
	for column in row:
		la = column[0]
		fa = column[1]
		fai = column[2]
		term = column[3]
		ir = column[4]
		i = column[5]
		g = column[6]
		ho = column[7]
		ai = column[8]
		vs = column[9]
		id = column[10]
		ls = column[11]
		ads = column[12]
		oa = column[13]
		at = column[14]
		query = cursor.execute("INSERT INTO dbo.LendingTree VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",la,fa,fai,term,ir,i,g,ho,ai,vs,id,ls,ads,oa,at)
	cnxn.commit()
	print('file done')
	
def main():
	fileList = []
	l = listFiles()
	for f in l:
		directory = 'C:\\Users\\Daniel.Beach\\Desktop\\LendingCLubData'
		fullfile = os.path.join(directory,f)
		row = fileToRow(fullfile)
		rowToSQL(row)
	cnxn.close()
	

if __name__ == '__main__':
	main()
		
		

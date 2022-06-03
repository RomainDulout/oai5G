# MANDATORY : install mysql-connector-python
# pip3 install mysql-connector-python

import mysql.connector


print("--> CONNECTION TO MYSQL DATABASE")

mydb = mysql.connector.connect(
  host="192.168.71.131",
  user="root",
  password="linux",
  database="oai_db"
)


mycursor = mydb.cursor()

print("--> WRITTING IN DATABASE")

f1 = "INSERT INTO `users` VALUES ('2089901000011"
f2 = "','1','55000000000000',NULL,'PURGED',50,40000000,100000000,47,0000000000,1,0xfec86ba6eb707ed08905757b1bb44b8f,0,0,0x40,'ebd07771ace8677a',0xc42449363bbad02b66d16bc975d77cc1)"

for i in range (2,100):
  if i < 10:
    tmp = f1 + "0" + str(i) + f2
  else:
    tmp = f1 + str(i) + f2
  mycursor.execute(tmp)
  mydb.commit()

print("--> DONE")





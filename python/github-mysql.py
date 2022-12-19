import pymysql
#创建连接和游标
conn=pymysql.connect(host='192.168.21.96',user='root',password='xmz',db='test',charset='utf8')
cur=conn.cursor()
#编写sql
sql_s='select * from me;'
#执行sql
cur.execute(sql_s)
#打印结果
info=cur.fetchall()
print(info)
#关闭游标和连接
cur.close()
conn.close()
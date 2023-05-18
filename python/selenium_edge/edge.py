from selenium import webdriver
from selenium.webdriver.edge.options import Options

'''
先配置msedge.exe的环境变量
执行以下命令打开网页操作登录后，可执行自动化代码
msedge.exe --remote-debugging-port=9222 --user-data-dir="D:\selenum\AutomationProfile"
'''


options=Options()
options.add_experimental_option("debuggerAddress", "127.0.0.1:9222")
driver='msedge.exe'
edge_driver=webdriver.Edge(driver,options=options)
print(edge_driver.title)

from selenium import webdriver
from selenium.webdriver.edge.service import Service
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver import ActionChains
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
'''
先配置msedge.exe的环境变量
执行以下命令打开网页操作登录后，可执行自动化代码
msedge.exe --remote-debugging-port=9222 --user-data-dir="D:\selenum\AutomationProfile"
'''
def cli(css):
    c=WebDriverWait(driver, 1, 0.3).until(EC.presence_of_element_located((By.CSS_SELECTOR,css)))
    c.click()
def send(css,txt):
    s=driver.find_element(By.CSS_SELECTOR,css)
    s.send_keys(txt,Keys.ENTER)


options = webdriver.EdgeOptions()
options.service = Service('msedge.exe')
options.add_experimental_option("debuggerAddress", "127.0.0.1:9222")
options.add_argument("disable-gpu")
options.page_load_strategy = 'none'
driver = webdriver.Edge(options=options)
driver.implicitly_wait(3)


driver.get('https://www.damai.cn/')

ss='body > div.dm-header-wrap > div > div.search-header > input'
ych='body > div.search-box > div.search-box-flex > div.search-main > div.search-factor > div:nth-child(2) > div > div > div > span'

send(ss,'许嵩')
cli(ych)

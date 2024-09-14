import requests,json,time
from datetime import datetime
import datetime as d
def post_dingding(who,text):
    # print(who,text)
    token = 'f09f602ed839e5c34b78bd4671dbcec1a1e64f0bd5b3d817e9b4d9a7508354dd'
    url=f"https://oapi.dingtalk.com/robot/send?access_token={token}"
    headers={"Content-Type":"application/json"}
    data={"msgtype": "text","text": {"content":f"tips:{text}"},"at":{"atMobiles":who}}
    try:
        requests.post(url=url,headers=headers,data=json.dumps(data))
    except:
        time.sleep(1)
        try:
            requests.post(url=url, headers=headers, data=json.dumps(data))
        except:
            time.sleep(1)
            requests.post(url=url, headers=headers, data=json.dumps(data))

def get_data_code(date):
    url = f'http://timor.tech/api/holiday/info/{date}'  # 接口地址
    headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:126.0) Gecko/20100101 Firefox/126.0'}
    response = requests.get(url=url, headers=headers)
    data = json.loads(response.text)
    data_code = data.get('type').get('type')
    return data_code

if __name__ == '__main__':

    #定义变量
    text_1='叮~要上班打卡哦！'
    text_2='点外卖了！'
    text_3='下班了，记得打卡哦！'
    text_4='点单明天的下午茶！'
    text_5='到点了，干饭了！'
    text_6='本地文件长时间未更新，请手动更新D:/document/python/repo/dingding/dingding.txt'
    text_7='节假日接口调用错误，请手动更新D:/document/python/repo/dingding/dingding.txt'
    gy=["18106561932"]
    xqr=["15857181495"]
    all=["18106561932","15857181495"]

    #读取记录文件
    txt_path="D:/document/python/repo/dingding/dingding.txt"
    with open(txt_path, 'r',encoding='utf-8') as file:
        lines = file.readlines()
    t=time.localtime()
    txt_day=datetime.strptime(lines[1],"%Y-%m-%d\n")
    now_date=datetime.strptime(f'{t.tm_year}-{t.tm_mon}-{t.tm_mday}',"%Y-%m-%d")
    days=(now_date-txt_day).days
    who_day=int(lines[2])
    t_now = datetime.now()
    if days == 1:
        date = str(t_now.date())
        lines[1] = date + '\n'
        try:
            data_code=get_data_code(date)
        except:
            time.sleep(2)
            try:
                data_code=get_data_code(date)
            except:
                post_dingding(gy, text_7)
                data_code=4
        # date_code节假日类型，0工作日、1周末、2节日、3补班,4获取失败信息未更新
        if data_code in [0, 3]:
            who_day = (who_day + 1) % 3
            lines[2] = str(who_day) + '\n'
        lines[3] = str(data_code)
        with open(txt_path, 'w', encoding='utf-8') as file:
            file.writelines(lines)
    elif days == 0:
        pass
    else:
        post_dingding(gy, text_6)
        exit()
    today_code = int(lines[3])

    #发送提醒消息
    if today_code in [0,3]:
        if who_day == 0:
            text_1 = '【值班】' + text_1
            text_2 = '【值班】' + text_2
            text_3 = '【值班】' + text_3
            text_4 = '【值班】' + text_4
            text_5 = '【值班】' + text_5
            if t.tm_hour in [18]:
                post_dingding(gy, text_5)
            if t.tm_hour in [21]:
                post_dingding(gy, text_3)
        elif t.tm_hour in [18]:
            post_dingding(gy, text_3)
        if t.tm_hour in [9]:
            post_dingding(gy, text_1)
        if t.tm_hour in [10]:
            post_dingding(gy, text_2)
        if t.tm_hour in [12]:
            post_dingding(gy, text_5)
    elif today_code in [1,2]:
        if days == 1:
            tomorrow = t_now + d.timedelta(days=1)
            tomorrow_date = str(tomorrow.date())
            try:
                tomorrow_code=get_data_code(tomorrow_date)
            except:
                time.sleep(2)
                try:
                    tomorrow_code=get_data_code(tomorrow_date)
                except:
                    post_dingding(gy, text_7)
                    data_code=4
            if tomorrow_code in [0,3]:
                my_days = 3-who_day
                week_now = t_now.weekday()
                week_day = (week_now + my_days) % 7
                post_dingding(all, f"下次值班是周{'一二三四五六日'[week_day]}")

    #工作提醒
    p_date=datetime.strptime('2024-10-04',"%Y-%m-%d")
    p_days = (p_date-now_date).days
    if p_days<=20:
        post_dingding(gy,'闲趣资源包,内容安全要及时续费')
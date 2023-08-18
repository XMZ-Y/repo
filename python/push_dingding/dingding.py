import json
import requests
import time,datetime
def post_dingding(token,text):
    url=f"https://oapi.dingtalk.com/robot/send?access_token={token}"
    headers={"Content-Type":"application/json"}
    data={"msgtype": "text","text": {"content":f"tips:{text}"},"at":{"isAtAll":True}}
    res=requests.post(url=url,headers=headers,data=json.dumps(data))
    print(res)
if __name__ == '__main__':
    token='f09f602ed839e5c34b78bd4671dbcec1a1e64f0bd5b3d817e9b4d9a7508354dd'
    text_1='到公司了，叮~上班打卡'
    text_2='可以点外卖了'
    text_3='下班了，记得打卡哦'
    t=time.localtime()
    start_date=datetime.datetime.strptime('2023-8-14',"%Y-%m-%d")
    end_date=datetime.datetime.strptime(f'{t.tm_year}-{t.tm_mon}-{t.tm_mday}',"%Y-%m-%d")
    num_day=(end_date-start_date).days
    day_w=int(num_day/7)
    who_day=(num_day-day_w*2)%3
    ignore_w=[6,7]
    if t.tm_wday+1 not in ignore_w:
        if who_day == 0:
            text_1='【值班】'+text_1
            text_2='【值班】'+text_2
            text_3='【值班】'+text_3
            if t.tm_hour in [17]:
                post_dingding(token, text_2)
            if t.tm_hour in [21]:
                post_dingding(token, text_3)
        elif t.tm_hour in [18]:
            post_dingding(token, text_3)
        if t.tm_hour in [8,9]:
            post_dingding(token, text_1)
        if t.tm_hour in [11]:
            post_dingding(token, text_2)

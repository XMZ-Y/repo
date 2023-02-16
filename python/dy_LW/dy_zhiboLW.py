from dy_pb2 import PushFrame,Response,ChatMessage,GiftMessage
from websocket import WebSocketApp
from urllib.parse import unquote_plus
import gzip
import websocket
import json
import re
import requests
import datetime
import time

def fetch_live_room_info(url):
    res=requests.get(
        url=url,
        headers={
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36",
        },
        cookies={
            "__ac_nonce": "2023013011232740CE842751D35E26FA92"
        }
    )

    data_string = re.findall(r'<script id="RENDER_DATA" type="application/json">(.*?)</script>',res.text)[0]
    data_dict = json.loads(unquote_plus(data_string))
    room_id = data_dict['app']['initialState']['roomStore']['roomInfo']['roomId']
    room_title = data_dict['app']['initialState']['roomStore']['roomInfo']["room"]['title']
    room_user_count = data_dict['app']['initialState']['roomStore']['roomInfo']["room"]['user_count_str']
    wss_url=f"wss://webcast3-ws-web-hl.douyin.com/webcast/im/push/v2/?app_name=douyin_web&version_code=180800&webcast_sdk_version=1.3.0&update_version_code=1.3.0&compress=gzip&internal_ext=internal_src:dim|wss_push_room_id:{room_id}|wss_push_did:7194720819045713412|dim_log_id:202301311551337804232F98F5241E5599|fetch_time:1675151493644|seq:1|wss_info:0-1675151493644-0-0|wrds_kvs:InputPanelComponentSyncData-1675133124833050530_MoreLiveSyncData-1675151482619449349_WebcastRoomStatsMessage-1675151490682963987_WebcastRoomRankMessage-1675151406710703300&cursor=t-1675151493644_r-1_d-1_u-1_h-1&host=https://live.douyin.com&aid=6383&live_id=1&did_rule=3&debug=false&endpoint=live_pc&support_wrds=1&im_path=/webcast/im/fetch/&user_unique_id=7194720819045713412&device_platform=web&cookie_enabled=true&screen_width=1920&screen_height=1080&browser_language=zh-CN&browser_platform=Win32&browser_name=Mozilla&browser_version=5.0%20(Windows%20NT%2010.0;%20Win64;%20x64)%20AppleWebKit/537.36%20(KHTML,%20like%20Gecko)%20Chrome/109.0.0.0%20Safari/537.36&browser_online=true&tz_name=Asia/Shanghai&identity=audience&room_id={room_id}&heartbeatDuration=0"
    ttwid = res.cookies.get_dict()['ttwid']

    return room_title,room_user_count,wss_url,ttwid


def on_open(ws):
    print("on_open")
    print(ws)

def on_message(ws,content):
    frame = PushFrame()
    frame.ParseFromString(content)

    origin_bytes = gzip.decompress(frame.payload)

    response = Response()
    response.ParseFromString(origin_bytes)

    if response.needAck:
        s = PushFrame()
        s.payloadType = "ack"
        s.payload = response.internalExt.encode('utf-8')
        s.logid = frame.logid
        ws.send(s.SerializeToString())

    f = open(r"D:\dy_LW.txt", "a", encoding="UTF-8")
    for item in response.messagesList:
        if item.method != "WebcastGiftMessage":
            continue
        message = GiftMessage()
        message.ParseFromString(item.payload)
        # print(message)
        time_now = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        info = f"{message.user.nickName}  送来  {message.comboCount}个  {message.gift.name}"
        print(time_now,info)
        f.write(f"{time_now} {info}\n")
    f.close()

def on_error(ws,content):
    print("on_error")
    print(ws,content)

def on_close(ws,content,close):
    print("on_close")
    print(ws,content,close)


def run():
    web_url="https://live.douyin.com/271069055515"        #原神呼呼直播间
    # web_url="https://live.douyin.com/80017709309"         #东方甄选直播间

    room_title,room_user_count,wss_url,ttwid=fetch_live_room_info(web_url)
    print(room_title + "\n" + room_user_count)
    ws=WebSocketApp(
        url=wss_url,
        header={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/109.0.0.0 Safari/537.36"},
        cookie=f"ttwid={ttwid}",
        on_open=on_open,
        on_message=on_message,
        on_error=on_error,
        on_close=on_close,
    )
    websocket.enableTrace(False)
    if room_user_count != "0":
        ws.run_forever()
    return room_user_count




if __name__ == '__main__':
    while True:
        time_now = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        print(time_now)
        room_user_count=run()
        time.sleep(3)
        if room_user_count == "0":
            break
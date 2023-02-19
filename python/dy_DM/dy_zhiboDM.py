from dy_pb2 import PushFrame,Response,ChatMessage,MemberMessage,GiftMessage
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
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/110.0",
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
    wss_url=f"wss://webcast3-ws-web-lq.douyin.com/webcast/im/push/v2/?app_name=douyin_web&version_code=180800&webcast_sdk_version=1.3.0&update_version_code=1.3.0&compress=gzip&internal_ext=internal_src:dim|wss_push_room_id:{room_id}|wss_push_did:7201038058799924771|dim_log_id:20230217162605E0E5E7C072BD370F241F|fetch_time:1676622365057|seq:1|wss_info:0-1676622365057-0-0|wrds_kvs:InputPanelComponentSyncData-1676594689577582834_WebcastRoomRankMessage-1676622187293684595_WebcastRoomStatsMessage-1676622361264550308&cursor=t-1676622365057_r-1_d-1_u-1_h-1&host=https://live.douyin.com&aid=6383&live_id=1&did_rule=3&debug=false&endpoint=live_pc&support_wrds=1&im_path=/webcast/im/fetch/&user_unique_id=7201038058799924771&device_platform=web&cookie_enabled=true&screen_width=1920&screen_height=1080&browser_language=zh-CN&browser_platform=Win32&browser_name=Mozilla&browser_version=5.0%20(Windows%20NT%2010.0;%20Win64;%20x64)%20AppleWebKit/537.36%20(KHTML,%20like%20Gecko)%20Chrome/109.0.0.0%20Safari/537.36&browser_online=true&tz_name=Asia/Shanghai&identity=audience&room_id={room_id}&heartbeatDuration=0&signature=RhQlmTBX7xC0wIiP"
    ttwid = res.cookies.get_dict()['ttwid']

    return room_title,room_user_count,wss_url,ttwid


def on_open(ws):
    print("on_open")
    # print(ws)

def on_message(ws,content):
    frame = PushFrame()
    frame.ParseFromString(content)

    origin_bytes = gzip.decompress(frame.payload)

    response = Response()
    response.ParseFromString(origin_bytes)

    time_now = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    if response.needAck:
        s = PushFrame()
        s.payloadType = "ack"
        s.payload = response.internalExt.encode('utf-8')
        s.logid = frame.logid
        ws.send(s.SerializeToString())

    f_DM = open(r"D:\dy_DM.txt", "a", encoding="UTF-8")
    # f_LW = open(r"D:\dy_LW.txt", "a", encoding="UTF-8")
    for item in response.messagesList:
        if item.method == "WebcastChatMessage":
            message = ChatMessage()
            message.ParseFromString(item.payload)
            info_ChatMessage = f"{message.user.gender} {message.user.nickName}      {message.content}"
            print(time_now,info_ChatMessage)
            f_DM.write(f"{time_now} {info_ChatMessage}\n")
        if item.method == "WebcastMemberMessage":
            message = MemberMessage()
            message.ParseFromString(item.payload)
            info_MemberMessage = f"{message.user.gender} {message.user.nickName}进入直播间"
            print(time_now,info_MemberMessage)
            # f_DM.write(f"{time_now} {info_MemberMessage}\n")
        if item.method == "WebcastGiftMessage":
            message = GiftMessage()
            message.ParseFromString(item.payload)
            info_GiftMessage = f"{message.user.nickName}  送来  {message.comboCount}个{message.gift.name}"
            print(time_now,info_GiftMessage)
        #     f_LW.write(f"{time_now} {info_GiftMessage}\n")
    f_DM.close()
    # f_LW.close()

def on_error(ws,content):
    print("on_error")
    # print(ws,content)

def on_close(ws,content,close):
    print("on_close")
    # print(ws,content,close)


def run():
    web_url="https://live.douyin.com/271069055515"        #原神呼呼直播间
    # web_url="https://live.douyin.com/80017709309"         #东方甄选直播间

    room_title,room_user_count,wss_url,ttwid=fetch_live_room_info(web_url)
    print(room_title + "\n" + room_user_count)
    ws=WebSocketApp(
        url=wss_url,
        header={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/110.0"},
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
        room_user_count=run()
        time.sleep(3)
        if room_user_count == "0":
            # break
            time.sleep(1800)
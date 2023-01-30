import gzip
import binascii
from dy_pb2 import PushFrame,Response,ChatMessage
from websocket import WebSocketApp
import json
import re
from urllib.parse import unquote_plus
import requests

def fetch_live_room_info(url):
    res=requests.get(
        url=url,
        headers={
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/109.0",
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

    wss_url=f"wss://webcast3-ws-web-lf.douyin.com/webcast/im/push/v2/?app_name=douyin_web&version_code=180800&webcast_sdk_version=1.3.0&update_version_code=1.3.0&compress=gzip&internal_ext=internal_src:dim|wss_push_room_id:{room_id}|wss_push_did:7194365801431533114|dim_log_id:202301301654078F75DDA92C5A60041FEB|fetch_time:1675068847837|seq:1|wss_info:0-1675068847837-0-0|wrds_kvs:InputPanelComponentSyncData-1675046737740515894_MoreLiveSyncData-1675068837641753048_HighlightContainerSyncData-2_WebcastRoomStatsMessage-1675068846997103164_WebcastRoomRankMessage-1675068847026484656&cursor=t-1675068847837_r-1_d-1_u-1_h-1&host=https://live.douyin.com&aid=6383&live_id=1&did_rule=3&debug=false&endpoint=live_pc&support_wrds=1&im_path=/webcast/im/fetch/&user_unique_id=7194365801431533114&device_platform=web&cookie_enabled=true&screen_width=1920&screen_height=1080&browser_language=zh-CN&browser_platform=Win32&browser_name=Mozilla&browser_version=5.0%20(Windows)&browser_online=true&tz_name=Asia/Shanghai&identity=audience&room_id={room_id}&heartbeatDuration=0&signature=R0BAHsL3ng2x7LqD"

    ttwid = res.cookies.get_dict()['ttwid']

    return room_id,room_title,room_user_count,wss_url,ttwid


def on_open(ws,content):
    print("on_open")

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
        s.logId = frame.logId

        ws.send(s.SerializeToString())

    for item in response.messagesList:
        if item.method != "WebcastChatMessage":
            continue
        message = ChatMessage()
        message.ParseFromString(item.payload)
        info = f"{message.user.gender} {message.user.nickName}:    {message.content}\n"
        print(info)

def on_error(ws,content):
    print("on_error")
    print(content)

def on_close(ws,content):
    print("on_close")



def run():
    web_url="https://live.douyin.com/80017709309"
    room_id,room_title,room_user_count,wss_url,ttwid=fetch_live_room_info(web_url)
    print(room_id + "\n" + room_title + "\n" + room_user_count + "\n" + wss_url + "\n" + ttwid)
    ws=WebSocketApp(
        url=wss_url,
        header={},
        cookie=f"ttwid={ttwid}",
        on_open=on_open,
        on_message=on_message,
        on_error=on_error,
        on_close=on_close,
    )
    ws.run_forever()

if __name__ == '__main__':
    run()
import websockets
url = "ws://127.0.0.1:5000"

async def send(msg):
    async with websockets.connect(url) as websocket:
        await websocket.send(str(msg))
        await websocket.recv()
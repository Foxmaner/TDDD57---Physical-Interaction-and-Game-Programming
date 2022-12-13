# WebSocket Client
import websockets

ws_address = "ws://127.0.0.1:5000"

# Send message
async def send(message):
    async with websockets.connect(ws_address) as websocket:
        await websocket.send(str(message))
        await websocket.recv()
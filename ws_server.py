import asyncio
import websockets

USERS = set()
port = 5000

async def msg_handler(websocket):
    global USERS
    try:
        USERS.add(websocket)
        async for message in websocket:
            websockets.broadcast(USERS, message)
       
    finally:
        USERS.remove(websocket)
        

async def main():
    print("Starting websocket server on port" + str(port) )
    server1 = await websockets.serve(msg_handler, '', port)
    await asyncio.gather(server1.wait_closed())


asyncio.run(main())

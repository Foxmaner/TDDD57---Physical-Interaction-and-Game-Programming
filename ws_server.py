import asyncio
import websockets

USERS = set()
port = 5000

async def ws_handler(websocket):
    global USERS
    try:
        USERS.add(websocket)
        async for msg in websocket:
            #print(msg)
            websockets.broadcast(USERS, msg)
       
    finally:
        USERS.remove(websocket)
        

async def main():
    print("Serving on localhost : " + str(port) )
    da_server = await websockets.serve(ws_handler, '', port)
    await asyncio.gather(da_server.wait_closed())


asyncio.run(main())

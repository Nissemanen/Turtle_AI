import asyncio, websockets, json
import log

SERVER_VERSION = "0.3.1"
SERVER_CAPABILITIES = []


async def main_loop(websocket: websockets.ServerConnection, session: dict):
    async for message in websocket:
        msg = json.loads(message)
        msg_type = msg.get("type")

        if msg_type == "state":
            pass

        else:
            log.info(f"Unknown message type: {msg_type}")


async def handler(websocket: websockets.ServerConnection):
    log.info("Turtle connected!")
    
    # Handle input
    msg = await websocket.recv()
    client_hello = json.loads(msg)

    if client_hello.get("type") != "hello":
        log.info("Client didnt send hello, disconnecting")
        return
    
    client_capabilities = client_hello.get("capabilities", [])
    log.info("Turtle connected: {capabilities: "+str(client_capabilities)+"}")

    # Give output

    await websocket.send(json.dumps({
        "type": "hello",
        "version": SERVER_VERSION,
        "capabilities": SERVER_CAPABILITIES
    }))

    session = {
        "capabilities": client_capabilities
    }

    # Start connection

    await main_loop(websocket, session)



async def main():
    async with websockets.serve(handler, "0.0.0.0", 8765):
        log.info("Server running on port 8765")
        await asyncio.Future()

if __name__ == "__main__":
    asyncio.run(main())
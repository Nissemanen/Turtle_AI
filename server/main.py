import asyncio
import server
import json
import llm

FACING_DATA = {
    "0, 0":'You are currently facing north, or in other words towards the negative Z',
    "1, 0":'You are currently facing east, or in other words towards the positive X',
    "0, 1":'You are currently facing west, or in other words towards the negative X',
    "-1, 0":'You are currently facing south, or in other words towards the positive Z',
    "0, -1":'You are currently facing north, or in other words towards the negative Z'
    }
messages = []

async def idk_do_stuff(msg, first=False):
    global messages

    result = llm.get_action(msg)

    facing = FACING_DATA.get(str(data.get('facing')))



async def on_request(websocket, data, session):
    global messages

    facing = data.get('facing', [0, 0])

    messages = [{"role":"system", "content":f"""
You are a robot living inside a Minecraft world. You can move arround in the world and search for things.

## Surroundings
Your surroundings will be formated as a list of JSON objects, their structure will be:
[{'{'}"y": int (how high up the block is relative to you), "x": int (how far forwards/backwards the block is relative you), "name": str (what type of block it is, including its namespace), "z": int (how far left/right the block is relative you){'}'}]
Your curent surroundings are:
{data.get('scan')}

all blocks you can see in the list are 1 block away from your position.
{facing_text}

---

To do stuff you have gotten a tool "submit_action".
Currently, you can not interract with anything. You can only move arround and explore the world.
""".strip()}]

    first = True

    async for message in websocket:
        msg = json.loads(message)
        print(msg)
        
        facing = data.get('facing', [0, 0])
        facing_text = 'You are currently facing east, or in other words towards the positive X' if facing[0] == 1 else 'You are currently facing west, or in other words towards the negative X' if facing[0] == -1 else 'You are currently facing south, or in other words towards the positive Z' if facing[1] == 1 else 'You are currently facing north, or in other words towards the negative Z'

        messages.append({"role": "tool", "tool_name": "submit_action", "content": f"""
        ## Surroundings
        {msg.get('scan')}

        {facing_text}
        """.strip()})

        response = llm.get_action(messages)

        result = ""
        
        if response.message.tool_calls:
            result = llm.submit_action(**response.message.tool_calls[0].function.arguments)
        
        await websocket.send(result)


asyncio.run(server.start(on_request))
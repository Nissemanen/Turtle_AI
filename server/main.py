import asyncio
import server
import json
import llm


messages = []

def on_request(data, session, raw_message):
    global messages

    if not messages:
        Wacing = data.get('facing', [0, 0])
        facing_text = 'You are currently facing east, or in other words towards the positive X' if facing[0] == 1 else 'You are currently facing west, or in other words towards the negative X' if facing[0] == -1 else 'You are currently facing south, or in other words towards the positive Z' if facing[1] == 1 else 'You are currently facing north, or in other words towards the negative Z'

        messages = [{"role":"system", "content":f"""
You are a robot living inside a Minecraft world. You can move arround in the world and search for things.

## Surroundings
Your surroundings will be formated as a list of JSON objects, their structure will be:
[{'{'}"y": int (how far away the block is from you in the y axis), "x": int (how far away the block is from you in the x axis), "name": str (what type of block it is, including its namespace), "z": int (how far away the block is from you in the z axis){'}'}]
Your curent surroundings are:
{data.get('scan')}

all blocks you can see in the list are 1 block away from your position (including diagonals).
{facing_text}

---

to do anything you have gotten a tool "submit_action".
currently, you can not interract with any blocks. You can only move arround and try searching for things.
    """.strip()}]


    print(raw_message)

    return input();

    print("messages: "+str(messages))

    actions, response, messages = llm.get_action(data, session, messages)
    print("\n\n--------------------1---------------------\n")
    print(response.message.thinking)
    print("\n\n--------------------2---------------------\n")
    print(response.message.content)
    print("\n\n--------------------3---------------------\n")
    print(actions)



    try:
        return actions if actions else "";

    except Exception as e:
        e.with_traceback()
        return "";


asyncio.run(server.start(on_request))
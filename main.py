import asyncio
import server
import json
import llm


def on_request(data, session):
    print(f"data: {json.dumps(data, indent=2)}\nsession: {session}")

    response = llm.get_action(data, session)
    print("\n\n--------------------1---------------------\n")
    print(response.message.thinking)
    print("\n\n--------------------2---------------------\n")
    print(response.message.content)
    print("\n\n------------------------------------------\n")

    message = str(response.message.content)


    print("response: "+message)
    try:
        print("formated:\n"+json.dumps(json.loads(message), indent=2))
        return message;

    except Exception as e:
        e.with_traceback()
        return "";


asyncio.run(server.start(on_request))
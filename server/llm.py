from typing import Iterator
import ollama, chromadb
import json

client = chromadb.PersistentClient(path="./data/memory")
collection = client.get_or_create_collection("turtle_memory")
short_term: list[dict] = []
expiering_memory = []


def add_short_term(mem):
    short_term.append(mem)
    if len(short_term) > 15:
        expiering_memory.append(short_term.pop(0))

def add_long_term(mem:str, mem_id:str, pos:dict[str, int]):
    collection.add(
        documents=[json.dumps(mem)],
        ids=[mem_id],
        metadatas={"x_pos": pos.get("x", 0), "y_pos":pos.get("y", 0)}
    )

def recall(query, n=3):
    results = collection.query(query_texts=[query], n_results=n)
    return results["documents"][0]

def submit_action(thought: str, action: int) -> str:
    """Submit your actions to be done

    Args:
      thought: your current internal though (in character)
      action: an integer from 0 to 4, 0 = idle, 1 = move_forwards, 2 = move_backwards, 3 = turn_right, 4 = turn_left.
    
    Returns:
      How the world looks now, as either a result of your action, or by Minecrafts random nature
    """

    action = "move_forwards" if action == 1 else "move_backwards" if action == 2 else "turn_right" if action == 3 else "turn_left" if action == 4 else "idle"

    return json.dumps({"thought": thought, "action": action})

def get_action(messages) -> ollama.ChatResponse|Iterator[ollama.ChatResponse]:
    response = ollama.chat(model="qwen3.5:latest", messages=messages, think=True, tools=[submit_action])
    
    return response

def parse_llama_message(message:str):
    return message.split("\n\n")[1]

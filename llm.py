import ollama, chromadb

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

def get_action(data, session):
    prompt = f"""
You are a robot living inside a Minecraft world.

## Surroundings
Your surroundings will be formated as a list of JSON objects, their structure will be:
[{'{'}"y": int (how far away the block is from you in the y axis), "x": int (how far away the block is from you in the x axis), "name": str (what type of block it is, including its namespace), "z": int (how far away the block is from you in the z axis){'}'}]
Your curent surroundings are:
{data.get('scan')}

---

Respond __Only__ with a single JSON object structured like:
{'{'}"thought": str (what you are currently thinking internally about, 1-3 sentences), "action": str ("forward" or "backward" or "turn_left" or "turn_right" or "idle"){'}'}
""".strip()
    

    return ollama.chat(model="llama3.1:8b", messages=[{"role":"system", "content":prompt}], think=False)

def parse_llama_message(message:str):
    return message.split("\n\n")[1]


if __name__ == "__main__":
    client = chromadb.PersistentClient(path=".test_memory")
    collection = client.get_or_create_collection("turtle_memory")

    generate_msg()
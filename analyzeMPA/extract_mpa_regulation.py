import json

mpa_regulations = {}
name = ""
regulations = []
item = ""

with open('data.txt', 'r') as f:
    for line in f:
        if line[0] == "(":
            if line[1].isdigit():
                if name != "":
                    mpa_regulations[name] = regulations
                    regulations = []
                name = line.split(' ', 1)[1].rstrip()
            else:
                if "This area is bounded by " not in item:
                    regulations += [item.rstrip()]
                item = line.split(' ', 1)[1]
        else:
            item += line


json_path = 'mpa_regulations.json'
with open(json_path, 'w', encoding='utf-8') as f:
    json.dump(mpa_regulations, f, ensure_ascii=False, indent=4)

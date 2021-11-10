import json

mpa_regulations = {}
name = ""
regulations = []
item = ""

# Load general rules
with open('general_rules.txt', 'r') as f:
    for i, line in enumerate(f):
        if line[0] == '(':
            name = line.split(' ', 1)[1].rstrip()[:-1]
        elif line[0] != '\n':
            mpa_regulations[name] = line.rstrip()

# Load exceptions
with open('exceptions.txt', 'r') as f:
    for i, line in enumerate(f):
        
        if line[0] == '(':
            
            if item:
                mpa_regulations[name].append(item)
                item = ''
            
            if line[1].isdigit():
                name = line.split(' ', 1)[1].rstrip()    # Remove newline
                key_sentence = 'Special restrictions'
                index = line.find(key_sentence)
                if index != -1:
                    name = name[:index-2]    # Remove Special restrictions...
                else:
                    name = name[:-1]    # Remove dot
                mpa_regulations[name] = []

            elif line[1] == 'B':
                key_sentence = 'with the following specified exceptions:'
                index = line.find(key_sentence)
                # Thers is sentence after 'with the following specified exceptions:'
                if index != -1 and index + len(key_sentence) + 1 < len(line):
                    mpa_regulations[name].append(line[index + len(key_sentence) + 1:].rstrip())
                elif index == -1:
                    mpa_regulations[name].append(line[4:].rstrip())
            elif line[1] != 'A':
                mpa_regulations[name].append(line.split(' ', 1)[1].rstrip())

        elif (line[0].isdigit() and line[1]=='.'):
            if item:
                mpa_regulations[name].append(item)
                
            item = line.split(' ', 1)[1].rstrip()
        
        elif item:
            item += ' ' + line.rstrip()
            
json_path = 'mpa_regulations.json'
with open(json_path, 'w', encoding='utf-8') as f:
    json.dump(mpa_regulations, f, ensure_ascii=False, indent=4)
    
with open('../assets/%s'%(json_path), 'w', encoding='utf-8') as f:
    json.dump(mpa_regulations, f, ensure_ascii=False, indent=4)


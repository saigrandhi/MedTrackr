import json
from pprint import pprint
import re
import enchant

with open('test.json', 'r', encoding='utf8') as data_file:
    data = json.load(data_file)
    isDousage = False
    dousage = []

    numbers = {"one": 1, "two": 2, "three": 3}

    regions = data['regions']
    for region in regions:
        for line in region['lines']:
            for word in line['words']:
                #print(word['text'])
                text = word['text']
                #text = enchant.EnchantStr.encode(tet)
                #print(text)
                #text = text.decode()
                #new_text = text.encode("ascii").decode("unicode-escape")
                #print(new_text)
                d2 = enchant.request_pwl_dict("drug_names.txt")
                if d2.check(text) == False:
                    words = d2.suggest(word)
                else:
                    #print("ayyy")
                    print(text)


    print("dosage is" + str(dousage))
#pprint(data)
#
# text = enchant.UTF16EnchantStr.encode(text)
#                     d2 = enchant.DictWithPWL("en_US", "drug_names.txt")
#                     if d2.check(text) == False:
#                         words = d2.suggest(word)
#                     else:
#                         print(text)
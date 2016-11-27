from flask import Flask, request, jsonify
import http.client, urllib.request, urllib.parse, urllib.error, base64
import enchant
import requests
import json
import random
from PIL import Image
import string
import io
import pprint
import os

application = Flask(__name__)

BASE_URL = 'http://02c9958e.ngrok.io'
UPLOAD_FOLDER = './files'
application.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER


@application.route('/')
def index():
    return "Well hello there!"


@application.route('/api/getroute', methods=['GET'])
def api_getroute():
    args = request.args
    output = {
        'sum': int(args['x']) + int(args['y']),
        'product': int(args['x']) * int(args['y'])
    }
    return jsonify(output)


@application.route('/api/getDrugDetails', methods=['GET'])
def drug_details(product):
    try:
        ndc_data = requests.get(('https://api.fda.gov/drug/label.json?search=' + product))
        ndc_dict = json.loads(ndc_data.text)
        code_list = ndc_dict["results"][0]["openfda"]["product_ndc"][-1]
        drug_code = "".join(code_list)
        drug_bank = requests.get(('https://api.drugbankplus.com/v1/us/products/' + drug_code),
                               headers={'Authorization': '2aa20d1f6ba0730f4af0c20e91be9670'})
        drug_bank_dict = json.loads(drug_bank.text)
        drug_bank_id = drug_bank_dict["ingredients"][0]["drugbank_id"]
        drug_id = requests.get(('https://api.drugbankplus.com/v1/us/drugs/' + drug_bank_id),
                              headers={'Authorization': '2aa20d1f6ba0730f4af0c20e91be9670'})
        drug_id_dict = json.loads(drug_id.text)
        id = drug_id_dict["pharmacology"]["indication_descripton"]
        return id
    except KeyError:
        return 0


@application.route('/api/pushImage/', methods=['GET', 'POST'])
def push_image():
    if request.method == 'POST':
        file = request.files['file']
        if file:
            fileName = ''.join(random.SystemRandom().choice(string.ascii_uppercase + string.digits) for _ in range(0, 6))
            file.save(os.path.join(application.config['UPLOAD_FOLDER'], fileName))
            image_url = BASE_URL + '/img/' + fileName + '.jpg'
            print('ayyy')
            print(image_url)
            json_url = '{ "url": "' + image_url + '" }'
            return json_url
    return None


@application.route('/api/getImageInfo/<url>', methods=['GET', 'POST'])
def image_details(image_url):
    headers = {
        # Request headers
        'Content-Type': 'application/json',
        'Ocp-Apim-Subscription-Key': 'be6d561231ec489d8593ca3ef59a67ba',
    }

    params = urllib.parse.urlencode({
        # Request parameters
        'language': 'unk',
        'detectOrientation ': 'true',
    })

    try:
        conn = http.client.HTTPSConnection('api.projectoxford.ai')
        conn.request("POST", "/vision/v1.0/ocr?%s" % params, image_url, headers)
        response = conn.getresponse()
        raw = response.read()
        data = json.loads(raw)
        print(data)
        output = {}
        regions = data['regions']
        for region in regions:
            for line in region['lines']:
                for word in line['words']:
                    text = word['text']
                    # spell checking
                    d2 = enchant.request_pwl_dict("drug_names.txt")
                    if d2.check(text) == False:
                        words = d2.suggest(word)
                        output['count'] = 1
                        output['words'] = words
                        return jsonify(output)
                    else:
                        print(text)
                        output['count'] = 2
                        details = drug_details(text)
                        output['details'] = details
                        output['name'] = text
                        return jsonify(output)
        return jsonify(output)
        conn.close()
    except Exception as e:
        print("[Errno {0}] {1}".format(e.errno, e.strerror))


def spell_check(word):
    d2 = enchant.DictWithPWL("en_US","drug_names.txt")
    if d2.check(word) == False:
        return d2.suggest(word)
    else:
        return None


if __name__ == "__main__":
    application.run(debug=True)

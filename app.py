#!flask/bin/python
from flask import Flask, jsonify, render_template, request
from model import DBconn
import flask
import sys
import json

app = Flask(__name__)

def spcall(qry, param, commit=False):
    try:
        dbo = DBconn()
        cursor = dbo.getcursor()
        cursor.callproc(qry, param)
        res = cursor.fetchall()
        if commit:
            dbo.dbcommit()
        return res
    except:
        res = [("Error: " + str(sys.exc_info()[0]) + " " + str(sys.exc_info()[1]),)]
    return res

@app.route('/')
def index():
    return render_template('index.html')


@app.route('/customers', methods=['GET'])
def get_customer():

    customers = spcall('get_customers',())

    lists = []

    for l in customers:
        lists.append({'id':str(l[0]), 'name':str(l[1]), 'address':str(l[2]), 'phone':str(l[3])})

    return jsonify({'count':len(lists), 'lists': lists})

@app.route('/staffs', methods=['GET'])
def get_staff():

    staffs = spcall('get_staffs', ())

    lists = []

    for l in staffs:
        lists.append({'id':str(l[0]), 'name':str(l[1]), 'address':str(l[2]), 'position':str(l[3])})

    return jsonify({'count':len(lists), 'lists':lists})

@app.route('/transaction/<int:custno>/<int:staffid>', methods=['POST'])
def add_transaction(custno, staffid):

    transaction = spcall('add_transaction', (0, custno, staffid, 0, 0), True)

    return jsonify({'orno': transaction[0][0]})

@app.route('/transaction/<int:orno>', methods=['GET'])
def get_transaction(orno):

    transaction = spcall('get_transaction', (orno,))

    lists = []

    for l in transaction:
        lists.append({'orno':str(l[0]), 'date':str(l[1]), 'amountdue':str(l[2]), 'custno':str(l[3]), 'staffid':str(l[4]), 'amountpaid':str(round (l[5],2)), 'discount':str(l[6])});

    return jsonify({'count': len(lists), 'lists':lists})

@app.route('/products', methods=['GET'])
def get_products():

    products = spcall('get_products',())

    lists = []

    for l in products:
        lists.append({'id':str(l[0]), 'description':str(l[1]), 'price':str( round(l[2], 2) ), 'discount':str(l[5])})

    return jsonify({'count':len(lists), 'lists': lists})

@app.route('/products', methods=['POST'])
def add_products():

    data = json.loads(request.data)

    description = data['description']
    price = data['price']
    qtyonhand = data['qtyonhand']
    stocklimit = data['stocklimit']
    sale_dis = data['sale_dis']

    save_product = spcall('add_products', (description, price, qtyonhand, stocklimit, sale_dis), True)

    return jsonify({'status':'OK', 'message':'successfully added'})

@app.route('/purchase/<int:orno>/<int:prodno>/<int:cust_id>/<int:qty>', methods=['POST'])
def purchase(orno, prodno, cust_id, qty):
    check_stock = spcall('check_product_stock', (prodno,))

    available_product = check_stock[0][0] - check_stock[0][1]

    if qty > available_product:
        return jsonify({'status':'out of stock'})

    product = spcall('purchase_item', (orno, prodno, cust_id, qty), True)

    return jsonify({'status':product[0][0]})


@app.after_request
def add_cors(resp):
    resp.headers['Access-Control-Allow-Origin'] = flask.request.headers.get('Origin', '*')
    resp.headers['Access-Control-Allow-Credentials'] = True
    resp.headers['Access-Control-Allow-Methods'] = 'POST, OPTIONS, GET, PUT, DELETE'
    resp.headers['Access-Control-Allow-Headers'] = flask.request.headers.get('Access-Control-Request-Headers',
                                                                             'Authorization')
    # set low for debugging

    if app.debug:
        resp.headers["Access-Control-Max-Age"] = '1'
    return resp




if __name__ == '__main__':
    app.run(debug=True, port=8000)

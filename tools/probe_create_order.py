"""
Probe script for POST /api/orders/createOrder

Usage:
- Set environment variable API_TOKEN with a valid Bearer token (optional).
- Run: python tools\probe_create_order.py

The script will POST several payload variants and print status + body.
"""
import os
import json
import sys

try:
    import requests
except Exception:
    requests = None

BASE_URL = os.environ.get('BASE_URL', 'http://129.151.188.8:8085')
API_TOKEN = os.environ.get('API_TOKEN', '')

HEADERS = {
    'Content-Type': 'application/json',
}
if API_TOKEN:
    HEADERS['Authorization'] = f'Bearer {API_TOKEN}'

DEFAULT_FULL = {
    "restaurantId": 2,
    "customerId": 1,
    "deliveryAddressId": 52,
    "orderStatus": "PLACED",
    "deliveryAddress": "Kimihurura, KK 1 Avenue, Kigali",
    "contactNumber": "0784107365",
    "paymentStatus": "PENDING",
    "subTotal": 9.12,
    "deliveryFee": 2000,
    "discountAmount": 0,
    "finalAmount": 2009.12,
    "paymentMethod": "MOMO",
    "orderPlacedAt": "2025-11-27",
    "estimatedDelivery": "2025-11-27",
    "orderItems": [
        { "menuItemId": 3, "quantity": 4 }
    ],
    "specialInstructions": "ok"
}

VARIANTS = []

# 1: Full payload
VARIANTS.append(("full", DEFAULT_FULL))

# 2: Remove deliveryAddressId
v2 = dict(DEFAULT_FULL)
v2.pop('deliveryAddressId', None)
VARIANTS.append(("no_deliveryAddressId", v2))

# 3: deliveryAddressId as string
v3 = dict(DEFAULT_FULL)
v3['deliveryAddressId'] = str(v3.get('deliveryAddressId', ''))
VARIANTS.append(("deliveryAddressId_string", v3))

# 4: Minimal payload (restaurantId, customerId, finalAmount, orderItems)
v4 = {
    'restaurantId': DEFAULT_FULL['restaurantId'],
    'customerId': DEFAULT_FULL['customerId'],
    'contactNumber': DEFAULT_FULL['contactNumber'],
    'finalAmount': DEFAULT_FULL['finalAmount'],
    'orderItems': [ { 'menuItemId': 3, 'quantity': 1 } ]
}
VARIANTS.append(("minimal", v4))

# 5: Remove orderStatus/paymentStatus
v5 = dict(DEFAULT_FULL)
v5.pop('orderStatus', None)
v5.pop('paymentStatus', None)
VARIANTS.append(("no_status_fields", v5))

# 6: orderItems with itemId only
v6 = dict(DEFAULT_FULL)
v6['orderItems'] = [ { 'itemId': 3, 'quantity': 4 } ]
VARIANTS.append(("itemId_only", v6))

# 7: orderItems enriched with unitPrice/totalPrice
v7 = dict(DEFAULT_FULL)
v7['orderItems'] = [ { 'menuItemId': 3, 'quantity': 4, 'unitPrice': 2.28, 'totalPrice': 9.12 } ]
VARIANTS.append(("with_prices", v7))

def do_post(path, body):
    url = BASE_URL.rstrip('/') + path
    text_body = json.dumps(body)
    print('\n--- POST', url)
    print('Headers:', HEADERS)
    print('Body:', text_body)
    if requests:
        try:
            resp = requests.post(url, headers=HEADERS, data=text_body, timeout=15)
            print('Status:', resp.status_code)
            print('Response headers:', dict(resp.headers))
            print('Response body:', resp.text)
            return resp.status_code, resp.text
        except Exception as e:
            print('Request failed:', e)
            return None, str(e)
    else:
        # fallback to urllib
        try:
            from urllib import request as urequest
            req = urequest.Request(url, data=text_body.encode('utf-8'), headers=HEADERS)
            with urequest.urlopen(req, timeout=15) as r:
                status = r.getcode()
                body = r.read().decode('utf-8')
                print('Status:', status)
                print('Response body:', body)
                return status, body
        except Exception as e:
            print('Request failed (urllib):', e)
            return None, str(e)

def main():
    print('Starting probe testing for /api/orders/createOrder')
    print('BASE_URL =', BASE_URL)
    if API_TOKEN:
        print('Using API_TOKEN from environment')
    else:
        print('No API_TOKEN set; requests may be unauthorized (401)')

    for name, payload in VARIANTS:
        print('\n=== Variant:', name)
        do_post('/api/orders/createOrder', payload)

if __name__ == '__main__':
    main()

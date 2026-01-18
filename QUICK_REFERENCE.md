# Quick Implementation Guide - Payment Status & Delivery Fee

## What Was Implemented

### 1. **Dynamic Delivery Fee Fetching** ✅
- **File:** `lib/api/order.api.dart` → `getDeliveryFee()` method
- **File:** `lib/providers/cartproviders.dart` → `fetchDeliveryFee()` method
- **When:** Automatically fetched when order summary page loads
- **API:** `GET /api/restaurants/{restaurantId}/delivery-fee`

### 2. **Payment Status Management** ✅
- **File:** `lib/api/order.api.dart` → `updateOrderPaymentStatus()` method
- **When:** 
  - **PROCESSING** - Right after order is created
  - **COMPLETED** - When MoMo payment succeeds
  - **FAILED** - When payment fails
- **API:** `PUT /api/orders/{orderId}/updatePaymentStatus`

---

## Files Modified

| File | Changes | Purpose |
|------|---------|---------|
| `lib/api/order.api.dart` | Added 2 new methods | Fetch delivery fee & update payment status |
| `lib/providers/cartproviders.dart` | Added delivery fee state & fetch method | Store and fetch dynamic delivery fee |
| `lib/screens/order_summary_page.dart` | Added delivery fee fetch in init & payment status update | Integrate delivery fee & payment status updates |
| `lib/screens/waiting_for_payment_page.dart` | Updated success/failure handlers | Update payment status on completion/failure |

---

## Key Features

### ✅ Delivery Fee
```
✓ Fetched from backend before order creation
✓ Dynamically included in finalAmount calculation
✓ Graceful fallback to 0.0 if API fails
✓ Supports multiple response formats
```

### ✅ Payment Status
```
✓ Updates from PENDING → PROCESSING when order created
✓ Updates to COMPLETED when MoMo payment succeeds
✓ Updates to FAILED when payment fails
✓ Non-blocking: won't prevent order flow if update fails
✓ Comprehensive logging with debug emojis
```

---

## Testing Instructions

### 1. Test Delivery Fee
```
1. Navigate to a restaurant menu
2. Add items to cart
3. Go to Order Summary
4. Verify delivery fee is displayed (should not be 0 if API returns a fee)
5. Verify finalAmount includes the delivery fee
```

### 2. Test Payment Status - Success Path
```
1. Create order with cart items
2. Select MOMO payment
3. Observe: Order status should update to PROCESSING in backend
4. Complete payment in MOMO
5. Observe: Order status should update to COMPLETED
6. Check Orders page: Payment status should show COMPLETED
```

### 3. Test Payment Status - Failure Path
```
1. Create order with cart items
2. Select MOMO payment
3. Let payment timeout or fail
4. Observe: Payment dialog shows failure
5. Observe: Order status should update to FAILED in backend
6. Check Orders page: Payment status should show FAILED
```

---

## API Requirements

### Endpoint 1: Fetch Delivery Fee
**Request:**
```
GET /api/restaurants/{restaurantId}/delivery-fee
Headers: Content-Type: application/json
```

**Response (200 OK):**
```json
{
  "deliveryFee": 500,
  "message": "Success"
}
```
*Also supports: `"fee"` or `"amount"` field names*

### Endpoint 2: Update Payment Status
**Request:**
```
PUT /api/orders/{orderId}/updatePaymentStatus
Headers: 
  Content-Type: application/json
  Authorization: Bearer {token}
Body: {
  "paymentStatus": "PROCESSING|COMPLETED|FAILED"
}
```

**Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "orderId": 123,
    "paymentStatus": "COMPLETED",
    ...
  },
  "message": "Payment status updated"
}
```

---

## Debugging

### Enable Verbose Logging
All changes include emoji-prefixed logging for easy debugging:
- 🔄 = Loading/Processing
- ✅ = Success
- ❌ = Error
- ⚠️ = Warning
- 💳 = Payment related
- 💰 = Amount/Fee
- 📡 = API Response
- 📦 = Order

Check Flutter console or use:
```dart
Logger.info('message');  // Info level
Logger.warn('message');  // Warning level
Logger.error('message', exception, stackTrace);  // Error level
```

### Common Issues

**Issue:** Delivery fee not displaying
- **Cause:** API endpoint not available or returning error
- **Fix:** Check network tab, verify endpoint is correct
- **Fallback:** App uses 0.0, order still works

**Issue:** Order status not updating to PROCESSING
- **Cause:** `updateOrderPaymentStatus` endpoint failing
- **Fix:** Check endpoint path is correct, verify token is valid
- **Note:** Non-blocking, order creation succeeds anyway

**Issue:** Payment status stuck on PENDING
- **Cause:** Payment status update endpoint not called or failing
- **Fix:** Check endpoint path format matches API spec
- **Workaround:** Payment will still complete, status just won't update

---

## Code Examples

### Using CartProvider to access delivery fee
```dart
final cartProvider = Provider.of<CartProvider>(context);
print(cartProvider.deliveryFee);  // Get current delivery fee
print(cartProvider.isLoadingDeliveryFee);  // Check if loading
print(cartProvider.finalAmount);  // Includes delivery fee
```

### Manual delivery fee set (testing)
```dart
cartProvider.setDeliveryFee(1000); // Set to 1000 RWF
```

### Check payment status in Orders page
```dart
final status = order.paymentStatus;
if (status == 'COMPLETED') {
  // Payment successful
}
```

---

## Backward Compatibility

✅ **Fully backward compatible**
- If delivery fee API is unavailable, defaults to 0.0
- If payment status update fails, order continues normally
- No breaking changes to existing code

---

## Next Steps (Optional Enhancements)

1. **Per-Restaurant Delivery Fees** - Fetch fee for each restaurant in multi-restaurant orders
2. **Delivery Fee Caching** - Cache delivery fees to reduce API calls
3. **Payment Retry Logic** - Automatic retry for payment status updates
4. **User Notifications** - Show delivery fee in a banner before checkout
5. **Admin Dashboard** - View payment status analytics


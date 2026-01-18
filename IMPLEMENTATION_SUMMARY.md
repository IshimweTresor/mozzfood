# Payment Status & Delivery Fee Implementation Summary

## Overview
This document summarizes the implementation of:
1. **Dynamic Delivery Fee Fetching** - Fetch from API before creating orders
2. **Payment Status Management** - Update payment status through the payment lifecycle

---

## Changes Made

### 1. **Order API (`lib/api/order.api.dart`)**

#### Added: `getDeliveryFee()` Method
```dart
/// Get delivery fee for a restaurant
/// GET /api/restaurants/{restaurantId}/delivery-fee
static Future<ApiResponse<Map<String, dynamic>>> getDeliveryFee({
  required int restaurantId,
}) async
```
- Fetches delivery fee dynamically from the backend
- Supports multiple response formats: `deliveryFee`, `fee`, or `amount` fields
- Gracefully falls back to 0.0 if API fails

#### Added: `updateOrderPaymentStatus()` Method
```dart
/// Update order payment status
/// PUT /api/orders/{orderId}/updatePaymentStatus
static Future<ApiResponse<Order>> updateOrderPaymentStatus({
  required String token,
  required int orderId,
  required String paymentStatus,
}) async
```
- Updates the order's payment status to: `PROCESSING`, `COMPLETED`, or `FAILED`
- Called at different points in the payment lifecycle

---

### 2. **Cart Provider (`lib/providers/cartproviders.dart`)**

#### Changes:
- **Added state variables:**
  - `double _deliveryFee = 0.0` - Stores fetched delivery fee
  - `bool _isLoadingDeliveryFee = false` - Loading indicator

- **Added getters:**
  - `double get deliveryFee` - Returns current delivery fee
  - `bool get isLoadingDeliveryFee` - Indicates if fee is being fetched

- **Added method: `fetchDeliveryFee()`**
  ```dart
  Future<void> fetchDeliveryFee() async
  ```
  - Automatically called when order summary loads
  - Fetches fee for the current restaurant
  - Updates finalAmount calculation automatically
  - Handles errors gracefully

- **Added method: `setDeliveryFee()`**
  ```dart
  void setDeliveryFee(double fee)
  ```
  - Allows manual override for testing or fallback

---

### 3. **Order Summary Page (`lib/screens/order_summary_page.dart`)**

#### Changes:

**A. Initialize delivery fee fetch on load:**
```dart
@override
void initState() {
  super.initState();
  _momoController.text = widget.selectedNumber;
  _fetchDeliveryFee();  // NEW: Fetch delivery fee
}

Future<void> _fetchDeliveryFee() async {
  try {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    if (cartProvider.currentRestaurantId != null) {
      await cartProvider.fetchDeliveryFee();
    }
  } catch (e) {
    Logger.error('❌ Error fetching delivery fee: $e');
  }
}
```

**B. Update payment status when order is created:**
```dart
// After successful order creation:
if (createdOrderId != null) {
  try {
    int? orderId = int.tryParse(createdOrderId);
    if (orderId != null) {
      Logger.info('🔄 Updating order payment status to PROCESSING');
      await OrderApi.updateOrderPaymentStatus(
        token: token,
        orderId: orderId,
        paymentStatus: 'PROCESSING',
      );
    }
  } catch (e) {
    Logger.warn('⚠️ Could not update order payment status: $e');
  }
}
```

---

### 4. **Waiting for Payment Page (`lib/screens/waiting_for_payment_page.dart`)**

#### Changes:

**A. Update to COMPLETED on successful payment:**
```dart
Future<void> _onSuccess() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('order_placed', true);
    await prefs.setString('order_placed_id', widget.orderId);
  } catch (e) {
    // ignore
  }

  // Update order payment status to COMPLETED when payment is successful
  try {
    int? orderId = int.tryParse(widget.orderId);
    if (orderId != null) {
      await OrderApi.updateOrderPaymentStatus(
        token: widget.token,
        orderId: orderId,
        paymentStatus: 'COMPLETED',
      );
      Logger.info('✅ Order payment status updated to COMPLETED');
    }
  } catch (e) {
    print('⚠️ Could not update order payment status: $e');
  }

  if (!mounted) return;
  // ... rest of success handling
}
```

**B. Update to FAILED on payment failure:**
```dart
Future<void> _onFailure() async {
  if (!mounted) return;

  // Update order payment status to FAILED when payment fails
  try {
    int? orderId = int.tryParse(widget.orderId);
    if (orderId != null) {
      await OrderApi.updateOrderPaymentStatus(
        token: widget.token,
        orderId: orderId,
        paymentStatus: 'FAILED',
      );
      Logger.info('❌ Order payment status updated to FAILED');
    }
  } catch (e) {
    print('⚠️ Could not update order payment status: $e');
  }

  if (!mounted) return;
  // ... rest of failure handling
}
```

---

## Payment Status Flow

```
Order Created
    ↓
[PENDING] ← Initial status from order creation
    ↓
orderResponse.data received
    ↓
[PROCESSING] ← Updated when order summary confirms creation
    ↓
User completes payment
    ↓
[COMPLETED] ← Updated when MoMo payment succeeds
    ↓
Order displayed in Orders list
```

### Alternative Failure Path:
```
Order Created [PENDING]
    ↓
[PROCESSING] ← Order update call
    ↓
Payment fails or times out
    ↓
[FAILED] ← Updated in failure handler
```

---

## Delivery Fee Flow

```
Order Summary Page Loads
    ↓
_fetchDeliveryFee() called in initState()
    ↓
CartProvider.fetchDeliveryFee() executes
    ↓
GET /api/restaurants/{id}/delivery-fee
    ↓
_deliveryFee updated
    ↓
finalAmount recalculated automatically
    ↓
UI displays updated total
```

---

## API Endpoints Used

### Fetch Delivery Fee
- **Endpoint:** `GET /api/restaurants/{restaurantId}/delivery-fee`
- **Response Format:** 
  ```json
  {
    "deliveryFee": 500,  // or "fee" or "amount"
    "message": "Success"
  }
  ```

### Update Order Payment Status
- **Endpoint:** `PUT /api/orders/{orderId}/updatePaymentStatus`
- **Request Body:**
  ```json
  {
    "paymentStatus": "PROCESSING|COMPLETED|FAILED"
  }
  ```
- **Response:** Updated Order object

---

## Error Handling

### Delivery Fee Failures
- If API call fails, delivery fee defaults to **0.0**
- Warning logged but doesn't block order creation
- User can still proceed with checkout

### Payment Status Update Failures
- Logged as warnings but don't block order flow
- Order continues to process even if status update fails
- User is not shown error dialogs for these failures

---

## Testing Checklist

- [ ] Add item to cart from restaurant
- [ ] Navigate to order summary
- [ ] Verify delivery fee is fetched and displayed
- [ ] Create order
- [ ] Verify payment status updates to PROCESSING
- [ ] Complete MoMo payment
- [ ] Verify payment status updates to COMPLETED
- [ ] Check orders page shows correct payment status
- [ ] Test payment failure scenario
- [ ] Verify payment status updates to FAILED
- [ ] Test with multiple restaurants
- [ ] Verify finalAmount includes correct delivery fee

---

## Notes

1. **Multi-Restaurant Orders:** Delivery fee is now fetched for the first restaurant in the order. If implementing per-restaurant delivery fees, modify `fetchDeliveryFee()` to handle this.

2. **Payment Status Transitions:** Current implementation supports PENDING → PROCESSING → COMPLETED/FAILED flow. Backend should validate state transitions if needed.

3. **Backward Compatibility:** Changes are backward compatible. If `getDeliveryFee` API is not available, app falls back to 0.0 fee.

4. **Logger Calls:** All changes include comprehensive logging with emoji indicators for debugging:
   - 🔄 = Loading/Processing
   - 📡 = API Response
   - ✅ = Success
   - ❌ = Error
   - ⚠️ = Warning
   - 💳 = Payment
   - 💰 = Amount
   - 📦 = Order
   - 📍 = Location


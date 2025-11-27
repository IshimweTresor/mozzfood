# Probe script for POST /api/orders/createOrder using PowerShell
# Usage: set environment variable API_TOKEN if you have a Bearer token

$baseUrl = $env:BASE_URL
if (-not $baseUrl) { $baseUrl = 'http://129.151.188.8:8085' }
$apiToken = $env:API_TOKEN

Write-Host "Starting probe testing for /api/orders/createOrder"
Write-Host "BASE_URL = $baseUrl"
if ($apiToken) { Write-Host 'Using API_TOKEN from environment' } else { Write-Host 'No API_TOKEN set; requests may be unauthorized (401)'}

$headers = @{ 'Content-Type' = 'application/json' }
if ($apiToken) { $headers['Authorization'] = "Bearer $apiToken" }

$defaultFull = @{
    restaurantId = 2
    customerId = 1
    deliveryAddressId = 52
    orderStatus = 'PLACED'
    deliveryAddress = 'Kimihurura, KK 1 Avenue, Kigali'
    contactNumber = '0784107365'
    paymentStatus = 'PENDING'
    subTotal = 9.12
    deliveryFee = 2000
    discountAmount = 0
    finalAmount = 2009.12
    paymentMethod = 'MOMO'
    orderPlacedAt = '2025-11-27'
    estimatedDelivery = '2025-11-27'
    orderItems = @( @{ menuItemId = 3; quantity = 4 } )
    specialInstructions = 'ok'
}

$variants = @()

# 1 full
$variants += @{ name = 'full'; body = $defaultFull }

# 2 without deliveryAddressId
$v2 = $defaultFull.PSObject.Copy()
$v2.PSObject.Properties.Remove('deliveryAddressId') | Out-Null
$variants += @{ name = 'no_deliveryAddressId'; body = $v2 }

# 3 deliveryAddressId as string
$v3 = $defaultFull.PSObject.Copy()
$v3.deliveryAddressId = [string]$v3.deliveryAddressId
$variants += @{ name = 'deliveryAddressId_string'; body = $v3 }

# 4 minimal
$v4 = @{
    restaurantId = $defaultFull.restaurantId
    customerId = $defaultFull.customerId
    contactNumber = $defaultFull.contactNumber
    finalAmount = $defaultFull.finalAmount
    orderItems = @( @{ menuItemId = 3; quantity = 1 } )
}
$variants += @{ name = 'minimal'; body = $v4 }

# 5 remove status fields
$v5 = $defaultFull.PSObject.Copy()
$v5.PSObject.Properties.Remove('orderStatus') | Out-Null
$v5.PSObject.Properties.Remove('paymentStatus') | Out-Null
$variants += @{ name = 'no_status_fields'; body = $v5 }

# 6 itemId only
$v6 = $defaultFull.PSObject.Copy()
$v6.orderItems = @( @{ itemId = 3; quantity = 4 } )
$variants += @{ name = 'itemId_only'; body = $v6 }

# 7 with prices
$v7 = $defaultFull.PSObject.Copy()
$v7.orderItems = @( @{ menuItemId = 3; quantity = 4; unitPrice = 2.28; totalPrice = 9.12 } )
$variants += @{ name = 'with_prices'; body = $v7 }

foreach ($variant in $variants) {
    Write-Host "`n=== Variant: $($variant.name) ==="
    $json = $variant.body | ConvertTo-Json -Depth 6
    Write-Host "Request body: $json"
    try {
        $resp = Invoke-WebRequest -Uri "$baseUrl/api/orders/createOrder" -Method Post -Body $json -Headers $headers -UseBasicParsing -TimeoutSec 15
        Write-Host "Status: $($resp.StatusCode)"
        Write-Host "Response: $($resp.Content)"
    } catch {
        $err = $_.Exception
        if ($err.Response -ne $null) {
            try {
                $status = $err.Response.StatusCode.Value__
                $body = (New-Object System.IO.StreamReader($err.Response.GetResponseStream())).ReadToEnd()
                Write-Host "Status: $status"
                Write-Host "Response body: $body"
            } catch {
                Write-Host "Request failed: $err"
            }
        } else {
            Write-Host "Request failed: $err"
        }
    }
}

Write-Host "\nProbe finished."

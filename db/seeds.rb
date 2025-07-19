# db/seeds.rb
# Seed data for trades table

# Clear existing records (optional)
Trade.delete_all

# Create trades from SQL dump
Trade.create!([
  { dtg: '2025-07-18 08:43:26.930398-05', symbol: 'SPY', expiry: '2025-07-21 08:30:00-05', side: 'Buy',  effect: 'ToOpen',  strike: 623.0, price: 0.475, qty: 1, delta: -0.154, theta: -0.206, gamma: 0.041, vega: 0.156, iv: 0.098, spot: 628.655 },
  { dtg: '2025-07-18 08:49:44.527994-05', symbol: 'SPY', expiry: '2025-07-21 08:30:00-05', side: 'Buy',  effect: 'ToOpen',  strike: 632.0, price: 0.635, qty: 1, delta:  0.253, theta: -0.219, gamma: 0.078, vega: 0.189, iv: 0.069, spot: 629.125 },
  { dtg: '2025-07-18 10:31:22.245882-05', symbol: 'SPY', expiry: '2025-07-21 08:30:00-05', side: 'Buy',  effect: 'ToOpen',  strike: 631.0, price: 0.475, qty: 1, delta:  0.200, theta: -0.181, gamma: 0.071, vega: 0.172, iv: 0.067, spot: 627.785 },
  { dtg: '2025-07-18 11:52:36.389434-05', symbol: 'SPY', expiry: '2025-07-21 08:30:00-05', side: 'Buy',  effect: 'ToOpen',  strike: 630.0, price: 0.605, qty: 1, delta:  0.247, theta: -0.215, gamma: 0.080, vega: 0.185, iv: 0.068, spot: 627.325 },
  { dtg: '2025-07-18 12:34:40.251975-05', symbol: 'SPY', expiry: '2025-07-21 08:30:00-05', side: 'Buy',  effect: 'ToOpen',  strike: 630.0, price: 0.555, qty: 1, delta:  0.246, theta: -0.209, gamma: 0.082, vega: 0.184, iv: 0.066, spot: 627.285 },

  { dtg: '2025-07-18 09:05:17.830709-05', symbol: 'SPY', expiry: '2025-07-21 08:30:00-05', side: 'Sell', effect: 'ToClose', strike: 632.0, price: 0.465, qty: 1, delta:  0.209, theta: -0.189, gamma: 0.071, vega: 0.182, iv: 0.069, spot: 628.350 },
  { dtg: '2025-07-18 11:07:18.398002-05', symbol: 'SPY', expiry: '2025-07-21 08:30:00-05', side: 'Sell', effect: 'ToClose', strike: 631.0, price: 0.405, qty: 1, delta:  0.212, theta: -0.184, gamma: 0.076, vega: 0.182, iv: 0.065, spot: 627.650 },
  { dtg: '2025-07-18 11:58:18.957257-05', symbol: 'SPY', expiry: '2025-07-21 08:30:00-05', side: 'Sell', effect: 'ToClose', strike: 630.0, price: 0.505, qty: 1, delta:  0.228, theta: -0.204, gamma: 0.075, vega: 0.185, iv: 0.069, spot: 626.600 },
  { dtg: '2025-07-18 14:55:02.339694-05', symbol: 'SPY', expiry: '2025-07-21 08:30:00-05', side: 'Sell', effect: 'ToClose', strike: 623.0, price: 0.380, qty: 1, delta: -0.155, theta: -0.175, gamma: 0.053, vega: 0.149, iv: 0.080, spot: 627.620 },
  { dtg: '2025-07-18 14:55:03.656062-05', symbol: 'SPY', expiry: '2025-07-21 08:30:00-05', side: 'Sell', effect: 'ToClose', strike: 630.0, price: 0.425, qty: 1, delta:  0.226, theta: -0.169, gamma: 0.094, vega: 0.182, iv: 0.056, spot: 627.620 }
])

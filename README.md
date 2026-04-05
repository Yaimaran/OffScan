# OffScan 🐻
*A hyper-focused, strictly offline scanner built for speed.*

## What is this?
OffScan is a minimalist 1D/2D barcode and QR scanner. It was built to solve a very specific, real-world bottleneck in the fast-paced logistics and delivery industry.

## The Problem
Through direct feedback from delivery agents and warehouse logistics managers, we identified a major bottleneck they face every day: **Dead zones.** 

Delivery personnel constantly find themselves in elevators, underground parking lots, deep warehouse aisles, or rural areas with zero internet or spotty network coverage. Yet, almost all barcode scanning apps on the market either:
* Require an active internet connection to process data.
* Are bloated with third-party tracking and heavy corporate features, making them slow and laggy.
* Are completely filled with intrusive popup ads that waste valuable time.

In a fast-paced environment where every second counts, a laggy or ad-filled scanner is incredibly frustrating.

## The Solution
I built OffScan as a direct response to this validated demand. It does exactly one thing, and it does it instantly natively on the device.

*   **100% Offline:** It uses on-device ML hardware buffers. No internet connection is ever required to scan or copy data. It works perfectly in a basement.
*   **Featherweight & Fast:** By stripping out unnecessary translation bloat and tracking, the entire app is tiny. It opens instantly and doesn't drain the battery.
*   **No Ads, No Clutter:** A perfectly clean, minimalist interface optimized for one-handed operation. 

## Installation 
If you want to pull this code and install it yourself:

1. Clone the repo:
   ```bash
   git clone https://github.com/Yaimaran/OffScan.git
   cd OffScan
   ```
2. Build and run via Flutter:
   ```bash
   flutter run --release
   ```

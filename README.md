# OffScan

An offline 1D/2D barcode and QR scanner.

OffScan is a Flutter application designed for environments with unreliable network connectivity, such as warehouses or delivery routes. 

## Motivation

Many existing barcode scanners require an active internet connection to process data or contain third-party analytics SDKs that impact performance. OffScan processes all data locally on the device to ensure consistent performance in dead zones.

## Features

* **Local Processing:** Utilizes on-device ML hardware buffers. No network calls are made during scanning.
* **Minimal Footprint:** Stripped of non-essential dependencies and analytics to optimize start time and battery consumption.
* **Simple Interface:** Optimized for one-handed operation without ads or popups.

## Installation 

To build and install the project locally:

1. Clone the repository:
   ```bash
   git clone https://github.com/Yaimaran/OffScan.git
   cd OffScan
   ```
2. Build and run via Flutter:
   ```bash
   flutter run --release
   ```

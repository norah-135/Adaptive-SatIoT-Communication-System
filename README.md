# Adaptive-SatIoT-Communication-System

**An Adaptive Communication System for LEO-based IoT nodes in extreme desert environments.**
---

## **1. Overview**
This project focuses on designing an **Adaptive Modulation and Coding (AMC)** system for IoT nodes deployed in **Rub' al Khali (The Empty Quarter)**. In such isolated regions, terrestrial infrastructure (GSM/LTE) is non-existent, making Satellite Communication the only viable monitoring method. The system intelligently balances data reliability and energy efficiency by sensing real-time environmental dynamics.

## **2. The Challenge: Why Adaptability?**
The Rub' al Khali presents two major technical hurdles:
1.  **Extreme Thermal Fluctuations:** Temperatures exceeding **55°C** increase the **Thermal Noise Floor** and degrade battery life.
2.  **Satellite Dynamics:** LEO satellites are constantly moving, causing the Signal-to-Noise Ratio ($SNR$) to fluctuate every second.

A fixed modulation scheme is either too fragile (failing when the signal is weak) or too wasteful (draining battery when the signal is strong).

---

## **3. System Architecture**
The experiment was implemented using a dual-layer approach:

### **A. Physical Layer (Simulink)**
Two distinct modulation circuits were designed to realize the switching modes:
* **BPSK (Binary Phase Shift Keying):** High-reliability mode used when link quality drops to ensure data delivery despite high noise.
* **QPSK (Quadrature Phase Shift Keying):** High-efficiency mode utilized when link quality is excellent for faster transmission.

### **B. Control Layer (MATLAB)**
An intelligent **"Decision Brain"** performs real-time sensing of the $SNR$ and ambient temperature. It dynamically switches between:
* **QPSK Mode:** Saves energy through fast bursts.
* **BPSK Mode:** Ensures robustness in harsh conditions.
* **Smart Sleep Mode:** Enters a deep sleep state if the link quality is too poor, avoiding the **Retransmission Penalty**.

---

## **4. Performance Results**
Simulation results demonstrate the superiority of the adaptive approach:

* **Enhanced Reliability:** Achieved a **56.5%** success rate, outperforming Fixed QPSK by approximately **28%**.
* **Energy Autonomy:** Doubled the battery life compared to Fixed BPSK.
* **Efficiency:** QPSK bursts reduced active transmission time from **4 seconds** to **1 second** when the link was strong.

---

## **5. Key System Assumptions**
* **Orbit:** Low Earth Orbit (LEO) at **600 km - 2000 km**.
* **Path Loss Model:** Free Space Path Loss ($FSPL$) in a harsh desert environment.
    $$FSPL = 20 \log_{10}(d) + 20 \log_{10}(f) + 92.45$$
* **Hardware:** 4 dBm Transmission Power, 200

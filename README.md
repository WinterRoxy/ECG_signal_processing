# Median Filter Module

## Overview

The `median_filter` module is a parameterized digital filter designed to reduce spike noise and high-frequency interference from a signal. By default, it uses a sliding window of 3 samples (N = 3), which makes it very effective at removing narrow, impulsive noise (also known as "spike noise" or "high-frequency noise"). The filter outputs the median value of the window, thereby suppressing outlier values.

For applications such as ECG signal processing, where baseline wandering (low-frequency noise) is also a concern, the sliding window size can be increased. A larger window will allow the filter to extract and remove low-frequency variations as well.
## Demo for a real ECG signal that has been digitized and processed to remove spike noise.
<img width="516" alt="Image" src="https://github.com/user-attachments/assets/a233f4e6-67e0-406f-834f-e0b7833112b6" />
## Demo of the ECG signal after extracting the baseline wandering noise component from the original signal.
<img width="512" alt="Image" src="https://github.com/user-attachments/assets/81a7a211-b767-4536-9579-20b9aaca52d2" />
## Operation

The module operates as follows:

1. **Sliding Window and Median Computation:**
   - The module uses a sliding window of size *N* (default is 3). As new samples arrive at the input `X`, they are processed through a chain of unit cells (instantiated via a generate loop).
   - Each unit cell compares the current sample with its neighboring samples. Through a series of comparisons and exchanges, the median value is determined.

2. **Synchronization and Valid Output:**
   - A counter (`cnt`) is used to track the number of clock cycles since the filter started processing. Once the counter exceeds a preset value (based on the window size), the output `valid` is asserted.
   - The final median output is available at the output `Y`, which is taken from the middle unit cell of the window. For a window size of 3, this is equivalent to the second (or median) value.

3. **Noise Reduction:**
   - **High-Frequency Noise / Spike Noise:**  
     The default window (N = 3) efficiently removes narrow, high-frequency noise (spikes) by rejecting extreme outlier values.
   - **Low-Frequency Noise / Baseline Wandering:**  
     If low-frequency noise is present (e.g., baseline wandering in ECG signals), the window size can be increased. A larger window will average out slower fluctuations, allowing for the removal of such baseline shifts while preserving the important features of the signal.

## Parameters

- **R_WIDTH (default = 8):**  
  Sets the bit width of the input and output signal. For example, R_WIDTH = 8 supports 8-bit input samples.

- **N (default = 3):**  
  Specifies the sliding window size. The default value (3) is optimal for removing narrow spike noise. Increasing N can improve filtering of low-frequency noise but may also introduce delay and affect signal features.

- **P_WIDTH:**  
  Derived automatically using `$clog2(N+1)`, it is used for internal counters and indexing within the filter.

## Module Interface

- **Inputs:**
  - `srst`: Synchronous reset. When asserted, it resets the internal state.
  - `clk`: Clock signal.
  - `X`: The input sample (R_WIDTH bits wide).

- **Outputs:**
  - `Y`: The filtered output sample (median of the window, R_WIDTH bits wide).
  - `valid`: A flag indicating that the filter output is valid (after sufficient samples have been processed).

## Internal Operation Details

- **Data Pipelining:**  
  The filter uses an array of wires (`R_out`, `P_out`, `Z_out`, `T_out`) and generates a chain of `unit_cell` instances that perform local comparisons and sorting between adjacent elements.

- **Counter for Validity:**  
  A counter (`cnt`) is incremented each clock cycle until it reaches a threshold based on the window size. When this threshold is met, the output is marked as valid.

- **Median Output Selection:**  
  The median value is selected from the central cell of the sorted window. For N = 3, this corresponds to `R_out[(N+1)/2]`.

## Usage

- **Default Operation (High-Frequency Noise Removal):**  
  Use the filter with the default parameter `N = 3` to effectively remove spike noise or high-frequency interference from your signal.

- **Low-Frequency Noise Removal:**  
  For applications like ECG signal processing where baseline wandering is present, increase the parameter `N` (e.g., N = 7 or higher) to capture and remove low-frequency variations.

- **Integration:**  
  Integrate the module into your signal processing chain by connecting the input signal to `X` and using the filtered output from `Y` once the `valid` flag is asserted.

## Summary

The `median_filter` module provides a robust and flexible solution for digital noise reduction. With a default sliding window of 3 samples, it efficiently suppresses spike noise and high-frequency interference. For signals affected by low-frequency noise, the window size can be adjusted to optimize performance. This module is well-suited for applications in biomedical signal processing, sensor data filtering, and any digital system requiring robust noise suppression.

# NEV-Utils: MATLAB Utilities for Neurophysiology Data

NEV-Utils is a comprehensive MATLAB toolbox for processing and analyzing neural data recorded with Blackrock Microsystems hardware. It provides a suite of functions to handle `.nev` (neural event) and `.nsx` (continuous signal) files, taking raw data from the recording system to an analysis-ready format.

This toolbox is designed to streamline the common workflow of parsing trial-based experiments, synchronizing event data (spikes, digital triggers) with continuous data (LFP, eye signals), and preparing the data for scientific analysis.

## Core Workflow

The primary data processing pipeline in NEV-Utils follows a two-step process that converts raw data files into a structured, trial-aligned format.

1.  **`nev2dat`**: This function is the first major processing step. It reads a `.nev` file to extract spike times and digital event codes. It parses the data into discrete trials based on start and end markers. Critically, it can also be instructed to read in the corresponding `.nsx` files (e.g., `.ns2`, `.ns5`) to retrieve continuous data, such as local field potentials (LFP) or eye-tracking signals, for each trial. The output is a `dat` struct, which is an array of structs, where each element represents a single trial.

    ```matlab
    % Basic usage:
    dat = nev2dat('my_data_file.nev');

    % Advanced usage with NSx data and eye-tracking conversion:
    dat = nev2dat('my_data_file.nev', 'readNS5', true, 'convertEyes', true);
    ```

2.  **`dat2ex`**: This function takes the `dat` struct from `nev2dat` and transforms it into a final `ex` struct, which is organized for easy analysis. It groups trials by experimental condition, aligns spike and event times to a specified event code (e.g., stimulus onset), and filters trials based on experimental outcomes (e.g., keeping only rewarded trials). The resulting `ex` struct contains all the necessary data—spikes, events, LFP, eye data, etc.—in a format that is easy to work with for plotting and statistical analysis.

    ```matlab
    % Convert the dat struct to an ex struct, aligning to event code 10:
    ex = dat2ex(dat, 'alignCode', 10);
    ```

## Key Features

*   **Robust File Reading**: Efficiently reads `.nev` and `.nsx` file formats, with MEX-optimized functions for performance-critical operations.
*   **Trial Parsing**: Automatically segments data into trials based on user-defined start and end event codes.
*   **Event and Continuous Data Synchronization**: Aligns spike and digital event data from `.nev` files with continuous signals from `.nsx` files on a per-trial basis.
*   **Multi-File Combination**: Provides utilities to concatenate data from multiple recording sessions into a single, continuous dataset (`concatenateNevFiles`, `combineNsx`).
*   **Eye Data Processing**: Includes functions to convert raw eye-tracker data into degrees of visual angle (`eye2deg`).
*   **Spike Sorting Integration**: Contains hooks for integrating with external spike sorting tools (e.g., NASNet).
*   **Flexible Data Structuring**: Creates well-organized `dat` and `ex` structs that are easy to navigate and use for further analysis.

## Function Overview

### Core Pipeline
-   `nev2dat`: The main entry point for parsing a single recording session.
-   `dat2ex`: The second step for structuring the parsed data for analysis.

### File Handling and Reading
-   `readNEV`: A MEX-optimized function to read data from `.nev` files.
-   `read_nsx`: A pure MATLAB function to read data from `.nsx` files, compatible with the FieldTrip toolbox format.
-   `concatenateNevFiles`: A high-level script to process and concatenate multiple `.nev` files and their associated data.
-   `combineNsx`: A utility to combine multiple `.nsx` files, filling time gaps with `NaN`s to maintain a continuous timeline.

### Helper Functions & Utilities
-   `getNS2Data`, `getNS5Data`: Helper functions called by `nev2dat` to retrieve and process continuous data.
-   `eye2deg`: Converts eye position data from raw pixels to degrees of visual angle.
-   `pix2deg`: A lower-level conversion from pixels to degrees.
-   `detectMissingStartEndCode`: A utility to gracefully handle files with missing trial markers.
-   `unpackSpikes`: A helper function to decompress spike time data within the `dat2ex` script.

## Dependencies

*   **MATLAB**: This toolbox is designed for use in the MATLAB environment.
*   **Signal Processing Toolbox**: Functions like `filtfilt` are used, which may require the Signal Processing Toolbox.
*   A C compiler configured for MATLAB is required to use the MEX-optimized `readNEV` function. Pre-compiled versions for Windows, macOS, and Linux are included.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

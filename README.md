# PPM Image Processing in Assembly

This project implements a PPM (Portable Pixmap) image processing pipeline in x86-64 assembly language using YASM. The program can read P6 format PPM files, perform histogram equalization, and write the processed images back to disk.

## Team Members
- Shaylin Govender
- Reece Jordaan
- Ayush Sanjith
- Aryan Mohanlall

## Features

### 1. PPM File Reading (`read_ppm_file.asm`)
- Reads P6 format PPM files
- Parses image header (width, height, max color value)
- Handles comments in header
- Stores image data in a linked list structure
- Performs basic error checking

### 2. CDF Computation (`compute_cdf_values.asm`)
- Computes grayscale intensity for each pixel
- Builds a histogram of pixel intensities
- Calculates cumulative distribution function (CDF)
- Normalizes CDF values for histogram equalization

### 3. Histogram Equalization (`histogram_equalisation.asm`)
- Applies histogram equalization to enhance image contrast
- Handles intensity clamping (0-255 range)
- Processes image in row-major order
- Preserves original CDF values while updating RGB channels

### 4. PPM File Writing (`write_ppm.asm`)
- Writes processed image back to PPM format
- Generates proper P6 header
- Converts numerical values to ASCII
- Maintains proper PPM file structure

## Build Instructions

1. Ensure you have YASM and GCC installed
2. Clone this repository
3. Run `make` to build the project
4. Run `make run` to execute the program
5. Use `make debug` for debugging with GDB
6. `make clean` removes build artifacts

## File Structure

- `read_ppm_file.asm`: PPM file reader implementation
- `compute_cdf_values.asm`: CDF computation logic
- `histogram_equalisation.asm`: Histogram equalization
- `write_ppm.asm`: PPM file writer
- `Makefile`: Build system configuration

## Technical Details

- Written in x86-64 assembly using YASM assembler
- Uses Linux system calls for file operations
- Implements a linked list structure for pixel storage
- Follows PPM (Portable Pixmap) format specifications
- Built with `-no-pie` flag for position-independent code
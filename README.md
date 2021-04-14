# perceptron
Verilog implementation of perceptrons.

# Directory Organization
* rtl: Datapath for integer, fixed point and boolean <br>
  - Datapath modules such as boo, int and fixed point
* include: Parameters and defines used across designs <br>
  - Include files used in synthesizable designs
* slp: Single layer perceptrons (SLP) <br>
  - Example design of single layer perceptron
  - Logic "AND" and "OR" training sample is provided (see test directory)
  - Currently int and fixed point SLP works correctly
* test: Test vectors for each modules <br>
  - Test vectors of datapath modules and SLP
  - Confirmed behavior in Xcelium19.09, VCS O-2018.09-1 and Vivado 2020.1 simulator (xsim)
* syn: Synthesis scripts for ASIC flows <br>
  - Synthesis (Design Compiler and GENUS ) and formal verification (Formality and Conformal) are supported
  - Sample configurations for ASAP7 (https://github.com/The-OpenROAD-Project/asap7) and SkyWater (https://github.com/google/skywater-pdk) are included 

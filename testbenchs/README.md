# BLDC Motor Controller Testbench (`tb_bldc_registers.v`)

## Description

This is a Verilog testbench designed to simulate and verify the behavior of a BLDC motor controller system. The simulation focuses on testing:

- Register configuration and readback (`bldc_registers.v`)
- Velocity-to-period conversion using a one-hot encoded lookup table (`lookup_table.v`)
- Integration and functional interaction of these components

## Modules Under Test

- **`bldc_registers.v`**: Stores and outputs the motor control parameters: velocity (`vel`), duty cycle (`duty`), enable (`en`), and phase state.
- **`lookup_table.v`**: Maps a one-hot encoded velocity to a 32-bit period value `T_value`.
- **Binary-to-OneHot Converter**: Converts the 8-bit binary velocity into an 8-bit one-hot signal used by the lookup table.

## Testbench Features

### Clock and Reset

- 50 MHz clock (`clk`): 20 ns period.
- Synchronous reset (`rst`): Active high, asserted during the first 40 ns.

### Simulation Phases

#### 1. PWM Mode (Fixed Velocity, Varying Duty)
- Sets `vel = 3` (2.4 kHz).
- Sweeps the `duty` cycle from 0 to 255.
- Writes values to the CONFIG register.
- Reads values from the OUT register.
- Logs the period `T` from the lookup table.

#### 2. FSM Mode (Varying Velocity, Fixed Duty)
- Sets a fixed `duty = 128`.
- Iterates through all 8 defined velocities (0 to 7).
- For each velocity, writes to the CONFIG register and reads from OUT.
- Logs the PWM period `T` corresponding to each velocity.

### Key Signals

| Signal        | Width  | Description                                      |
|---------------|--------|--------------------------------------------------|
| `clk`         | 1 bit  | 50 MHz system clock                              |
| `rst`         | 1 bit  | Synchronous reset                                |
| `write`       | 1 bit  | Write enable                                     |
| `read`        | 1 bit  | Read enable                                      |
| `addr`        | 1 bit  | Address: 0 = CONFIG, 1 = OUT                     |
| `data_in`     | 32 bit | Input data for the CONFIG register               |
| `data_out`    | 32 bit | Output data from the OUT register                |
| `vel`         | 8 bit  | Velocity in binary                               |
| `vel_onehot`  | 8 bit  | Velocity in one-hot format (for lookup table)    |
| `duty`        | 8 bit  | Duty cycle (0–255)                               |
| `en`          | 1 bit  | Enable motor control                             |
| `T`           | 32 bit | Period retrieved from the lookup table           |
| `phase_state` | 3 bit  | Placeholder for FSM phase state simulation       |

---

# PWM generator testbench (tb_pwm_generator.v)

## Description:
This testbench verifies the functionality of the pwm_generator module. It simulates a PWM signal generation at a defined base frequency and tests the output for different duty cycle values written via a control interface (write-enable and addressable register).

## Features:
- Correct generation of PWM signals at the specified frequency
- Handling of multiple 8-bit duty cycle values
- Write and read operations to/from duty cycle registers

## Clock and Timing;
- System Clock: 50MHz
- PWM base frequency: 1MHz
- Time simulation covers multiple PWM cycles for visual inspection

---

# Register and PWM modules connection testbench (reg_pwm_tb.v)

## Description:
This testbench verifies the functionality of two interconnected modules:
bldc_registers: Stores and provides velocity, duty cycle, enable, and phase state signals through a simple register interface.
pwm_generator: Generates a PWM signal based on duty cycle and enable signals.


## Components Under Test:
- bldc_registers: Interface for writing and reading velocity, duty, and en.
- pwm_generator : Produces a PWM waveform controlled by register values.

## Functionality Tested:
1. Write to register with different duty cycles and enable = 1.
2. Read back values to confirm correct register behavior.
3. Observe PWM output for various duty cycles (25%, 50%, 75%).

## Test Inputs:
- clk, rst: Clock and reset signals.
- write, read, addr, data_in: Signals for interacting with the registers.
- phase_state: Current state of the motor phases (not used directly here).

## Observed Outputs:
- data_out: Output from reading registers.
- vel, duty, en: Internal signals exposed by the register module.
- pwm_out: Output PWM waveform.

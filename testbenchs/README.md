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

## Simulation in GTKwave: 

<img width="1013" height="260" alt="image" src="https://github.com/user-attachments/assets/146e45ad-d4f0-4f64-82e8-927269ee9e80" />

The orange signals represent the control variables, such as addr (responsible of enable the config or out registers), clk (system clock), write (variable for the config register) and read (variable for the read register). The red ones show the output of both registers: data_in for the config register and data_out for the out register. Vel and duty are the outputs of the Out register that later are going to be use for the lookup table and the PWM signal. Finally, the yellow signals are the values taken for the lookup table, where a certain value of velocity is related to a period (T_value).

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

## Simulation in GTKwave 

<img width="909" height="386" alt="image" src="https://github.com/user-attachments/assets/44b0acb9-96fb-4105-82b3-81c0cc8430b1" />

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

## Simulation GTKwave:

<img width="904" height="433" alt="image" src="https://github.com/user-attachments/assets/8c6b3c43-737e-4092-b769-c8d711b8033d" />


In the first signal shown, it can be seen that the PWM has a duty cicle of 64, then next one in 128 and the last one in 196. proving that the PWM indeed changes its duty cycle according to the value given by the OUT register.

# Variable frequency wave generator

## Description:
This testbench intends to assess tha capacity of the variable frequency wave generator for its capacity of generating a three phased rounded sine wave.

## Components under test:
* Variable Frequency Generator module:

## Functionality tested:

* **Test 1: Zero-Value Input (T_VALUE = 0)**
Justification: This is a critical edge case test. When T_VALUE is 0, the main_counter (which starts at 0) will immediately match the target value on the first clock cycle after reset. This should cause the state_counter to increment on every single clock cycle. This test verifies that the module can handle this high-frequency state progression without issues.

* **Test 2: Typical Operation (T_VALUE = 10)**
Justification: This test verifies the module's core functionality under a normal, non-trivial condition. It confirms that the main_counter correctly counts up to the specified value (10) and that the state_counter increments only after the correct number of clock cycles have passed (11 cycles: 0 through 10). Running it for many repetitions, as you've done, thoroughly checks the wrap-around logic of the state_counter.

* **Test 3: Mid-Operation Reset**
Justification: This is a crucial asynchronous event test. It ensures that the rst_n signal works as intended, forcing the internal counters back to a known state (zero) regardless of their current values. This validates the design's reset logic, which is fundamental for system reliability.

* **Test 4: High-Frequency Operation (T_VALUE = 1)**
Justification: This is another valuable edge case test that pushes the limits of the design. With T_48_VALUE set to 1, the state_counter should increment every 2 clock cycles. This is the fastest rate of change besides the zero-value case and is excellent for stress-testing the logic that updates the state_counter and the output_val.

* **Test 5: Dynamic Input Change**
Justification: The purpose of this test is to verify how the circuit behaves when its configuration (T_48_VALUE) is altered during operation. This is an important system-level test, as inputs in a real system are not always static. While the expected outcome in your testbench was incorrect for the presumed hardware, the test itself is very important for characterizing the module's actual behavior in this scenario.


Observed outputs:

* **Test 1:** When T_value is 0, it is possible to evidence that the main counter increments each clock cycle:
<img width="1449" height="199" alt="image" src="https://github.com/user-attachments/assets/7f638c02-84bd-4aa4-aeb9-3946fdc6f1a0" />

* **Test 2:** With a higher `T_value` value, each main_counter increment takes 10 clock cycles, and after 480 clock cycles it is possible to evidence a full cycle of the three phase sine wave:
<img width="1565" height="244" alt="image" src="https://github.com/user-attachments/assets/2808dd08-a6c4-4852-b898-98e4707cbf68" />

* **Test 3:** During the reset, it is possible to evidence how the internal counter is reset back to 0 and when reset is ignored:

<img width="1552" height="298" alt="image" src="https://github.com/user-attachments/assets/5e1d60d1-96cd-48e6-ac89-bfe13ab1e0b6" />

* **Test 4:** Like Test 1, the device operates as expected. Incrementing `state_counter` every 2 clock cycles.
<img width="1578" height="245" alt="image" src="https://github.com/user-attachments/assets/15fd4ff8-e08b-4adb-b0b3-5f089c13c7bb" />


* **Test 5:** When the counter exceeds `T_value`, it's set back to 0, this behaviour avoids keep counting until higher values, breaking the expected signal and allowing to perform dynamic configuration.
<img width="1600" height="155" alt="image" src="https://github.com/user-attachments/assets/60b7f9f7-6a52-47ca-ac8b-98368eca7b76" />

# Lookup table + Variable Frequency Wave generator:

## Description:
This testbench asserts the communication between the lookup table and the variable frequency generator, it also intends to assert the time response of the combined system asserting that the configured frequencies are being generated.

## Components under test:
* Variable Frequency Generator module
* Lookup table module

## Functionality tested:

All 8 possible speeds will be loaded into the lookup table, the corresponding waves should be generated.

## Observed outputs

### Overall performance
All speeds are successfully generated and is a visual difference in frequency
<img width="1452" height="263" alt="image" src="https://github.com/user-attachments/assets/6fcb6c2c-a37f-4870-a6aa-12aced918e91" />

### Time response:
The following times were obtained measuring a full cycle time (1/2 and 1/6) for the lower frequencies like in the following screenshot:
<img width="1163" height="411" alt="image" src="https://github.com/user-attachments/assets/14650836-69a5-49c4-9d59-8087af334e0e" />


## Functionality tested:

# BLDC Registers Module
<img width="1025" height="695" alt="image" src="https://github.com/user-attachments/assets/07c9688b-a4ed-4902-9b07-e3f4fd3e713c" />

## Description

This module implements a register interface for configuring and monitoring a 3-phase BLDC (Brushless DC) motor controller. It provides read/write access via a simple bus interface and stores parameters such as speed, duty cycle, and enable flag.

##  Inputs

| Signal       | Width   | Description                                      |
|--------------|---------|--------------------------------------------------|
| `clk`        | 1 bit   | System clock                                     |
| `rst`        | 1 bit   | Active-high synchronous reset                    |
| `write`      | 1 bit   | Write enable signal                              |
| `read`       | 1 bit   | Read enable signal                               |
| `addr`       | 1 bit   | Register address selector: `0` = CONFIG, `1` = OUT |
| `data_in`    | 32 bits | Input data for writing to the CONFIG register    |
| `phase_state`| 3 bits  | Current state of the motor phases (from FSM)     |

## Outputs

| Signal     | Width   | Description                                        |
|------------|---------|----------------------------------------------------|
| `data_out` | 32 bits | Output data when reading from the OUT register     |
| `vel`      | 8 bits  | Speed configuration value                          |
| `duty`     | 8 bits  | PWM duty cycle value                               |
| `en`       | 1 bit   | Motor enable flag                                  |

## Functionality

### Write Operation (`addr == 0`)
When `write` is high and `addr == 0`:
- `data_in[31:24]` → `vel` (velocity selection)
- `data_in[23:16]` → `duty` (PWM duty cycle)
- `data_in[15]`    → `en` (motor enable)

The rest of the bits in `data_in` are ignored.

### Read Operation (`addr == 1`)
When `read` is high and `addr == 1`, `data_out` is loaded with the following format:
**imagen**

This allows monitoring of current speed, duty, enable flag, and the motor commutation state.

## Internal Registers

| Register    | Width   | Description               |
|-------------|---------|---------------------------|
| `vel_reg`   | 8 bits  | Stores selected velocity  |
| `duty_reg`  | 8 bits  | Stores duty cycle         |
| `en_reg`    | 1 bit   | Motor enable flag         |

--- 

# Look Up Table
![WhatsApp Image 2025-07-21 at 17 33 36_d5c29d36](https://github.com/user-attachments/assets/796345ea-e1c2-4629-8db7-1ab6ac5f8bea)

## Description

The `lookup_table` module maps a one-hot encoded velocity input to a specific 32-bit period value (`T_value`) corresponding to different motor speeds. 

Each one-hot encoded input corresponds to a predefined frequency, which translates into a specific timer period `T_value` (used for PWM generation or phase switching). If the input does not match any defined one-hot value, the output defaults to zero.

## Inputs

| Name         | Width | Description                                                |
|--------------|-------|------------------------------------------------------------|
| `vel_onehot` | 8 bits| One-hot encoded velocity input. Only one bit should be '1' at a time. Each bit corresponds to a predefined motor speed. |

## Outputs

| Name      | Width  | Description                                                       |
|-----------|--------|-------------------------------------------------------------------|
| `T_value` | 32 bits| Timer period in clock cycles. This value determines the switching period of the motor phases according to the selected speed. |

---

## One-Hot Encoding Table

| `vel_onehot` | Velocity Index | Frequency (Hz) | `T_value` (Clock Cycles) |
|--------------|----------------|----------------|---------------------------|
| 00000001     | 0              | 400            | 2603                      |
| 00000010     | 1              | 800            | 62500                     |
| 00000100     | 2              | 1600           | 1301                      |
| 00001000     | 3              | 2400           | 650                       |
| 00010000     | 4              | 3200           | 433                       |
| 00100000     | 5              | 4000           | 325                       |
| 01000000     | 6              | 5600           | 259                       |
| 10000000     | 7              | 6400           | 162                       |

If no bit is set or multiple bits are high, the output `T_value` is set to `0` as a fail-safe.

---

# PWM Generator Module
<img width="903" height="681" alt="image" src="https://github.com/user-attachments/assets/857d686e-0ad4-4156-8ade-e1c84c5383d7" />

## Description:

This module generates a PWM (Pulse Width Modulated) signal based on an 8-bit duty cycle input. The output frequency is fixed (e.g., 20 kHz for a 50 MHz clock). The duty cycle controls how long the output stays high in each PWM period.

## Inputs:
clk   : System clock.
rst   : Synchronous reset.
- en    : Enable signal for the PWM output.
 duty  : 8-bit duty cycle (0-255).

## Output:
pwm_out : PWM output signal.

## Functionality:
The module scales the 8-bit duty input to match a fixed PWM period. The output pwm_out is high when the internal counter is less than the computed threshold (duty scaled to period). If enable is low, pwm_out is forced low.

---

# Variable Frequency wave generator
![WhatsApp Image 2025-07-21 at 17 36 07_33219aa8](https://github.com/user-attachments/assets/5a8d4c20-6276-4141-9490-17f3c58a06fd)

Works a s a three phase variable sine wave generator, uses a precomputed sine wave rounded to 0 and 1 depending if it's positive or negative. Performs a full cycle in 48 steps of `T_value+1` clock cycles.

| Name         | Width | Description                                                |
|--------------|-------|------------------------------------------------------------|
| `clk`        | 1 bit   | System clock                                     |
| `rst`        | 1 bit   | Active-high synchronous reset                    |
| `T_value` | 32 bits| Timer period in clock cycles. This value determines the switching period of the motor phases according to the selected speed. |

## Outputs

| Name      | Width  | Description                                                       |
|-----------|--------|-------------------------------------------------------------------|
| `output_val` | 3 bits| Value of the three phased output, each bit corresponds to a phase. |
* **Test 1: Zero-Value Input (T_48_VALUE = 0)**
Justification: This is a critical edge case test. When T_48_VALUE is 0, the main_counter (which starts at 0) will immediately match the target value on the first clock cycle after reset. This should cause the state_counter to increment on every single clock cycle. This test verifies that the module can handle this high-frequency state progression without issues.

* **Test 2: Typical Operation (T_48_VALUE = 10)**
Justification: This test verifies the module's core functionality under a normal, non-trivial condition. It confirms that the main_counter correctly counts up to the specified value (10) and that the state_counter increments only after the correct number of clock cycles have passed (11 cycles: 0 through 10). Running it for many repetitions, as you've done, thoroughly checks the wrap-around logic of the state_counter.

* **Test 3: Mid-Operation Reset**
Justification: This is a crucial asynchronous event test. It ensures that the rst_n signal works as intended, forcing the internal counters back to a known state (zero) regardless of their current values. This validates the design's reset logic, which is fundamental for system reliability.

* **Test 4: High-Frequency Operation (T_48_VALUE = 1)**
Justification: This is another valuable edge case test that pushes the limits of the design. With T_48_VALUE set to 1, the state_counter should increment every 2 clock cycles. This is the fastest rate of change besides the zero-value case and is excellent for stress-testing the logic that updates the state_counter and the output_val.

* **Test 5: Dynamic Input Change**
Justification: The purpose of this test is to verify how the circuit behaves when its configuration (T_48_VALUE) is altered during operation. This is an important system-level test, as inputs in a real system are not always static. While the expected outcome in your testbench was incorrect for the presumed hardware, the test itself is very important for characterizing the module's actual behavior in this scenario.

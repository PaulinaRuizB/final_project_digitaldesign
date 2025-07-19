# pwm_generator.v

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

# BLDC Registers Module

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

# lookup_table.v

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
| 00000001     | 0              | 400            | 125000                    |
| 00000010     | 1              | 800            | 62500                     |
| 00000100     | 2              | 1600           | 31250                     |
| 00001000     | 3              | 2400           | 20833                     |
| 00010000     | 4              | 3200           | 15625                     |
| 00100000     | 5              | 4000           | 12500                     |
| 01000000     | 6              | 5600           | 8929                      |
| 10000000     | 7              | 6400           | 7813                      |

If no bit is set or multiple bits are high, the output `T_value` is set to `0` as a fail-safe.


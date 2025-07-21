# Digital Design Final Project: Brushless motor controller

## Authors:
- Felipe Fernández Alzate
- Paulina Ruiz Bonilla
- Juan Esteban Guevara Roncancio

## Description:
This project implements a basic brushless DC (BLDC) motor controller using Verilog HDL. It is designed for educational purposes as part of the Digital Design course, focusing on core concepts such as PWM signal generation, state machines, and control logic for motor phase switching.

## Objectives:
- Implement a digital controller for a 3-phase brushless DC (BLDC) motor using Verilog.
- Design a PWM generator to control motor speed digitally.
- Apply digital design principles such as modularity, timing control, and simulation testing.
- Gain practical experience in hardware description languages and motor control logic.

## Functionality:
Our system stores speed, duty cycle and enable values into a CONFIG register used to pass the Duty cycle value to the PWM generator module and the speed value into the variable frequency wave generator. These values are copied into the OUT register for the CPU to read in case to be necessary. The idea in this last part is to compare the speed value with our Look-up Table which converts from One-Hot enconding to an assigned value with its own Frequency and Period. All of this to create limited sinusoidal waves we will use later in three different phases (120º difference).
By taking the duty cycle value from before we get into the PWM generator module, we output the corresponding PWM signal based on a threshold defined by the PWM cycle (In this case is 50 as its clock works at 1MHz and is correlated to the 50MHz clock from the system) and the Duty value.
At last we take the sinusoidal waves and the PWM signal, then they are combined to create single signals with their proper unphase.

## General Structure:
<img width="877" height="714" alt="image" src="https://github.com/user-attachments/assets/13ec646d-7da7-481e-9c8a-ebea10575957" />

## Finite State Machine:
![WhatsApp Image 2025-07-21 at 17 35 17_3662cbe8](https://github.com/user-attachments/assets/403a8f04-1fc1-44a6-bda4-d356589c6c1a)

## Results:
In the next image we can see all signals behaviour:
![WhatsApp Image 2025-07-21 at 17 31 17_43ac4b24](https://github.com/user-attachments/assets/c8b3a4fe-7bbf-488e-82d9-32b167bfcc07)

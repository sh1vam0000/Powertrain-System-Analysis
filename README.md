# eBAJA Powertrain System Analysis

MATLAB-based analysis of an eBAJA electric vehicle powertrain, covering motor performance, chain-sprocket transmission, gearbox reduction, tyre torque, vehicle speed, tractive force, traction limits, and power consistency.

## Powertrain Configuration

**Motor → Chain/Sprocket → Gearbox → Output Shaft → Tyre**

- Motor sprocket: 15 teeth
- Gearbox sprocket: 14 teeth
- Gearbox reduction: 9:1
- Total reduction ratio: 8.4:1
- Output shaft ratio: 1:1
- Overall mechanical efficiency: 77.5%

## Motor Specifications

| Parameter | Value |
|---|---:|
| Rated Power | 5 kW |
| Peak Power | 9 kW |
| Rated Torque | 15.5 Nm |
| Peak Torque | 90 Nm |
| Rated Current | 80 A |
| Maximum Current | 180 A |
| Rated Speed | 4200 RPM |
| Maximum Speed | 4300 RPM |
| Motor Efficiency | 97% |

## Vehicle Parameters

| Parameter | Value |
|---|---:|
| Vehicle Mass + Driver | 320 kg |
| Tyre Rolling Radius | 0.3048 m |
| Driven-Wheel Load | 55% |
| Coefficient of Friction | 0.7 |

## Key Results

- Maximum tyre torque: **585.9 Nm**
- Maximum tyre speed: **511.90 RPM**
- Theoretical maximum vehicle speed: **58.82 km/h**
- Maximum tractive force from peak tyre torque: **1922.2 N**
- Estimated traction-limited tyre torque: **368.4 Nm**

## MATLAB Analysis

The MATLAB model generates the following performance plots:

1. Motor Torque vs Motor Current
2. Tyre Torque vs Motor Current
3. Motor Speed vs Tyre Speed
4. Motor Speed vs Vehicle Speed
5. Tyre Torque vs Vehicle Speed
6. Motor Power vs Motor Speed
7. Tractive Force vs Vehicle Speed
8. Motor Current vs Vehicle Speed

## Files

- `Powertrain_System_Analysis.m` — Main MATLAB powertrain analysis
- `powertrain_analysiscombined.m` — Combined performance plots
- `Powertrain_System_Analysis_Report.docx` — Detailed analysis report

## Engineering Assumptions

- Overall mechanical drivetrain efficiency = 77.5%
- Output shaft ratio = 1:1
- Tyre rolling radius = 0.3048 m
- Driven-wheel load = 55% of vehicle weight
- Coefficient of friction = 0.7
- 5 kW is used as the continuous motor power limit
- 9 kW is treated as peak/short-duration motor capability
- Torque-current behavior is modeled using the assumptions described in the report

## Conclusion

The analysis evaluates the complete mechanical power path from the electric motor to the tyre and determines the resulting torque, speed, tractive force, power, and traction limits.

The calculated theoretical maximum speed is **58.82 km/h**, while the peak drivetrain torque exceeds the estimated tyre-road traction limit under the stated assumptions.

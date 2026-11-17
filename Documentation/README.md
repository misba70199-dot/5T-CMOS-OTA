# 5-Transistor CMOS OTA — Project README

**Technology:** 180 nm CMOS | **Supply:** 1.8 V | **Tool:** LTspice XVII

---

## 📁 File Guide

| File | What it is | Start here? |
|------|-----------|-------------|
| `5T_OTA_v2.sp` | ⭐ **Main simulation file** (plain SPICE, always works) | YES |
| `5T_OTA_v2.asc` | LTspice graphical schematic (open to see the diagram) | Optional |
| `models.lib` | MOSFET model library — MUST be in same folder | Required |
| `5T_OTA_circuit.png` | Circuit diagram image for reference | Reference |

> **Important:** Always keep all files in the **same folder**. LTspice looks for `models.lib` in the same directory as the simulation file.

---

## ⚡ Quick Start (Under 2 Minutes)

1. Install **LTspice XVII** (free): https://www.analog.com/en/design-center/design-tools-and-calculators/ltspice-simulator.html
2. Open LTspice → **File → Open** → select `5T_OTA_v2.sp`
3. Press **Alt + R** (or click the green Run button)
4. Click on any wire to probe voltages

---

## 🔌 Circuit Connections — Plain English

### The Big Picture
The OTA takes **two inputs** (Vinp and Vinn) and produces an **output current** that charges the load capacitor CL to produce output voltage Vout. The relationship is:

> **Iout = Gm × (Vinp − Vinn)**

Think of it like a water pipe: the **differential voltage** (Vinp − Vinn) controls how much **current** flows to the output.

---

### Node-by-Node Explanation

```
         +1.8V VDD
            |
    ┌───────┴───────┐
    │               │
  [M3-PMOS]      [M4-PMOS]      ← PMOS current mirror (active load)
  Source→VDD    Source→VDD
    │               │
    ├──[Gate]────[Gate]─────── Vmirror (the mirror voltage)
    │               │
  Drain           Drain ────────────── Vout ──┤CL 1pF├── GND
    │               │
  [M1-NMOS]      [M2-NMOS]      ← NMOS differential pair
  Gate←Vinn(−)  Gate←Vinp(+)
    │               │
    └───────┬───────┘
          Vtail  (common source)
            │
         [M5-NMOS]              ← Tail current source
         Gate←Vbias=1.0V
            │
           GND
```

---

### Each Transistor Explained

#### M1 — NMOS Differential Pair (Inverting Input Side)
- **Connections:** D→Vmirror, G→Vinn(−), S→Vtail, B→GND
- **Size:** W=10µm, L=0.5µm → W/L ratio = 20 (large for high Gm)
- **What it does:** When Vinn increases, M1 pulls more current → Vmirror drops → M4 mirrors less current → Vout rises. This is the **inverting** side.
- **Matching rule:** M1 and M2 **must be identical** (same W, L, same layout) or the OTA has offset.

#### M2 — NMOS Differential Pair (Non-Inverting Input Side)
- **Connections:** D→Vout, G→Vinp(+), S→Vtail, B→GND
- **Size:** W=10µm, L=0.5µm (must match M1 exactly)
- **What it does:** When Vinp increases, M2 takes more current → Vout drops momentarily. But the mirror action of M3/M4 makes the net output follow Vinp. This is the **non-inverting** side.

#### M3 — PMOS Active Load (Diode-Connected)
- **Connections:** D→Vmirror, G→Vmirror (gate=drain!), S→VDD, B→VDD
- **Size:** W=4µm, L=0.5µm
- **What it does:** The gate is shorted to the drain → it's always in saturation, acting like a "smart diode." It converts M1's drain current into the mirror voltage Vmirror = VDD − |Vgsp|.
- **Why diode-connected?** Creates low impedance (~1/gm3) at that node → stable reference for M4's gate. Output resistance here is LOW (not high).

#### M4 — PMOS Active Load (Current Mirror)
- **Connections:** D→Vout, G→Vmirror, S→VDD, B→VDD
- **Size:** W=4µm, L=0.5µm (must match M3 exactly)
- **What it does:** Has the same Vgs as M3 (they share gate voltage Vmirror) → copies M3's current. I_M4 ≈ I_M1 at any instant. The difference between I_M4 and I_M2 is the **output current** that charges Vout.
- **Why is output impedance high?** Unlike M3 (diode-connected), M4 is a simple mirror → output resistance = ro4 ≈ 400kΩ → high voltage gain.

#### M5 — NMOS Tail Current Source
- **Connections:** D→Vtail, G→Vbias=1.0V, S→GND, B→GND
- **Size:** W=5µm, L=1µm → W/L = 5
- **What it does:** Sets the total tail current Itail ≈ 100µA. This current is split between M1 and M2. The long channel (L=1µm) reduces LAMBDA, making the current more stable (higher output resistance).
- **Why Vbias = 1.0V?**
  ```
  Id = (KP/2)*(W/L)*(Vgs−Vtn)² = (170µ/2)*5*(Vbias−0.5)² = 100µA
  → Vbias = 0.5 + √(100µ/425µ) = 0.5 + 0.485 ≈ 1.0V
  ```

---

## 📐 Key Design Equations

### Transconductance (Gm)
> How much output current per volt of input

$$G_m = \sqrt{2 \cdot KP \cdot \frac{W_1}{L_1} \cdot \frac{I_{tail}}{2}} = \sqrt{2 \times 170\mu \times 20 \times 50\mu} \approx 583\,\mu S$$

### Output Resistance (Rout)
> M2 and M4 drain resistances in parallel

$$R_{out} = r_{o2} \| r_{o4} = \frac{1}{\lambda_n \cdot I_{D2}} \| \frac{1}{\lambda_p \cdot I_{D4}} = 200k \| 400k = 133\,k\Omega$$

### DC Voltage Gain (Av)
$$A_v = G_m \cdot R_{out} = 583\mu \times 133k \approx 78\,V/V \approx 38\,dB$$

### Unity-Gain Bandwidth (GBW)
$$GBW = \frac{G_m}{2\pi \cdot C_L} = \frac{583\mu}{2\pi \times 1p} \approx 93\,MHz$$

### -3dB Bandwidth
$$f_{-3dB} = \frac{1}{2\pi \cdot R_{out} \cdot C_L} = \frac{1}{2\pi \times 133k \times 1p} \approx 1.2\,MHz$$

### Slew Rate
$$SR = \frac{I_{tail}}{C_L} = \frac{100\mu}{1p} = 100\,V/\mu s$$

---

## 🔬 Simulation Guide

### After Running .op (DC Operating Point)
In LTspice → **View → SPICE Error Log** — look for:

| Node / Current | Expected Value | Meaning |
|----------------|---------------|---------|
| V(Vtail) | 0.3 – 0.5 V | M5 is in saturation |
| V(Vmirror) | 1.1 – 1.3 V | = VDD − \|Vgsp_M3\| |
| V(Vout) | 0.7 – 1.1 V | Should be near 0.9V at balance |
| Id(M5) | −100 µA | Tail current (negative = into drain) |
| Id(M1) | −50 µA | Left branch ≈ half of tail |
| Id(M2) | −50 µA | Right branch ≈ half of tail |

> **Saturation check for each transistor:**  
> NMOS: Vds > Vgs − Vtn → Vds > (Vgs − 0.5)  
> PMOS: Vsd > Vsg − |Vtp| → Vsd > (Vsg − 0.5)

### After Running .tran (Transient)
- Click **Vout** wire → see output sinewave at 100 kHz
- Click **Vinn** wire → see input sinewave (inverted phase at output)
- **Expected output amplitude:** ~40–80 mV (from 0.5 mV input → gain ≈ 80–160)
- If output is clipped: input is too large. Reduce Vd from 1mV to 0.1mV.

### After Running .ac (Bode Plot)
- Click **Vout** → Y-axis shows gain in dB vs frequency
- Right-click Y-axis → **Phase** to overlay phase plot
- Read from the plot:
  - **Flat region (low-f gain):** ~36–42 dB
  - **−3dB point:** ~1–5 MHz
  - **GBW (gain=0dB):** ~50–200 MHz
  - **Phase at GBW:** >45° (stable if used in unity feedback)

---

## 🛠️ Troubleshooting

| Problem | Likely Cause | Fix |
|---------|-------------|-----|
| "Cannot find model PMOS_Model" | models.lib not found | Put models.lib in same folder as .sp file |
| Vout stuck at VDD | M4 not saturated / Vbias too low | Try Vbias = 0.9V or 1.1V |
| Vout stuck at GND | M5 off / Vbias too low | Increase Vbias to 1.0–1.2V |
| Output waveform very small | Gain is working, input is small | That's correct — 1mV input × 80 gain = 80mV output |
| Distorted output | Input amplitude too large | Reduce SINE amplitude from 0.5m to 0.1m |
| "Floating body" warning | NMOS bulk not connected | Use .sp netlist; it has explicit bulk connections |

---

## 🎓 Viva Quick Reference

| Question | Short Answer |
|----------|-------------|
| Why 5 transistors? | M1+M2 (diff pair) + M3+M4 (mirror load) + M5 (tail). Minimum for a complete OTA. |
| What does M3-M4 do together? | Current mirror: M3 senses M1's current, M4 copies it to the output side |
| Why is M3 diode-connected? | Gate=Drain → always in saturation → low impedance reference for the mirror |
| Why must M1=M2 and M3=M4? | Mismatch causes input offset voltage (output ≠ 0 when inputs are equal) |
| What determines Gm? | Gm = √(2·KP·(W/L)·ID1) — depends on tail current and device size |
| What limits output swing? | NMOS triode at low Vout; PMOS triode at high Vout. Usable range ≈ 0.3V to 1.5V |
| What is the dominant pole? | At Vout: fp = 1/(2π·Rout·CL). Larger CL → slower, but more stable |
| What is slew rate? | Max dVout/dt = Itail/CL. Limited by M5's tail current and CL. |

---

## 📊 Expected Performance Summary

| Parameter | Symbol | Calculated | Unit |
|-----------|--------|------------|------|
| Supply | VDD | 1.8 | V |
| Tail current | Itail | ~100 | µA |
| Transconductance | Gm | ~583 | µS |
| Output resistance | Rout | ~133 | kΩ |
| DC gain | Av | ~78 (38 dB) | V/V |
| Bandwidth (−3dB) | f−3dB | ~1.2 | MHz |
| Unity-gain BW | GBW | ~93 | MHz |
| Slew rate | SR | 100 | V/µs |
| Power | P = VDD × Itail | 180 | µW |
| Output CM range | — | 0.3 – 1.5 | V |

# How to Open and Run the 5T OTA in LTspice

## Step 1 — Open the Schematic
1. Download and install **LTspice XVII** (free from Analog Devices: https://www.analog.com/en/design-center/design-tools-and-calculators/ltspice-simulator.html)
2. Open LTspice → **File → Open** → navigate to `5T_OTA/` folder
3. Open `5T_OTA_netlist.sp` (recommended for beginners — just click Run)

**OR** open `5T_OTA.asc` to see the graphical schematic.

---

## Step 2 — Verify the Library Path
LTspice must find `models.lib`. Two options:

**Option A (Easiest):** Keep all files in the same folder.
```
5T_OTA/
  ├── 5T_OTA.asc
  ├── 5T_OTA_netlist.sp
  └── models.lib
```

**Option B:** Add full path in the netlist:
```spice
.lib "C:\path\to\5T_OTA\models.lib"
```

---

## Step 3 — Run DC Operating Point (.op)
- Click the **Run** button (green play button) OR press `Alt+R`
- After simulation: **View → SPICE Error Log**
- Look for lines like:
  ```
  --- Operating Point ---
  V(Vtail):   0.XXX    voltage
  V(Vd1):     1.XXX    voltage
  V(Vout):    ~0.9     voltage
  Id(M5):    -100e-6   device_current
  Id(M1):    -50e-6
  Id(M2):    -50e-6
  ```

---

## Step 4 — View Transient Waveforms
1. After running transient (.tran), the waveform viewer opens automatically
2. Click on the **Vout wire** in the schematic → see the output sine wave
3. Click on **Vinn** wire → see the input
4. You should see Vout swinging ~100× more than Vinn (gain ≈ 40 dB)

**What to observe:**
- Output sine wave at 100 kHz
- Phase: Vout should be **in-phase** with Vinp (non-inverting)
- Amplitude: ~50-100mV peak (from 0.5mV input → gain ~100-200)

---

## Step 5 — View AC (Bode Plot)
1. After .ac simulation, click on **Vout** wire
2. Right-click on the Y-axis → select **dB**
3. Right-click → **Add Trace** → type `ph(V(Vout))` to add phase

**What to observe:**
- Low-frequency gain: ~35-45 dB
- -3dB frequency (bandwidth): ~1-10 MHz
- Unity Gain Bandwidth (GBW): ~100-500 MHz
- Phase at GBW: >45° (indicating stability for unity feedback)

---

## Step 6 — Measure Key Parameters
In LTspice waveform viewer:
- **Gain**: Place cursor at f=1Hz, read Y-axis in dB
- **GBW**: Find where gain = 0 dB, read the frequency
- **Phase Margin**: Read phase at GBW frequency

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| "Cannot find model" | Check models.lib is in same folder |
| Vout stuck at VDD or GND | Vbias too high/low; try 0.8V–1.1V |
| No oscillation in transient | Increase Vd amplitude to 5m or 10m |
| Simulation very slow | Increase max step: `.tran 0 10u 0 1n` |

---

## Key Node Names to Probe
| Node | Description |
|------|-------------|
| `V(Vout)` | Output voltage |
| `V(Vinn)` | Inverting input |
| `V(Vinp)` | Non-inverting input |
| `V(Vtail)` | Common source of M1 & M2 |
| `V(Vd1)` | Drain of M3 (mirror reference) |
| `Id(M5)` | Tail current (~100 µA) |
| `Id(M1)` | Left branch current (~50 µA) |
| `Id(M2)` | Right branch current (~50 µA) |

* ============================================================
*  5-Transistor CMOS Operational Transconductance Amplifier
*  SPICE Netlist (can be used in LTspice or any SPICE simulator)
*
*  TOPOLOGY:
*   - Differential Input Pair  : M1 (NMOS, Vinn), M2 (NMOS, Vinp)
*   - Active Current Mirror Load: M3 (PMOS diode), M4 (PMOS mirror)
*   - Tail Current Source      : M5 (NMOS, biased by Vbias)
*
*  SPECIFICATIONS:
*   - Supply Voltage VDD       : 1.8 V
*   - Tail Bias Current (Id_M5): ~100 uA
*   - Each branch current      : ~50 uA
*   - CL (load cap)            : 1 pF
*   - Input CM voltage         : 0.9 V
*   - Differential input Vd    : 1 mV peak (100 kHz)
*
*  HOW TO RUN IN LTSPICE:
*   1. File > Open > 5T_OTA_netlist.sp
*   2. Simulate > Run
*   3. Click on wires to see waveforms
* ============================================================

.title 5T CMOS OTA

* ---- Include MOSFET Model Library ----
.lib models.lib

* ============================================================
*  POWER SUPPLY
* ============================================================
* VDD to GND = 1.8V
VDD VDD 0 DC 1.8V

* ============================================================
*  BIAS VOLTAGE FOR TAIL CURRENT SOURCE (M5)
* ============================================================
*  Vbias is chosen so that M5 (W=5u, L=1u, NMOS) carries ~100uA.
*  Using Id = (KP/2)*(W/L)*(Vgs - Vtn)^2  with KP=170u, W/L=5:
*     100u = (170u/2)*5*(Vgs-0.5)^2
*     100u = 425u*(Vgs-0.5)^2
*     (Vgs-0.5)^2 = 0.235
*     Vgs-0.5 = 0.485V  =>  Vgs = 0.985V ~ 1.0V
*  We set Vbias = 1.0V (Vs of M5 = 0, so Vgs = Vbias = 1.0V)
Vbias Vbias 0 DC 1.0V

* ============================================================
*  INPUT SOURCES
* ============================================================
*  Differential pair inputs:
*    Vinn (inverting)    = Vcm - Vd/2
*    Vinp (non-inverting)= Vcm + Vd/2
*
*  For transient: sinusoidal at 100kHz, 0.5mV amplitude each
*  For AC: use AC 1 (frequency sweep done by .ac directive)

* Vcm = 0.9V common-mode
* Vinp: non-inverting input (+terminal)
Vinp Vinp 0 DC 0.9 AC 0.5m SINE(0.9 0.5m 100k 0 0 0)

* Vinn: inverting input (-terminal)
Vinn Vinn 0 DC 0.9 AC -0.5m SINE(0.9 -0.5m 100k 0 0 0)

* ============================================================
*  CIRCUIT COMPONENTS
* ============================================================

*  ----- TAIL CURRENT SOURCE -----
*  M5: NMOS transistor
*  Drain  = Vtail (common source of M1 & M2)
*  Gate   = Vbias
*  Source = GND (0)
*  Body   = GND (0)   [n-well process: bulk of NMOS = substrate = GND]
*
*  FUNCTION: Sets the total tail current ~100uA. This current
*  is split equally between M1 and M2 when Vinn = Vinp.
*  W=5u, L=1u gives W/L = 5. Longer L improves output resistance.
M5 Vtail Vbias 0 0 NMOS_Model W=5u L=1u

*  ----- DIFFERENTIAL INPUT PAIR -----
*  M1: NMOS (driven by Vinn - inverting input)
*  Drain  = Vd1  (connects to M3 drain, diode PMOS)
*  Gate   = Vinn
*  Source = Vtail
*  Body   = GND (NMOS bulk always GND)
*
*  FUNCTION: If Vinn increases, M1 conducts more current → Vd1 drops.
M1 Vd1 Vinn Vtail 0 NMOS_Model W=10u L=0.5u

*  M2: NMOS (driven by Vinp - non-inverting input)
*  Drain  = Vout  (connects to M4 drain, output node)
*  Gate   = Vinp
*  Source = Vtail
*  Body   = GND
*
*  FUNCTION: If Vinp increases, M2 conducts more current → output drops.
M2 Vout Vinp Vtail 0 NMOS_Model W=10u L=0.5u

*  ----- PMOS ACTIVE LOAD (CURRENT MIRROR) -----
*  M3: PMOS (diode-connected = gate shorted to drain)
*  Source = VDD
*  Gate   = Vd1  (also = Drain of M3, diode-connected)
*  Drain  = Vd1
*  Body   = VDD  (PMOS bulk tied to VDD, the highest potential)
*
*  FUNCTION: Sets the mirror reference. M3 "sees" the current from M1
*  and converts it to a voltage at Vd1 (which becomes Vgs_mirror).
M3 Vd1 Vd1 VDD VDD PMOS_Model W=4u L=0.5u

*  M4: PMOS (mirror transistor = output current source)
*  Source = VDD
*  Gate   = Vd1  (same gate as M3 → copies M3's current)
*  Drain  = Vout (output node)
*  Body   = VDD
*
*  FUNCTION: Mirrors the current from M3. If M1 current decreases
*  (because Vinp > Vinn), M4 current stays temporarily high →
*  Vout rises. This creates the differential-to-single-ended conversion.
M4 Vout Vd1 VDD VDD PMOS_Model W=4u L=0.5u

*  ----- OUTPUT LOAD CAPACITOR -----
*  CL: Represents input capacitance of next stage or test load
*  Connected from Vout to GND
CL Vout 0 1p

* ============================================================
*  SIMULATION COMMANDS
* ============================================================

*  1) DC Operating Point Analysis
*     Tells SPICE to solve all DC voltages and currents.
*     Check: Vtail ~ 0.3-0.5V, Vd1 ~ VDD - |Vgsp|, Id(M5)~100uA
.op

*  2) Transient Analysis
*     Simulate from t=0 to t=10us with max step 10ns
*     Shows output sine wave responding to differential input
.tran 0 10u 0 10n

*  3) AC Analysis (Small-signal frequency response)
*     100 points per decade, from 1Hz to 1GHz
*     Plots gain (dB) and phase vs frequency
*     Unity-gain frequency (ft) and phase margin visible here
.ac dec 100 1 1G

*  4) DC Transfer Characteristic
*     Sweep Vinp from 0 to 1.8V while Vinn = 0.9V (fixed)
*     Shows linear region of the OTA transfer curve
*.dc Vinp 0 1.8 0.001

* ============================================================
*  PROBE / SAVE SIGNALS
* ============================================================
.probe V(Vout) V(Vinn) V(Vinp) V(Vtail) V(Vd1) V(VDD)
.probe I(M5) I(M1) I(M2) I(M3) I(M4)

* Measure statements (LTspice calculates these automatically)
.meas AC GainDC    find V(Vout) at f=1
.meas AC GBW       when mag(V(Vout))=1
.meas AC PM        find ph(V(Vout)) when mag(V(Vout))=1
.meas AC f3dB      when mag(V(Vout))=0.7071 fall=1

.end

# ZYBO basic board test

Tests the programmable logic, 125 MHz oscillator, four user LEDs, four slide switches, and four user pushbuttons. No processor design, Vitis application, external wiring, or board-definition installation is needed. This is a basic functional check; it does not test DDR, ARM processors, HDMI, Ethernet, USB, audio, SD, or Pmod connectors.

## Choose your board

Read the board label before building. The original ZYBO and ZYBO Z7 have different clock and button pins. The default is the original ZYBO (Zynq-7010). Supported configurations:

| Board label | Script argument | FPGA part |
| --- | --- | --- |
| ZYBO (original) | zybo | xc7z010clg400-1 |
| ZYBO Z7-10 | z7-10 | xc7z010clg400-1 |
| ZYBO Z7-20 | z7-20 | xc7z020clg400-1 |

## Create and program in Vivado

1. Open a Vivado command prompt in this folder, then run `vivado -mode batch -source create_project.tcl -tclargs zybo`. Substitute `z7-10` or `z7-20` if appropriate. Generated project files stay under `build/` in this folder; rerunning the script replaces that variant's project settings.
2. Open `build/zybo/zybo_test.xpr` in Vivado (adjust the variant folder if needed).
3. Select **Generate Bitstream**, allowing synthesis and implementation to run.
4. Power the board according to its power-source jumper setting. Connect a data-capable USB cable to the board's **PROG/UART** port. Use the board's documented JTAG boot-mode setting if necessary.
5. Open **Hardware Manager > Open Target > Auto Connect**. Select the Zynq FPGA and **Program Device**, then choose `build/zybo/zybo_test.runs/impl_1/zybo_test.bit` (adjust variant).

For manual project creation, add `zybo_test.v` as a design source, `tb_zybo_test.v` as a simulation source, and `common.xdc` plus exactly ONE of `zybo.xdc` or `zybo_z7.xdc` as constraints. Set design top to `zybo_test` and simulation top to `tb_zybo_test`.

## Check the hardware

SW0 is the least significant mode bit; SW1 is the next bit. Switch ON means 1. Use the four user buttons BTN0 through BTN3, not the processor reset button.

| SW1 | SW0 | Expected LEDs LD3..LD0 |
| --- | --- | --- |
| 0 | 0 | One LED moves LD0 -> LD1 -> LD2 -> LD3 every 0.25 seconds |
| 0 | 1 | LEDs mirror SW3..SW0; toggle SW2 and SW3 to check them |
| 1 | 0 | Each LED lights while its matching user button is pressed |
| 1 | 1 | Four-bit binary counter advances every 0.25 seconds |

To check SW0 and SW1, confirm all four modes work. The counter and chase keep running in every mode. Inputs use two-stage synchronizers. Buttons are level indicators, so mechanical bounce may briefly appear when pressed or released; no button counts presses. Registers initialize when the FPGA is programmed. Programming is volatile: reprogram after power-off.

## Simulation

In Vivado select **Run Simulation > Run Behavioral Simulation**, then **Run All**. The testbench uses a faster divider and prints `PASS` after checking the chase, switch display, all button combinations, and counter wraparound. Alternatively, with Icarus Verilog installed:

```powershell
iverilog -g2012 -s tb_zybo_test -o zybo_test_sim tb_zybo_test.v zybo_test.v
vvp zybo_test_sim
```

## Pin references

Constraints were checked against Digilent's official master constraints:
- Original ZYBO: https://github.com/Digilent/digilent-xdc/blob/master/Zybo-Master.xdc
- ZYBO Z7: https://github.com/Digilent/digilent-xdc/blob/master/Zybo-Z7-Master.xdc

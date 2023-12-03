# grabPDM
VHDL intended to interface with PDM microphones and send the result to a host
## Specifics:
There is HDL intended to manage a PDM microphone and decimate via 2-stage CIC. Then there is additional HDL intended to send the result out via UART to the host. Finally, there is a quick python script to read the input and also to do some limited filtering of the result. 
This was tested using a custom PCBA based on the CMM-4737DT-26386-TR, which has the relevant lines interfacing to a CYC1000 dev board.
## Future work, if I get time:
1) Support for multiple microphones (this will happen given that this is a springboard for beamforming)
2) Support for using the high and low parts of the clock
3) Misc signal processing things on the python side

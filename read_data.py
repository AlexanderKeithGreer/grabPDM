import serial
import numpy as np
import scipy.signal as sg
import matplotlib.pyplot as plt
import time
import scipy.io.wavfile as wv

# Set up the serial connection
ser = serial.Serial('COM4', 12000000)

# Read data for 1 second
start_time = time.time()
data = []
while time.time() - start_time < 1:
    if ser.in_waiting:
        # Read a byte and append it to the list
        data.append(ser.read()[0])  # ser.read() returns a bytes object, we take the first byte

# Close the serial connection
ser.close()

# Convert the list of bytes to a NumPy array of dtype=np.int8
data_np = np.array(data, dtype=np.int8)

# Plot the data
plt.figure()
plt.plot(data_np)
plt.xlabel('Sample')
plt.ylabel('Data Value')
plt.title('Data from UART')

plt.figure()
plt.plot(np.convolve(data_np, sg.windows.blackman(64)))
plt.xlabel('Sample')
plt.ylabel('Data Value')
plt.title('Data from UART')
plt.show()

wv.write("grabbed.wav", 40000, data_np.astype(np.int16))

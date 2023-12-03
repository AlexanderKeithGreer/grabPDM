import matplotlib.pyplot as plt
import numpy as np
import numpy.fft as npfft
import scipy.signal as sg
import sys

def main():
    """
    Main function, takes in arguments as INPUT OUTPUT RATE
    """

    if (len(sys.argv) == 3):
        print("WARN: Wrong number of arguments")
        print("WARN:   Generate Test data")
        arg_file_into = sys.argv[1]
        arg_up_rate = np.int64(sys.argv[2])
        time = np.arange(0, 0.01, 1/19.2e3)
        data = np.sin(time*2*np.pi*20e3)
        data_long = np.int64(np.floor(np.repeat(data*100, arg_up_rate)))
        print("INFO: Shape of data is ", np.shape(data))
        out = modulateSigmaDelta(data, arg_up_rate)
        plt.plot(data_long)
        plt.plot(np.convolve(out,np.blackman(64)))
        out_formatted = np.array([data_long, np.int64(out*0.5+0.5)]).T
        np.savetxt(arg_file_into, out_formatted, fmt=["%d","%d"], delimiter=",")
        print("INFO: Plotting data")
        plt.show()
    elif (len(sys.argv) != 4):
        print("ERROR: Wrong number of arguments")
    else:
        arg_file_from = sys.argv[1]
        arg_file_into = sys.argv[2]
        arg_up_rate = np.int64(sys.argv[3])

        data = np.genfromtxt(arg_file_from, dtype=np.int64, delimiter=',')
        print("INFO: Shape of data is ", np.shape(data))
        out = modulateSigmaDelta(data, arg_up_rate)

        plt.plot(data)
        plt.plot(np.convolve(out,np.blackman(64)))
        out_formatted = np.array([np.int64(out*0.5+0.5)]).T
        np.savetxt(arg_file_into, out_formatted, fmt="%d", delimiter=",")
        print("INFO: Plotting data")
        plt.show()



def modulateSigmaDelta(input_data, rate_factor):
    """
    Typical upsampling rate is around about
    22.050kHz, with assumed sampling rate around 2MHz, approx
        91 Hz/Hz upsampling ratio
    """
    n_taps = np.int64(np.round(rate_factor*2.5))
    win = np.kaiser(n_taps, 5.0)
    integ = np.zeros(2)
    up_data = sg.resample_poly(input_data, rate_factor, 1, window=win)

    n_samples = len(up_data)

    out_data = np.zeros(n_samples)
    int_data = np.zeros(n_samples)

    last_data = 0
    for idx in range(n_samples):

        int_data[idx] = integ[0]
        if (integ[1] > 0):
            last_data = 1
            out_data[idx] = 1
        else:
            last_data = -1
            out_data[idx] = -1
        integ[0] += up_data[idx] - 1000*last_data
        integ[1] += integ[0] - 1000*last_data

    return out_data


def moduleteSigmaDelta_test():
    T = 10e-3
    f_s = 20e3
    f_test = 5e3
    rate_factor = 90
    time = np.arange(0,T,1/f_s)

    data = np.sin(time*2*np.pi*f_test)
    print("n_samp = ", len(data))
    h_time = np.arange(0, T, 1/(f_s*rate_factor) )
    h_data = np.sin(h_time*2*np.pi*f_test)

    out = modulateSigmaDelta(data, rate_factor)
    plt.figure()
    plt.plot(h_time, h_data)
    plt.plot(h_time, out)

    plt.figure()
    f_out = 20*np.log10(np.abs(npfft.fft(out+1e-15)))
    f_data = 20*np.log10(np.abs(npfft.fft(h_data+1e-7)))
    freqs = np.linspace(0,f_s*rate_factor, len(f_out))
    plt.plot(freqs, f_data)
    plt.plot(freqs, f_out)

    plt.show()


main()



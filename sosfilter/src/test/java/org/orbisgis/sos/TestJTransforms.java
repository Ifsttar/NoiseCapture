package org.orbisgis.sos;

import org.jtransforms.fft.FloatFFT_1D;
import org.junit.Assert;
import org.junit.Test;

import java.io.IOException;
import java.io.InputStream;
import java.nio.ByteOrder;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static org.junit.Assert.assertEquals;


public class TestJTransforms {
    public static final double[] STANDARD_FREQUENCIES_UNITTEST = new double[]{100, 125, 160, 200, 250, 315, 400, 500, 630, 800, 1000, 1250, 1600, 2000, 2500, 3150, 4000, 5000, 6300, 8000, 10000, 12500, 16000};

    @Test
    public void testProcessingWhiteNoise() throws IOException {
        final int sampleRate = 44100;
        final double length = 0.5;
        InputStream inputStream = CoreSignalProcessingTest.class.getResourceAsStream("whitenoise_44100Hz_16bitPCM_10s.raw");
        FFTSignalProcessing fftSignalProcessing =
                new FFTSignalProcessing(sampleRate, STANDARD_FREQUENCIES_UNITTEST, (int) (sampleRate * length));
        // Read input signal up to buffer.length
        short[] signal = SOSSignalProcessing.loadShortStream(inputStream, ByteOrder.LITTLE_ENDIAN);
        inputStream.close();
        fftSignalProcessing.addSample(signal);
        FFTSignalProcessing.ProcessingResult processingResult = fftSignalProcessing.processSample(false, false, false);
        System.out.println("RMS : " + fftSignalProcessing.computeRms() + "\ndbRMS " +
                fftSignalProcessing.computeGlobalLeq() + "\nThird octave spl :" + processingResult.getGlobaldBaValue());
    }

    /**
     * Check combination to third octave of white noise.
     * Disabled as the combination is rectangular
     */
    //@Test
    public void testThirdOctaveSum() {
        float[] fftResult = new float[20000];
        Arrays.fill(fftResult, 1.f);
        FFTSignalProcessing fftSignalProcessing = new FFTSignalProcessing(44100,
                ThirdOctaveBandsFiltering.STANDARD_FREQUENCIES_REDUCED, fftResult.length);
        float[] thirdOctaveSum = fftSignalProcessing.thirdOctaveProcessing(fftResult, false);
        double ref = FFTSignalProcessing.todBspl(thirdOctaveSum[0]);
        for(int idThirdOctave  = 1; idThirdOctave < thirdOctaveSum.length; idThirdOctave++) {
            assertEquals(ref + idThirdOctave, FFTSignalProcessing.todBspl(thirdOctaveSum[idThirdOctave]), 0.01);
        }
    }

    @Test
    public void testProcessing() {
        // Make 1000 Hz signal
        final int sampleRate = 44100;
        final int signalFrequency = 1000;
        double powerRMS = 2500; // 90 dBspl
        double powerPeak = powerRMS * Math.sqrt(2);
        short[] signal = new short[sampleRate * 2];
        for (int s = 0; s < sampleRate * 2; s++) {
            double t = s * (1 / (double) sampleRate);
            signal[s] = (short)(Math.sin(2 * Math.PI * signalFrequency * t) * (powerPeak));
        }

        FFTSignalProcessing fftSignalProcessing =
                new FFTSignalProcessing(sampleRate, ThirdOctaveBandsFiltering.STANDARD_FREQUENCIES_REDUCED, signal.length);
        fftSignalProcessing.addSample(signal);
        FFTSignalProcessing.ProcessingResult processingResult = fftSignalProcessing.processSample(false, false, false);

        assertEquals(90, fftSignalProcessing.computeGlobalLeq(), 0.01);
        assertEquals(90,
                processingResult.dBaLevels[Arrays.binarySearch(ThirdOctaveBandsFiltering.STANDARD_FREQUENCIES_REDUCED,
                        signalFrequency)], 0.01);
        assertEquals(90,
                processingResult.getGlobaldBaValue(), 0.01);


    }

    @Test
    public void testProcessingFast() {
        // Make 1000 Hz signal
        double fastRate = 0.250;
        final int sampleRate = 44100;
        final int signalFrequency = 1000;
        double powerRMS = 2500; // 90 dBspl
        double powerPeak = powerRMS * Math.sqrt(2);
        short[] signal = new short[(int)(sampleRate * fastRate)];
        for (int s = 0; s < signal.length; s++) {
            double t = s * (1 / (double) sampleRate);
            signal[s] = (short)(Math.sin(2 * Math.PI * signalFrequency * t) * (powerPeak));
        }

        FFTSignalProcessing fftSignalProcessing =
                new FFTSignalProcessing(sampleRate, ThirdOctaveBandsFiltering.STANDARD_FREQUENCIES_REDUCED, signal.length);
        fftSignalProcessing.addSample(signal);
        FFTSignalProcessing.ProcessingResult processingResult = fftSignalProcessing.processSample(false, false, false);

        assertEquals(90, fftSignalProcessing.computeGlobalLeq(), 0.01);
        assertEquals(90,
                processingResult.dBaLevels[Arrays.binarySearch(ThirdOctaveBandsFiltering.STANDARD_FREQUENCIES_REDUCED,
                        signalFrequency)], 0.01);
        assertEquals(90,
                processingResult.getGlobaldBaValue(), 0.01);

    }
    @Test
    public void testRecorder() throws IOException {
        int rate = 44100;
        InputStream inputStream = CoreSignalProcessingTest.class.getResourceAsStream("capture_1000hz_16bits_44100hz_signed.raw");
        FFTSignalProcessing fftSignalProcessing =
                new FFTSignalProcessing(rate, STANDARD_FREQUENCIES_UNITTEST, (int)(0.3 * rate));
        // Read input signal up to buffer.length
        short[] signal = SOSSignalProcessing.loadShortStream(inputStream, ByteOrder.LITTLE_ENDIAN);
        // Split signal to simulate recording
        int[] splitParts = new int[] {10, 5, 5, 30, 1, 9 , 20, 19, 1};
        int lastPart = 0;
        for(int part : splitParts) {
            short[] signalPart = new short[(int)((part / 100.) * signal.length)];
            System.arraycopy(signal, lastPart, signalPart, 0, signalPart.length);
            fftSignalProcessing.addSample(signalPart);
            lastPart += signalPart.length;
        }
        FFTSignalProcessing.ProcessingResult processingResult = fftSignalProcessing.processSample(false, false, false);

        assertEquals(323.85, fftSignalProcessing.computeRms(), 0.01);
        assertEquals(72.24, processingResult.getGlobaldBaValue(), 1);
        assertEquals(72.24, fftSignalProcessing.computeGlobalLeq(), 0.01);
    }

    @Test
    public void testAmplitude() {

        // Make 50 Hz signal
        final int sampleRate = 44100;
        final int signalFrequency = 50;
        float power = 2500;
        float[] signal = new float[sampleRate];
        for(int s = 0; s < sampleRate; s++) {
            double t = s * (1 / (double)sampleRate);
            signal[s] = (float)Math.sin(2 * Math.PI * signalFrequency * t) * power;
        }

        // Execute FFT
        FloatFFT_1D floatFFT_1D = new FloatFFT_1D(sampleRate);
        floatFFT_1D.realForward(signal);

        // Extract Real part
        float localMax = Float.MIN_VALUE;
        int maxValueFreq = -1;
        float[] result = new float[signal.length / 2];
        for(int s = 0; s < result.length; s++) {
            //result[s] = Math.abs(signal[2*s]);
            float re = signal[s * 2];
            float im = signal[s * 2 + 1];
            result[s] = (float) Math.sqrt(re * re + im * im) / result.length;
            if(result[s] > localMax) {
                maxValueFreq = s;
            }
            localMax = Math.max(localMax, result[s]);
        }

        assertEquals(power, localMax, 0.001);
        assertEquals(signalFrequency, maxValueFreq);
    }

    private float[] getMinMax(float[] signal) {
        float localMin = Float.MAX_VALUE;
        float localMax = Float.MIN_VALUE;
        int maxVal = -1;
        int pos = 0;
        for(float val : signal) {
            if(val > localMax) {
                maxVal = pos;
            }
            localMin = Math.min(localMin, val);
            localMax = Math.max(localMax, val);
            pos++;
        }
        return new float[] {localMin, localMax, (float) maxVal};
    }
}

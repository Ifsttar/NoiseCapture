/*
 * This file is part of the NoiseCapture application and OnoMap system.
 *
 * The 'OnoMaP' system is led by Lab-STICC and Ifsttar and generates noise maps via
 * citizen-contributed noise data.
 *
 * This application is co-funded by the ENERGIC-OD Project (European Network for
 * Redistributing Geospatial Information to user Communities - Open Data). ENERGIC-OD
 * (http://www.energic-od.eu/) is partially funded under the ICT Policy Support Programme (ICT
 * PSP) as part of the Competitiveness and Innovation Framework Programme by the European
 * Community. The application work is also supported by the French geographic portal GEOPAL of the
 * Pays de la Loire region (http://www.geopal.org).
 *
 * Copyright (C) IFSTTAR - LAE and Lab-STICC – CNRS UMR 6285 Equipe DECIDE Vannes
 *
 * NoiseCapture is a free software; you can redistribute it and/or modify it under the terms of the
 * GNU General Public License as published by the Free Software Foundation; either version 3 of
 * the License, or(at your option) any later version. NoiseCapture is distributed in the hope that
 * it will be useful,but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
 * more details.You should have received a copy of the GNU General Public License along with this
 * program; if not, write to the Free Software Foundation,Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301  USA or see For more information,  write to Ifsttar,
 * 14-20 Boulevard Newton Cite Descartes, Champs sur Marne F-77447 Marne la Vallee Cedex 2 FRANCE
 *  or write to scientific.computing@ifsttar.fr
 */

package org.noise_planet.noisecapture;

import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.ServiceConnection;
import android.content.SharedPreferences;
import android.os.Handler;
import android.os.Bundle;
import android.os.IBinder;
import android.os.Looper;
import android.os.Message;
import android.os.SystemClock;
import android.preference.PreferenceManager;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import org.orbisgis.sos.LeqStats;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.beans.PropertyChangeEvent;
import java.beans.PropertyChangeListener;
import java.util.Locale;
import java.util.concurrent.atomic.AtomicLong;


public class CalibrationActivity extends MainActivity implements PropertyChangeListener, SharedPreferences.OnSharedPreferenceChangeListener {
    private enum CALIBRATION_STEP {IDLE, WARMUP, CALIBRATION, END}
    private ProgressBar progressBar_wait_calibration_recording;
    private Button startButton;
    private Button applyButton;
    private Button resetButton;
    private CALIBRATION_STEP calibration_step = CALIBRATION_STEP.IDLE;
    private TextView textStatus;
    private TextView textDeviceLevel;
    private EditText userInput;
    private Handler timeHandler;
    private int defaultWarmupTime;
    private int defaultCalibrationTime;
    private LeqStats leqStats;
    private boolean mIsBound = false;
    private MeasurementService measurementService;
    private static final Logger LOGGER = LoggerFactory.getLogger(CalibrationActivity.class);
    private static final int COUNTDOWN_STEP_MILLISECOND = 125;
    private ProgressHandler progressHandler = new ProgressHandler(this);

    private static final String SETTINGS_CALIBRATION_WARMUP_TIME = "settings_calibration_warmup_time";
    private static final String SETTINGS_CALIBRATION_TIME = "settings_calibration_time";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        initDrawer();
        setContentView(R.layout.activity_activity_calibration_start);
        SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(this);
        sharedPref.registerOnSharedPreferenceChangeListener(this);
        defaultCalibrationTime = Integer.valueOf(sharedPref.getString(SETTINGS_CALIBRATION_TIME, "10"));
        defaultWarmupTime = Integer.valueOf(sharedPref.getString(SETTINGS_CALIBRATION_WARMUP_TIME, "5"));

        progressBar_wait_calibration_recording = (ProgressBar) findViewById(R.id.progressBar_wait_calibration_recording);
        applyButton = (Button) findViewById(R.id.btn_apply);
        textStatus = (TextView) findViewById(R.id.textView_recording_state);
        textDeviceLevel = (TextView) findViewById(R.id.textView_value_SL_i);
        startButton = (Button) findViewById(R.id.btn_start);
        resetButton = (Button) findViewById(R.id.btn_reset);
        userInput = (EditText) findViewById(R.id.edit_text_external_measured);
        startButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onCalibrationStart();
            }
        });
        resetButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                onReset();
            }
        });


        initCalibration();
    }

    @Override
    public void onSharedPreferenceChanged(SharedPreferences sharedPreferences, String key) {
        if(SETTINGS_CALIBRATION_TIME.equals(key)) {
            defaultCalibrationTime = Integer.valueOf(sharedPreferences.getString(SETTINGS_CALIBRATION_TIME, "10"));
        } else if(SETTINGS_CALIBRATION_WARMUP_TIME.equals(key)) {
            defaultWarmupTime = Integer.valueOf(sharedPreferences.getString(SETTINGS_CALIBRATION_WARMUP_TIME, "5"));
        }
    }

    private void initCalibration() {
        textStatus.setText(R.string.calibration_status_waiting_for_user_start);
        progressBar_wait_calibration_recording.setProgress(progressBar_wait_calibration_recording.getMax());
        userInput.setText("");
        userInput.setEnabled(false);
        textDeviceLevel.setText(R.string.no_valid_dba_value);
        startButton.setEnabled(true);
        applyButton.setEnabled(false);
        resetButton.setEnabled(false);
    }

    private void onCalibrationStart() {
        textStatus.setText(R.string.calibration_status_waiting_for_start_timer);
        calibration_step = CALIBRATION_STEP.WARMUP;
        // Link measurement service with gui
        doBindService();
        startButton.setEnabled(false);
        timeHandler = new Handler(Looper.getMainLooper(), progressHandler);
        progressHandler.start(defaultWarmupTime * 1000);
    }

    @Override
    public void propertyChange(PropertyChangeEvent event) {
        if(calibration_step == CALIBRATION_STEP.CALIBRATION &&
                AudioProcess.PROP_DELAYED_STANDART_PROCESSING.equals(event.getPropertyName())) {
            // New leq
            AudioProcess.DelayedStandardAudioMeasure measure =
                    (AudioProcess.DelayedStandardAudioMeasure) event.getNewValue();
            leqStats.addLeq(measure.getGlobaldBaValue());
            runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    textDeviceLevel.setText(
                            String.format(Locale.getDefault(), "%.1f", leqStats.getLeqMean()));
                }
            });
        }
    }

    private ServiceConnection mConnection = new ServiceConnection() {
        public void onServiceConnected(ComponentName className, IBinder service) {
            measurementService = ((MeasurementService.LocalBinder)service).getService();
            measurementService.addPropertyChangeListener(CalibrationActivity.this);
            if(!measurementService.isRecording()) {
                measurementService.startRecording();
            }
        }

        public void onServiceDisconnected(ComponentName className) {
            // This is called when the connection with the service has been
            // unexpectedly disconnected -- that is, its process crashed.
            // Because it is running in our same process, we should never
            // see this happen.
            measurementService.removePropertyChangeListener(CalibrationActivity.this);
            measurementService = null;
        }
    };

    void doBindService() {
        // Establish a connection with the service.  We use an explicit
        // class name because we want a specific service implementation that
        // we know will be running in our own process (and thus won't be
        // supporting component replacement by other applications).
        if(!bindService(new Intent(this, MeasurementService.class), mConnection,
                Context.BIND_AUTO_CREATE)) {
            Toast.makeText(CalibrationActivity.this, R.string.measurement_service_disconnected,
                    Toast.LENGTH_SHORT).show();
        } else {
            mIsBound = true;
        }
    }

    public void onReset() {
        initCalibration();
    }

    void doUnbindService() {
        if (mIsBound) {
            measurementService.removePropertyChangeListener(this);
            // Detach our existing connection.
            unbindService(mConnection);
            mIsBound = false;
        }
    }


    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    private void onTimerEnd() {
        if(calibration_step == CALIBRATION_STEP.WARMUP) {
            calibration_step = CALIBRATION_STEP.CALIBRATION;
            textStatus.setText(R.string.calibration_status_on);
            // Start calibration
            leqStats = new LeqStats();
            progressHandler.start(defaultCalibrationTime * 1000);
        } else if(calibration_step == CALIBRATION_STEP.CALIBRATION) {
            calibration_step = CALIBRATION_STEP.END;
            textStatus.setText(R.string.calibration_status_end);
            measurementService.stopRecording();
            // Remove measurement service
            doUnbindService();
            // Activate user input
            applyButton.setEnabled(true);
            userInput.setText(String.format(Locale.getDefault(), "%.1f", leqStats.getLeqMean()));
            userInput.setEnabled(true);
            resetButton.setEnabled(true);
        }
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {
        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        //noinspection SimplifiableIfStatement
        if (id == R.id.action_settings) {
            return true;
        }

        return super.onOptionsItemSelected(item);
    }

    /**
     * Manage progress timer
     */
    private static final class ProgressHandler implements Handler.Callback {
        private CalibrationActivity activity;
        private int delay;
        private long beginTime;

        public ProgressHandler(CalibrationActivity activity) {
            this.activity = activity;
        }

        public void start(int delayMilliseconds) {
            delay = delayMilliseconds;
            beginTime = SystemClock.elapsedRealtime();
            activity.timeHandler.sendEmptyMessageDelayed(0, COUNTDOWN_STEP_MILLISECOND);
        }

        @Override
        public boolean handleMessage(Message msg) {
            long currentTime = SystemClock.elapsedRealtime();
            int newProg = (int)((((beginTime + delay) - currentTime) / (float)delay) *
                    activity.progressBar_wait_calibration_recording.getMax());
            activity.progressBar_wait_calibration_recording.setProgress(newProg);
            if(currentTime < beginTime + delay) {
                activity.timeHandler.sendEmptyMessageDelayed(0, COUNTDOWN_STEP_MILLISECOND);
            } else {
                activity.onTimerEnd();
            }
            return true;
        }
    }

}

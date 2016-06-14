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


import android.app.Activity;
import android.app.AlertDialog;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.preference.PreferenceManager;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBar;
import android.os.Bundle;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.Toast;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.IOException;


public class MainActivity extends AppCompatActivity {
    // Color for noise exposition representation
    public int[] NE_COLORS;
    protected static final Logger MAINLOGGER = LoggerFactory.getLogger(MainActivity.class);

    // For the list view
    public ListView mDrawerList;
    public DrawerLayout mDrawerLayout;
    public String[] mMenuLeft;
    public ActionBarDrawerToggle mDrawerToggle;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        Resources res = getResources();
        NE_COLORS = new int[]{res.getColor(R.color.R1_SL_level),
                res.getColor(R.color.R2_SL_level),
                res.getColor(R.color.R3_SL_level),
                res.getColor(R.color.R4_SL_level),
                res.getColor(R.color.R5_SL_level)};
    }

    void initDrawer(Integer recordId) {
        try {
            // List view
            mMenuLeft = getResources().getStringArray(R.array.dm_list_array);
            mDrawerLayout = (DrawerLayout) findViewById(R.id.drawer_layout);
            mDrawerList = (ListView) findViewById(R.id.left_drawer);
            // Set the adapter for the list view
            mDrawerList.setAdapter(new ArrayAdapter<String>(this,
                    R.layout.drawer_list_item, mMenuLeft));
            // Set the list's click listener
            mDrawerList.setOnItemClickListener(new DrawerItemClickListener(recordId));
            // Display the List view into the action bar
            mDrawerToggle = new ActionBarDrawerToggle(
                    this,                  /* host Activity */
                    mDrawerLayout,         /* DrawerLayout object */
                    R.string.drawer_open,  /* "open drawer" description */
                    R.string.drawer_close  /* "close drawer" description */
            ) {
                /**
                 * Called when a drawer has settled in a completely closed state.
                 */
                public void onDrawerClosed(View view) {
                    super.onDrawerClosed(view);
                    getSupportActionBar().setTitle(getTitle());
                }

                /**
                 * Called when a drawer has settled in a completely open state.
                 */
                public void onDrawerOpened(View drawerView) {
                    super.onDrawerOpened(drawerView);
                    getSupportActionBar().setTitle(getString(R.string.title_menu));
                }
            };
            // Set the drawer toggle as the DrawerListener
            mDrawerLayout.setDrawerListener(mDrawerToggle);
            getSupportActionBar().setDisplayHomeAsUpEnabled(true);
            getSupportActionBar().setHomeButtonEnabled(true);

        } catch (Exception e) {
            // TODO Auto-generated catch block
            e.printStackTrace();
            e.printStackTrace();
            e.printStackTrace();
        }
    }
    // Drawer navigation
    void initDrawer() {
        initDrawer(null);
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }

    @Override
    public void onBackPressed() {
        if(!(this instanceof Measurement)) {
            Intent im = new Intent(getApplicationContext(),Measurement.class);
            mDrawerLayout.closeDrawer(mDrawerList);
            startActivity(im);
            finish();
        } else {
            super.onBackPressed();
        }
    }

    private class DrawerItemClickListener implements ListView.OnItemClickListener {

        Integer recordId;

        public DrawerItemClickListener(Integer recordId) {
            this.recordId = recordId;
        }

        public void onItemClick(AdapterView<?> parent, View view, int position, long id) {

            switch(position) {
                case 0:
                    // Measurement
                    Intent im = new Intent(getApplicationContext(),Measurement.class);
                    mDrawerLayout.closeDrawer(mDrawerList);
                    startActivity(im);
                    finish();
                    break;
                case 1:
                    // Comment
                    Intent ir = new Intent(getApplicationContext(), CommentActivity.class);
                    if(recordId != null) {
                        ir.putExtra(CommentActivity.COMMENT_RECORD_ID, recordId);
                    }
                    mDrawerLayout.closeDrawer(mDrawerList);
                    startActivity(ir);
                    finish();
                    break;
                case 2:
                    // Results
                    ir = new Intent(getApplicationContext(), Results.class);
                    if(recordId != null) {
                        ir.putExtra(Results.RESULTS_RECORD_ID, recordId);
                    }
                    mDrawerLayout.closeDrawer(mDrawerList);
                    startActivity(ir);
                    finish();
                    break;
                case 3:
                    // History
                    Intent a = new Intent(getApplicationContext(), History.class);
                    startActivity(a);
                    finish();
                    mDrawerLayout.closeDrawer(mDrawerList);
                    break;
                case 4:
                    // Show the map if data transfer settings is true
                    // TODO: Check also if data transfer using wifi
                    if (CheckDataTransfer()) {
                        Intent imap = new Intent(getApplicationContext(), MapActivity.class);
                        //mDrawerLayout.closeDrawer(mDrawerList);
                        startActivity(imap);
                        finish();
                    }
                    else {
                        DialogBoxDataTransfer();
                    }
                    mDrawerLayout.closeDrawer(mDrawerList);
                    break;
                case 5:
                    Intent ics = new Intent(getApplicationContext(), activity_calibration_start.class);
                    mDrawerLayout.closeDrawer(mDrawerList);
                    startActivity(ics);
                    finish();
                    break;
                case 6:
                    Intent ih = new Intent(getApplicationContext(),View_html_page.class);
                    mDrawerLayout.closeDrawer(mDrawerList);
                    ih.putExtra(this.getClass().getPackage().getName() + ".pagetosee",
                            getString(R.string.url_help));
                    ih.putExtra(this.getClass().getPackage().getName() + ".titletosee",
                            getString(R.string.title_activity_help));
                    startActivity(ih);
                    finish();
                    break;
                case 7:
                    Intent ia = new Intent(getApplicationContext(),View_html_page.class);
                    ia.putExtra(this.getClass().getPackage().getName() + ".pagetosee",
                            getString(R.string.url_about));
                    ia.putExtra(this.getClass().getPackage().getName() + ".titletosee",
                            getString(R.string.title_activity_about));
                    mDrawerLayout.closeDrawer(mDrawerList);
                    startActivity(ia);
                    finish();
                    break;
                default:
                    break;
            }
        }
    }

    @Override
    public void setTitle(CharSequence title) {
        CharSequence mTitle = title;
        ActionBar actionBar = getSupportActionBar();
        if(actionBar != null) {
            actionBar.setTitle(mTitle);
        }
    }

    @Override
    public void onPostCreate(Bundle savedInstanceState) {
        super.onPostCreate(savedInstanceState);
        // Sync the toggle state after onRestoreInstanceState has occurred.
        if(mDrawerToggle != null) {
            mDrawerToggle.syncState();
        }
    }

    @Override
    public void onConfigurationChanged(Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        mDrawerToggle.onConfigurationChanged(newConfig);
    }

    @Override
    public boolean onOptionsItemSelected(MenuItem item) {

        mDrawerLayout.closeDrawers();

        // Pass the event to ActionBarDrawerToggle, if it returns
        // true, then it has handled the app icon touch event
        if (mDrawerToggle.onOptionsItemSelected(item)) {
            return true;
        }

        // Handle action bar item clicks here. The action bar will
        // automatically handle clicks on the Home/Up button, so long
        // as you specify a parent activity in AndroidManifest.xml.
        int id = item.getItemId();

        // Handle presses on the action bar items
        switch (item.getItemId()) {
            case R.id.action_settings:
                Intent is = new Intent(getApplicationContext(),Settings.class);
                startActivity(is);
            return true;
            /*
            case R.id.action_about:
                Intent ia = new Intent(getApplicationContext(),View_html_page.class);
                pagetosee=getString(R.string.url_about);
                titletosee=getString((R.string.title_activity_about));
                startActivity(ia);
                return true;
                */
            default:
                return super.onOptionsItemSelected(item);
        }

    }

    private boolean CheckDataTransfer() {
        SharedPreferences sharedPref = PreferenceManager.getDefaultSharedPreferences(this);
        Boolean DataTransfer = sharedPref.getBoolean("settings_data_transfer", true);
        return DataTransfer;
    }

    // Dialog box for activating data transfer
    public boolean DialogBoxDataTransfer() {
           new AlertDialog.Builder(this)
                .setTitle(R.string.title_caution_data_transfer)
                .setMessage(R.string.text_caution_data_transfer)
                .setPositiveButton(R.string.text_OK_data_transfer, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        // Goto to the settings page
                        Intent is = new Intent(getApplicationContext(),Settings.class);
                        startActivity(is);
                    }
                })
                .setNegativeButton(R.string.text_CANCEL_data_transfer, new DialogInterface.OnClickListener() {
                    public void onClick(DialogInterface dialog, int which) {
                        // Nothing is done
                    }
                })
                .setIcon(android.R.drawable.ic_dialog_alert)
                .show();
        return true;
    }

    public static final class SendZipToServer implements Runnable {
        private Activity activity;
        private int recordId;
        private ProgressDialog progress;
        private final OnUploadedListener listener;

        public SendZipToServer(Activity activity, int recordId, ProgressDialog progress, OnUploadedListener listener) {
            this.activity = activity;
            this.recordId = recordId;
            this.progress = progress;
            this.listener = listener;
        }

        @Override
        public void run() {
            MeasurementUploadWPS measurementUploadWPS = new MeasurementUploadWPS(activity);
            try {
                measurementUploadWPS.uploadRecord(recordId);
                if(listener != null) {
                    activity.runOnUiThread(new Runnable() {
                        @Override
                        public void run() {
                            listener.onMeasurementUploaded();
                        }
                    });
                }
            } catch (final IOException ex) {
                MAINLOGGER.error(ex.getLocalizedMessage(), ex);
                activity.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Toast.makeText(activity,
                                ex.getLocalizedMessage(), Toast.LENGTH_LONG).show();
                    }
                });
            } finally {
                progress.dismiss();
            }
        }
    }

    public interface OnUploadedListener {
        void onMeasurementUploaded();
    }
    // Choose color category in function of sound level
    public static int getNEcatColors(double SL) {

        int NbNEcat;

        if (SL > 75.) {
            NbNEcat = 0;
        } else if ((SL <= 75) & (SL > 65)) {
            NbNEcat = 1;
        } else if ((SL <= 65) & (SL > 55)) {
            NbNEcat = 2;
        } else if ((SL <= 55) & (SL > 45)) {
            NbNEcat = 3;
        } else {
            NbNEcat = 4;
        }
        return NbNEcat;
    }

}

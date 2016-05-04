package org.noise_planet.noisecapture;

import android.os.Bundle;
import android.view.Menu;
import android.webkit.WebView;


public class View_html_page extends MainActivity {

    @Override
    public void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_view_html_page);
        initDrawer();
        WebView myWebView = (WebView) findViewById(R.id.webview);
        myWebView.loadUrl(savedInstanceState.getString(this.getClass().getPackage().getName()
                + ".pagetosee"));
        getSupportActionBar().setTitle(this.getClass().getPackage().getName() + ".titletosee");

    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.menu_main, menu);
        return true;
    }
}

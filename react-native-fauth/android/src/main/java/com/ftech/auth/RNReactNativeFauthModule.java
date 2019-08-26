package com.ftech.auth;

import android.app.Activity;
import android.content.Intent;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.ReadableArray;
import com.ftech.auth.LoginActivity;

import java.util.ArrayList;

import javax.annotation.Nonnull;

public class RNReactNativeFauthModule extends ReactContextBaseJavaModule {
    public static final int REQUEST_CODE = 10;

    public RNReactNativeFauthModule(@Nonnull ReactApplicationContext reactContext) {
        super(reactContext);
    }

    @Nonnull
    @Override
    public String getName() {
        return "RNReactNativeFauthModule";
    }

    @ReactMethod
    public void showAuthenVC(ReadableArray readableArray) {
        Activity activity = getCurrentActivity();
        if (activity != null) {
            activity.startActivityForResult(
                    new Intent(activity, LoginActivity.class)
                            .putExtra("config", convertToArray(readableArray)),
                    REQUEST_CODE
            );
        }
    }

    private String[] convertToArray(ReadableArray readableArray) {
        ArrayList<String> arrayList = new ArrayList<>();
        for (int i = 0; i < readableArray.size(); i++)
            arrayList.add(readableArray.getString(i));
        return arrayList.toArray(new String[0]);
    }

}

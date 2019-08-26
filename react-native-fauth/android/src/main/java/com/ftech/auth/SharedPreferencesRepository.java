package com.ftech.auth;

import android.content.Context;
import android.preference.PreferenceManager;

import net.openid.appauth.AuthState;

import org.json.JSONException;

class SharedPreferencesRepository {

    private Context mContext;

    SharedPreferencesRepository(Context context) {
        mContext = context;
    }

    void saveAuthState(AuthState authState) {
        PreferenceManager.getDefaultSharedPreferences(mContext).edit()
                .putString("AuthState", authState.jsonSerializeString()).apply();
    }

    AuthState getAuthState() {
        String authStateString = PreferenceManager.getDefaultSharedPreferences(mContext)
                .getString("AuthState", null);
        if (authStateString != null) {
            try {
                return AuthState.jsonDeserialize(authStateString);
            } catch (JSONException e) {
                e.printStackTrace();
                return null;
            }
        }
        return null;
    }
}

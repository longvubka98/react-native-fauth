package com.ftech.auth;

import android.content.Context;
import android.net.Uri;
import android.util.Log;

import net.openid.appauth.AppAuthConfiguration;
import net.openid.appauth.AuthState;
import net.openid.appauth.AuthorizationException;
import net.openid.appauth.AuthorizationResponse;
import net.openid.appauth.AuthorizationService;
import net.openid.appauth.AuthorizationServiceConfiguration;
import net.openid.appauth.TokenResponse;

class AuthManager {

    private static AuthManager instance;
    private AuthState mAuthState;
    private Auth mAuth;
    private AuthorizationServiceConfiguration mAuthConfig;
    private SharedPreferencesRepository mSharedPrefRep;
    private AuthorizationService mAuthService;

    static AuthManager getInstance(Context context, String[] config) {
        if (instance == null) {
            instance = new AuthManager(context, config);
        }
        return instance;
    }

    private AuthManager(Context context, String[] config) {
        Log.d("AuthManager", "constructor");
        mSharedPrefRep = new SharedPreferencesRepository(context);
        setAuth(config);

        mAuthConfig = new AuthorizationServiceConfiguration(
                Uri.parse(mAuth.getAuthorizationEndpointUri()),
                Uri.parse(mAuth.getTokenEndpointUri()),
                null);
        mAuthState = mSharedPrefRep.getAuthState();

        AppAuthConfiguration.Builder appAuthConfigBuilder = new AppAuthConfiguration.Builder();

        //To Allow Http in requests in debug mode
        if (BuildConfig.DEBUG)
            appAuthConfigBuilder.setConnectionBuilder(AppAuthConnectionBuilderForTesting.INSTANCE);

        mAuthService = new AuthorizationService(context, appAuthConfigBuilder.build());
    }

    AuthorizationServiceConfiguration getAuthConfig() {
        return mAuthConfig;
    }

    Auth getAuth() {
//        if (mAuth == null)
//            setAuth();
        return mAuth;
    }

    AuthState getAuthState() {
        return mAuthState;
    }

    void updateAuthState(TokenResponse response, AuthorizationException ex) {
        mAuthState.update(response, ex);
        mSharedPrefRep.saveAuthState(mAuthState);
    }

    void setAuthState(AuthorizationResponse response, AuthorizationException ex) {
        if (mAuthState == null)
            mAuthState = new AuthState(response, ex);

        mSharedPrefRep.saveAuthState(mAuthState);
    }

    AuthorizationService getAuthService() {
        return mAuthService;
    }

    private void setAuth(String[] config) {
        mAuth = new Auth();
        if (config != null) {
            mAuth.setResponseType("code");
            mAuth.setClientId(config[1]);
            mAuth.setRedirectUri(config[2]);
            mAuth.setClientSecret(config[3]);
            mAuth.setScope(config[4]);
            mAuth.setAuthorizationEndpointUri(config[5]);
            mAuth.setTokenEndpointUri(config[6]);
        }
    }
}

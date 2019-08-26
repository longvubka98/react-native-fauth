package com.ftech.auth;

import android.content.Intent;
import android.net.Uri;
import android.os.Bundle;

import android.support.annotation.Nullable;
import android.support.v7.app.AppCompatActivity;

import net.openid.appauth.AuthState;
import net.openid.appauth.AuthorizationException;
import net.openid.appauth.AuthorizationRequest;
import net.openid.appauth.AuthorizationResponse;
import net.openid.appauth.ClientSecretPost;

public class LoginActivity extends AppCompatActivity {

    private final int REQUEST_CODE = 100;
    private AuthManager authManager;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        authManager = AuthManager.getInstance(this, getIntent().getStringArrayExtra("config"));
        AuthState authState = authManager.getAuthState();
        if (authState != null)
            if (authState.isAuthorized()) {
                setResult("");
                return;
            }

        login();
    }

    private void login() {
        Auth auth = authManager.getAuth();
        AuthorizationRequest authRequest = new AuthorizationRequest.Builder(
                authManager.getAuthConfig(),
                auth.getClientId(),
                auth.getResponseType(),
                Uri.parse(auth.getRedirectUri()))
                .setScope(auth.getScope())
                .build();

        Intent intent = authManager.getAuthService().getAuthorizationRequestIntent(authRequest);
        startActivityForResult(intent, REQUEST_CODE);
    }

    @Override
    protected void onActivityResult(int requestCode, int resultCode, @Nullable Intent data) {
        super.onActivityResult(requestCode, resultCode, data);

        if (resultCode == RESULT_OK && requestCode == REQUEST_CODE) {
            final AuthorizationResponse resp = AuthorizationResponse.fromIntent(data);
            AuthorizationException exception = AuthorizationException.fromIntent(data);

            final AuthManager authManager = AuthManager.getInstance(this, null);
            authManager.setAuthState(resp, exception);

            if (resp != null) {
                authManager.getAuthService().performTokenRequest(
                        resp.createTokenExchangeRequest(),
                        new ClientSecretPost(authManager.getAuth().getClientSecret()),
                        (response, ex) -> {
                            if (ex == null) {
                                authManager.updateAuthState(response, ex);
                                setResult(response.jsonSerializeString());
                            } else {
                                setResult("");
                            }
                        });
            } else {
                setResult("");
            }
        }
    }

    public void setResult(String response) {
        Intent resultIntent = new Intent()
                .putExtra("success", true)
                .putExtra("json", response);
        setResult(RESULT_OK, resultIntent);
        finish();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (authManager.getAuthService() != null) {
            authManager.getAuthService().dispose();
        }
    }

}

package com.ftech.auth;

class Auth {

    private String clientId;
    private String clientSecret;
    private String redirectUri;
    private String scope;
    private String authorizationEndpointUri;
    private String tokenEndpointUri;
    private String responseType;

    // all get, set:

    String getClientId() {
        return clientId;
    }

    void setClientId(String clientId) {
        this.clientId = clientId;
    }

    String getRedirectUri() {
        return redirectUri;
    }

    void setRedirectUri(String redirectUri) {
        this.redirectUri = redirectUri;
    }

    String getScope() {
        return scope;
    }

    void setScope(String scope) {
        this.scope = scope;
    }

    String getAuthorizationEndpointUri() {
        return authorizationEndpointUri;
    }

    void setAuthorizationEndpointUri(String authorizationEndpointUri) {
        this.authorizationEndpointUri = authorizationEndpointUri;
    }

    String getTokenEndpointUri() {
        return tokenEndpointUri;
    }

    void setTokenEndpointUri(String tokenEndpointUri) {
        this.tokenEndpointUri = tokenEndpointUri;
    }

    String getResponseType() {
        return responseType;
    }

    void setResponseType(String responseType) {
        this.responseType = responseType;
    }

    String getClientSecret() {
        return clientSecret;
    }

    void setClientSecret(String clientSecret) {
        this.clientSecret = clientSecret;
    }
}

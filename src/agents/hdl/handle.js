/**
 * @import {default as HandleHttpApiDeclaration} from "./handle.d.ts"
 * @implements {HandleHttpApiDeclaration}
 */
export default class HandleHttpApi {
    constructor(authInfo, serverUrl, verbose) {
        this.authInfo = authInfo;
        this.serverUrl = serverUrl;
        this.verbose = verbose;
        this.sessionId = null;
    }

    async authenticate() {
        const authResult = await this.startSession();
        if (!authResult.authenticated) {
            this.sessionId = null;
            if (this.verbose) console.log(authResult);
            throw new Error(authResult.error);
        }
        if (this.verbose) console.log(`Authenticated, sessionId: ${authResult.sessionId}`);
        this.sessionId = authResult.sessionId;
        return authResult;
    }

    setAuthInfo(authInfo) {
        this.authInfo = authInfo;
        this.sessionId = null;
    }

    async startSession() {
        if (this.authInfo.mode !== "HS_PUBKEY") {
            throw new Error(`${this.authInfo.mode} not supported`);
        }
        const url = `${this.serverUrl}/api/sessions`;
        const response = await this.sendHttpRequest("POST", url, null, null);
        if (this.verbose) console.log(response);
        const serverNonceString = response.nonce;
        this.sessionId = response.sessionId;
        const serverNonceBytes = HandleHttpApi.toUint8Array(serverNonceString);
        const clientNonceBytes = HandleHttpApi.generateClientNonceBytes();
        const clientNonceString = HandleHttpApi.toBase64String(clientNonceBytes);
        const combinedNonceBytes = HandleHttpApi.concatBytes(serverNonceBytes, clientNonceBytes);
        let signatureString = null;
        if (this.authInfo.privateKey.kty !== "RSA") {
            throw new Error(`Key type ${this.authInfo.privateKey.kty} is not supported by this client`);
        } else {
            signatureString = await HandleHttpApi.signRsaSha256(this.authInfo.privateKey, combinedNonceBytes);
        }
        const authResult = await this.sendAuthentication(clientNonceString, signatureString, "HS_PUBKEY");
        if (this.verbose) console.log(authResult);
        return authResult;
    }

    async sendHttpRequest(method, url, data, authorizationHeaderString) {
        if (this.verbose) console.log(`Sending ${method}: ${url}`);
        /** @type {Record<string,string>} */
        const headers = {};
        if (authorizationHeaderString) {
            headers['Authorization'] = authorizationHeaderString;
        }
        const request = {
            method,
            headers
        };
        if (data) {
            headers['Content-Type'] = 'application/json';
            request.body = JSON.stringify(data);
        }
        if (this.verbose) console.log(JSON.stringify(request));
        const response = await fetch(url, request);
        if (response.status === 401) {
            throw new Error("401 Unauthorized");
        }
        // TODO should other non-success responses throw error?
        const responseText = await response.text();
        if (!responseText) return undefined;
        return JSON.parse(responseText);
    }

    async sendHttpRequestWithAuthAndRetry(method, url, data) {
        if (!this.sessionId) {
            await this.authenticate();
        }
        try {
            const authorizationHeaderString = this.generateExistingSessionAuthorizationString();
            return await this.sendHttpRequest(method, url, data, authorizationHeaderString);
        } catch (error) {
            await this.authenticate();
            const authorizationHeaderString = this.generateExistingSessionAuthorizationString();
            return this.sendHttpRequest(method, url, data, authorizationHeaderString);
        }
    }

    async sendHttpRequestWithAuthIfPresent(method, url, data) {
        if (this.authInfo) {
            return await this.sendHttpRequestWithAuthAndRetry(method, url, data)
        } else {
            return await this.sendHttpRequest(method, url, data, null);
        }
    }

    async sendAuthentication(clientNonceString, signatureString, type) {
        const authorizationHeaderString = this.generateAuthorizationString(clientNonceString, signatureString, type);
        const url = `${this.serverUrl}/api/sessions/this`;
        const data = await this.sendHttpRequest("POST", url, null, authorizationHeaderString);
        return data;
    }

    generateAuthorizationString(clientNonceString, signatureString, type) {
        const id = `${this.authInfo.adminIndex}:${encodeURIComponent(this.authInfo.adminHandle)}`;
        return `Handle sessionId="${this.sessionId}", id="${id}", type="${type}", cnonce="${clientNonceString}", alg="SHA256", signature="${signatureString}"`;
    }

    generateExistingSessionAuthorizationString() {
        return `Handle sessionId="${this.sessionId}"`;
    }

    static async signRsaSha256(privateKey, bytes) {
        const key = await crypto.subtle.importKey(
            'jwk',
            privateKey,
            {
                name: 'RSASSA-PKCS1-v1_5',
                hash: 'SHA-256'
            },
            false,
            ['sign']
        );
        const signatureArrayBuffer = await crypto.subtle.sign('RSASSA-PKCS1-v1_5', key, bytes);
        const signatureUint8Array = new Uint8Array(signatureArrayBuffer);
        const base64Signature = HandleHttpApi.toBase64String(signatureUint8Array);
        return base64Signature;
    }

    static toBase64String(byteArray) {
        const binaryString = Array.from(byteArray, byte => String.fromCharCode(byte)).join('');
        const base64String = btoa(binaryString);
        return base64String;
    }

    static toUint8Array(base64String) {
        return new Uint8Array(atob(base64String).split('').map(c => c.charCodeAt(0)));
    }

    static concatBytes(a, b) {
        const result = new Uint8Array(a.length + b.length);
        result.set(a, 0);
        result.set(b, a.length);
        return result;
    }

    static generateClientNonceBytes() {
        const array = new Uint8Array(16);
        crypto.getRandomValues(array);
        return array;
    }

    async createHandle(handle, values) {
        return this.createOrUpdateHandle(handle, values, false);
    }

    async updateHandle(handle, values) {
        return this.createOrUpdateHandle(handle, values, true);
    }

    async deleteHandle(handle) {
        let url = `${this.serverUrl}/api/handles/${encodeURIComponent(handle)}`;
        const result = this.sendHttpRequestWithAuthAndRetry("DELETE", url, null);
        return result;
    }

    async updateUrl(handle, newUrlValue, index) {
        const handleRecord = {
            handle,
            values: [
                {
                    index,
                    type: "URL",
                    data: {
                        format: "string",
                        value: newUrlValue
                    }
                }
            ]
        };
        const url = `${this.serverUrl}/api/handles/${encodeURIComponent(handle)}?index=${index}`;
        const result = this.sendHttpRequestWithAuthAndRetry("PUT", url, handleRecord);
        return result;
    }

    static toPrefixHandle(handle) {
        return "0.NA/" + handle.split('/')[0];
    }

    async createUrlHandle(handle, newUrlValue) {
        const values = this.newUrlHandleValues(handle, newUrlValue);
        return this.createOrUpdateHandle(handle, values, false);
    }

    async createOrUpdateUrlHandle(handle, newUrlValue) {
        const values = this.newUrlHandleValues(handle, newUrlValue);
        return this.createOrUpdateHandle(handle, values, true);
    }

    newUrlHandleValues(handle, newUrlValue) {
        const values = [
            {
                index: 100,
                type: "HS_ADMIN",
                data: {
                    format: "admin",
                    value: {
                        handle: HandleHttpApi.toPrefixHandle(handle),
                        index: 200,
                        permissions: "011111110010"
                    }
                }
            },
            {
                index: 1,
                type: "URL",
                data: {
                    format: "string",
                    value: newUrlValue
                }
            }
        ];
        return values;
    }

    async createOrUpdateHandle(handle, values, overwrite) {
        let url = `${this.serverUrl}/api/handles/${encodeURIComponent(handle)}`;
        if (!overwrite) {
            url += "?overwrite=false";
        }
        const handleRecord = {
            handle,
            values
        };
        const result = this.sendHttpRequestWithAuthAndRetry("PUT", url, handleRecord);
        return result;
    }

    async getHandle(handle) {
        const url = `${this.serverUrl}/api/handles/${encodeURIComponent(handle)}`;
        const result = this.sendHttpRequestWithAuthIfPresent("GET", url, null);
        return result;
    }

    async getHandles(prefix) {
        const url = `${this.serverUrl}/api/handles?prefix=${encodeURIComponent(prefix)}`;
        const result = this.sendHttpRequestWithAuthAndRetry("GET", url, null);
        return result;
    }

    async getPrefixes() {
        const url = `${this.serverUrl}/api/prefixes`;
        const result = this.sendHttpRequestWithAuthAndRetry("GET", url, null);
        return result;
    }

    async homePrefix(prefix) {
        const url = `${this.serverUrl}/api/prefixes/${encodeURIComponent(prefix)}`;
        const result = this.sendHttpRequestWithAuthAndRetry("POST", url, null);
        return result;
    }

    async unhomePrefix(prefix) {
        const url = `${this.serverUrl}/api/prefixes/${encodeURIComponent(prefix)}`;
        const result = this.sendHttpRequestWithAuthAndRetry("DELETE", url, null);
        return result;
    }
}

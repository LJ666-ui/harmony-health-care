type AsyncCallback<T> = (err: Error | undefined, data: T) => void;

export namespace distributedDeviceManager {
  export interface DeviceManager {
    on(type: string, callback: Function): void;
    off(type: string, callback?: Function): void;
    getDeviceList(): DeviceInfo[];
    getTrustedDeviceList(): TrustedDeviceInfo[];
    authenticateDevice(deviceId: string, authParam: AuthParam, callback: AsyncCallback<AuthInfo>): void;
    unAuthenticateDevice(deviceId: string, callback: AsyncCallback<void>): void;
  }

  export interface DeviceInfo {
    deviceId: string;
    deviceName: string;
    deviceType: number;
  }

  export interface TrustedDeviceInfo {
    deviceId: string;
    deviceName: string;
    deviceType: number;
    networkId: string;
  }

  export interface AuthParam {
    extraInfo?: Record<string, Object>;
  }

  export interface AuthInfo {
    authToken: string;
  }

  export const createDeviceManager = (bundleName: string): DeviceManager | null => {
    return null;
  };
}

export namespace distributedKVStore {
  export enum SecurityLevel {
    S0 = 0,
    S1 = 1,
    S2 = 2,
    S3 = 3,
    S4 = 4
  }

  export type ValueType = string | number | boolean | Uint8Array;

  export interface Options {
    createIfMissing?: boolean;
    encrypt?: boolean;
    securityLevel?: SecurityLevel;
  }

  export interface KVStore {
    put(key: string, value: ValueType): Promise<void>;
    get(key: string): Promise<ValueType>;
    delete(key: string): Promise<void>;
    on(type: 'dataChange' | 'syncComplete', callback: Function): void;
    off(type: 'dataChange' | 'syncComplete', callback?: Function): void;
  }
}

export namespace cryptoFramework {
  export enum CipherMode {
    ECB = 0,
    CBC = 1,
    CTR = 2,
    OFB = 3,
    CFB = 4,
    GCM = 5
  }

  export enum CryptoPadding {
    NoPadding = 0,
    PKCS7 = 1
  }

  export enum CryptoMode {
    ENCRYPT_MODE = 0,
    DECRYPT_MODE = 1
  }

  export interface DataBlob {
    data: Uint8Array;
  }

  export interface SymKey {
    getEncoded(): Promise<DataBlob>;
  }

  export interface SymKeyGenerator {
    convertKey(data: DataBlob): Promise<SymKey>;
  }

  export interface Cipher {
    init(mode: CryptoMode, key: SymKey, params: CipherParams | null): Promise<void>;
    doFinal(data: DataBlob): Promise<DataBlob>;
  }

  export interface CipherParams {
    algName: string;
    mode: CipherMode;
    padding: CryptoPadding;
    iv?: DataBlob;
    aad?: DataBlob;
    authTag?: DataBlob;
    nonce?: DataBlob;
  }

  class MockDataBlob implements DataBlob {
    data: Uint8Array = new Uint8Array(0);
  }

  class MockSymKey implements SymKey {
    async getEncoded(): Promise<DataBlob> {
      return new MockDataBlob();
    }
  }

  class MockSymKeyGenerator implements SymKeyGenerator {
    async convertKey(data: DataBlob): Promise<SymKey> {
      return new MockSymKey();
    }
  }

  class MockCipher implements Cipher {
    async init(mode: CryptoMode, key: SymKey, params: CipherParams | null): Promise<void> {}
    async doFinal(data: DataBlob): Promise<DataBlob> {
      return new MockDataBlob();
    }
  }

  export const createSymKeyGenerator = (algName: string): SymKeyGenerator => {
    return new MockSymKeyGenerator();
  };

  export const createCipher = (params: CipherParams): Cipher => {
    return new MockCipher();
  };

  export const getRandomValues = (data: Uint8Array): void => {
    for (let i: number = 0; i < data.length; i++) {
      data[i] = Math.floor(Math.random() * 256);
    }
  };
}

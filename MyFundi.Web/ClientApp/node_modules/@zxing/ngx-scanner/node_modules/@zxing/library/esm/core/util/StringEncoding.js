import UnsupportedOperationException from '../UnsupportedOperationException';
import CharacterSetECI from '../common/CharacterSetECI';
/**
 * Responsible for en/decoding strings.
 */
export default class StringEncoding {
    /**
     * Decodes some Uint8Array to a string format.
     */
    static decode(bytes, encoding) {
        const encodingName = this.encodingName(encoding);
        // Increases browser support.
        if (typeof TextDecoder === 'undefined') {
            return this.decodeFallback(bytes, encodingName);
        }
        return new TextDecoder(encodingName).decode(bytes);
    }
    /**
     * Encodes some string into a Uint8Array.
     *
     * @todo natively support other string formats than UTF-8.
     */
    static encode(s, encoding) {
        // Uses `text-encoding` package.
        if (!StringEncoding.isBrowser()) {
            // SEE: https://nodejs.org/api/buffer.html#buffer_class_buffer
            // SEE: https://github.com/polygonplanet/encoding.js/
            // SEE: https://stackoverflow.com/questions/17191945/conversion-between-utf-8-arraybuffer-and-string
            const EncoderConstructor = TextEncoder;
            return new EncoderConstructor(this.encodingName(encoding), { NONSTANDARD_allowLegacyEncoding: true }).encode(s);
        }
        // Increases browser support.
        if (typeof TextEncoder === 'undefined') {
            return this.encodeFallback(s);
        }
        // TextEncoder only encodes to UTF8 by default as specified by encoding.spec.whatwg.org
        return new TextEncoder().encode(s);
    }
    static isBrowser() {
        return (typeof window !== 'undefined' && {}.toString.call(window) === '[object Window]');
    }
    /**
     * Returns the string value from some encoding character set.
     */
    static encodingName(encoding) {
        return typeof encoding === 'string'
            ? encoding
            : encoding.getName();
    }
    /**
     * Returns character set from some encoding character set.
     */
    static encodingCharacterSet(encoding) {
        return CharacterSetECI.getCharacterSetECIByName(this.encodingName(encoding));
    }
    /**
     * Runs a fallback for the native decoding funcion.
     */
    static decodeFallback(bytes, encoding) {
        const characterSet = this.encodingCharacterSet(encoding);
        if (characterSet.equals(CharacterSetECI.UTF8) ||
            characterSet.equals(CharacterSetECI.ISO8859_1) ||
            characterSet.equals(CharacterSetECI.ASCII)) {
            let s = '';
            for (let i = 0, length = bytes.length; i < length; i++) {
                let h = bytes[i].toString(16);
                if (h.length < 2) {
                    h = '0' + h;
                }
                s += '%' + h;
            }
            return decodeURIComponent(s);
        }
        if (characterSet.equals(CharacterSetECI.UnicodeBigUnmarked)) {
            return String.fromCharCode.apply(null, new Uint16Array(bytes.buffer));
        }
        throw new UnsupportedOperationException(`Encoding ${this.encodingName(encoding)} not supported by fallback.`);
    }
    /**
     * Runs a fallback for the native encoding funcion.
     *
     * @see https://stackoverflow.com/a/17192845/4367683
     */
    static encodeFallback(s) {
        const encodedURIstring = btoa(unescape(encodeURIComponent(s)));
        const charList = encodedURIstring.split('');
        const uintArray = [];
        for (let i = 0; i < charList.length; i++) {
            uintArray.push(charList[i].charCodeAt(0));
        }
        return new Uint8Array(uintArray);
    }
}
//# sourceMappingURL=StringEncoding.js.map
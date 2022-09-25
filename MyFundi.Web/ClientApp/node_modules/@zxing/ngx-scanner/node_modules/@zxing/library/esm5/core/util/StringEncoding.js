"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var UnsupportedOperationException_1 = require("../UnsupportedOperationException");
var CharacterSetECI_1 = require("../common/CharacterSetECI");
/**
 * Responsible for en/decoding strings.
 */
var StringEncoding = /** @class */ (function () {
    function StringEncoding() {
    }
    /**
     * Decodes some Uint8Array to a string format.
     */
    StringEncoding.decode = function (bytes, encoding) {
        var encodingName = this.encodingName(encoding);
        // Increases browser support.
        if (typeof TextDecoder === 'undefined') {
            return this.decodeFallback(bytes, encodingName);
        }
        return new TextDecoder(encodingName).decode(bytes);
    };
    /**
     * Encodes some string into a Uint8Array.
     *
     * @todo natively support other string formats than UTF-8.
     */
    StringEncoding.encode = function (s, encoding) {
        // Uses `text-encoding` package.
        if (!StringEncoding.isBrowser()) {
            // SEE: https://nodejs.org/api/buffer.html#buffer_class_buffer
            // SEE: https://github.com/polygonplanet/encoding.js/
            // SEE: https://stackoverflow.com/questions/17191945/conversion-between-utf-8-arraybuffer-and-string
            var EncoderConstructor = TextEncoder;
            return new EncoderConstructor(this.encodingName(encoding), { NONSTANDARD_allowLegacyEncoding: true }).encode(s);
        }
        // Increases browser support.
        if (typeof TextEncoder === 'undefined') {
            return this.encodeFallback(s);
        }
        // TextEncoder only encodes to UTF8 by default as specified by encoding.spec.whatwg.org
        return new TextEncoder().encode(s);
    };
    StringEncoding.isBrowser = function () {
        return (typeof window !== 'undefined' && {}.toString.call(window) === '[object Window]');
    };
    /**
     * Returns the string value from some encoding character set.
     */
    StringEncoding.encodingName = function (encoding) {
        return typeof encoding === 'string'
            ? encoding
            : encoding.getName();
    };
    /**
     * Returns character set from some encoding character set.
     */
    StringEncoding.encodingCharacterSet = function (encoding) {
        return CharacterSetECI_1.default.getCharacterSetECIByName(this.encodingName(encoding));
    };
    /**
     * Runs a fallback for the native decoding funcion.
     */
    StringEncoding.decodeFallback = function (bytes, encoding) {
        var characterSet = this.encodingCharacterSet(encoding);
        if (characterSet.equals(CharacterSetECI_1.default.UTF8) ||
            characterSet.equals(CharacterSetECI_1.default.ISO8859_1) ||
            characterSet.equals(CharacterSetECI_1.default.ASCII)) {
            var s = '';
            for (var i = 0, length_1 = bytes.length; i < length_1; i++) {
                var h = bytes[i].toString(16);
                if (h.length < 2) {
                    h = '0' + h;
                }
                s += '%' + h;
            }
            return decodeURIComponent(s);
        }
        if (characterSet.equals(CharacterSetECI_1.default.UnicodeBigUnmarked)) {
            return String.fromCharCode.apply(null, new Uint16Array(bytes.buffer));
        }
        throw new UnsupportedOperationException_1.default("Encoding " + this.encodingName(encoding) + " not supported by fallback.");
    };
    /**
     * Runs a fallback for the native encoding funcion.
     *
     * @see https://stackoverflow.com/a/17192845/4367683
     */
    StringEncoding.encodeFallback = function (s) {
        var encodedURIstring = btoa(unescape(encodeURIComponent(s)));
        var charList = encodedURIstring.split('');
        var uintArray = [];
        for (var i = 0; i < charList.length; i++) {
            uintArray.push(charList[i].charCodeAt(0));
        }
        return new Uint8Array(uintArray);
    };
    return StringEncoding;
}());
exports.default = StringEncoding;
//# sourceMappingURL=StringEncoding.js.map
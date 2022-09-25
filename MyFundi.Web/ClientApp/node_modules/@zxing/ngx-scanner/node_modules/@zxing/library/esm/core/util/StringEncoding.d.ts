import CharacterSetECI from '../common/CharacterSetECI';
/**
 * Responsible for en/decoding strings.
 */
export default class StringEncoding {
    /**
     * Decodes some Uint8Array to a string format.
     */
    static decode(bytes: Uint8Array, encoding: string | CharacterSetECI): string;
    /**
     * Encodes some string into a Uint8Array.
     *
     * @todo natively support other string formats than UTF-8.
     */
    static encode(s: string, encoding: string | CharacterSetECI): Uint8Array;
    private static isBrowser;
    /**
     * Returns the string value from some encoding character set.
     */
    static encodingName(encoding: string | CharacterSetECI): string;
    /**
     * Returns character set from some encoding character set.
     */
    static encodingCharacterSet(encoding: string | CharacterSetECI): CharacterSetECI;
    /**
     * Runs a fallback for the native decoding funcion.
     */
    private static decodeFallback;
    /**
     * Runs a fallback for the native encoding funcion.
     *
     * @see https://stackoverflow.com/a/17192845/4367683
     */
    private static encodeFallback;
}

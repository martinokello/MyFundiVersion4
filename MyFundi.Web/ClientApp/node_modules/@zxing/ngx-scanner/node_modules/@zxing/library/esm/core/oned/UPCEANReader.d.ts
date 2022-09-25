import BitArray from '../common/BitArray';
import DecodeHintType from '../DecodeHintType';
import Result from '../Result';
import OneDReader from './OneDReader';
/**
 * <p>Encapsulates functionality and implementation that is common to UPC and EAN families
 * of one-dimensional barcodes.</p>
 *
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Sean Owen
 * @author alasdair@google.com (Alasdair Mackintosh)
 */
export default abstract class UPCEANReader extends OneDReader {
    private static MAX_AVG_VARIANCE;
    private static MAX_INDIVIDUAL_VARIANCE;
    /**
     * Start/end guard pattern.
     */
    static START_END_PATTERN: number[];
    /**
     * Pattern marking the middle of a UPC/EAN pattern, separating the two halves.
     */
    static MIDDLE_PATTERN: number[];
    /**
     * end guard pattern.
     */
    static END_PATTERN: number[];
    /**
     * "Odd", or "L" patterns used to encode UPC/EAN digits.
     */
    static L_PATTERNS: number[][];
    /**
     * As above but also including the "even", or "G" patterns used to encode UPC/EAN digits.
     */
    static L_AND_G_PATTERNS: number[][];
    private decodeRowStringBuffer;
    constructor();
    static findStartGuardPattern(row: BitArray): number[];
    decodeRow(rowNumber: number, row: BitArray, hints?: Map<DecodeHintType, any>): Result;
    static checkChecksum(s: string): boolean;
    static checkStandardUPCEANChecksum(s: string): boolean;
    static getStandardUPCEANChecksum(s: string): number;
    static decodeEnd(row: BitArray, endStart: number): number[];
    static findGuardPattern(row: BitArray, rowOffset: number, whiteFirst: boolean, pattern: number[], counters: number[]): number[];
    static decodeDigit(row: BitArray, counters: number[], rowOffset: number, patterns: number[][]): number;
    /**
     * Get the format of this decoder.
     *
     * @return The 1D format.
     */
    abstract getBarcodeFormat(): any;
    /**
     * Subclasses override this to decode the portion of a barcode between the start
     * and end guard patterns.
     *
     * @param row row of black/white values to search
     * @param startRange start/end offset of start guard pattern
     * @param resultString {@link StringBuilder} to append decoded chars to
     * @return horizontal offset of first pixel after the "middle" that was decoded
     * @throws NotFoundException if decoding could not complete successfully
     */
    abstract decodeMiddle(row: BitArray, startRange: number[], resultString: string): any;
}

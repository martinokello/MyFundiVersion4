import BitArray from '../common/BitArray';
import Result from '../Result';
import ResultMetadataType from '../ResultMetadataType';
/**
 * @see UPCEANExtension2Support
 */
export default class UPCEANExtension5Support {
    private CHECK_DIGIT_ENCODINGS;
    private decodeMiddleCounters;
    private decodeRowStringBuffer;
    decodeRow(rowNumber: number, row: BitArray, extensionStartRange: number[]): Result;
    decodeMiddle(row: BitArray, startRange: number[], resultString: string): number;
    static extensionChecksum(s: string): number;
    determineCheckDigit(lgPatternFound: number): number;
    static parseExtensionString(raw: string): Map<ResultMetadataType, string>;
    static parseExtension5String(raw: string): string;
}

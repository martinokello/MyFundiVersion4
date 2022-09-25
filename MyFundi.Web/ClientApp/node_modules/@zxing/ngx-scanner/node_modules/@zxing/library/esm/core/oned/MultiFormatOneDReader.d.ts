import BitArray from '../common/BitArray';
import DecodeHintType from '../DecodeHintType';
import OneDReader from './OneDReader';
import Result from '../Result';
/**
 * @author Daniel Switkin <dswitkin@google.com>
 * @author Sean Owen
 */
export default class MultiFormatOneDReader extends OneDReader {
    private readers;
    constructor(hints: Map<DecodeHintType, any>);
    decodeRow(rowNumber: number, row: BitArray, hints: Map<DecodeHintType, any>): Result;
    reset(): void;
}

"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var IllegalArgumentException_1 = require("../../IllegalArgumentException");
/*
 * Copyright 2008 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/**
 * <p>Encapsulates a block of data within a Data Matrix Code. Data Matrix Codes may split their data into
 * multiple blocks, each of which is a unit of data and error-correction codewords. Each
 * is represented by an instance of this class.</p>
 *
 * @author bbrown@google.com (Brian Brown)
 */
var DataBlock = /** @class */ (function () {
    function DataBlock(numDataCodewords, codewords) {
        this.numDataCodewords = numDataCodewords;
        this.codewords = codewords;
    }
    /**
     * <p>When Data Matrix Codes use multiple data blocks, they actually interleave the bytes of each of them.
     * That is, the first byte of data block 1 to n is written, then the second bytes, and so on. This
     * method will separate the data into original blocks.</p>
     *
     * @param rawCodewords bytes as read directly from the Data Matrix Code
     * @param version version of the Data Matrix Code
     * @return DataBlocks containing original bytes, "de-interleaved" from representation in the
     *         Data Matrix Code
     */
    DataBlock.getDataBlocks = function (rawCodewords, version) {
        // Figure out the number and size of data blocks used by this version
        var ecBlocks = version.getECBlocks();
        // First count the total number of data blocks
        var totalBlocks = 0;
        var ecBlockArray = ecBlocks.getECBlocks();
        for (var _i = 0, ecBlockArray_1 = ecBlockArray; _i < ecBlockArray_1.length; _i++) {
            var ecBlock = ecBlockArray_1[_i];
            totalBlocks += ecBlock.getCount();
        }
        // Now establish DataBlocks of the appropriate size and number of data codewords
        var result = new Array(totalBlocks);
        var numResultBlocks = 0;
        for (var _a = 0, ecBlockArray_2 = ecBlockArray; _a < ecBlockArray_2.length; _a++) {
            var ecBlock = ecBlockArray_2[_a];
            for (var i = 0; i < ecBlock.getCount(); i++) {
                var numDataCodewords = ecBlock.getDataCodewords();
                var numBlockCodewords = ecBlocks.getECCodewords() + numDataCodewords;
                result[numResultBlocks++] = new DataBlock(numDataCodewords, new Uint8Array(numBlockCodewords));
            }
        }
        // All blocks have the same amount of data, except that the last n
        // (where n may be 0) have 1 less byte. Figure out where these start.
        // TODO(bbrown): There is only one case where there is a difference for Data Matrix for size 144
        var longerBlocksTotalCodewords = result[0].codewords.length;
        // int shorterBlocksTotalCodewords = longerBlocksTotalCodewords - 1;
        var longerBlocksNumDataCodewords = longerBlocksTotalCodewords - ecBlocks.getECCodewords();
        var shorterBlocksNumDataCodewords = longerBlocksNumDataCodewords - 1;
        // The last elements of result may be 1 element shorter for 144 matrix
        // first fill out as many elements as all of them have minus 1
        var rawCodewordsOffset = 0;
        for (var i = 0; i < shorterBlocksNumDataCodewords; i++) {
            for (var j = 0; j < numResultBlocks; j++) {
                result[j].codewords[i] = rawCodewords[rawCodewordsOffset++];
            }
        }
        // Fill out the last data block in the longer ones
        var specialVersion = version.getVersionNumber() === 24;
        var numLongerBlocks = specialVersion ? 8 : numResultBlocks;
        for (var j = 0; j < numLongerBlocks; j++) {
            result[j].codewords[longerBlocksNumDataCodewords - 1] = rawCodewords[rawCodewordsOffset++];
        }
        // Now add in error correction blocks
        var max = result[0].codewords.length;
        for (var i = longerBlocksNumDataCodewords; i < max; i++) {
            for (var j = 0; j < numResultBlocks; j++) {
                var jOffset = specialVersion ? (j + 8) % numResultBlocks : j;
                var iOffset = specialVersion && jOffset > 7 ? i - 1 : i;
                result[jOffset].codewords[iOffset] = rawCodewords[rawCodewordsOffset++];
            }
        }
        if (rawCodewordsOffset !== rawCodewords.length) {
            throw new IllegalArgumentException_1.default();
        }
        return result;
    };
    DataBlock.prototype.getNumDataCodewords = function () {
        return this.numDataCodewords;
    };
    DataBlock.prototype.getCodewords = function () {
        return this.codewords;
    };
    return DataBlock;
}());
exports.default = DataBlock;
//# sourceMappingURL=DataBlock.js.map
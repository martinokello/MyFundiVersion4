"use strict";
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
var __extends = (this && this.__extends) || (function () {
    var extendStatics = function (d, b) {
        extendStatics = Object.setPrototypeOf ||
            ({ __proto__: [] } instanceof Array && function (d, b) { d.__proto__ = b; }) ||
            function (d, b) { for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p]; };
        return extendStatics(d, b);
    };
    return function (d, b) {
        extendStatics(d, b);
        function __() { this.constructor = d; }
        d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
var BarcodeFormat_1 = require("../BarcodeFormat");
var DecodeHintType_1 = require("../DecodeHintType");
var Result_1 = require("../Result");
var ResultMetadataType_1 = require("../ResultMetadataType");
var ResultPoint_1 = require("../ResultPoint");
var OneDReader_1 = require("./OneDReader");
var UPCEANExtensionSupport_1 = require("./UPCEANExtensionSupport");
var NotFoundException_1 = require("../NotFoundException");
var FormatException_1 = require("../FormatException");
var ChecksumException_1 = require("../ChecksumException");
/**
 * <p>Encapsulates functionality and implementation that is common to UPC and EAN families
 * of one-dimensional barcodes.</p>
 *
 * @author dswitkin@google.com (Daniel Switkin)
 * @author Sean Owen
 * @author alasdair@google.com (Alasdair Mackintosh)
 */
var UPCEANReader = /** @class */ (function (_super) {
    __extends(UPCEANReader, _super);
    // private final UPCEANExtensionSupport extensionReader;
    // private final EANManufacturerOrgSupport eanManSupport;
    function UPCEANReader() {
        var _this = _super.call(this) || this;
        _this.decodeRowStringBuffer = '';
        _this.decodeRowStringBuffer = '';
        UPCEANReader.L_AND_G_PATTERNS = UPCEANReader.L_PATTERNS.map(function (arr) {
            return arr.slice();
        });
        for (var i = 10; i < 20; i++) {
            var widths = UPCEANReader.L_PATTERNS[i - 10];
            var reversedWidths = new Array(widths.length);
            for (var j = 0; j < widths.length; j++) {
                reversedWidths[j] = widths[widths.length - j - 1];
            }
            UPCEANReader.L_AND_G_PATTERNS[i] = reversedWidths;
        }
        return _this;
    }
    /*
    protected UPCEANReader() {
        decodeRowStringBuffer = new StringBuilder(20);
        extensionReader = new UPCEANExtensionSupport();
        eanManSupport = new EANManufacturerOrgSupport();
    }
    */
    UPCEANReader.findStartGuardPattern = function (row) {
        var foundStart = false;
        var startRange = null;
        var nextStart = 0;
        var counters = [0, 0, 0];
        while (!foundStart) {
            counters = [0, 0, 0];
            startRange = UPCEANReader.findGuardPattern(row, nextStart, false, this.START_END_PATTERN, counters);
            var start = startRange[0];
            nextStart = startRange[1];
            var quietStart = start - (nextStart - start);
            if (quietStart >= 0) {
                foundStart = row.isRange(quietStart, start, false);
            }
        }
        return startRange;
    };
    UPCEANReader.prototype.decodeRow = function (rowNumber, row, hints) {
        var startGuardRange = UPCEANReader.findStartGuardPattern(row);
        var resultPointCallback = hints == null ? null : hints.get(DecodeHintType_1.default.NEED_RESULT_POINT_CALLBACK);
        if (resultPointCallback != null) {
            var resultPoint_1 = new ResultPoint_1.default((startGuardRange[0] + startGuardRange[1]) / 2.0, rowNumber);
            resultPointCallback.foundPossibleResultPoint(resultPoint_1);
        }
        var budello = this.decodeMiddle(row, startGuardRange, this.decodeRowStringBuffer);
        var endStart = budello.rowOffset;
        var result = budello.resultString;
        if (resultPointCallback != null) {
            var resultPoint_2 = new ResultPoint_1.default(endStart, rowNumber);
            resultPointCallback.foundPossibleResultPoint(resultPoint_2);
        }
        var endRange = UPCEANReader.decodeEnd(row, endStart);
        if (resultPointCallback != null) {
            var resultPoint_3 = new ResultPoint_1.default((endRange[0] + endRange[1]) / 2.0, rowNumber);
            resultPointCallback.foundPossibleResultPoint(resultPoint_3);
        }
        // Make sure there is a quiet zone at least as big as the end pattern after the barcode. The
        // spec might want more whitespace, but in practice this is the maximum we can count on.
        var end = endRange[1];
        var quietEnd = end + (end - endRange[0]);
        if (quietEnd >= row.getSize() || !row.isRange(end, quietEnd, false)) {
            throw new NotFoundException_1.default();
        }
        var resultString = result.toString();
        // UPC/EAN should never be less than 8 chars anyway
        if (resultString.length < 8) {
            throw new FormatException_1.default();
        }
        if (!UPCEANReader.checkChecksum(resultString)) {
            throw new ChecksumException_1.default();
        }
        var left = (startGuardRange[1] + startGuardRange[0]) / 2.0;
        var right = (endRange[1] + endRange[0]) / 2.0;
        var format = this.getBarcodeFormat();
        var resultPoint = [new ResultPoint_1.default(left, rowNumber), new ResultPoint_1.default(right, rowNumber)];
        var decodeResult = new Result_1.default(resultString, null, 0, resultPoint, format, new Date().getTime());
        var extensionLength = 0;
        try {
            var extensionResult = UPCEANExtensionSupport_1.default.decodeRow(rowNumber, row, endRange[1]);
            decodeResult.putMetadata(ResultMetadataType_1.default.UPC_EAN_EXTENSION, extensionResult.getText());
            decodeResult.putAllMetadata(extensionResult.getResultMetadata());
            decodeResult.addResultPoints(extensionResult.getResultPoints());
            extensionLength = extensionResult.getText().length;
        }
        catch (err) {
        }
        var allowedExtensions = hints == null ? null : hints.get(DecodeHintType_1.default.ALLOWED_EAN_EXTENSIONS);
        if (allowedExtensions != null) {
            var valid = false;
            for (var length_1 in allowedExtensions) {
                if (extensionLength.toString() === length_1) { // check me
                    valid = true;
                    break;
                }
            }
            if (!valid) {
                throw new NotFoundException_1.default();
            }
        }
        if (format === BarcodeFormat_1.default.EAN_13 || format === BarcodeFormat_1.default.UPC_A) {
            // let countryID = eanManSupport.lookupContryIdentifier(resultString); todo
            // if (countryID != null) {
            //     decodeResult.putMetadata(ResultMetadataType.POSSIBLE_COUNTRY, countryID);
            // }
        }
        return decodeResult;
    };
    UPCEANReader.checkChecksum = function (s) {
        return UPCEANReader.checkStandardUPCEANChecksum(s);
    };
    UPCEANReader.checkStandardUPCEANChecksum = function (s) {
        var length = s.length;
        if (length === 0)
            return false;
        var check = parseInt(s.charAt(length - 1), 10);
        return UPCEANReader.getStandardUPCEANChecksum(s.substring(0, length - 1)) === check;
    };
    UPCEANReader.getStandardUPCEANChecksum = function (s) {
        var length = s.length;
        var sum = 0;
        for (var i = length - 1; i >= 0; i -= 2) {
            var digit = s.charAt(i).charCodeAt(0) - '0'.charCodeAt(0);
            if (digit < 0 || digit > 9) {
                throw new FormatException_1.default();
            }
            sum += digit;
        }
        sum *= 3;
        for (var i = length - 2; i >= 0; i -= 2) {
            var digit = s.charAt(i).charCodeAt(0) - '0'.charCodeAt(0);
            if (digit < 0 || digit > 9) {
                throw new FormatException_1.default();
            }
            sum += digit;
        }
        return (1000 - sum) % 10;
    };
    UPCEANReader.decodeEnd = function (row, endStart) {
        return UPCEANReader.findGuardPattern(row, endStart, false, UPCEANReader.START_END_PATTERN, new Array(UPCEANReader.START_END_PATTERN.length).fill(0));
    };
    UPCEANReader.findGuardPattern = function (row, rowOffset, whiteFirst, pattern, counters) {
        var width = row.getSize();
        rowOffset = whiteFirst ? row.getNextUnset(rowOffset) : row.getNextSet(rowOffset);
        var counterPosition = 0;
        var patternStart = rowOffset;
        var patternLength = pattern.length;
        var isWhite = whiteFirst;
        for (var x = rowOffset; x < width; x++) {
            if (row.get(x) !== isWhite) {
                counters[counterPosition]++;
            }
            else {
                if (counterPosition === patternLength - 1) {
                    if (OneDReader_1.default.patternMatchVariance(counters, pattern, UPCEANReader.MAX_INDIVIDUAL_VARIANCE) < UPCEANReader.MAX_AVG_VARIANCE) {
                        return [patternStart, x];
                    }
                    patternStart += counters[0] + counters[1];
                    var slice = counters.slice(2, counters.length);
                    for (var i = 0; i < counterPosition - 1; i++) {
                        counters[i] = slice[i];
                    }
                    counters[counterPosition - 1] = 0;
                    counters[counterPosition] = 0;
                    counterPosition--;
                }
                else {
                    counterPosition++;
                }
                counters[counterPosition] = 1;
                isWhite = !isWhite;
            }
        }
        throw new NotFoundException_1.default();
    };
    UPCEANReader.decodeDigit = function (row, counters, rowOffset, patterns) {
        this.recordPattern(row, rowOffset, counters);
        var bestVariance = this.MAX_AVG_VARIANCE;
        var bestMatch = -1;
        var max = patterns.length;
        for (var i = 0; i < max; i++) {
            var pattern = patterns[i];
            var variance = OneDReader_1.default.patternMatchVariance(counters, pattern, UPCEANReader.MAX_INDIVIDUAL_VARIANCE);
            if (variance < bestVariance) {
                bestVariance = variance;
                bestMatch = i;
            }
        }
        if (bestMatch >= 0) {
            return bestMatch;
        }
        else {
            throw new NotFoundException_1.default();
        }
    };
    // These two values are critical for determining how permissive the decoding will be.
    // We've arrived at these values through a lot of trial and error. Setting them any higher
    // lets false positives creep in quickly.
    UPCEANReader.MAX_AVG_VARIANCE = 0.48;
    UPCEANReader.MAX_INDIVIDUAL_VARIANCE = 0.7;
    /**
     * Start/end guard pattern.
     */
    UPCEANReader.START_END_PATTERN = [1, 1, 1];
    /**
     * Pattern marking the middle of a UPC/EAN pattern, separating the two halves.
     */
    UPCEANReader.MIDDLE_PATTERN = [1, 1, 1, 1, 1];
    /**
     * end guard pattern.
     */
    UPCEANReader.END_PATTERN = [1, 1, 1, 1, 1, 1];
    /**
     * "Odd", or "L" patterns used to encode UPC/EAN digits.
     */
    UPCEANReader.L_PATTERNS = [
        [3, 2, 1, 1],
        [2, 2, 2, 1],
        [2, 1, 2, 2],
        [1, 4, 1, 1],
        [1, 1, 3, 2],
        [1, 2, 3, 1],
        [1, 1, 1, 4],
        [1, 3, 1, 2],
        [1, 2, 1, 3],
        [3, 1, 1, 2],
    ];
    return UPCEANReader;
}(OneDReader_1.default));
exports.default = UPCEANReader;
//# sourceMappingURL=UPCEANReader.js.map
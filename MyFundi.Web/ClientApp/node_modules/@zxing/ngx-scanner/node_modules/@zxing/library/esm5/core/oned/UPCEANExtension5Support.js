"use strict";
/*
 * Copyright (C) 2010 ZXing authors
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
Object.defineProperty(exports, "__esModule", { value: true });
var BarcodeFormat_1 = require("../BarcodeFormat");
var UPCEANReader_1 = require("./UPCEANReader");
var Result_1 = require("../Result");
var ResultPoint_1 = require("../ResultPoint");
var ResultMetadataType_1 = require("../ResultMetadataType");
var NotFoundException_1 = require("../NotFoundException");
/**
 * @see UPCEANExtension2Support
 */
var UPCEANExtension5Support = /** @class */ (function () {
    function UPCEANExtension5Support() {
        this.CHECK_DIGIT_ENCODINGS = [0x18, 0x14, 0x12, 0x11, 0x0C, 0x06, 0x03, 0x0A, 0x09, 0x05];
        this.decodeMiddleCounters = [0, 0, 0, 0];
        this.decodeRowStringBuffer = '';
    }
    UPCEANExtension5Support.prototype.decodeRow = function (rowNumber, row, extensionStartRange) {
        var result = this.decodeRowStringBuffer;
        var end = this.decodeMiddle(row, extensionStartRange, result);
        var resultString = result.toString();
        var extensionData = UPCEANExtension5Support.parseExtensionString(resultString);
        var resultPoints = [
            new ResultPoint_1.default((extensionStartRange[0] + extensionStartRange[1]) / 2.0, rowNumber),
            new ResultPoint_1.default(end, rowNumber)
        ];
        var extensionResult = new Result_1.default(resultString, null, 0, resultPoints, BarcodeFormat_1.default.UPC_EAN_EXTENSION, new Date().getTime());
        if (extensionData != null) {
            extensionResult.putAllMetadata(extensionData);
        }
        return extensionResult;
    };
    UPCEANExtension5Support.prototype.decodeMiddle = function (row, startRange, resultString) {
        var counters = this.decodeMiddleCounters;
        counters[0] = 0;
        counters[1] = 0;
        counters[2] = 0;
        counters[3] = 0;
        var end = row.getSize();
        var rowOffset = startRange[1];
        var lgPatternFound = 0;
        for (var x = 0; x < 5 && rowOffset < end; x++) {
            var bestMatch = UPCEANReader_1.default.decodeDigit(row, counters, rowOffset, UPCEANReader_1.default.L_AND_G_PATTERNS);
            resultString += String.fromCharCode(('0'.charCodeAt(0) + bestMatch % 10));
            for (var _i = 0, counters_1 = counters; _i < counters_1.length; _i++) {
                var counter = counters_1[_i];
                rowOffset += counter;
            }
            if (bestMatch >= 10) {
                lgPatternFound |= 1 << (4 - x);
            }
            if (x !== 4) {
                // Read off separator if not last
                rowOffset = row.getNextSet(rowOffset);
                rowOffset = row.getNextUnset(rowOffset);
            }
        }
        if (resultString.length !== 5) {
            throw new NotFoundException_1.default();
        }
        var checkDigit = this.determineCheckDigit(lgPatternFound);
        if (UPCEANExtension5Support.extensionChecksum(resultString.toString()) !== checkDigit) {
            throw new NotFoundException_1.default();
        }
        return rowOffset;
    };
    UPCEANExtension5Support.extensionChecksum = function (s) {
        var length = s.length;
        var sum = 0;
        for (var i = length - 2; i >= 0; i -= 2) {
            sum += s.charAt(i).charCodeAt(0) - '0'.charCodeAt(0);
        }
        sum *= 3;
        for (var i = length - 1; i >= 0; i -= 2) {
            sum += s.charAt(i).charCodeAt(0) - '0'.charCodeAt(0);
        }
        sum *= 3;
        return sum % 10;
    };
    UPCEANExtension5Support.prototype.determineCheckDigit = function (lgPatternFound) {
        for (var d = 0; d < 10; d++) {
            if (lgPatternFound === this.CHECK_DIGIT_ENCODINGS[d]) {
                return d;
            }
        }
        throw new NotFoundException_1.default();
    };
    UPCEANExtension5Support.parseExtensionString = function (raw) {
        if (raw.length !== 5) {
            return null;
        }
        var value = UPCEANExtension5Support.parseExtension5String(raw);
        if (value == null) {
            return null;
        }
        return new Map([[ResultMetadataType_1.default.SUGGESTED_PRICE, value]]);
    };
    UPCEANExtension5Support.parseExtension5String = function (raw) {
        var currency;
        switch (raw.charAt(0)) {
            case '0':
                currency = '£';
                break;
            case '5':
                currency = '$';
                break;
            case '9':
                // Reference: http://www.jollytech.com
                switch (raw) {
                    case '90000':
                        // No suggested retail price
                        return null;
                    case '99991':
                        // Complementary
                        return '0.00';
                    case '99990':
                        return 'Used';
                }
                // Otherwise... unknown currency?
                currency = '';
                break;
            default:
                currency = '';
                break;
        }
        var rawAmount = parseInt(raw.substring(1));
        var unitsString = (rawAmount / 100).toString();
        var hundredths = rawAmount % 100;
        var hundredthsString = hundredths < 10 ? '0' + hundredths : hundredths.toString(); // fixme
        return currency + unitsString + '.' + hundredthsString;
    };
    return UPCEANExtension5Support;
}());
exports.default = UPCEANExtension5Support;
//# sourceMappingURL=UPCEANExtension5Support.js.map
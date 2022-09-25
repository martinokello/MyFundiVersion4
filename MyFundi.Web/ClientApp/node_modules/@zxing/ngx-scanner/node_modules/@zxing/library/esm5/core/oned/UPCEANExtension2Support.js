"use strict";
/*
 * Copyright (C) 2012 ZXing authors
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
 * @see UPCEANExtension5Support
 */
var UPCEANExtension2Support = /** @class */ (function () {
    function UPCEANExtension2Support() {
        this.decodeMiddleCounters = [0, 0, 0, 0];
        this.decodeRowStringBuffer = '';
    }
    UPCEANExtension2Support.prototype.decodeRow = function (rowNumber, row, extensionStartRange) {
        var result = this.decodeRowStringBuffer;
        var end = this.decodeMiddle(row, extensionStartRange, result);
        var resultString = result.toString();
        var extensionData = UPCEANExtension2Support.parseExtensionString(resultString);
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
    UPCEANExtension2Support.prototype.decodeMiddle = function (row, startRange, resultString) {
        var counters = this.decodeMiddleCounters;
        counters[0] = 0;
        counters[1] = 0;
        counters[2] = 0;
        counters[3] = 0;
        var end = row.getSize();
        var rowOffset = startRange[1];
        var checkParity = 0;
        for (var x = 0; x < 2 && rowOffset < end; x++) {
            var bestMatch = UPCEANReader_1.default.decodeDigit(row, counters, rowOffset, UPCEANReader_1.default.L_AND_G_PATTERNS);
            resultString += String.fromCharCode(('0'.charCodeAt(0) + bestMatch % 10));
            for (var _i = 0, counters_1 = counters; _i < counters_1.length; _i++) {
                var counter = counters_1[_i];
                rowOffset += counter;
            }
            if (bestMatch >= 10) {
                checkParity |= 1 << (1 - x);
            }
            if (x !== 1) {
                // Read off separator if not last
                rowOffset = row.getNextSet(rowOffset);
                rowOffset = row.getNextUnset(rowOffset);
            }
        }
        if (resultString.length !== 2) {
            throw new NotFoundException_1.default();
        }
        if (parseInt(resultString.toString()) % 4 !== checkParity) {
            throw new NotFoundException_1.default();
        }
        return rowOffset;
    };
    UPCEANExtension2Support.parseExtensionString = function (raw) {
        if (raw.length !== 2) {
            return null;
        }
        return new Map([[ResultMetadataType_1.default.ISSUE_NUMBER, parseInt(raw)]]);
    };
    return UPCEANExtension2Support;
}());
exports.default = UPCEANExtension2Support;
//# sourceMappingURL=UPCEANExtension2Support.js.map
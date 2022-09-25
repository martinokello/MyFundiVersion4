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
var UPCEANReader_1 = require("./UPCEANReader");
/**
 * <p>Implements decoding of the EAN-8 format.</p>
 *
 * @author Sean Owen
 */
var EAN8Reader = /** @class */ (function (_super) {
    __extends(EAN8Reader, _super);
    function EAN8Reader() {
        var _this = _super.call(this) || this;
        _this.decodeMiddleCounters = [0, 0, 0, 0];
        return _this;
    }
    EAN8Reader.prototype.decodeMiddle = function (row, startRange, resultString) {
        var counters = this.decodeMiddleCounters;
        counters[0] = 0;
        counters[1] = 0;
        counters[2] = 0;
        counters[3] = 0;
        var end = row.getSize();
        var rowOffset = startRange[1];
        for (var x = 0; x < 4 && rowOffset < end; x++) {
            var bestMatch = UPCEANReader_1.default.decodeDigit(row, counters, rowOffset, UPCEANReader_1.default.L_PATTERNS);
            resultString += String.fromCharCode(('0'.charCodeAt(0) + bestMatch));
            for (var _i = 0, counters_1 = counters; _i < counters_1.length; _i++) {
                var counter = counters_1[_i];
                rowOffset += counter;
            }
        }
        var middleRange = UPCEANReader_1.default.findGuardPattern(row, rowOffset, true, UPCEANReader_1.default.MIDDLE_PATTERN, new Array(UPCEANReader_1.default.MIDDLE_PATTERN.length).fill(0));
        rowOffset = middleRange[1];
        for (var x = 0; x < 4 && rowOffset < end; x++) {
            var bestMatch = UPCEANReader_1.default.decodeDigit(row, counters, rowOffset, UPCEANReader_1.default.L_PATTERNS);
            resultString += String.fromCharCode(('0'.charCodeAt(0) + bestMatch));
            for (var _a = 0, counters_2 = counters; _a < counters_2.length; _a++) {
                var counter = counters_2[_a];
                rowOffset += counter;
            }
        }
        return { rowOffset: rowOffset, resultString: resultString };
    };
    EAN8Reader.prototype.getBarcodeFormat = function () {
        return BarcodeFormat_1.default.EAN_8;
    };
    return EAN8Reader;
}(UPCEANReader_1.default));
exports.default = EAN8Reader;
//# sourceMappingURL=EAN8Reader.js.map
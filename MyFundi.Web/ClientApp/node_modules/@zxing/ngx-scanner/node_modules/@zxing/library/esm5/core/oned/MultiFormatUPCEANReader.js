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
var OneDReader_1 = require("./OneDReader");
var EAN13Reader_1 = require("./EAN13Reader");
var EAN8Reader_1 = require("./EAN8Reader");
var NotFoundException_1 = require("../NotFoundException");
/**
 * <p>A reader that can read all available UPC/EAN formats. If a caller wants to try to
 * read all such formats, it is most efficient to use this implementation rather than invoke
 * individual readers.</p>
 *
 * @author Sean Owen
 */
var MultiFormatUPCEANReader = /** @class */ (function (_super) {
    __extends(MultiFormatUPCEANReader, _super);
    function MultiFormatUPCEANReader(hints) {
        var _this = _super.call(this) || this;
        var possibleFormats = hints == null ? null : hints.get(DecodeHintType_1.default.POSSIBLE_FORMATS);
        var readers = [];
        if (possibleFormats != null) {
            if (possibleFormats.indexOf(BarcodeFormat_1.default.EAN_13) > -1) {
                readers.push(new EAN13Reader_1.default());
            }
            if (possibleFormats.indexOf(BarcodeFormat_1.default.EAN_8) > -1) {
                readers.push(new EAN8Reader_1.default());
            }
            // todo add UPC_A, UPC_E
        }
        if (readers.length === 0) {
            readers.push(new EAN13Reader_1.default());
            readers.push(new EAN8Reader_1.default());
            // todo add UPC_A, UPC_E
        }
        _this.readers = readers;
        return _this;
    }
    MultiFormatUPCEANReader.prototype.decodeRow = function (rowNumber, row, hints) {
        for (var _i = 0, _a = this.readers; _i < _a.length; _i++) {
            var reader = _a[_i];
            try {
                return reader.decodeRow(rowNumber, row, hints);
                // TODO ean13MayBeUPCA
            }
            catch (err) {
                // continue;
            }
        }
        throw new NotFoundException_1.default();
    };
    MultiFormatUPCEANReader.prototype.reset = function () {
        for (var _i = 0, _a = this.readers; _i < _a.length; _i++) {
            var reader = _a[_i];
            reader.reset();
        }
    };
    return MultiFormatUPCEANReader;
}(OneDReader_1.default));
exports.default = MultiFormatUPCEANReader;
//# sourceMappingURL=MultiFormatUPCEANReader.js.map
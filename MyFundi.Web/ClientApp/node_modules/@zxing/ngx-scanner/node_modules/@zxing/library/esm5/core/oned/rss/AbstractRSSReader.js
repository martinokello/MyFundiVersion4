"use strict";
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
var OneDReader_1 = require("../OneDReader");
var NotFoundException_1 = require("../../NotFoundException");
var MathUtils_1 = require("../../common/detector/MathUtils");
var AbstractRSSReader = /** @class */ (function (_super) {
    __extends(AbstractRSSReader, _super);
    function AbstractRSSReader() {
        var _this = _super.call(this) || this;
        _this.decodeFinderCounters = new Array(4);
        _this.dataCharacterCounters = new Array(8);
        _this.oddRoundingErrors = new Array(4);
        _this.evenRoundingErrors = new Array(4);
        _this.oddCounts = new Array(_this.dataCharacterCounters.length / 2);
        _this.evenCounts = new Array(_this.dataCharacterCounters.length / 2);
        return _this;
    }
    AbstractRSSReader.prototype.getDecodeFinderCounters = function () {
        return this.decodeFinderCounters;
    };
    AbstractRSSReader.prototype.getDataCharacterCounters = function () {
        return this.dataCharacterCounters;
    };
    AbstractRSSReader.prototype.getOddRoundingErrors = function () {
        return this.oddRoundingErrors;
    };
    AbstractRSSReader.prototype.getEvenRoundingErrors = function () {
        return this.evenRoundingErrors;
    };
    AbstractRSSReader.prototype.getOddCounts = function () {
        return this.oddCounts;
    };
    AbstractRSSReader.prototype.getEvenCounts = function () {
        return this.evenCounts;
    };
    AbstractRSSReader.prototype.parseFinderValue = function (counters, finderPatterns) {
        for (var value = 0; value < finderPatterns.length; value++) {
            if (OneDReader_1.default.patternMatchVariance(counters, finderPatterns[value], AbstractRSSReader.MAX_INDIVIDUAL_VARIANCE) < AbstractRSSReader.MAX_AVG_VARIANCE) {
                return value;
            }
        }
        throw new NotFoundException_1.default();
    };
    /**
     * @param array values to sum
     * @return sum of values
     * @deprecated call {@link MathUtils#sum(int[])}
     */
    AbstractRSSReader.count = function (array) {
        return MathUtils_1.default.sum(new Int32Array(array));
    };
    AbstractRSSReader.increment = function (array, errors) {
        var index = 0;
        var biggestError = errors[0];
        for (var i = 1; i < array.length; i++) {
            if (errors[i] > biggestError) {
                biggestError = errors[i];
                index = i;
            }
        }
        array[index]++;
    };
    AbstractRSSReader.decrement = function (array, errors) {
        var index = 0;
        var biggestError = errors[0];
        for (var i = 1; i < array.length; i++) {
            if (errors[i] < biggestError) {
                biggestError = errors[i];
                index = i;
            }
        }
        array[index]--;
    };
    AbstractRSSReader.isFinderPattern = function (counters) {
        var firstTwoSum = counters[0] + counters[1];
        var sum = firstTwoSum + counters[2] + counters[3];
        var ratio = firstTwoSum / sum;
        if (ratio >= AbstractRSSReader.MIN_FINDER_PATTERN_RATIO && ratio <= AbstractRSSReader.MAX_FINDER_PATTERN_RATIO) {
            // passes ratio test in spec, but see if the counts are unreasonable
            var minCounter = Number.MAX_SAFE_INTEGER;
            var maxCounter = Number.MIN_SAFE_INTEGER;
            for (var _i = 0, counters_1 = counters; _i < counters_1.length; _i++) {
                var counter = counters_1[_i];
                if (counter > maxCounter) {
                    maxCounter = counter;
                }
                if (counter < minCounter) {
                    minCounter = counter;
                }
            }
            return maxCounter < 10 * minCounter;
        }
        return false;
    };
    AbstractRSSReader.MAX_AVG_VARIANCE = 0.2;
    AbstractRSSReader.MAX_INDIVIDUAL_VARIANCE = 0.45;
    AbstractRSSReader.MIN_FINDER_PATTERN_RATIO = 9.5 / 12.0;
    AbstractRSSReader.MAX_FINDER_PATTERN_RATIO = 12.5 / 14.0;
    return AbstractRSSReader;
}(OneDReader_1.default));
exports.default = AbstractRSSReader;
//# sourceMappingURL=AbstractRSSReader.js.map
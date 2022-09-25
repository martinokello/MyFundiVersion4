"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
/**
 * RSS util functions.
 */
var RSSUtils = /** @class */ (function () {
    function RSSUtils() {
    }
    RSSUtils.prototype.RSSUtils = function () { };
    RSSUtils.getRSSvalue = function (widths, maxWidth, noNarrow) {
        var n = 0;
        for (var _i = 0, widths_1 = widths; _i < widths_1.length; _i++) {
            var width = widths_1[_i];
            n += width;
        }
        var val = 0;
        var narrowMask = 0;
        var elements = widths.length;
        for (var bar = 0; bar < elements - 1; bar++) {
            var elmWidth = void 0;
            for (elmWidth = 1, narrowMask |= 1 << bar; elmWidth < widths[bar]; elmWidth++, narrowMask &= ~(1 << bar)) {
                var subVal = RSSUtils.combins(n - elmWidth - 1, elements - bar - 2);
                if (noNarrow && (narrowMask === 0) && (n - elmWidth - (elements - bar - 1) >= elements - bar - 1)) {
                    subVal -= RSSUtils.combins(n - elmWidth - (elements - bar), elements - bar - 2);
                }
                if (elements - bar - 1 > 1) {
                    var lessVal = 0;
                    for (var mxwElement = n - elmWidth - (elements - bar - 2); mxwElement > maxWidth; mxwElement--) {
                        lessVal += RSSUtils.combins(n - elmWidth - mxwElement - 1, elements - bar - 3);
                    }
                    subVal -= lessVal * (elements - 1 - bar);
                }
                else if (n - elmWidth > maxWidth) {
                    subVal--;
                }
                val += subVal;
            }
            n -= elmWidth;
        }
        return val;
    };
    RSSUtils.combins = function (n, r) {
        var maxDenom;
        var minDenom;
        if (n - r > r) {
            minDenom = r;
            maxDenom = n - r;
        }
        else {
            minDenom = n - r;
            maxDenom = r;
        }
        var val = 1;
        var j = 1;
        for (var i = n; i > maxDenom; i--) {
            val *= i;
            if (j <= minDenom) {
                val /= j;
                j++;
            }
        }
        while ((j <= minDenom)) {
            val /= j;
            j++;
        }
        return val;
    };
    return RSSUtils;
}());
exports.default = RSSUtils;
//# sourceMappingURL=RSSUtils.js.map
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var System_1 = require("./System");
var Arrays = /** @class */ (function () {
    function Arrays() {
    }
    Arrays.equals = function (first, second) {
        if (!first) {
            return false;
        }
        if (!second) {
            return false;
        }
        if (!first.length) {
            return false;
        }
        if (!second.length) {
            return false;
        }
        if (first.length !== second.length) {
            return false;
        }
        for (var i = 0, length_1 = first.length; i < length_1; i++) {
            if (first[i] !== second[i]) {
                return false;
            }
        }
        return true;
    };
    Arrays.hashCode = function (a) {
        if (a === null) {
            return 0;
        }
        var result = 1;
        for (var _i = 0, a_1 = a; _i < a_1.length; _i++) {
            var element = a_1[_i];
            result = 31 * result + element;
        }
        return result;
    };
    Arrays.fillUint8Array = function (a, value) {
        for (var i = 0; i !== a.length; i++) {
            a[i] = value;
        }
    };
    Arrays.copyOf = function (original, newLength) {
        var copy = new Int32Array(newLength);
        System_1.default.arraycopy(original, 0, copy, 0, Math.min(original.length, newLength));
        return copy;
    };
    /*
    * Returns the index of of the element in a sorted array or (-n-1) where n is the insertion point
    * for the new element.
    * Parameters:
    *     ar - A sorted array
    *     el - An element to search for
    *     comparator - A comparator function. The function takes two arguments: (a, b) and returns:
    *        a negative number  if a is less than b;
    *        0 if a is equal to b;
    *        a positive number of a is greater than b.
    * The array may contain duplicate elements. If there are more than one equal elements in the array,
    * the returned value can be the index of any one of the equal elements.
    *
    * http://jsfiddle.net/aryzhov/pkfst550/
    */
    Arrays.binarySearch = function (ar, el, comparator) {
        if (undefined === comparator) {
            comparator = Arrays.numberComparator;
        }
        var m = 0;
        var n = ar.length - 1;
        while (m <= n) {
            var k = (n + m) >> 1;
            var cmp = comparator(el, ar[k]);
            if (cmp > 0) {
                m = k + 1;
            }
            else if (cmp < 0) {
                n = k - 1;
            }
            else {
                return k;
            }
        }
        return -m - 1;
    };
    Arrays.numberComparator = function (a, b) {
        return a - b;
    };
    return Arrays;
}());
exports.default = Arrays;
//# sourceMappingURL=Arrays.js.map
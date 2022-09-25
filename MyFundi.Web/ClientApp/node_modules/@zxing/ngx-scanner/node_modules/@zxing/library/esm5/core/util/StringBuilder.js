"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var StringBuilder = /** @class */ (function () {
    function StringBuilder(value) {
        if (value === void 0) { value = ''; }
        this.value = value;
    }
    StringBuilder.prototype.append = function (s) {
        if (typeof s === 'string') {
            this.value += s.toString();
        }
        else {
            this.value += String.fromCharCode(s);
        }
        return this;
    };
    StringBuilder.prototype.length = function () {
        return this.value.length;
    };
    StringBuilder.prototype.charAt = function (n) {
        return this.value.charAt(n);
    };
    StringBuilder.prototype.deleteCharAt = function (n) {
        this.value = this.value.substr(0, n) + this.value.substring(n + 1);
    };
    StringBuilder.prototype.setCharAt = function (n, c) {
        this.value = this.value.substr(0, n) + c + this.value.substr(n + 1);
    };
    StringBuilder.prototype.toString = function () {
        return this.value;
    };
    StringBuilder.prototype.insert = function (n, c) {
        this.value = this.value.substr(0, n) + c + this.value.substr(n + c.length);
    };
    return StringBuilder;
}());
exports.default = StringBuilder;
//# sourceMappingURL=StringBuilder.js.map
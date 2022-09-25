export default class StringBuilder {
    constructor(value = '') {
        this.value = value;
    }
    append(s) {
        if (typeof s === 'string') {
            this.value += s.toString();
        }
        else {
            this.value += String.fromCharCode(s);
        }
        return this;
    }
    length() {
        return this.value.length;
    }
    charAt(n) {
        return this.value.charAt(n);
    }
    deleteCharAt(n) {
        this.value = this.value.substr(0, n) + this.value.substring(n + 1);
    }
    setCharAt(n, c) {
        this.value = this.value.substr(0, n) + c + this.value.substr(n + 1);
    }
    toString() {
        return this.value;
    }
    insert(n, c) {
        this.value = this.value.substr(0, n) + c + this.value.substr(n + c.length);
    }
}
//# sourceMappingURL=StringBuilder.js.map
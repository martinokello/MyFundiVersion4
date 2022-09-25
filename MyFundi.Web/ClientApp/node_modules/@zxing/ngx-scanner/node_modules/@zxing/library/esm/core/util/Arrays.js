import System from './System';
export default class Arrays {
    static equals(first, second) {
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
        for (let i = 0, length = first.length; i < length; i++) {
            if (first[i] !== second[i]) {
                return false;
            }
        }
        return true;
    }
    static hashCode(a) {
        if (a === null) {
            return 0;
        }
        let result = 1;
        for (const element of a) {
            result = 31 * result + element;
        }
        return result;
    }
    static fillUint8Array(a, value) {
        for (let i = 0; i !== a.length; i++) {
            a[i] = value;
        }
    }
    static copyOf(original, newLength) {
        const copy = new Int32Array(newLength);
        System.arraycopy(original, 0, copy, 0, Math.min(original.length, newLength));
        return copy;
    }
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
    static binarySearch(ar, el, comparator) {
        if (undefined === comparator) {
            comparator = Arrays.numberComparator;
        }
        let m = 0;
        let n = ar.length - 1;
        while (m <= n) {
            const k = (n + m) >> 1;
            const cmp = comparator(el, ar[k]);
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
    }
    static numberComparator(a, b) {
        return a - b;
    }
}
//# sourceMappingURL=Arrays.js.map
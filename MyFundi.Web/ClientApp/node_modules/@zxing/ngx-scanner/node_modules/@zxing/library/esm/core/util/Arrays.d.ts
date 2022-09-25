export default class Arrays {
    static equals(first: any, second: any): boolean;
    static hashCode(a: any): number;
    static fillUint8Array(a: Uint8Array, value: number): void;
    static copyOf(original: Int32Array, newLength: number): Int32Array;
    static binarySearch(ar: Int32Array, el: number, comparator?: (a: number, b: number) => number): number;
    static numberComparator(a: number, b: number): number;
}

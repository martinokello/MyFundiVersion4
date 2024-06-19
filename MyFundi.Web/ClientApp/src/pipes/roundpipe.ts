import { Pipe, PipeTransform } from '@angular/core';

enum Direction {
    UP = 'up',
    DOWN = 'down'
}

@Pipe({ name: 'toFixed' })
export class ToFixedPipe implements PipeTransform {
    /**
     *
     * @param value - some number
     * @param digits - number of digits after the decimal point
     * @param dir - round up or down (floor/ceil)
     * @returns {string} formatted number with a fixed number of digits after the decimal point
     */
    transform(value: number, digits: number = 0, dir: Direction = Direction.DOWN): number {
        const round = dir === Direction.DOWN ? Math.floor : Math.ceil;
        return round(value * (10 ** digits)) / (10 ** digits);
    }
}
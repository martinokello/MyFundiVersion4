import { CustomError } from 'ts-custom-error';
/**
 * Custom Error class of type Exception.
 */
export default class Exception extends CustomError {
    message: string;
    /**
     * Allows Exception to be constructed directly
     * with some message and prototype definition.
     */
    constructor(message?: string);
}

/// <reference path="image-capture.d.ts" />
import { BrowserMultiFormatReader } from '@zxing/library';
import { Observable } from 'rxjs';
import { ResultAndError } from './ResultAndError';
/**
 * Based on zxing-typescript BrowserCodeReader
 */
export declare class BrowserMultiFormatContinuousReader extends BrowserMultiFormatReader {
    /**
     * Exposes _tochAvailable .
     */
    readonly isTorchAvailable: Observable<boolean>;
    /**
     * Says if there's a torch available for the current device.
     */
    private _isTorchAvailable;
    /**
     * The device id of the current media device.
     */
    private deviceId;
    /**
     * If there's some scan stream open, it shal be here.
     */
    private scanStream;
    /**
     * Starts the decoding from the current or a new video element.
     *
     * @param callbackFn The callback to be executed after every scan attempt
     * @param deviceId The device's to be used Id
     * @param videoSource A new video element
     */
    continuousDecodeFromInputVideoDevice(deviceId?: string, videoSource?: HTMLVideoElement): Observable<ResultAndError>;
    /**
     * Gets the media stream for certain device.
     * Falls back to any available device if no `deviceId` is defined.
     */
    getStreamForDevice({ deviceId }: Partial<MediaDeviceInfo>): Promise<MediaStream>;
    /**
     * Creates media steram constraints for certain `deviceId`.
     * Falls back to any environment available device if no `deviceId` is defined.
     */
    getUserMediaConstraints(deviceId: string): MediaStreamConstraints;
    /**
     * Enables and disables the device torch.
     */
    setTorch(on: boolean): void;
    /**
     * Update the torch compatibility state and attachs the stream to the preview element.
     */
    private attachStreamToVideoAndCheckTorch;
    /**
     * Checks if the stream supports torch control.
     *
     * @param stream The media stream used to check.
     */
    private updateTorchCompatibility;
    /**
     *
     * @param stream The video stream where the tracks gonna be extracted from.
     */
    private getVideoTracks;
    /**
     *
     * @param track The media stream track that will be checked for compatibility.
     */
    private isTorchCompatible;
    /**
     * Apply the torch setting in all received tracks.
     */
    private applyTorchOnTracks;
    /**
     * Correctly sets a new scanStream value.
     */
    private _setScanStream;
    /**
     * Cleans any old scan stream value.
     */
    private _cleanScanStream;
    /**
     * Decodes values in a stream with delays between scans.
     *
     * @param scan$ The subject to receive the values.
     * @param videoElement The video element the decode will be applied.
     * @param delay The delay between decode results.
     */
    private decodeOnSubject;
    /**
     * Restarts the scanner.
     */
    private restart;
}

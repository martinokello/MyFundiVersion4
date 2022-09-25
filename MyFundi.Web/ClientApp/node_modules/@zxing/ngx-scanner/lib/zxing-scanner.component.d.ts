import { AfterViewInit, ElementRef, EventEmitter, OnDestroy } from '@angular/core';
import { BarcodeFormat, DecodeHintType, Exception, Result } from '@zxing/library';
import { BrowserMultiFormatContinuousReader } from './browser-multi-format-continuous-reader';
export declare class ZXingScannerComponent implements AfterViewInit, OnDestroy {
    /**
     * Supported Hints map.
     */
    private _hints;
    /**
     * The ZXing code reader.
     */
    private _codeReader;
    /**
     * The device that should be used to scan things.
     */
    private _device;
    /**
     * The device that should be used to scan things.
     */
    private _enabled;
    /**
     *
     */
    private _isAutostarting;
    /**
     * Has `navigator` access.
     */
    private hasNavigator;
    /**
     * Says if some native API is supported.
     */
    private isMediaDevicesSuported;
    /**
     * If the user-agent allowed the use of the camera or not.
     */
    private hasPermission;
    /**
     * Reference to the preview element, should be the `video` tag.
     */
    previewElemRef: ElementRef<HTMLVideoElement>;
    /**
     * Enable or disable autofocus of the camera (might have an impact on performance)
     */
    autofocusEnabled: boolean;
    /**
     * Emits when and if the scanner is autostarted.
     */
    autostarted: EventEmitter<void>;
    /**
     * True during autostart and false after. It will be null if won't autostart at all.
     */
    autostarting: EventEmitter<boolean | null>;
    /**
     * If the scanner should autostart with the first available device.
     */
    autostart: boolean;
    /**
     * How the preview element shoud be fit inside the :host container.
     */
    previewFitMode: 'fill' | 'contain' | 'cover' | 'scale-down' | 'none';
    /**
     * Emitts events when the torch compatibility is changed.
     */
    torchCompatible: EventEmitter<boolean>;
    /**
     * Emitts events when a scan is successful performed, will inject the string value of the QR-code to the callback.
     */
    scanSuccess: EventEmitter<string>;
    /**
     * Emitts events when a scan fails without errors, usefull to know how much scan tries where made.
     */
    scanFailure: EventEmitter<Exception | undefined>;
    /**
     * Emitts events when a scan throws some error, will inject the error to the callback.
     */
    scanError: EventEmitter<Error>;
    /**
     * Emitts events when a scan is performed, will inject the Result value of the QR-code scan (if available) to the callback.
     */
    scanComplete: EventEmitter<Result>;
    /**
     * Emitts events when no cameras are found, will inject an exception (if available) to the callback.
     */
    camerasFound: EventEmitter<MediaDeviceInfo[]>;
    /**
     * Emitts events when no cameras are found, will inject an exception (if available) to the callback.
     */
    camerasNotFound: EventEmitter<any>;
    /**
     * Emitts events when the users answers for permission.
     */
    permissionResponse: EventEmitter<boolean>;
    /**
     * Emitts events when has devices status is update.
     */
    hasDevices: EventEmitter<boolean>;
    /**
     * Exposes the current code reader, so the user can use it's APIs.
     */
    readonly codeReader: BrowserMultiFormatContinuousReader;
    /**
     * User device input
     */
    /**
    * User device acessor.
    */
    device: MediaDeviceInfo | null;
    /**
     * Emits when the current device is changed.
     */
    deviceChange: EventEmitter<MediaDeviceInfo>;
    /**
     * Returns all the registered formats.
     */
    /**
    * Registers formats the scanner should support.
    *
    * @param input BarcodeFormat or case-insensitive string array.
    */
    formats: BarcodeFormat[];
    /**
     * Returns all the registered hints.
     */
    /**
    * Does what it takes to set the hints.
    */
    hints: Map<DecodeHintType, any>;
    /**
     *
     */
    isAutostarting: boolean | null;
    /**
     *
     */
    readonly isAutstarting: boolean | null;
    /**
     * Allow start scan or not.
     */
    torch: boolean;
    /**
     * Allow start scan or not.
     */
    enable: boolean;
    /**
     * Tells if the scanner is enabled or not.
     */
    readonly enabled: boolean;
    /**
     * If is `tryHarder` enabled.
     */
    /**
    * Enable/disable tryHarder hint.
    */
    tryHarder: boolean;
    /**
     * Constructor to build the object and do some DI.
     */
    constructor();
    /**
     * Gets and registers all cammeras.
     */
    askForPermission(): Promise<boolean>;
    /**
     *
     */
    getAnyVideoDevice(): Promise<MediaStream>;
    /**
     * Terminates a stream and it's tracks.
     */
    private terminateStream;
    /**
     * Initializes the component without starting the scanner.
     */
    private initAutostartOff;
    /**
     * Initializes the component and starts the scanner.
     * Permissions are asked to accomplish that.
     */
    private initAutostartOn;
    /**
     * Checks if the given device is the current defined one.
     */
    isCurrentDevice(device: MediaDeviceInfo): boolean;
    /**
     * Executed after the view initialization.
     */
    ngAfterViewInit(): void;
    /**
     * Executes some actions before destroy the component.
     */
    ngOnDestroy(): void;
    /**
     * Stops old `codeReader` and starts scanning in a new one.
     */
    restart(): void;
    /**
     * Discovers and updates known video input devices.
     */
    updateVideoInputDevices(): Promise<MediaDeviceInfo[]>;
    /**
     * Starts the scanner with the back camera otherwise take the last
     * available device.
     */
    private autostartScanner;
    /**
     * Dispatches the scan success event.
     *
     * @param result the scan result.
     */
    private dispatchScanSuccess;
    /**
     * Dispatches the scan failure event.
     */
    private dispatchScanFailure;
    /**
     * Dispatches the scan error event.
     *
     * @param error the error thing.
     */
    private dispatchScanError;
    /**
     * Dispatches the scan event.
     *
     * @param result the scan result.
     */
    private dispatchScanComplete;
    /**
     * Returns the filtered permission.
     */
    private handlePermissionException;
    /**
     * Returns a valid BarcodeFormat or fails.
     */
    private getBarcodeFormatOrFail;
    /**
     * Retorna um code reader, cria um se nenhume existe.
     */
    private getCodeReader;
    /**
     * Starts the continuous scanning for the given device.
     *
     * @param deviceId The deviceId from the device.
     */
    private scanFromDevice;
    /**
     * Handles decode errors.
     */
    private _onDecodeError;
    /**
     * Handles decode results.
     */
    private _onDecodeResult;
    /**
     * Stops the code reader and returns the previous selected device.
     */
    private _reset;
    /**
     * Resets the scanner and emits device change.
     */
    reset(): void;
    /**
     * Sets the permission value and emmits the event.
     */
    private setPermission;
}

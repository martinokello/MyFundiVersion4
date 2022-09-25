import BitMatrix from '../../common/BitMatrix';
import DetectorResult from '../../common/DetectorResult';
/**
 * <p>Encapsulates logic that can detect a Data Matrix Code in an image, even if the Data Matrix Code
 * is rotated or skewed, or partially obscured.</p>
 *
 * @author Sean Owen
 */
export default class Detector {
    private image;
    private rectangleDetector;
    constructor(image: BitMatrix);
    /**
     * <p>Detects a Data Matrix Code in an image.</p>
     *
     * @return {@link DetectorResult} encapsulating results of detecting a Data Matrix Code
     * @throws NotFoundException if no Data Matrix Code can be found
     */
    detect(): DetectorResult;
    /**
     * Calculates the position of the white top right module using the output of the rectangle detector
     * for a rectangular matrix
     */
    private correctTopRightRectangular;
    /**
     * Calculates the position of the white top right module using the output of the rectangle detector
     * for a square matrix
     */
    private correctTopRight;
    private isValid;
    private static distance;
    /**
     * Increments the Integer associated with a key by one.
     */
    private static increment;
    private static sampleGrid;
    /**
     * Counts the number of black/white transitions between two points, using something like Bresenham's algorithm.
     */
    private transitionsBetween;
}

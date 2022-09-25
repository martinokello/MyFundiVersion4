"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
var ResultPoint_1 = require("../../ResultPoint");
var DetectorResult_1 = require("../../common/DetectorResult");
var GridSamplerInstance_1 = require("../../common/GridSamplerInstance");
var MathUtils_1 = require("../../common/detector/MathUtils");
var WhiteRectangleDetector_1 = require("../../common/detector/WhiteRectangleDetector");
var NotFoundException_1 = require("../../NotFoundException");
/*
 * Copyright 2008 ZXing authors
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
/**
 * <p>Encapsulates logic that can detect a Data Matrix Code in an image, even if the Data Matrix Code
 * is rotated or skewed, or partially obscured.</p>
 *
 * @author Sean Owen
 */
var Detector = /** @class */ (function () {
    function Detector(image) {
        this.image = image;
        this.rectangleDetector = new WhiteRectangleDetector_1.default(image);
    }
    /**
     * <p>Detects a Data Matrix Code in an image.</p>
     *
     * @return {@link DetectorResult} encapsulating results of detecting a Data Matrix Code
     * @throws NotFoundException if no Data Matrix Code can be found
     */
    Detector.prototype.detect = function () {
        var cornerPoints = this.rectangleDetector.detect();
        var pointA = cornerPoints[0];
        var pointB = cornerPoints[1];
        var pointC = cornerPoints[2];
        var pointD = cornerPoints[3];
        // Point A and D are across the diagonal from one another,
        // as are B and C. Figure out which are the solid black lines
        // by counting transitions
        var transitions = [];
        transitions.push(this.transitionsBetween(pointA, pointB));
        transitions.push(this.transitionsBetween(pointA, pointC));
        transitions.push(this.transitionsBetween(pointB, pointD));
        transitions.push(this.transitionsBetween(pointC, pointD));
        transitions.sort(ResultPointsAndTransitions.resultPointsAndTransitionsComparator);
        // Sort by number of transitions. First two will be the two solid sides; last two
        // will be the two alternating black/white sides
        var lSideOne = transitions[0];
        var lSideTwo = transitions[1];
        // Figure out which point is their intersection by tallying up the number of times we see the
        // endpoints in the four endpoints. One will show up twice.
        var pointCount = new Map();
        Detector.increment(pointCount, lSideOne.getFrom());
        Detector.increment(pointCount, lSideOne.getTo());
        Detector.increment(pointCount, lSideTwo.getFrom());
        Detector.increment(pointCount, lSideTwo.getTo());
        var maybeTopLeft = null;
        var bottomLeft = null;
        var maybeBottomRight = null;
        for (var _i = 0, _a = Array.from(pointCount.entries()); _i < _a.length; _i++) {
            var _b = _a[_i], point = _b[0], value = _b[1];
            if (value === 2) {
                bottomLeft = point; // this is definitely the bottom left, then -- end of two L sides
            }
            else {
                // Otherwise it's either top left or bottom right -- just assign the two arbitrarily now
                if (maybeTopLeft == null) {
                    maybeTopLeft = point;
                }
                else {
                    maybeBottomRight = point;
                }
            }
        }
        if (maybeTopLeft == null || bottomLeft == null || maybeBottomRight == null) {
            throw new NotFoundException_1.default();
        }
        // Bottom left is correct but top left and bottom right might be switched
        var corners = [maybeTopLeft, bottomLeft, maybeBottomRight];
        // Use the dot product trick to sort them out
        ResultPoint_1.default.orderBestPatterns(corners);
        // Now we know which is which:
        var bottomRight = corners[0];
        bottomLeft = corners[1];
        var topLeft = corners[2];
        // Which point didn't we find in relation to the "L" sides? that's the top right corner
        var topRight;
        if (!pointCount.has(pointA)) {
            topRight = pointA;
        }
        else if (!pointCount.has(pointB)) {
            topRight = pointB;
        }
        else if (!pointCount.has(pointC)) {
            topRight = pointC;
        }
        else {
            topRight = pointD;
        }
        // Next determine the dimension by tracing along the top or right side and counting black/white
        // transitions. Since we start inside a black module, we should see a number of transitions
        // equal to 1 less than the code dimension. Well, actually 2 less, because we are going to
        // end on a black module:
        // The top right point is actually the corner of a module, which is one of the two black modules
        // adjacent to the white module at the top right. Tracing to that corner from either the top left
        // or bottom right should work here.
        var dimensionTop = this.transitionsBetween(topLeft, topRight).getTransitions();
        var dimensionRight = this.transitionsBetween(bottomRight, topRight).getTransitions();
        if ((dimensionTop & 0x01) === 1) {
            // it can't be odd, so, round... up?
            dimensionTop++;
        }
        dimensionTop += 2;
        if ((dimensionRight & 0x01) === 1) {
            // it can't be odd, so, round... up?
            dimensionRight++;
        }
        dimensionRight += 2;
        var bits;
        var correctedTopRight;
        // Rectangular symbols are 6x16, 6x28, 10x24, 10x32, 14x32, or 14x44. If one dimension is more
        // than twice the other, it's certainly rectangular, but to cut a bit more slack we accept it as
        // rectangular if the bigger side is at least 7/4 times the other:
        if (4 * dimensionTop >= 7 * dimensionRight || 4 * dimensionRight >= 7 * dimensionTop) {
            // The matrix is rectangular
            correctedTopRight =
                this.correctTopRightRectangular(bottomLeft, bottomRight, topLeft, topRight, dimensionTop, dimensionRight);
            if (correctedTopRight == null) {
                correctedTopRight = topRight;
            }
            dimensionTop = this.transitionsBetween(topLeft, correctedTopRight).getTransitions();
            dimensionRight = this.transitionsBetween(bottomRight, correctedTopRight).getTransitions();
            if ((dimensionTop & 0x01) === 1) {
                // it can't be odd, so, round... up?
                dimensionTop++;
            }
            if ((dimensionRight & 0x01) === 1) {
                // it can't be odd, so, round... up?
                dimensionRight++;
            }
            bits = Detector.sampleGrid(this.image, topLeft, bottomLeft, bottomRight, correctedTopRight, dimensionTop, dimensionRight);
        }
        else {
            // The matrix is square
            var dimension = Math.min(dimensionRight, dimensionTop);
            // correct top right point to match the white module
            correctedTopRight = this.correctTopRight(bottomLeft, bottomRight, topLeft, topRight, dimension);
            if (correctedTopRight == null) {
                correctedTopRight = topRight;
            }
            // Redetermine the dimension using the corrected top right point
            var dimensionCorrected = Math.max(this.transitionsBetween(topLeft, correctedTopRight).getTransitions(), this.transitionsBetween(bottomRight, correctedTopRight).getTransitions());
            dimensionCorrected++;
            if ((dimensionCorrected & 0x01) === 1) {
                dimensionCorrected++;
            }
            bits = Detector.sampleGrid(this.image, topLeft, bottomLeft, bottomRight, correctedTopRight, dimensionCorrected, dimensionCorrected);
        }
        return new DetectorResult_1.default(bits, [topLeft, bottomLeft, bottomRight, correctedTopRight]);
    };
    /**
     * Calculates the position of the white top right module using the output of the rectangle detector
     * for a rectangular matrix
     */
    Detector.prototype.correctTopRightRectangular = function (bottomLeft, bottomRight, topLeft, topRight, dimensionTop, dimensionRight) {
        var corr = Detector.distance(bottomLeft, bottomRight) / dimensionTop;
        var norm = Detector.distance(topLeft, topRight);
        var cos = (topRight.getX() - topLeft.getX()) / norm;
        var sin = (topRight.getY() - topLeft.getY()) / norm;
        var c1 = new ResultPoint_1.default(topRight.getX() + corr * cos, topRight.getY() + corr * sin);
        corr = Detector.distance(bottomLeft, topLeft) / dimensionRight;
        norm = Detector.distance(bottomRight, topRight);
        cos = (topRight.getX() - bottomRight.getX()) / norm;
        sin = (topRight.getY() - bottomRight.getY()) / norm;
        var c2 = new ResultPoint_1.default(topRight.getX() + corr * cos, topRight.getY() + corr * sin);
        if (!this.isValid(c1)) {
            if (this.isValid(c2)) {
                return c2;
            }
            return null;
        }
        if (!this.isValid(c2)) {
            return c1;
        }
        var l1 = Math.abs(dimensionTop - this.transitionsBetween(topLeft, c1).getTransitions()) +
            Math.abs(dimensionRight - this.transitionsBetween(bottomRight, c1).getTransitions());
        var l2 = Math.abs(dimensionTop - this.transitionsBetween(topLeft, c2).getTransitions()) +
            Math.abs(dimensionRight - this.transitionsBetween(bottomRight, c2).getTransitions());
        if (l1 <= l2) {
            return c1;
        }
        return c2;
    };
    /**
     * Calculates the position of the white top right module using the output of the rectangle detector
     * for a square matrix
     */
    Detector.prototype.correctTopRight = function (bottomLeft, bottomRight, topLeft, topRight, dimension) {
        var corr = Detector.distance(bottomLeft, bottomRight) / dimension;
        var norm = Detector.distance(topLeft, topRight);
        var cos = (topRight.getX() - topLeft.getX()) / norm;
        var sin = (topRight.getY() - topLeft.getY()) / norm;
        var c1 = new ResultPoint_1.default(topRight.getX() + corr * cos, topRight.getY() + corr * sin);
        corr = Detector.distance(bottomLeft, topLeft) / dimension;
        norm = Detector.distance(bottomRight, topRight);
        cos = (topRight.getX() - bottomRight.getX()) / norm;
        sin = (topRight.getY() - bottomRight.getY()) / norm;
        var c2 = new ResultPoint_1.default(topRight.getX() + corr * cos, topRight.getY() + corr * sin);
        if (!this.isValid(c1)) {
            if (this.isValid(c2)) {
                return c2;
            }
            return null;
        }
        if (!this.isValid(c2)) {
            return c1;
        }
        var l1 = Math.abs(this.transitionsBetween(topLeft, c1).getTransitions() -
            this.transitionsBetween(bottomRight, c1).getTransitions());
        var l2 = Math.abs(this.transitionsBetween(topLeft, c2).getTransitions() -
            this.transitionsBetween(bottomRight, c2).getTransitions());
        return l1 <= l2 ? c1 : c2;
    };
    Detector.prototype.isValid = function (p) {
        return p.getX() >= 0 && p.getX() < this.image.getWidth() && p.getY() > 0 && p.getY() < this.image.getHeight();
    };
    Detector.distance = function (a, b) {
        return MathUtils_1.default.round(ResultPoint_1.default.distance(a, b));
    };
    /**
     * Increments the Integer associated with a key by one.
     */
    Detector.increment = function (table, key) {
        var value = table.get(key);
        table.set(key, value == null ? 1 : value + 1);
    };
    Detector.sampleGrid = function (image, topLeft, bottomLeft, bottomRight, topRight, dimensionX, dimensionY) {
        var sampler = GridSamplerInstance_1.default.getInstance();
        return sampler.sampleGrid(image, dimensionX, dimensionY, 0.5, 0.5, dimensionX - 0.5, 0.5, dimensionX - 0.5, dimensionY - 0.5, 0.5, dimensionY - 0.5, topLeft.getX(), topLeft.getY(), topRight.getX(), topRight.getY(), bottomRight.getX(), bottomRight.getY(), bottomLeft.getX(), bottomLeft.getY());
    };
    /**
     * Counts the number of black/white transitions between two points, using something like Bresenham's algorithm.
     */
    Detector.prototype.transitionsBetween = function (from, to) {
        // See QR Code Detector, sizeOfBlackWhiteBlackRun()
        var fromX = from.getX() | 0;
        var fromY = from.getY() | 0;
        var toX = to.getX() | 0;
        var toY = to.getY() | 0;
        var steep = Math.abs(toY - fromY) > Math.abs(toX - fromX);
        if (steep) {
            var temp = fromX;
            fromX = fromY;
            fromY = temp;
            temp = toX;
            toX = toY;
            toY = temp;
        }
        var dx = Math.abs(toX - fromX);
        var dy = Math.abs(toY - fromY);
        var error = -dx / 2;
        var ystep = fromY < toY ? 1 : -1;
        var xstep = fromX < toX ? 1 : -1;
        var transitions = 0;
        var inBlack = this.image.get(steep ? fromY : fromX, steep ? fromX : fromY);
        for (var x = fromX, y = fromY; x !== toX; x += xstep) {
            var isBlack = this.image.get(steep ? y : x, steep ? x : y);
            if (isBlack !== inBlack) {
                transitions++;
                inBlack = isBlack;
            }
            error += dy;
            if (error > 0) {
                if (y === toY) {
                    break;
                }
                y += ystep;
                error -= dx;
            }
        }
        return new ResultPointsAndTransitions(from, to, transitions);
    };
    return Detector;
}());
exports.default = Detector;
var ResultPointsAndTransitions = /** @class */ (function () {
    function ResultPointsAndTransitions(from, to, transitions) {
        this.from = from;
        this.to = to;
        this.transitions = transitions;
    }
    ResultPointsAndTransitions.prototype.getFrom = function () {
        return this.from;
    };
    ResultPointsAndTransitions.prototype.getTo = function () {
        return this.to;
    };
    ResultPointsAndTransitions.prototype.getTransitions = function () {
        return this.transitions;
    };
    // @Override
    ResultPointsAndTransitions.prototype.toString = function () {
        return this.from + '/' + this.to + '/' + this.transitions;
    };
    ResultPointsAndTransitions.resultPointsAndTransitionsComparator = function (o1, o2) {
        return o1.getTransitions() - o2.getTransitions();
    };
    return ResultPointsAndTransitions;
}());
//# sourceMappingURL=Detector.js.map
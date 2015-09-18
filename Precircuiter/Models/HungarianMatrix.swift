//
//  HungarianMatrix.swift
//  Precircuiter
//
//  Created by Harry Shamansky on 8/3/14.
//
//  Based on Java implementation of Hungarian Algorithm
//  http://robotics.stanford.edu/~gerkey/tools/Hungarian.java

import Cocoa

protocol HungarianMatrixDelegate {
    func didUpdateProgress(progress: Double)
}

class HungarianMatrix {
    private var matrix: DoubleMatrix
    private var stars: IntMatrix
    private var rCov: [Bool]
    private var cCov: [Bool]
    private var rows: Int
    private var columns: Int
    private var dimension: Int
    private var solutions: Int
    
    internal var delegate: HungarianMatrixDelegate?
    
    // columns = agents = dimmers
    // rows = roles = lights
    
    private struct DoubleMatrix {
        let rows: Int, columns: Int
        var grid: [Double]
        init(rows: Int, columns: Int) {
            self.rows = rows
            self.columns = columns
            grid = Array(count: rows * columns, repeatedValue: 0.0)
        }
        func indexIsValidForRow(row: Int, column: Int) -> Bool {
            return row >= 0 && row < rows && column >= 0 && column < columns
        }
        subscript(row: Int, column: Int) -> Double {
            get {
                assert(indexIsValidForRow(row, column: column), "Index out of range")
                return grid[(row * columns) + column]
            }
            set {
                assert(indexIsValidForRow(row, column: column), "Index out of range")
                grid[(row * columns) + column] = newValue
            }
        }
    }
    
    private struct IntMatrix {
        let rows: Int, columns: Int
        var grid: [Int]
        init(rows: Int, columns: Int) {
            self.rows = rows
            self.columns = columns
            grid = Array(count: rows * columns, repeatedValue: 0)
        }
        func indexIsValidForRow(row: Int, column: Int) -> Bool {
            return row >= 0 && row < rows && column >= 0 && column < columns
        }
        subscript(row: Int, column: Int) -> Int {
            get {
                assert(indexIsValidForRow(row, column: column), "Index out of range")
                return grid[(row * columns) + column]
            }
            set {
                assert(indexIsValidForRow(row, column: column), "Index out of range")
                grid[(row * columns) + column] = newValue
            }
        }
    }
    
    init(rows: Int, columns: Int) {
        self.rows = rows
        self.columns = columns
        self.dimension = max(rows, columns)
        self.solutions = self.dimension
        self.matrix = DoubleMatrix(rows: rows, columns: columns)
        self.stars = IntMatrix(rows: rows, columns: columns)
        self.rCov = Array(count: rows, repeatedValue: false)
        self.cCov = Array(count: columns, repeatedValue: false)
    }
    
    
    
    // MARK: Matrix Setup
    private func createDistanceMatrix(inout dimmers: [Instrument], inout lights: [Instrument], cutCorners: Bool) throws {
        
        if dimmers.count < lights.count {
            let difference = lights.count - dimmers.count
            let alert = NSAlert()
            alert.messageText = "The plot contains more channels than available dimmers."
            alert.informativeText = "Using Vectorworks or Lightwright, add \(difference) dimmers to the plot, delete \(difference) instruments from the plot, or twofer channels so that there are the number of dimmers is greater than or equal to the number of channels."
            alert.runModal()
            throw HungarianMatrixError.MoreChannelsThanDimmers
        } else if lights.count < dimmers.count {
            let difference = dimmers.count - lights.count
            for _ in 0..<difference {
                let dummyInstrument = Instrument(UID: nil, location: nil)
                dummyInstrument.dummyInstrument = true
                lights.append(dummyInstrument)
            }
        }
        
        for i in 0..<lights.count {
            for j in 0..<dimmers.count {
                if lights[i].dummyInstrument {
                    self.matrix[i, j] = 0.0
                } else {
                    do {
                        self.matrix[i, j] = try self.dynamicType.distanceBetween(lights[i], dimmer: dimmers[j], cutCorners: cutCorners)
                    } catch {
                        throw HungarianMatrixError.CouldNotCreateMatrix
                    }
                }
            }
        }
    }
    
    // MARK: Step 0: Convert the Matrix from Maximization to Minimization
    private func max2Min() {
        var maxValue: Double = 0.0
        
        for i in 0..<rows {
            for j in 0..<columns {
                if matrix[i, j] > maxValue {
                    maxValue = matrix[i, j]
                }
            }
        }
        for i in 0..<rows {
            for j in 0..<columns {
                matrix[i, j] = maxValue - matrix[i, j]
            }
        }
    }
    
    // MARK: Step 1: Subtract Minimum in Each Row
    private func rowMin() {
        for i in 0..<rows {
            var minValue: Double = matrix[i, 0]
            for j in 1..<columns {
                if minValue > matrix[i, j] {
                    minValue = matrix[i, j]
                }
            }
            for j in 0..<columns {
                matrix[i, j] -= minValue
            }
        }
    }
    
    // MARK: Step 1.5: Subtract Minimum in Each Column
    private func colMin() {
        for j in 0..<rows {
            var minValue: Double = matrix[0, j]
            for i in 1..<columns {
                if minValue > matrix[i, j] {
                    minValue = matrix[i, j]
                }
            }
            for i in 0..<columns {
                matrix[i, j] -= minValue
            }
        }
    }
    
    // MARK: Step 2: Star the Zeros
    private func starZeros() {
        for i in 0..<rows {
            for j in 0..<columns {
                if matrix[i, j] == 0 && cCov[j] == false && rCov[i] == false {
                    stars[i, j] = 1
                    cCov[j] = true
                    rCov[i] = true
                }
            }
        }
        clearCovers()
    }
    
    // MARK: Step 3: Check for Solutions
    private func coveredColumns() -> Int {
        var k: Int = 0
        for i in 0..<rows {
            for j in 0..<columns {
                if stars[i, j] == 1 {
                    cCov[j] = true
                }
            }
        }
        for j in 0..<columns {
            if cCov[j] {
                k++
            }
        }
        return k
    }
    
    // MARK: Step 4: Cover Zeros (calls step 5)
    private func coverZeros() -> Bool {
        while (findUncoveredZero() != nil) {
            if let (zeroRow, zeroCol) = findUncoveredZero() {
                stars[zeroRow, zeroCol] = 2
                if let starCol = foundStarInRow(zeroRow) {
                    rCov[zeroRow] = true
                    cCov[starCol] = false
                } else {
                    starZeroInRow((zeroRow, zeroCol))
                    return false
                }
            }
        }
        return true
    }
    
    private func starZeroInRow(position: (Int, Int)) {
        let (zeroRow, zeroCol) = position
        var count: Int = 0
        var path: IntMatrix = IntMatrix(rows: 100, columns: 2)
        path[count, 0] = zeroRow
        path[count, 1] = zeroCol
        var done: Bool = false
        
        while (!done) {
            if let r = findStarInCol(path[count, 1]) {
                count++
                path[count, 0] = r
                path[count, 1] = path[count-1, 1]
            } else {
                done = true
                break
            }
            let c = findPrimeInRow(path[count, 0])
            count++
            path[count, 0] = path[count-1, 0]
            path[count, 1] = c
        }
        convertPath(path, count: count)
        clearCovers()
        erasePrimes()
    }
    
    private func findUncoveredZero() -> (Int, Int)? {
        for i in 0..<rows {
            for j in 0..<columns {
                if matrix[i, j] == 0 && rCov[i] == false && cCov[j] == false {
                    return (i, j)
                }
            }
        }
        return nil
    }
    
    private func foundStarInRow(zeroY: Int) -> Int? {
        for j in 0..<columns {
            if stars[zeroY, j] == 1 {
                return j
            }
        }
        return nil
    }
    
    private func findStarInCol(col: Int) -> Int? {
        if col < 0 {
            assert(false, "column out of range")
        }
        for i in 0..<self.rows {
            if stars[i, col] == 1 {
                return i
            }
        }
        return nil
    }
    
    private func findPrimeInRow(row: Int) -> Int {
        for j in 0..<self.columns {
            if stars[row, j] == 2 {
                return j
            }
        }
        print("No prime in row \(row) found")
        return -1
    }
    
    private func convertPath(path: IntMatrix, count: Int) {
        for i in 0...count {
            let x = path[i, 0]
            let y = path[i, 1]
            if stars[x, y] == 1 {
                stars[x, y] = 0
            } else if stars[x, y] == 2 {
                stars[x, y] = 1
            }
        }
    }
    
    private func erasePrimes() {
        for i in 0..<self.rows {
            for j in 0..<self.columns {
                if stars[i, j] == 2 {
                    stars[i, j] = 0
                }
            }
        }
    }
    
    private func findSmallestUncoveredVal() -> Double {
        var minValue: Double = Double(UINT32_MAX)
        for i in 0..<self.rows {
            for j in 0..<self.columns {
                if rCov[i] == false && cCov[j] == false {
                    if minValue > matrix[i, j] {
                        minValue = matrix[i, j]
                    }
                }
            }
        }
        return minValue
    }
    
    private func uncoverSmallest(smallest: Double) {
        for i in 0..<self.rows {
            for j in 0..<self.columns {
                if rCov[i] == true {
                    matrix[i, j] += smallest
                }
                if cCov[j] == false {
                    matrix[i, j] -= smallest
                }
            }
        }
    }
    
    private func freeRow(row: Int, col: Int) -> Bool {
        for i in 0..<self.rows {
            if i != row && stars[i, col] == 1 {
                return false
            }
        }
        return true
    }
    
    private func freeCol(row: Int, col: Int) -> Bool {
        for j in 0..<self.columns {
            if j != col && stars[row, j] == 1 {
                return false
            }
        }
        return true
    }
    
    // MARK: Solving
    private func solve() {
        // uncomment this line to maximize
        //self.max2Min()
        self.rowMin()
        self.colMin()
        self.starZeros()
        var done: Bool = false
        
        while (done == false) {
            let covCols = coveredColumns()
            
            //print("\(covCols)/\(solutions)")
            delegate?.didUpdateProgress(Double(covCols) / Double(solutions))
            
            if covCols >= solutions {
                break
            }
            done = coverZeros()
            
            while (done == true) {
                let smallest: Double = findSmallestUncoveredVal()
                uncoverSmallest(smallest)
                done = coverZeros()
            }
        }
        delegate?.didUpdateProgress(1.0)
    }
    
    // MARK: Returning Solutions
    // returns pairs of solutions as an array of (Dimmer Number, Light Number)
    private func getSolutions() -> [(Int, Int)] {
        var solutions: [(Int, Int)] = []
        for j in 0..<self.columns {
            for i in 0..<self.rows {
                if stars[i, j] == 1 && (freeRow(i, col: j) || freeCol(i, col: j)) {
                    solutions.append((j, i))
                }
            }
        }
        return solutions
    }
    
    // MARK: Assignment
    // These are the functions that other files should call
    
    // pairs lights and dimmers
    internal func assignAndPair(inout lights: [Instrument], inout dimmers: [Instrument], cutCorners: Bool, completion: () -> ()) {
        
        if let mainViewController = delegate as? NSViewController {
            mainViewController.view.window?.undoManager?.disableUndoRegistration()
        }
        
        do {
            try createDistanceMatrix(&dimmers, lights: &lights, cutCorners: cutCorners)
        } catch HungarianMatrixError.MoreChannelsThanDimmers {
            // alert is shown before we throw the error
            return
        } catch {
            let alert = NSAlert()
            alert.messageText = "Error Precircuiting"
            alert.informativeText = "Precircuiter encountered an unknown error when attempting to precircuit your plot. Please verify that the data you imported is valid."
            alert.runModal()
            return
        }
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), {
            self.solve()
            dispatch_async(dispatch_get_main_queue(), {
                let pairs = self.getSolutions()
                
                // connect the pairs
                for (dim, light) in pairs {
                    if lights[light].dummyInstrument == false {
                        lights[light].receptacle = dimmers[dim]
                        lights[light].dimmer = dimmers[dim].dimmer
                        lights[light].assignedBy = .Auto
                        dimmers[dim].light = lights[light]
                        dimmers[dim].assignedBy = .Auto
                    }
                }
                
                // filter out the dummy instruments
                lights = lights.filter({ $0.dummyInstrument != true })
                
                if let mainViewController = self.delegate as? NSViewController {
                    mainViewController.view.window?.undoManager?.enableUndoRegistration()
                }
                
                completion()
            })
        })
    }
    
    internal func printPatch(lights: [Instrument], dimmers: [Instrument]) {
        for dimmer in dimmers {
            if let light = dimmer.light {
                print("Dimmer \(dimmer.dimmer) = Light \(light.channel)")
            } else {
                print("Dimmer \(dimmer.dimmer) is free")
            }
        }
    }
    
    
    // MARK: Utilities
    internal class func distanceBetween(light: Instrument, dimmer: Instrument, cutCorners: Bool) throws -> Double {
        
        func simpleDistBetween(coordinate1: Coordinate, coordinate2: Coordinate, cutCorners: Bool) -> Double {
            let xd: Double = Double(abs(coordinate1.x - coordinate2.x))
            let yd: Double = Double(abs(coordinate1.y - coordinate2.y))
            let zd: Double = Double(abs(coordinate1.z - coordinate2.z))
            if cutCorners {
                return Double(sqrt((xd*xd) + (yd*yd) + (zd*zd)))
            } else {
                return Double((xd + yd + zd))
            }
        }
        
        if light.locations.count == 1 && dimmer.locations.count == 1 {    // one-to-one pairing
            
            guard let p1 = light.locations.first, p2 = dimmer.locations.first else {
                throw HungarianMatrixError.NoLocationSpecified
            }
            return simpleDistBetween(p1, coordinate2: p2, cutCorners: cutCorners)
            
        } else if light.locations.count == 1 && dimmer.locations.count >= 1 { // doubled dimmers
            
            guard let lightLocation = light.locations.first else {
                throw HungarianMatrixError.NoLocationSpecified
            }
            
            var shortestDist = Double(UINT32_MAX)
            for coord in dimmer.locations {
                let newDist = simpleDistBetween(lightLocation, coordinate2: coord, cutCorners: cutCorners)
                if newDist < shortestDist {
                    shortestDist = newDist
                }
            }
            return shortestDist
            
        } else if light.locations.count >= 1 && dimmer.locations.count == 1 { // twoferred
            
            // TODO: Inflate the value if the dimmer in question is not of sufficient capacity
            // will have to cast wattage to Double
            
            guard let dimmerLocation = dimmer.locations.first else {
                throw HungarianMatrixError.NoLocationSpecified
            }
            
            // TODO: Does this need refinement? Or is just combining the distance as if it were two runs the right call?
            var total: Double = 0.0
            for coord in light.locations {
                total += simpleDistBetween(dimmerLocation, coordinate2: coord, cutCorners: cutCorners)
            }
            return total
            
        } else if light.locations.count >= 1 && dimmer.locations.count >= 1 { // doubled dimmers AND twoferred
            
            // TODO: This is a really naïve greedy implementation. If there are fewer
            // light locations than there are dimmer locations, greedy is probably fine
            // but if there are a lot of lights around only a few dimmers, we should
            // group the lights using a clustering algorithm and then calculate the
            // distance based on what group the light is in
            
            var usedDimmerIndices: [Int] = []
            var total: Double = 0.0
            
            for lCoord in light.locations {
                
                var shortestDist = Double(UINT32_MAX)
                var shortestIndex = 0
                
                for (i, dCoord) in dimmer.locations.enumerate() {
                    if usedDimmerIndices.contains(i) == false {
                        let newDist = simpleDistBetween(lCoord, coordinate2: dCoord, cutCorners: cutCorners)
                        if newDist < shortestDist {
                            shortestDist = newDist
                            shortestIndex = i
                        }
                    }
                }
                usedDimmerIndices.append(shortestIndex)
                total += simpleDistBetween(lCoord, coordinate2: dimmer.locations[shortestIndex], cutCorners: cutCorners)
            }
            return total
        } else {
            throw HungarianMatrixError.NoLocationSpecified
        }
    }
    
    private func clearCovers() {
        for i in 0..<rows {
            rCov[i] = false
        }
        for j in 0..<columns {
            cCov[j] = false
        }
    }
    
    // MARK: Printing for Debugging
    private func printMatrix() {
        for i in 0..<rows {
            for j in 0..<columns {
                print(self.matrix[i, j], terminator: "")
                print(" ", terminator: "")
            }
            print("")
        }
    }
    
    private func printStars() {
        for i in 0..<rows {
            for j in 0..<columns {
                print(stars[i, j], terminator: "")
                print(" ", terminator: "")
            }
            print(rCov[i])
        }
        for j in 0..<columns {
            print(cCov[j], terminator: "")
            print(" ", terminator: "")
        }
        print("")
    }
    
    private func printStarZeros() {
        for i in 0..<rows {
            for j in 0..<columns {
                if stars[i, j] == 1 && (freeRow(i, col: j) || freeCol(i, col: j)) {
                    print("\(i) assigned to \(j) is a solution.")
                }
            }
        }
    }
    
}
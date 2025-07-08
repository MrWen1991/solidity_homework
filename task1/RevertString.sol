// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

// ✅ 反转字符串 (Reverse String)
// 题目描述：反转一个字符串。输入 "abcde"，输出 "edcba"

contract RevertString {
    function revert_string(string memory s)
        public
        pure
        returns (string memory)
    {
        bytes memory buffer = bytes(s);
        uint256 len = buffer.length;
        bytes memory outBuffer = new bytes(len);
        for (uint256 i = 0; i < len; i++) {
            outBuffer[i] = buffer[len - i - 1];
        }

        return string(outBuffer);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

// 用 solidity 实现罗马数字转数整数
// 题目描述在 https://leetcode.cn/problems/roman-to-integer/description/3.
/**
罗马数字包含以下七种字符: I， V， X， L，C，D 和 M。

字符          数值
I             1
V             5
X             10
L             50
C             100
D             500
M             1000
例如， 罗马数字 2 写做 II ，即为两个并列的 1 。12 写做 XII ，即为 X + II 。 27 写做  XXVII, 即为 XX + V + II 。

通常情况下，罗马数字中小的数字在大的数字的右边。但也存在特例，例如 4 不写做 IIII，而是 IV。数字 1 在数字 5 的左边，所表示的数等于大数 5 减小数 1 得到的数值 4 。同样地，数字 9 表示为 IX。这个特殊的规则只适用于以下六种情况：

I 可以放在 V (5) 和 X (10) 的左边，来表示 4 和 9。
X 可以放在 L (50) 和 C (100) 的左边，来表示 40 和 90。 
C 可以放在 D (500) 和 M (1000) 的左边，来表示 400 和 900。
给定一个罗马数字，将其转换成整数。
**/

contract RomanToInt {
    mapping(bytes1 => uint256) public _map;

    constructor() {
        _map[bytes1("I")] = 1;
        _map[bytes1("V")] = 5;
        _map[bytes1("X")] = 10;
        _map[bytes1("L")] = 50;
        _map[bytes1("C")] = 100;
        _map[bytes1("D")] = 500;
        _map[bytes1("M")] = 1000;
    }

    function roman2Int(string memory s) public view returns (uint256) {
        bytes memory b = bytes(s);
        uint256 len = b.length;
        uint256 res = 0;
        uint256 last = 0;
        uint256 curr = 0;
        for (uint8 i = 0; i < len; i++) {
            last = curr;
            curr = _map[b[i]];
            if (curr > last) {
                res += curr;
                res -= 2 * last;
            } else {
                res += curr;
            }
        }
        return res;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

// 合并两个有序数组 (Merge Sorted Array)
// 题目描述：将两个有序数组合并为一个有序数组。

contract MergeTwoArray {
    function merge(uint256[] memory arr1, uint256[] memory arr2)
        public
        pure
        returns (uint256[] memory)
    {
        uint256 idx1 = 0;
        uint256 idx2 = 0;
        uint256 l1 = arr1.length;
        uint256 l2 = arr2.length;
        uint256[] memory res= new uint256[](l1 + l2);
        for (uint256 i = 0; i < l1 + l2; i++) {
            if (idx1 < l1 && idx2 < l2) {
                if (arr1[idx1] <= arr2[idx2]) {
                    res[i] = arr1[idx1];
                    idx1++;
                } else {
                    res[i] = arr2[idx2];
                    idx2++;
                }
                continue;
            } else if (idx1 < l1) {
                res[i] = arr1[idx1];
                idx1++;
            } else if (idx2 < l2) {
                res[i] = arr2[idx2];
                idx2++;
            }
            
        }
        return res;
    }
}

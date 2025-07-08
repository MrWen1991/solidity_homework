// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

// 二分查找 (Binary Search)
// 题目描述：在一个有序数组中查找目标值。
contract BinarySearch{
    function search(uint256[]memory arr, uint256 target)public pure returns(uint256){
        uint256 left = 0;
        uint256 right = arr.length -1;
        uint256 mid ;
        while(left <= right){
            mid = left + (right-left)/2;
            if(arr[mid] < target){
                left = mid + 1;
            }else if (arr[mid] == target){
                return mid;
            }else{
                right = mid -1;
            }
        }
        return mid;   
    }
}
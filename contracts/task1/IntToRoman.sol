// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract IntToRoman {
    mapping(uint256 => string) private _map;
    uint256[] private _arr = [1000,900,500,400,100,90,50,40,10,9,5,4,1];
    constructor() {
        _map[1] = "I";
        _map[4] = "IV";
        _map[5] = "V";
        _map[9] = "IX";
        _map[10] = "X";
        _map[40] = "XL";
        _map[50] = "L";
        _map[90] = "XC";
        _map[100] = "C";
        _map[400] = "CD";
        _map[500] = "D";
        _map[900] = "CM";
        _map[1000] = "M";
    }

    function intToRoman(uint256 num) public view returns (string memory) {
        uint256 len = _arr.length;
        uint256 idx = 0;
        bytes memory bts = new bytes(15*10);
        bytes memory curr;
        uint256 ix = 0;
        while(num > 0 && idx < len){
            if(num < _arr[idx]){
                idx ++;
                continue;
            }else{
                num -= _arr[idx];
                curr =bytes(_map[_arr[idx]]);
                for(uint256 i =0;i<curr.length;i++){
                    bts[ix++]=curr[i];
                }
            }

        }
        return string(bts);

    }


}

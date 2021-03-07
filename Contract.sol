// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.8.0;

/**
 * @title Storage
 * @dev Store & retrieve value in a variable
 */
contract Contract {

    // owner account id
    address payable owner;
    
    // last win 
    string public lastWin = "None";
    // new bet 1
    string public option1 = "GME";
    // new bet 2
    string public option2 = "AMC";
    
    Bidder[10] public bidders;
    
    uint public bidderCount = 0;
    uint public runningEther0 = 0;
    uint public runningEther1 = 0;

    struct Bidder {
        uint betAmount;
        address payable bidderAddress;
        bool vote;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function setWin(string memory _lastWin, bool _index, string memory _opt1, string memory _opt2) payable public onlyOwner {
        lastWin = _lastWin;
        option1 = _opt1;
        option2 = _opt2;
        
        uint winEther;
        uint lostEther;
        if (_index==false) {
            winEther =  runningEther0;
            lostEther = runningEther1;
        } else {
            winEther =  runningEther1;
            lostEther = runningEther0;
        }

        uint i;
        for (i = 0; i < bidderCount; i++) {
            if (bidders[i].vote == _index) {
                bidders[i].bidderAddress.send(bidders[i].betAmount);  //returning original ether
                bidders[i].bidderAddress.send(lostEther*(bidders[i].betAmount/winEther)); //profit payback
            }     
        }

    }
    
    function bid(bool _index) public payable {
        require(msg.value > 0);
        if(bidderCount < bidders.length) {
            bidders[bidderCount].betAmount = msg.value;
            bidders[bidderCount].bidderAddress = msg.sender;
            bidders[bidderCount].vote = _index;
            bidderCount++;
            owner.send(msg.value);
            if (_index == false) {
                runningEther0+= msg.value;
            } else {
                runningEther1+= msg.value;
            } 
        }
    }
}

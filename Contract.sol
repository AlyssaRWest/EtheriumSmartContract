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
    
    
    //group $$$
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
    
    function setWin(string memory _lastWin, uint8 _index, string memory _opt1, string memory _opt2) public onlyOwner {
        lastWin = _lastWin;
        option1 = _opt1;
        option2 = _opt2;
        
        uint winEther;
        uint lostEther;
        bool winBid;
        if (_index==0) {
            winEther =  runningEther0;
            lostEther = runningEther1;
            winBid = false;
        } else {
            winEther =  runningEther1;
            lostEther = runningEther0;
            winBid = true;
        }
        
        uint i;
        for (i = 0; i < 10; i++) { //returning original ether
            if (bidders[i].vote == winBid) {
                bidders[i].bidderAddress.send(bidders[i].betAmount);
            }     
        }
        // bidder 1(0): 1
        // bidder 2(0): 10
        // bidder 3(1): 10
        // (runningEther0) won
        // bidder 1: 1 (og)
        // bidder 1: lostEther*(bidder[1].betAmount/winEther)

    }
    
    // function owner only:
        //auth
        //set last win
        //change bet 1 and bet 2
        //distribute the $$$
        
    
    function bid(bool _index) public payable {
        require(msg.value > 0);
        if(bidderCount < 10) {
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

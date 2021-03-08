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
    uint public runningEther1 = 0;
    uint public runningEther2 = 0;

    struct Bidder {
        uint betAmount;
        address payable bidderAddress;
        uint8 vote;
    }
    
    constructor() {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
    function setWin(string memory _lastWin, uint8 _index, string memory _opt1, string memory _opt2) payable public onlyOwner {
        lastWin = _lastWin;
        option1 = _opt1;
        option2 = _opt2;
        
        uint winEther;
        uint lostEther;
        if (_index==1) {
            winEther =  runningEther1;
            lostEther = runningEther2;
        } else {
            winEther =  runningEther2;
            lostEther = runningEther1;
        }

        uint i;
        for (i = 0; i < bidderCount; i++) {
            if (bidders[i].vote == _index) {
                bidders[i].bidderAddress.transfer(bidders[i].betAmount);  //returning original ether
                bidders[i].bidderAddress.transfer(lostEther*(bidders[i].betAmount/winEther)); //profit payback
            }     
        }
    
        reset(); //clean up
    }
    
    function reset() private {
        runningEther1 = 0;
        runningEther2 = 0;
        uint i;
        for (i = 0; i < bidderCount; i++) { 
                bidders[i].betAmount = 0; 
                bidders[i].bidderAddress = 0x0000000000000000000000000000000000000000;
                bidders[i].vote = 0;
        }
        bidderCount = 0;
    }
    function bid(bool _index) public payable {
        require(msg.value > 0);
        if(bidderCount < bidders.length) {
            bidders[bidderCount].betAmount = msg.value;
            bidders[bidderCount].bidderAddress = msg.sender;
            bidders[bidderCount].vote = _index;
            bidderCount++;
            owner.transfer(msg.value);
            if (_index == false) {
                runningEther1+= msg.value;
            } else {
                runningEther2+= msg.value;
            } 
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Lottery {
    address public  immutable manager;
    address payable[] public participants;
    uint public constant commissionPercentage = 10; 
     uint256 public  managerCommission=0;
     uint256 public amountToWinner=0;

     uint256 public constant minParticipants = 4; 
     uint256 public immutable lotteryStartTimeBlock;
     uint256 public immutable lotteryEndTimeBlock;

   constructor() {
      manager = msg.sender;
      lotteryStartTimeBlock = block.number + 60; // Start after 60 blocks
      lotteryEndTimeBlock = lotteryStartTimeBlock + 120; // End after an additional 120 blocks
}


    mapping (address => uint256) public  userAmount;
    receive() external payable {

    }

    function addEtherToContract() public payable  {
     require(block.number >= lotteryStartTimeBlock,"Lottery Not Started Yet");
     require(block.number < lotteryEndTimeBlock,"Lottery is Now Ended");
     require(msg.value == 100 wei, "You must send exactly 100 Wei to participate");
     participants.push(payable(msg.sender));
     userAmount[msg.sender]  = msg.value;
}


    function getBalance() public view returns (uint) {
        require(msg.sender == manager, "You are not the manager");
        return address(this).balance;
    }

    function random() internal view returns(uint) {
        bytes32 hash = blockhash(block.number - 1);
        return uint(keccak256(abi.encodePacked(hash, participants.length, block.timestamp)));
    }

    address payable public winner;

    modifier someCondition{
        require(msg.sender == manager, "You are not the manager");
        require(block.timestamp > lotteryEndTimeBlock,"Lottery is Not Ended Yet");
        _;
    }

    function pickWinner() public someCondition {
        require(participants.length >= minParticipants, "There is a Not Enough(3) participants In Your Lottery");
        
        uint256 r = random();
        uint256 index = r % participants.length;
        winner = participants[index];

        managerCommission = (address(this).balance * commissionPercentage) / 100;
        amountToWinner = address(this).balance - managerCommission;

        winner.transfer(amountToWinner);
        payable(manager).transfer(managerCommission);
        participants = new address payable[](0);
    }

    function retunAmount() public someCondition {
    require(!(participants.length >= minParticipants), "There are enough participants in the lottery");
    managerCommission = (address(this).balance * 1) / 100;
    payable(manager).transfer(managerCommission);

    uint256 participantCount = participants.length;

    for (uint i = 0; i < participantCount; i++) {
        uint256 returnAmount = (userAmount[participants[i]] * 99) / 100; 
        participants[i].transfer(returnAmount);
        userAmount[participants[i]] = 0; 
    }

    participants = new address payable[](0);
}



}


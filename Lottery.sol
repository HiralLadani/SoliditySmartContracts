// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.2 <0.9.0;

contract Lottery
{
    address public manager;
    address payable [] public participants;
    constructor (){
            manager = msg.sender;  //manager starts as the creator of the contract
        }
        
       
        
    receive() external payable
     {      require(msg.value>=1 ether);
            participants.push(payable(msg.sender));
    } 
           
          
            function random() private view returns (uint)
             {
                 return uint(keccak256(abi.encodePacked(block.timestamp, block.prevrandao,participants.length)));
            }
            function selectWinner() public 
                        {   require(msg.sender==manager);
                require(participants.length>=3);
                uint r=random();
                address payable winner;
                uint index=r%participants.length;
                winner=participants[index];
               // return winner;
                winner.transfer(getbalance());
                participants = new address payable[](0); // Initialize with empty array of the correct type.
            }
            function getbalance()public view returns (uint)
            {      ///checking if money has been withdrawn
            require(msg.sender==manager);
            return address(this).balance;  ///returns the amount of money held in the contract
        }        
}
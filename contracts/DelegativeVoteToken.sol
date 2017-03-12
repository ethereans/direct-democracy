pragma solidity ^0.4.0;

/**
 * CarbonVoteToken is a wrapped eth contract with delegative democracy token vote
 * 
 * By Ricardo Guilherme Schmidt
 * Released under GPLv3 License
 */

import "lib/ethereans/abstract-token/WrappedEthToken.sol";

contract DelegativeVoteToken is WrappedEthToken {

    mapping (address => uint256) private votes;
    mapping (address => address) private delegation;
    event Delegate(address who, address to);

    function deposit()
     payable {
        votes[delegation[msg.sender]] += msg.value;
        super.deposit();
     }

    function destroy(address _from, uint _value)
     internal {
        votes[delegation[_from]] -= _value;
        super.destroy(_from, _value); 
    }
    
    function transferFrom(address _from, address _to, uint256 _value) 
     returns (bool) {
        votes[delegation[_from]] -= _value;
        votes[delegation[_to]] += _value;
        return super.transferFrom(_from, _to, _value);
    }
    
    function transfer(address _to, uint256 _value) 
     returns (bool) {
         votes[delegation[msg.sender]] -= _value;
         votes[delegation[_to]] += _value;
         return super.transfer(_to, _value);
    }
    
    function delegate(address _to) {
        uint256 amount = balanceOf(msg.sender);
        votes[delegation[msg.sender]] -= amount;
        delegation[msg.sender] = _to;
        votes[delegation[msg.sender]] += amount;
        Delegate(msg.sender, _to);
    }
    
    function delegationOf(address _who)
     constant 
     returns(address) {
        return delegation[_who];
    }
    
    function votesOf(address _who)
     constant 
     returns(uint256) {
        return votes[_who];
    }

}
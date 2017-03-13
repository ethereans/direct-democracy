pragma solidity ^0.4.9;

/**
 * CarbonVoteToken is a wrapped eth contract with delegative democracy token vote
 * 
 * By Ricardo Guilherme Schmidt
 * Released under GPLv3 License
 */

import "lib/ethereans/abstract-token/WrappedEthToken.sol";

contract DelegativeVoteToken is WrappedEthToken {

    mapping (address => uint256) private votes;
    mapping (address => Delegation) private delegations;
    event Delegate(address who, address to);
    
    struct Delegation {
     uint256 fromLenght;
     mapping (uint256 => address) fromIndex;
     mapping (address => uint256) from;
     address to;
     uint256 toIndex;
    }
    

    function deposit()
     payable {
        votes[delegationOf(msg.sender)] += msg.value;
        super.deposit();
     }

    function destroy(address _from, uint _value)
     internal {
        votes[delegationOf(_from)] -= _value;
        super.destroy(_from, _value); 
    }
    
    function transferFrom(address _from, address _to, uint256 _value) 
     returns (bool) {
        votes[delegationOf(_from)] -= _value;
        votes[delegationOf(_to)] += _value;
        return super.transferFrom(_from, _to, _value);
    }
    
    function transfer(address _to, uint256 _value) 
     returns (bool) {
         votes[delegationOf(msg.sender)] -= _value;
         votes[delegationOf(_to)] += _value;
         // Todo: transfer delegation 
         return super.transfer(_to, _value);
    }
    
    function setDelegation(address _from, address _to) 
     internal{
        address _oldTo = delegations[_from].to; //the delegation to be undone
        if(_oldTo != 0x0) {
            uint256 _oldToIndex = delegations[_from].toIndex; //msg.sender index in Delegator from list.
            delete delegations[_oldTo].from[_from]; //delete our votes
            delegations[_oldTo].fromLenght--;
            if(_oldToIndex < delegations[_oldTo].fromLenght)
                delegations[_oldTo].fromIndex[_oldToIndex] = delegations[_oldTo].fromIndex[delegations[_oldTo].fromLenght]; //put latest index in place of msg.sender position
            delete delegations[_oldTo].fromIndex[delegations[_oldTo].fromLenght]; //clear impossible position;
        }
        if(_to != 0x0) {
            uint256 newPos = delegations[_to].fromLenght;
            delegations[_to].from[_from] =  balanceOf(_from) +  votesDelegatedTo(_from); // include our votes in delegator data
            delegations[_to].fromIndex[newPos] = _from; //add account into stack mapped to lenght
            delegations[_from].toIndex = newPos; //register the index of our address delegation (for mapping clean)
            delegations[_to].fromLenght++; 
        } els {
            delegations[_from].toIndex = 0;
        }
        delegations[_from].to = _to; //register where our delegation is going
    }
    
    function delegate(address _to) {
        if(_to == msg.sender) throw;
        Delegate(msg.sender,_to);
        setDelegation(msg.sender,_to);
    }
    
    function delegationOf(address _who)
     constant 
     returns(address) {
        if(delegations[_who].to != 0x0) 
         return delegationOf(delegations[_who].to);
        return _who;
    }
    
    function votesDelegatedTo(address _who)
     constant
     returns(uint256 total) {
        total = 0;
        for(uint256 i = 0; delegations[_who].fromLenght > i;i++)  
            total += delegations[_who].from[delegations[_who].fromIndex[i]]; //sum the from delegation votes
    }

    
    function votesOf(address _who)
     constant 
     returns(uint256) {
        return votes[_who];
    }

}
pragma solidity ^0.4.9;

/**
 * CarbonVoteToken is a wrapped eth contract with delegative democracy token vote
 * 
 * By Ricardo Guilherme Schmidt
 * Released under GPLv3 License
 */

import "lib/ethereans/abstract-token/WrappedEthToken.sol";

contract DelegativeVoteToken is WrappedEthToken {
    
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
        super.deposit();
         _forwardDelegation(msg.sender);
     }

    function destroy(address _from, uint _value)
     internal {
        super.destroy(_from, _value); 
         _forwardDelegation(_from);
    }
    
    function transferFrom(address _from, address _to, uint256 _value) 
     returns (bool) {
         super.transferFrom(_from, _to, _value);
         _forwardDelegation(_from);
         _forwardDelegation(_to);
        return true;    
    }
    
    function transfer(address _to, uint256 _value) 
     returns (bool) {
         super.transfer(_to, _value);
        _forwardDelegation(msg.sender);
        _forwardDelegation(_to);
        return true;
    }
    
    function delegate(address _to) {
        address _from = msg.sender;
        if(delegationOf(_to) == _from) throw; //impossible circular delegation

        Delegate(msg.sender,_to);
        address _oldTo = delegations[_from].to; //the delegation to be undone
        if(_oldTo != 0x0) {
            uint256 _oldToIndex = delegations[_from].toIndex; //msg.sender index in Delegator from list.
            delete delegations[_oldTo].from[_from]; //delete our votes
            delegations[_oldTo].fromLenght--;
            if(_oldToIndex < delegations[_oldTo].fromLenght)
                delegations[_oldTo].fromIndex[_oldToIndex] = delegations[_oldTo].fromIndex[delegations[_oldTo].fromLenght]; //put latest index in place of msg.sender position
            delete delegations[_oldTo].fromIndex[delegations[_oldTo].fromLenght]; //clear impossible position;
            _forwardDelegation(_oldTo); //update values
        }
        
        delegations[_from].to = _to; //register where our delegation is going
        if(_to != 0x0) {
            uint256 newPos = delegations[_to].fromLenght;
            _forwardDelegation(_from); //update values
            delegations[_to].fromIndex[newPos] = _from; //add account into stack mapped to lenght
            delegations[_from].toIndex = newPos; //register the index of our address delegation (for mapping clean)
            delegations[_to].fromLenght++; 
        } else {
            delegations[_from].toIndex = 0;
        }
        
    }
    
    function _forwardDelegation(address _from)
     internal {
        if(delegations[_from].to != 0x0){
            delegations[delegations[_from].to].from[_from] = votesDelegatedTo(_from); // include our votes in delegator data
            _forwardDelegation(delegations[_from].to);
        }
    }
    
    function votesDelegatedTo(address _who)
     constant
     returns(uint256 total) {
        total = 0;
        for(uint256 i = 0; delegations[_who].fromLenght > i;i++)  
            total += delegations[_who].from[delegations[_who].fromIndex[i]]; //sum the from delegation votes
        total += balanceOf(_who);
    }

    function delegationOf(address _who)
     constant 
     returns(address) {
        if(delegations[_who].to != 0x0) 
         return delegationOf(delegations[_who].to);
        return _who;
    }  
    
    function votesOf(address _who)
     constant 
     returns(uint256) {
        if(delegations[_who].to == 0x0) 
            return votesDelegatedTo(_who);
        else return 0;
    }

}
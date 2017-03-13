pragma solidity ^0.4.9;

/**
 * LiquidDelegativeDemocracy is an abstract contract to issue delegateable votes from a source _votesSource; 
 * 
 * By Ricardo Guilherme Schmidt
 * Released under GPLv3 License
 */

contract LiquidDelegativeDemocracy {
    
    mapping (address => Delegation) private delegations;
    event Delegate(address who, address to);
    
    struct Delegation {
     uint256 fromLenght;
     mapping (uint256 => address) fromIndex;
     mapping (address => uint256) from;
     address to;
     uint256 toIndex;
     
    }
    
    //returns the destination of an account's votes
    function delegationOf(address _who)
     constant returns(address) {
        if(delegations[_who].to != 0x0) 
         return delegationOf(delegations[_who].to);
        return _who;
    }  
    
    //returns the voting power of an account
    function votesOf(address _who)
     constant returns(uint256) {
        if(delegations[_who].to == 0x0) 
            return _votesDelegatedTo(_who);
        else return 0;
    }   
    
    //changes the delegation of an account, if _to 0x00: self delegation (become voter)
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
            _updateDelegation(_oldTo); //update values
        }
        
        delegations[_from].to = _to; //register where our delegation is going
        if(_to != 0x0) {
            uint256 newPos = delegations[_to].fromLenght;
            _updateDelegation(_from); //update values
            delegations[_to].fromIndex[newPos] = _from; //add account into stack mapped to lenght
            delegations[_from].toIndex = newPos; //register the index of our address delegation (for mapping clean)
            delegations[_to].fromLenght++; 
        } else {
            delegations[_from].toIndex = 0;
        }
        
    }
    //updates the delegation votes (need to be called when _votesSource(_from) changes)
    function _updateDelegation(address _from)
     internal {
        if(delegations[_from].to != 0x0){
            delegations[delegations[_from].to].from[_from] = _votesDelegatedTo(_from); // include our votes in delegator data
            _updateDelegation(delegations[_from].to);
        }
    }
    
    //returns the votes a account delegates
    function _votesDelegatedTo(address _who)
     internal
     constant returns(uint256 total) {
        total = 0;
        for(uint256 i = 0; delegations[_who].fromLenght > i;i++)  
            total += delegations[_who].from[delegations[_who].fromIndex[i]]; //sum the from delegation votes
        total += _votesSource(_who); // source of votes
    }
    
    //abstract function to return the votes each account owns
    function _votesSource(address _who)
     internal 
     constant returns (uint256);
    


}
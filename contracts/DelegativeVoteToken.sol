pragma solidity ^0.4.9;

/**
 * DelegativeVoteToken is a Liquid Delegative Democracy contract with votes source from wrapped eth in contract.
 * 
 * By Ricardo Guilherme Schmidt
 * Released under GPLv3 License
 */

import "lib/ethereans/abstract-token/WrappedEthToken.sol";
import "./LiquidDelegativeDemocracy.sol";

contract DelegativeVoteToken is WrappedEthToken, LiquidDelegativeDemocracy {
    
    function deposit()
     payable {
        super.deposit();
         _updateDelegation(msg.sender);
     }

    function destroy(address _from, uint _value)
     internal {
        super.destroy(_from, _value); 
         _updateDelegation(_from);
    }
    
    function transferFrom(address _from, address _to, uint256 _value) 
     returns (bool) {
         super.transferFrom(_from, _to, _value);
         _updateDelegation(_from);
         _updateDelegation(_to);
        return true;    
    }
    
    function transfer(address _to, uint256 _value) 
     returns (bool) {
         super.transfer(_to, _value);
        _updateDelegation(msg.sender);
        _updateDelegation(_to);
        return true;
    }
    
    
    function _votesSource(address _who)
    internal 
    constant returns (uint256) {
         return balanceOf(_who);
     }

}
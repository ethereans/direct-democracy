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
    
    function _balanceUpdated(address _from)
     internal {
        _updateDelegation(_from);
    }
    
    function _votesSource(address _who)
    internal 
    constant returns (uint256) {
         return balanceOf(_who);
     }

}
pragma solidity ^0.8.0;

import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {ERC1820Client} from "../../../erc1820/ERC1820Client.sol";
import {ProxyContext} from "../../../proxy/context/ProxyContext.sol";
import {ERC1820Implementer} from "../../../erc1820/ERC1820Implementer.sol";
import {ERC20ExtendableRouter} from "../extensions/ERC20ExtendableRouter.sol";
import {TokenStorage} from "../../storage/TokenStorage.sol";

contract ERC20Storage is TokenStorage, ERC20ExtendableRouter {
    string constant internal ERC20_LOGIC_INTERFACE_NAME = "ERC20TokenLogic";
    string constant internal ERC20_STORAGE_INTERFACE_NAME = "ERC20TokenStorage";
    
    constructor(address token) TokenStorage(token) {
        ERC1820Client.setInterfaceImplementation(ERC20_STORAGE_INTERFACE_NAME, address(this));
        ERC1820Implementer._setInterface(ERC20_STORAGE_INTERFACE_NAME); // For migration
    }
    
    function _getCurrentImplementationAddress() internal override view returns (address) {
        address token = _callsiteAddress();
        return ERC1820Client.interfaceAddr(token, ERC20_LOGIC_INTERFACE_NAME);
    }

    function _msgSender() internal view override(Context, ProxyContext) returns (address) {
        return ProxyContext._msgSender();
    }

    function _isExtensionFunction(bytes4 funcSig) internal override(TokenStorage, ERC20ExtendableRouter) view returns (bool) {
        ERC20ExtendableRouter._isExtensionFunction(funcSig);
    }

    function _invokeExtensionFunction() internal override(TokenStorage, ERC20ExtendableRouter) {
        ERC20ExtendableRouter._invokeExtensionFunction();
    }

    // Find facet for function that is called and execute the
    // function if a facet is found and return any value.
    fallback() external override(TokenStorage, ERC20ExtendableRouter) payable onlyToken {
        _fallback();
    }

    function registerExtension(address extension) external override onlyToken returns (bool) {
        return _registerExtension(extension);
    }

    function removeExtension(address extension) external override onlyToken returns (bool) {
        return _removeExtension(extension);
    }

    function disableExtension(address extension) external override onlyToken returns (bool) {
        return _disableExtension(extension);
    }

    function enableExtension(address extension) external override onlyToken returns (bool) {
        return _enableExtension(extension);
    }
}
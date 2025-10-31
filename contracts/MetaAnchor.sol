// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title MetaAnchor - A lightweight decentralized metadata anchoring system
/// @notice Allows users to anchor metadata hashes to their address for proof or verification

contract MetaAnchor {
    mapping(address => bytes32) private anchors;

    /// @notice Anchor a metadata hash (e.g., IPFS CID hash, content hash, etc.)
    /// @param metaHash bytes32 hash representing the metadata or content reference
    function anchorMeta(bytes32 metaHash) external {
        anchors[msg.sender] = metaHash;
    }

    /// @notice Retrieve the anchored metadata hash of a specific user
    /// @param owner address of the user
    /// @return metaHash the stored metadata hash
    function getAnchor(address owner) external view returns (bytes32 metaHash) {
        return anchors[owner];
    }

    /// @notice Clear or revoke your anchored metadata
    function clearAnchor() external {
        delete anchors[msg.sender];
    }
}

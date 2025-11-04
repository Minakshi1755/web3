// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/**
 * @title MetaAnchor
 * @notice A decentralized anchoring protocol that permanently stores proof-of-existence 
 *         for digital documents, media, and data on-chain using content hashes. 
 *         Ideal for ensuring authenticity, timestamping, and ownership verification 
 *         in digital ecosystems.
 */
contract Project {
    address public admin;
    uint256 public anchorCount;

    struct AnchorRecord {
        uint256 id;
        address creator;
        string contentHash;
        string metadataURI;
        uint256 timestamp;
        bool verified;
    }

    mapping(uint256 => AnchorRecord) public anchors;
    mapping(address => uint256[]) public userAnchors;

    event AnchorCreated(uint256 indexed id, address indexed creator, string contentHash, string metadataURI);
    event AnchorVerified(uint256 indexed id, address indexed verifier);
    event AnchorRevoked(uint256 indexed id, address indexed admin);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    modifier onlyCreator(uint256 _id) {
        require(anchors[_id].creator == msg.sender, "Only creator can modify this record");
        _;
    }

    constructor() {
        admin = msg.sender;
    }

    /**
     * @notice Create a new anchor record for a digital file or data
     * @param _contentHash Hash of the digital file (IPFS/Keccak256)
     * @param _metadataURI Optional metadata URI (e.g., IPFS link or JSON metadata)
     */
    function createAnchor(string memory _contentHash, string memory _metadataURI) external {
        require(bytes(_contentHash).length > 0, "Content hash is required");

        anchorCount++;
        anchors[anchorCount] = AnchorRecord({
            id: anchorCount,
            creator: msg.sender,
            contentHash: _contentHash,
            metadataURI: _metadataURI,
            timestamp: block.timestamp,
            verified: false
        });

        userAnchors[msg.sender].push(anchorCount);

        emit AnchorCreated(anchorCount, msg.sender, _contentHash, _metadataURI);
    }

    /**
     * @notice Verify an existing anchor record (only admin)
     * @param _id Anchor ID to verify
     */
    function verifyAnchor(uint256 _id) external onlyAdmin {
        AnchorRecord storage record = anchors[_id];
        require(!record.verified, "Already verified");

        record.verified = true;
        emit AnchorVerified(_id, msg.sender);
    }

    /**
     * @notice Revoke (invalidate) an anchor if found malicious (only admin)
     * @param _id Anchor ID to revoke
     */
    function revokeAnchor(uint256 _id) external onlyAdmin {
        AnchorRecord storage record = anchors[_id];
        require(record.verified, "Anchor not verified yet");

        record.verified = false;
        emit AnchorRevoked(_id, msg.sender);
    }

    /**
     * @notice Retrieve details of an anchor record by ID
     * @param _id Anchor ID
     * @return AnchorRecord struct with all metadata
     */
    function getAnchor(uint256 _id) external view returns (AnchorRecord memory) {
        require(_id > 0 && _id <= anchorCount, "Invalid anchor ID");
        return anchors[_id];
    }

    /**
     * @notice Retrieve all anchor IDs created by a specific user
     * @param _user Address of the creator
     */
    function getUserAnchors(address _user) external view returns (uint256[] memory) {
        return userAnchors[_user];
    }

    /**
     * @notice Get total number of anchors created so far
     */
    function getTotalAnchors() external view returns (uint256) {
        return anchorCount;
    }
}

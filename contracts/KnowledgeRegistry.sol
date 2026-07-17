// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title KnowledgeRegistry
 * @dev Ported from Clarity to Solidity for the Celo Ecosystem.
 * Manages educational resources, reviews, tipping, and reputation.
 */
contract KnowledgeRegistry {
    address public contractOwner;
    uint256 public totalResources;
    uint256 public totalReviews;
    uint256 public platformFeePercentage = 5; // 5% fee

    struct Resource {
        uint256 id;
        address uploader;
        string title;
        string description;
        string url;
        string category;
        uint256 totalTips;
        uint256 downloadCount;
        uint256 ratingSum;
        uint256 ratingCount;
        uint256 createdAt;
        bool isActive;
    }

    struct Reputation {
        uint256 score;
        uint256 totalUploads;
        uint256 totalTipsReceived;
        uint256 totalTipsGiven;
    }

    struct Review {
        uint256 id;
        uint256 resourceId;
        address reviewer;
        uint8 rating;
        string comment;
        uint256 createdAt;
    }

    mapping(uint256 => Resource) public resources;
    mapping(address => Reputation) public userReputation;
    mapping(uint256 => Review) public reviews;
    mapping(address => mapping(uint256 => bool)) public hasUserReviewed;
    
    // Additional features maps
    mapping(uint256 => bool) public isFeatured;
    mapping(address => bool) public isVerifiedEducator;
    mapping(uint256 => bool) public isArchived;
    mapping(string => uint256) public platformAnalytics;

    event ResourceRegistered(uint256 indexed resourceId, address indexed uploader, string title);
    event ResourceTipped(uint256 indexed resourceId, address indexed tipper, uint256 amount);
    event ReviewAdded(uint256 indexed reviewId, uint256 indexed resourceId, address indexed reviewer, uint8 rating);

    modifier onlyOwner() {
        require(msg.sender == contractOwner, "err-owner-only");
        _;
    }

    modifier onlyUploader(uint256 _resourceId) {
        require(resources[_resourceId].uploader == msg.sender, "err-unauthorized");
        _;
    }

    modifier resourceActive(uint256 _resourceId) {
        require(resources[_resourceId].isActive && !isArchived[_resourceId], "err-not-active");
        _;
    }

    constructor() {
        contractOwner = msg.sender;
    }

    function registerResource(
        string memory _title,
        string memory _description,
        string memory _url,
        string memory _category
    ) external returns (uint256) {
        totalResources++;
        
        resources[totalResources] = Resource({
            id: totalResources,
            uploader: msg.sender,
            title: _title,
            description: _description,
            url: _url,
            category: _category,
            totalTips: 0,
            downloadCount: 0,
            ratingSum: 0,
            ratingCount: 0,
            createdAt: block.timestamp,
            isActive: true
        });

        userReputation[msg.sender].totalUploads++;
        platformAnalytics["total-resources"]++;

        emit ResourceRegistered(totalResources, msg.sender, _title);
        return totalResources;
    }

    function tipResource(uint256 _resourceId) external payable resourceActive(_resourceId) {
        require(msg.value > 0, "err-invalid-amount");
        
        Resource storage res = resources[_resourceId];
        uint256 platformFee = (msg.value * platformFeePercentage) / 100;
        uint256 uploaderAmount = msg.value - platformFee;

        // Transfers
        payable(res.uploader).transfer(uploaderAmount);
        payable(contractOwner).transfer(platformFee);

        // Update Stats
        res.totalTips += msg.value;
        userReputation[res.uploader].totalTipsReceived += msg.value;
        userReputation[res.uploader].score++;
        userReputation[msg.sender].totalTipsGiven += msg.value;
        platformAnalytics["total-tips"] += msg.value;

        emit ResourceTipped(_resourceId, msg.sender, msg.value);
    }

    function addReview(uint256 _resourceId, uint8 _rating, string memory _comment) external resourceActive(_resourceId) {
        require(_rating >= 1 && _rating <= 5, "err-invalid-rating");
        require(!hasUserReviewed[msg.sender][_resourceId], "err-already-exists");

        totalReviews++;
        
        reviews[totalReviews] = Review({
            id: totalReviews,
            resourceId: _resourceId,
            reviewer: msg.sender,
            rating: _rating,
            comment: _comment,
            createdAt: block.timestamp
        });

        hasUserReviewed[msg.sender][_resourceId] = true;
        
        Resource storage res = resources[_resourceId];
        res.ratingSum += _rating;
        res.ratingCount++;

        emit ReviewAdded(totalReviews, _resourceId, msg.sender, _rating);
    }

    function incrementDownload(uint256 _resourceId) external resourceActive(_resourceId) {
        resources[_resourceId].downloadCount++;
    }

    function deactivateResource(uint256 _resourceId) external onlyUploader(_resourceId) {
        resources[_resourceId].isActive = false;
    }

    function setFeaturedResource(uint256 _resourceId, bool _status) external onlyOwner {
        isFeatured[_resourceId] = _status;
    }

    function verifyEducator(address _educator, bool _status) external onlyOwner {
        isVerifiedEducator[_educator] = _status;
    }

    function setPlatformFee(uint256 _newFee) external onlyOwner {
        require(_newFee <= 100, "err-invalid-amount");
        platformFeePercentage = _newFee;
    }

    function getResourceRating(uint256 _resourceId) external view returns (uint256) {
        Resource memory res = resources[_resourceId];
        if (res.ratingCount == 0) return 0;
        return res.ratingSum / res.ratingCount;
    }
}

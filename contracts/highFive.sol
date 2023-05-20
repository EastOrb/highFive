// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

/// @title A Come Fund Me decentralized campaign
/// @author Your Name
contract HighFive {
    uint256 public totalCampaign;

    struct Campaign {
        uint256 id;
        address payable creator;
        uint256 created_at;
        string title;
        string description;
        string image;
        uint256 amount;
        uint256 contributors;
        uint256 raised;
        bool ended;
    }

    Campaign[] internal campaigns;

    modifier isValidId(uint256 _id) {
        require(_id < totalCampaign, "Invalid ID");
        _;
    }

    event CampaignCreated(
        uint256 id,
        address creator,
        string title,
        uint256 amount
    );

    event DonationReceived(
        uint256 campaignId,
        address contributor,
        uint256 amount
    );

    event FundsWithdrawn(uint256 campaignId, address recipient, uint256 amount);

    function createCampaign(
        string memory _title,
        string memory _description,
        string memory _image,
        uint256 _amount
    ) public {
        Campaign memory newCampaign = Campaign(
            totalCampaign,
            payable(msg.sender),
            block.timestamp,
            _title,
            _description,
            _image,
            _amount,
            0,
            0,
            false
        );
        campaigns.push(newCampaign);
        totalCampaign++;

        emit CampaignCreated(totalCampaign - 1, msg.sender, _title, _amount);
    }

    function getCampaign(uint256 _id)
        public
        view
        isValidId(_id)
        returns (Campaign memory)
    {
        return campaigns[_id];
    }

    function donate(uint256 _id) public payable isValidId(_id) {
        require(msg.value > 0, "Amount must be greater than 0!");
        require(!campaigns[_id].ended, "Campaign has ended");
        require(
            msg.sender != campaigns[_id].creator,
            "You cannot donate to your own campaign"
        );

        campaigns[_id].contributors++;
        campaigns[_id].raised += msg.value;

        emit DonationReceived(_id, msg.sender, msg.value);
    }

    function withdraw(uint256 _id) public isValidId(_id) {
        Campaign storage campaign = campaigns[_id];
        require(
            campaign.creator == msg.sender,
            "Only creator can withdraw"
        );
        require(!campaign.ended, "Funds have been withdrawn");
        require(campaign.raised > 0, "No funds to withdraw");

        uint256 amount = campaign.raised;
        campaign.ended = true;
        campaign.raised = 0;

        campaign.creator.transfer(amount);

        emit FundsWithdrawn(_id, msg.sender, amount);
    }
}

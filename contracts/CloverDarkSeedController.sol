pragma solidity 0.8.13;

// SPDX-License-Identifier: MIT

import "./IContract.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

contract CloverDarkSeedController is Ownable {
    using SafeMath for uint256;

    address public CloverDarkSeedToken;
    address public CloverDarkSeedNFT;
    address public CloverDarkSeedPicker;
    address public CloverDarkSeedStake;
    address public CloverDarkSeedPotion;
    address public teamWallet;

    uint256 public totalCloverFieldMinted;
    uint256 public totalCloverYardMinted;
    uint256 public totalCloverPotMinted;

    uint256 private _totalCloverYardMinted = 1e3;
    uint256 private _totalCloverPotMinted = 11e3;

    uint256 public totalCloverFieldCanMint = 1e3;
    uint256 public totalCloverYardCanMint = 1e4;
    uint256 public totalCloverPotCanMint = 1e5;

    uint256 public maximumTokenCanBuy = 20;
    uint256 public maxMintAmount = 100;
    
    uint16 public nftBuyFeeForTeam = 920;
    uint16 public nftBuyFeeForDev = 80;
    uint16 public nftBuyFeeForMarketing = 1000;
    uint16 public nftBuyFeeForLiquidity = 3000;

    uint256 public yardBuyPriceUsingBNB = 15e16;
    uint256 public fieldBuyPriceUsingBNB = 15e17;

    uint256 public cloverFieldPrice = 1e22;
    uint256 public cloverYardPrice = 1e21;
    uint256 public cloverPotPrice = 1e20;

    uint8 public fieldPercentByPotion = 60;
    uint8 public yardPercentByPotion = 38;
    uint8 public potPercentByPotion = 2;

    uint256 public poorTokenAmount;
    bool public isContractActivated = false;

    mapping(address => bool) public isTeamAddress;
    mapping(address => bool) public isWhitelistedForPresell;
    mapping(address => bool) private finishPresell;
    mapping(address => bool) public isWhitelistedForFieldPresell;
    mapping(address => bool) private finishFieldPresell;
    mapping(address => bool) public isVIPAddress;
    mapping(address => bool) private finishVIP;
    mapping(address => uint256) public availableTokenCanBuy;
    mapping(address => uint16) public mintAmount;
    
    mapping(uint256 => bool) private isCloverFieldCarbon;
    mapping(uint256 => bool) private isCloverFieldPearl;
    mapping(uint256 => bool) private isCloverFieldRuby;
    mapping(uint256 => bool) private isCloverFieldDiamond;

    mapping(uint256 => bool) private isCloverYardCarbon;
    mapping(uint256 => bool) private isCloverYardPearl;
    mapping(uint256 => bool) private isCloverYardRuby;
    mapping(uint256 => bool) private isCloverYardDiamond;

    mapping(uint256 => bool) private isCloverPotCarbon;
    mapping(uint256 => bool) private isCloverPotPearl;
    mapping(uint256 => bool) private isCloverPotRuby;
    mapping(uint256 => bool) private isCloverPotDiamond;
    
    mapping (address => uint256) public stakingTime;
    mapping (address => uint256) public lastClaimedTime;

    mapping(uint256 => address) private _owners;

    uint256 private lastMintedTokenId ;

    event RewardsTransferred(address holder, uint256 amount);

    constructor(address _teamWallet, address _CloverDarkSeedToken, address _CloverDarkSeedNFT, address _CloverDarkSeedPotion) {
        CloverDarkSeedToken = _CloverDarkSeedToken;
        CloverDarkSeedNFT = _CloverDarkSeedNFT;
        CloverDarkSeedPotion = _CloverDarkSeedPotion;
        teamWallet = _teamWallet;
        isCloverFieldCarbon[1] = true;
    }

    function isCloverFieldCarbon_(uint256 tokenId) public view returns (bool) {
        return isCloverFieldCarbon[tokenId];
    }

    function isCloverFieldPearl_(uint256 tokenId) public view returns (bool) {
        return isCloverFieldPearl[tokenId];
    }

    function isCloverFieldRuby_(uint256 tokenId) public view returns (bool) {
        return isCloverFieldRuby[tokenId];
    }

    function isCloverFieldDiamond_(uint256 tokenId) public view returns (bool) {
        return isCloverFieldDiamond[tokenId];
    }

    function isCloverYardCarbon_(uint256 tokenId) public view returns (bool) {
        return isCloverYardCarbon[tokenId];
    }

    function isCloverYardPearl_(uint256 tokenId) public view returns (bool) {
        return isCloverYardPearl[tokenId];
    }

    function isCloverYardRuby_(uint256 tokenId) public view returns (bool) {
        return isCloverYardRuby[tokenId];
    }

    function isCloverYardDiamond_(uint256 tokenId) public view returns (bool) {
        return isCloverYardDiamond[tokenId];
    }

    function isCloverPotCarbon_(uint256 tokenId) public view returns (bool) {
        return isCloverPotCarbon[tokenId];
    }

    function isCloverPotPearl_(uint256 tokenId) public view returns (bool) {
        return isCloverPotPearl[tokenId];
    }

    function isCloverPotRuby_(uint256 tokenId) public view returns (bool) {
        return isCloverPotRuby[tokenId];
    }

    function isCloverPotDiamond_(uint256 tokenId) public view returns (bool) {
        return isCloverPotDiamond[tokenId];
    }

    function updateNftBuyFeeFor_Team_Marketing_Liquidity(uint16 _team, uint16 _mark, uint16 _liqu) public onlyOwner {
        nftBuyFeeForTeam = _team * 92 / 100;
        nftBuyFeeForDev = _team - nftBuyFeeForTeam;
        nftBuyFeeForMarketing = _mark;
        nftBuyFeeForLiquidity = _liqu;
    }

    function buyCloverField() public {
        require(totalCloverFieldMinted + 1 <= totalCloverFieldCanMint, "Controller: All Clover Field Has Minted..");
        require(isContractActivated, "Controller: Contract is not activeted yet..");
        address to = msg.sender;
        uint256 tokenId = totalCloverFieldMinted + 1;
        uint256 random = IContract(CloverDarkSeedPicker).randomNumber();

        bool lucky = ((random >> 245) % 20) == 0 ;

        if (lucky) {
            address luckyWalletForCloverField = IContract(CloverDarkSeedStake).getLuckyWalletForCloverField();
            if (luckyWalletForCloverField != address(0)) {
                to = luckyWalletForCloverField;
            }
        }

        uint256 liquidityFee = cloverFieldPrice.div(1e4).mul(nftBuyFeeForLiquidity);
        uint256 marketingFee = cloverFieldPrice.div(1e4).mul(nftBuyFeeForMarketing);
        uint256 teamFee = cloverFieldPrice.div(1e4).mul(nftBuyFeeForTeam);
        uint256 devFee = cloverFieldPrice.div(1e4).mul(nftBuyFeeForDev);

        if (isTeamAddress[msg.sender]) {
            cloverFieldPrice = 0;
        }
        
        if (cloverFieldPrice > 0) {
            IContract(CloverDarkSeedToken).Approve(address(this), cloverFieldPrice);
            IContract(CloverDarkSeedToken).transferFrom(msg.sender, CloverDarkSeedToken, cloverFieldPrice);
            IContract(CloverDarkSeedToken).AddFeeS(marketingFee, devFee, teamFee, liquidityFee);
        }
        IContract(CloverDarkSeedNFT).mint(to, tokenId);

    }

    function buyCloverYard() public {
        require(totalCloverYardMinted + 1 <= totalCloverYardCanMint, "Controller: All Clover Yard Has Minted..");
        require(isContractActivated, "Controller: Contract is not activeted yet..");

        address to = msg.sender;
        uint256 tokenId = _totalCloverYardMinted + 1;

        uint256 random = IContract(CloverDarkSeedPicker).randomNumber();
        bool lucky = ((random >> 245) % 20) == 0 ;

        if (lucky) {
            address luckyWalletForCloverYard = IContract(CloverDarkSeedStake).getLuckyWalletForCloverYard();
            if (luckyWalletForCloverYard != address(0)) {
                to = luckyWalletForCloverYard;
            }
        }

        uint256 liquidityFee = cloverYardPrice.div(1e4).mul(nftBuyFeeForLiquidity);
        uint256 marketingFee = cloverYardPrice.div(1e4).mul(nftBuyFeeForMarketing);
        uint256 teamFee = cloverYardPrice.div(1e4).mul(nftBuyFeeForTeam);
        uint256 devFee = cloverYardPrice.div(1e4).mul(nftBuyFeeForDev);

        
        if (isTeamAddress[msg.sender]) {
            cloverYardPrice = 0;
        }

        if (cloverYardPrice > 0) {
            IContract(CloverDarkSeedToken).Approve(address(this), cloverYardPrice);
            IContract(CloverDarkSeedToken).transferFrom(msg.sender, CloverDarkSeedToken, cloverYardPrice);
            IContract(CloverDarkSeedToken).AddFeeS(marketingFee, devFee, teamFee, liquidityFee);
        }
        
        IContract(CloverDarkSeedNFT).mint(to, tokenId);
    }

    function buyCloverPot() public {
        require(totalCloverPotMinted + 1 <= totalCloverPotCanMint, "Controller: All Clover Pot Has Minted..");
        require(isContractActivated, "Controller: Contract is not activeted yet..");

        address to = msg.sender;
        uint256 tokenId = _totalCloverPotMinted + 1;

        uint256 random = IContract(CloverDarkSeedPicker).randomNumber();
        bool lucky = ((random >> 245) % 20) == 0 ;

        if (lucky) {
            address luckyWalletForCloverPot = IContract(CloverDarkSeedStake).getLuckyWalletForCloverPot();
            if (luckyWalletForCloverPot != address(0)) {
                to = luckyWalletForCloverPot;
            }
        }

        uint256 liquidityFee = cloverPotPrice.div(1e4).mul(nftBuyFeeForLiquidity);
        uint256 marketingFee = cloverPotPrice.div(1e4).mul(nftBuyFeeForMarketing);
        uint256 teamFee = cloverPotPrice.div(1e4).mul(nftBuyFeeForTeam);
        uint256 devFee = cloverPotPrice.div(1e4).mul(nftBuyFeeForDev);

        if (isTeamAddress[msg.sender]) {
            cloverPotPrice = 0;
        }

        if (cloverPotPrice > 0) {
            IContract(CloverDarkSeedToken).Approve(address(this), cloverPotPrice);
            IContract(CloverDarkSeedToken).transferFrom(msg.sender, CloverDarkSeedToken, cloverPotPrice);
            IContract(CloverDarkSeedToken).AddFeeS(marketingFee, devFee, teamFee, liquidityFee);
        }
        
        IContract(CloverDarkSeedNFT).mint(to, tokenId);
    }

    function setTokenForPoorPotion(uint256 amt) public onlyOwner {
        poorTokenAmount = amt;
    }

    function setPotionPercentage(uint8 _potionField, uint8 _potionYard, uint8 _potionPot) public onlyOwner {
        fieldPercentByPotion = _potionField;
        yardPercentByPotion = _potionYard;
        potPercentByPotion = _potionPot;
    }
    function mintUsingPotion(bool isNormal) public {
        uint256 random = IContract(CloverDarkSeedPicker).randomNumber() % 100;
        uint256 tokenID;
        if (isNormal) {
            if (random < potPercentByPotion) {
                tokenID = _totalCloverPotMinted + 1;
            } else if (random < potPercentByPotion + yardPercentByPotion) {
                tokenID = _totalCloverYardMinted + 1;
            } else {
                tokenID = totalCloverFieldMinted + 1;
            }
            IContract(CloverDarkSeedNFT).mint(msg.sender, tokenID);
        } else {
            IContract(CloverDarkSeedToken).sendToken2Account(msg.sender, poorTokenAmount);
        }
        IContract(CloverDarkSeedPotion).burn(msg.sender, isNormal);
    }

    function AddVIPs(address[] memory vipS, uint256[] memory numberOfToken) public onlyOwner {
        require(vipS.length == numberOfToken.length, "Controller: Please enter correct vipS & numberOfToken length...");
        for (uint256 i = 0; i < vipS.length; i++) {
            isVIPAddress[vipS[i]] = true;
            availableTokenCanBuy[vipS[i]] = availableTokenCanBuy[vipS[i]].add(numberOfToken[i]);
        }
    }

    function addMintedTokenId(uint256 tokenId) public returns (bool) {
        require(msg.sender == CloverDarkSeedNFT, "Controller: Only for Seeds NFT..");
        require(mintAmount[tx.origin] <= maxMintAmount, "You have already minted all nfts.");
        
        if (tokenId <= totalCloverFieldCanMint) {
            totalCloverFieldMinted = totalCloverFieldMinted.add(1);
        }

        if (tokenId > totalCloverFieldCanMint && tokenId <= totalCloverYardCanMint) {
            _totalCloverYardMinted = _totalCloverYardMinted.add(1);
            totalCloverYardMinted = totalCloverYardMinted.add(1);
        }

        if (tokenId > totalCloverYardCanMint && tokenId <= totalCloverPotCanMint) {
            _totalCloverPotMinted = _totalCloverPotMinted.add(1);
            totalCloverPotMinted = totalCloverPotMinted.add(1);
        }

        lastMintedTokenId = tokenId;
        mintAmount[tx.origin]++;
        return true;
    }

    function readMintedTokenURI() public view returns(string memory) {
        string memory uri = IContract(CloverDarkSeedNFT).tokenURI(lastMintedTokenId);
        return uri;
    }
    function addOnWhitelistForYardPreSell(address[] memory accounts) public onlyOwner {
        
        for (uint256 i = 0; i < accounts.length; i++) {
            isWhitelistedForPresell[accounts[i]] = true;
        }
    }

    function addOnWhitelistForFieldPreSell(address[] memory accounts) public onlyOwner {
        
        for (uint256 i = 0; i < accounts.length; i++) {
            isWhitelistedForFieldPresell[accounts[i]] = true;
        }
    }

    function addAsCloverFieldCarbon(uint256 tokenId) public returns (bool) {
        require(msg.sender == CloverDarkSeedPicker, "Controller: You are not CloverDarkSeedPicker..");
        isCloverFieldCarbon[tokenId] = true;
        return true;
    }

    function addAsCloverFieldPearl(uint256 tokenId) public returns (bool) {
        require(msg.sender == CloverDarkSeedPicker, "Controller: You are not CloverDarkSeedPicker..");
        isCloverFieldPearl[tokenId] = true;
        return true;
    }

    function addAsCloverFieldRuby(uint256 tokenId) public returns (bool) {
        require(msg.sender == CloverDarkSeedPicker, "Controller: You are not CloverDarkSeedPicker..");
        isCloverFieldRuby[tokenId] = true;
        return true;
    }

    function addAsCloverFieldDiamond(uint256 tokenId) public returns (bool) {
        require(msg.sender == CloverDarkSeedPicker, "Controller: You are not CloverDarkSeedPicker..");
        isCloverFieldDiamond[tokenId] = true;
        return true;
    }

    function addAsCloverYardCarbon(uint256 tokenId) public returns (bool) {
        require(msg.sender == CloverDarkSeedPicker, "Controller: You are not CloverDarkSeedPicker..");
        isCloverYardCarbon[tokenId] = true;
        return true;
    }

    function addAsCloverYardPearl(uint256 tokenId) public returns (bool) {
        require(msg.sender == CloverDarkSeedPicker, "Controller: You are not CloverDarkSeedPicker..");
        isCloverYardPearl[tokenId] = true;
        return true;
    }

    function addAsCloverYardRuby(uint256 tokenId) public returns (bool) {
        require(msg.sender == CloverDarkSeedPicker, "Controller: You are not CloverDarkSeedPicker..");
        isCloverYardRuby[tokenId] = true;
        return true;
    }

    function addAsCloverYardDiamond(uint256 tokenId) public returns (bool) {
        require(msg.sender == CloverDarkSeedPicker, "Controller: You are not CloverDarkSeedPicker..");
        isCloverYardDiamond[tokenId] = true;
        return true;
    }

    function addAsCloverPotCarbon(uint256 tokenId) public returns (bool) {
        require(msg.sender == CloverDarkSeedPicker, "Controller: You are not CloverDarkSeedPicker..");
        isCloverPotCarbon[tokenId] = true;
        return true;
    }

    function addAsCloverPotPearl(uint256 tokenId) public returns (bool) {
        require(msg.sender == CloverDarkSeedPicker, "Controller: You are not CloverDarkSeedPicker..");
        isCloverPotPearl[tokenId] = true;
        return true;
    }

    function addAsCloverPotRuby(uint256 tokenId) public returns (bool) {
        require(msg.sender == CloverDarkSeedPicker, "Controller: You are not CloverDarkSeedPicker..");
        isCloverPotRuby[tokenId] = true;
        return true;
    }

    function addAsCloverPotDiamond(uint256 tokenId) public returns (bool) {
        require(msg.sender == CloverDarkSeedPicker, "Controller: You are not CloverDarkSeedPicker..");
        isCloverPotDiamond[tokenId] = true;
        return true;
    }

    function ActiveThisContract() public onlyOwner {
        isContractActivated = true;
    }

    function setCloverDarkSeedPicker(address _CloverDarkSeedPicker) public onlyOwner {
        CloverDarkSeedPicker = _CloverDarkSeedPicker;
    }

    function setCloverDarkSeedStake(address _CloverDarkSeedStake) public onlyOwner {
        CloverDarkSeedStake = _CloverDarkSeedStake;
    }

    function setTeamAddress(address account) public onlyOwner {
        isTeamAddress[account] = true;
    }

    function set_CloverDarkSeedToken(address SeedsToken) public onlyOwner {
        CloverDarkSeedToken = SeedsToken;
    }

    function set_CloverDarkSeedNFT(address nftToken) public onlyOwner {
        CloverDarkSeedNFT = nftToken;
    }

    function setCloverFieldPrice(uint256 price) public onlyOwner {
        cloverFieldPrice = price;
    }

    function setCloverYardPrice(uint256 price) public onlyOwner {
        cloverYardPrice = price;
    }

    function setCloverPotPrice (uint256 price) public onlyOwner {
        cloverPotPrice = price;
    }

    function setYardPriceInBNB(uint256 price) public onlyOwner {
        yardBuyPriceUsingBNB = price;
    }

      function setFieldPriceInBNB(uint256 price) public onlyOwner {
        fieldBuyPriceUsingBNB = price;
    }
    
    // function to allow admin to transfer *any* BEP20 tokens from this contract..
    function transferAnyBEP20Tokens(address tokenAddress, address recipient, uint256 amount) public onlyOwner {
        require(amount > 0, "SEED$ Controller: amount must be greater than 0");
        require(recipient != address(0), "SEED$ Controller: recipient is the zero address");
        IContract(tokenAddress).transfer(recipient, amount);
    }

    function buyYardUsingBNB() public payable {
        require(totalCloverYardMinted.add(1) <= totalCloverYardCanMint, "Controller: All Clover Yard has been Minted..");
        require(isWhitelistedForPresell[msg.sender], "Controller: You are not whitelisted..");
        require(!finishPresell[msg.sender], "Presell finished...");
        require(isContractActivated, "Controller: Contract is not activeted yet..");

        address to = msg.sender;
        uint256 bnbAmount = msg.value;
        require(bnbAmount >= yardBuyPriceUsingBNB, "Controller: Please send valid amount..");
        
        if (bnbAmount < yardBuyPriceUsingBNB.mul(2)) {
            uint256 Id = _totalCloverYardMinted.add(1);
            IContract(CloverDarkSeedNFT).mint(to, Id);
            uint256 forTeamWallet = yardBuyPriceUsingBNB;
            uint256 remainingBNB = bnbAmount.sub(forTeamWallet);
            payable(teamWallet).transfer(forTeamWallet);
            
            if (remainingBNB > 0) {
                payable(msg.sender).transfer(remainingBNB);
            }
        }
        
        if (bnbAmount >= yardBuyPriceUsingBNB.mul(2)) {
            require(totalCloverYardMinted.add(2) <= totalCloverYardCanMint, "Controller: All Clover Yard has been Minted..");
            uint256 Id = _totalCloverYardMinted.add(1);
            IContract(CloverDarkSeedNFT).mint(to, Id);
            Id = _totalCloverYardMinted.add(1);
            IContract(CloverDarkSeedNFT).mint(to, Id);

            uint256 forTeamWallet = yardBuyPriceUsingBNB.mul(2);
            uint256 remainingBNB = bnbAmount.sub(forTeamWallet);
            payable(teamWallet).transfer(forTeamWallet);
            
            if (remainingBNB > 0) {
                payable(msg.sender).transfer(remainingBNB);
            }
        }

        finishPresell[msg.sender] = true;
    }

    function buyFieldUsingBNB() public payable {
        require(totalCloverFieldMinted.add(1) <= totalCloverFieldCanMint, "Controller: All Clover Field has been Minted..");
        require(isWhitelistedForFieldPresell[msg.sender], "Controller: You are not whitelisted..");
        require(!finishFieldPresell[msg.sender], "Field Presell finished...");
        require(isContractActivated, "Controller: Contract is not activeted yet..");

        address to = msg.sender;
        uint256 bnbAmount = msg.value;
        require(bnbAmount >= fieldBuyPriceUsingBNB, "Controller: Please send valid amount..");
        
        if (bnbAmount < fieldBuyPriceUsingBNB.mul(2)) {
            uint256 Id = totalCloverFieldMinted.add(1);
            IContract(CloverDarkSeedNFT).mint(to, Id);
            uint256 forTeamWallet = fieldBuyPriceUsingBNB;
            uint256 remainingBNB = bnbAmount.sub(forTeamWallet);
            payable(teamWallet).transfer(forTeamWallet);
            
            if (remainingBNB > 0) {
                payable(msg.sender).transfer(remainingBNB);
            }
        }
        
        if (bnbAmount >= fieldBuyPriceUsingBNB.mul(2)) {
            require(totalCloverFieldMinted.add(2) <= totalCloverYardCanMint, "Controller: All CloverField has been minted ...");
            uint256 Id = totalCloverFieldMinted.add(1);
            IContract(CloverDarkSeedNFT).mint(to, Id);
            Id = totalCloverFieldMinted.add(1);
            IContract(CloverDarkSeedNFT).mint(to, Id);

            uint256 forTeamWallet = fieldBuyPriceUsingBNB.mul(2);
            uint256 remainingBNB = bnbAmount.sub(forTeamWallet);
            payable(teamWallet).transfer(forTeamWallet);
            
            if (remainingBNB > 0) {
                payable(msg.sender).transfer(remainingBNB);
            }
        }

        finishFieldPresell[msg.sender] = true;
    }

    function buyCloverFields(uint256 numberOfToken) public {
        require(totalCloverFieldMinted.add(numberOfToken) <= totalCloverFieldCanMint, "Controller: All Clover Field Has Minted..");
        require(numberOfToken > 0 && numberOfToken < maximumTokenCanBuy, "Controller: Please enter a valid number..");
        require(availableTokenCanBuy[msg.sender] > 0 && numberOfToken <= availableTokenCanBuy[msg.sender], "Please enter a valid number..");
        require(isContractActivated, "Controller: Contract is not activeted yet..");
        require(!finishVIP[msg.sender], "Controller: Contract is not activeted yet..");

        address to = msg.sender;
        for (uint8 i = 0; i < numberOfToken; i ++) {
            uint Id = totalCloverFieldMinted + 1;
            IContract(CloverDarkSeedNFT).mint(to, Id);
        }

        finishVIP[msg.sender] = true;
    }

    function isFinishPresell(address account) public view returns (bool) {
        return finishPresell[account];
    }

    function isFinishFieldPresell(address account) public view returns (bool) {
        return finishFieldPresell[account];
    }

    function isFinishVIP(address account) public view returns (bool) {
        return finishVIP[account];
    }

    function setMaximumVIPMint(uint amount) public onlyOwner {
        maximumTokenCanBuy = amount;
    }

}
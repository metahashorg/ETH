/* version metahash ETH multi sign wallet 0.1.3 RC */
pragma solidity ^0.4.18;

contract mhethkeeper {

	/* contract settings */

	/* dynamic data section */
	address public recipient;			/* recipient */
	uint256 public amountToTransfer;		/* quantity */


	/* static data section */
	uint public isFinalized;			/* settings are finalized */
	uint public minVotes;				/* minimum amount of votes */
	uint public curVotes;				/* current amount of votes */
	address public owner;				/* contract creator */
	uint public mgrCount; 				/* number of managers */
	mapping (uint => uint) public mgrVotes; 	/* managers votes */
	mapping (uint256 => address) public mgrAddress; /* managers address */

	/* constructor */
	function mhethkeeper() public{
		owner = msg.sender;
		isFinalized = 0;
		curVotes = 0;
		mgrCount = 1;
		mgrAddress[mgrCount] = msg.sender;
		mgrVotes[mgrCount] = 0;
	}

	/* set the required number of votes */
	function SetNeedVoice(uint _count) public{
		if (msg.sender != owner){
			revert();
		}
		if (mgrCount > _count){
			revert();
		}
		if (isFinalized == 1){
			revert();
		}
		minVotes = _count;
	}

	/* add a wallet manager */
	function AddManager(address _manager) public{
		if ((msg.sender == owner) && (isFinalized == 0)){
			mgrCount = mgrCount + 1;
			mgrAddress[mgrCount] = _manager;
			mgrVotes[mgrCount] = 0;
		} else {
			revert();
		}
	}

	/* finalize settings */
	function Finalize() public{
		if ((msg.sender == owner) && (isFinalized == 0)){
			isFinalized = 1;
		} else {
			revert();
		}
	}

	/* set new action and set to zero vote */
	function SetAction(address _recipient, uint256 _count) public{
		if ((msg.sender == owner) && (isFinalized == 1)){
			if (this.balance < _count){
				revert();
			}
			recipient = _recipient;
			amountToTransfer = _count;
			
			for (uint i = 1; i < mgrCount; i++) {
				mgrVotes[i] = 0;
			}
			curVotes = 0;
		} else {
			revert();
		}
	}

	/* manager votes for the action */
	function Approve() public returns (bool){
		if (isFinalized == 0){
			revert();
		}

		for (uint i = 1; i <= mgrCount; i++) {
			if (mgrAddress[i] == msg.sender){
				if (mgrVotes[i] == 0){
					mgrVotes[i] = 1;
					curVotes = curVotes + 1;

					if (curVotes >= minVotes){
						recipient.transfer(amountToTransfer);
						NullSettings();
					} 
				} else {
					revert();
				}
			}
		}
	}

	/* set a default payable function */
	function pay() public payable {}
	
	/* set a default empty settings  */
	function NullSettings() private{
		recipient = address(0x0);
		amountToTransfer = 0;
		curVotes = 0;
		for (uint i = 1; i <= mgrCount; i++) {
			mgrVotes[i] = 0;
		}

	}
}

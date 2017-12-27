/* version metahash ETH multi sign wallet 0.1.2 RC */
pragma solidity ^0.4.18;

contract mhethkeeper {

	/* contract settings */
	address public recipient;	/* recipient */
	uint256 public count;		/* quantity */

	uint public ready;		/* settings are finalized */
	uint public need_voice;		/* min vote */
	uint public now_voice;		/* сur vote */

	address public owner;		/* contract creator */
	mapping (uint => uint) public managers_voices; /*managers vote*/
	mapping (uint256 => address) public managers; /* managers */
	uint public managers_count;

	/* constructor */
	function mhethkeeper() public{
		owner = msg.sender;
		ready = 0;
		now_voice = 0;
		managers_count = 1;
		managers[managers_count] = msg.sender;
		managers_voices[managers_count] = 0;
	}

	/* set how many vote are needed */
	function SetNeedVoice(uint _count) public{
		if (msg.sender != owner){
			revert();
		}
		if (managers_count > _count){
			revert();
		}
		if (ready == 1){
			revert();
		}
		need_voice = _count;
	}

	/* add a wallet manager */
	function AddManager(address _manager) public{
		if ((msg.sender == owner) && (ready == 0)){
			managers_count = managers_count + 1;
			managers[managers_count] = _manager;
			managers_voices[managers_count] = 0;
		} else {
			revert();
		}
	}

	/* finalyze settings */
	function finalyze() public{
		if ((msg.sender == owner) && (ready == 0)){
			ready = 1;
		} else {
			revert();
		}
	}

	/* set new action and set to zero vote */
	function SetAction(address _recipient, uint256 _count) public{
		if ((msg.sender == owner) && (ready == 1)){
			if (this.balance < _count){
				revert();
			}
			recipient = _recipient;
			count = _count;
			
			for (uint i = 1; i < managers_count; i++) {
				managers_voices[i] = 0;
			}
			now_voice = 0;
		} else {
			revert();
		}
	}

	/* manager votes for the action */
	function Approve() public returns (bool){
		if (ready == 0){
			revert();
		}

		for (uint i = 1; i <= managers_count; i++) {
			if (managers[i] == msg.sender){
				if (managers_voices[i] == 0){
					managers_voices[i] = 1;
					now_voice = now_voice + 1;

					if (now_voice >= need_voice){
						recipient.transfer(count);
						NullSettings();
					} 
				} else {
					revert();
				}
			}
		}
	}

	/* set default payable function */
	function pay() public payable {}
	
	/* check adress */
	function NullSettings() private{
		recipient = address(0x0);
		count = 0;
		now_voice = 0;
		for (uint i = 1; i <= managers_count; i++) {
			managers_voices[i] = 0;
		}

	}
}

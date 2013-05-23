<?php
// characters.php
// 
// This file houses the classes for the various types
// of characters in the game. All player and zombie 
// classes inherit from a generic "character" class
// which has the necessary functions to perform actions
// common to everyone. 
//

class character { 
	protected $name = ''; 
	protected $level = ''; 
	protected $hitpoints = array(
		"label" => "", 
		"value" => ""
	); 

	private $hitPoints = ''; 

	function __construct() { 
		// constructor for character{} 
			
	} // end __construct()

	function setName($name) { 
		$this->name = $name; 
	}

	function incLevel($incBy) { 
		$this->level += $incBy; 
		return $this->level; 
	}

	function takeDamage($damage) { 
		$this->hitpoints["value"] -= $damage; 
		return $this->hitpoints["value"]; 
	}

	function healDamage($damage) { 
		$this->hitpoints["value"] += $damage; 
		return $this->hitpoints["value"]; 
	}

	function getDamage() { 
		return $this->hitpoints["value"]; 
	}

	public function getStat($stat) { 
		//print_r($this); 
		if ( isset($this->$stat) ) { 
			return $this->$stat;
		} else { 
			return -1; 
		}
	}


} // end class character{} 

class player extends character { 
	protected $money 				= ""; 
	protected $specialAttacks 	= ""; 
	protected $weapons 			= array(); 
	protected $agility 			= "";
	

	function __construct($initValues) { 
		$this->hitpoints["label"] = "Stamina"; 
		//parent::__construct(); 

		switch (gettype($initValues) ) { 
		case "array": 
			foreach ($initValues as $key => $value) { 
				$this->$key = $value; 
			}
			break;
		default:
			print "Error: Unable to determine intial values\n"; 
			return -1; 
		}
	} // end constructor

	function showMoney() { 
		return $this->money; 
	}

	function spendMoney($amount) { 
		if ( ($this->money - $amount) < 0 ) { 
			return -1
		} else { 
			$this->money -= $amount; 
			return $this->money; 
		}
	} // end spendMoney()

	function addMoney($amount) { 
		$this->money += $amount; 
		return $this->money; 
	}

	function useSpecialAttack() { 
		$this->specialAttacks--; 
		return $this->specialAttacks; 
	}

	function addSpecialAttacks($num) { 
		$this->specialAttacks += $num; 
		return $this->specialAttacks; 
	}

	function depleteAgility($val) { 
		if (($this->agility - $val) < 0 ) { 
			$this->agility = 0; 
		} else { 
			$this->agility -= $val; 
		}
		return $this->agility; 
	}

	// TODO: Add weapons code here

} // end class player{}

class zombie extends character { 
	protected $isOnFire		= ""; 
	protected $defense		= ""; 
	protected $typeClass		= ""; 
	protected $desc			= ""; 
	protected $armsAttached	= ""; 
	protected $legsAttached	= ""; 

	function __construct($initValues) { 
		$this->hitpoints["label"] = "Hit Points"; 

		switch(gettype($initValues) ) { 
		case "array":
			foreach($initValues as $key => $value) { 
				$this->$key = $value; 
			}
			break;
		default:
			print "Error: Unable to determine initial values\n"; 
			return -1; 
		}
	} // end constructor

	function ignite() { 
		$this->isOnFire = 1; 
		return $this->isOnFire; 
	}

	function isOnFire() { 
		return $this->isOnFire; 
	}

	function removeArm() { 
		$this->armsAttached--; 
		return $this->armsAttached; 
	}

	function removeLeg() { 
		$this->legsAttached--; 
		return $this->legsAttached; 
	}

	function getDesc() { 
		return $this->desc; 
	}

} // end class zombie{}


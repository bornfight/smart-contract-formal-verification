var Cashout = artifacts.require("Cashout");

contract("Cashout", function(accounts) {
    it("Deploy the contract", async function() {
        cashoutContract = await Cashout.deployed();
    });

    it("Test the owner", async function() {
        let owner = await cashoutContract.owner();
        assert.equal(accounts[0], owner);    
    });
    
    it("Test claimAll() when not owner", async function() {
        
    });
});

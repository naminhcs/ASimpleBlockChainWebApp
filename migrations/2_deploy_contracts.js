const Project = artifacts.require('../contracts/Project.sol');
const Crowdfunding = artifacts.require('../contracts/Crowdfunding.sol')

module.exports = async function (deployer, network, accounts) {
    deployer.deploy(Crowdfunding)
//    deployer.deploy(Project, accounts[0], "First Block", "Create First Block", 10, 10);
};

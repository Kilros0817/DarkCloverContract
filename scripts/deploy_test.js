const team_address = "0xD8B3aE82310BF95874ea8B0D5831Bd2B0744DFdD";
const marketing_address = "0x4fDF2017Cb4f73Ba03CA6BD823dDEcDf163C3b29";

async function main() {

  const iterableLib = await ethers.getContractFactory("IterableMapping");
  const iterableLibContract = await iterableLib.deploy();
  console.log("IterableMapping deployed to:", iterableLibContract.address);
  // const seedFT = await ethers.getContractFactory("Clover_Seeds_Token");
  // const seedFTContract = await seedFT.deploy(team_address, marketing_address);
  // console.log("Clover_Seeds_Token deployed to:", seedFTContract.address);

  // const seedStake= await ethers.getContractFactory("Clover_Seeds_Stake" ,{
  //     libraries: {
  //     IterableMapping: "0x267f604461E0D879d46B328fa70e95A0298be8A3",
  //   }
  // });
  // const seedStakeContract = await seedStake.deploy(marketing_address
  //   , "0xe98D562A0366a789E5a1bb3EC788a778F17ef922"
  //   , "0xE49eEE34F7816F274a32426A98E2F2cAd0C020ea"
  //   , "0xE69191B4CBc9e64F00A5192960cD6a40b8E99263"
  //   , "0x203E89ACfD139933a0C1675A2A38371877a7d6d0"
  // );
  // console.log("Clover_Seeds_Stake deployed to:", seedStakeContract.address);
}

main()
.then(() => process.exit(0))
.catch((error) => {
  console.error(error);
  process.exit(1);
});
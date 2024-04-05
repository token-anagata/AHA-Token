const assert = require('assert');

const contracts = require('../compile');
const checkpointsArgs = require('../data/checkpoints');

const tokenContract = contracts['AHAToken.sol'].AHAToken;
const stakeContract = contracts['AHATokenStake.sol'].AHATokenStake;

const tether = require('../compiled/tether.json');

const { secondsInTheFuture, newArray, randomInt } = require('../utils/helper');
const { useWeb3, useMethodsOn } = require('../utils/web3-utils');

const name = 'AHAToken';
const symbol = 'AHA';
const maxSupply = 700000000;
const mintOnDeployPointPercent = 300;
const tetherSupply = 100000000;
const rewardDifferenceThreshold = 4;

describe('AHAToken tests', () => {
  let accounts, AHAToken, AHATokenStake, TetherToken;

  beforeEach(async () => {
    const { getAccounts, deploy } = useWeb3();

    accounts = await getAccounts();
    TetherToken = await deploy(
      tether,
      [tetherSupply, 'Tether', 'USDT', 18],
      accounts[0]
    );
    AHAToken = await deploy(
      tokenContract,
      [name, symbol, maxSupply, mintOnDeployPointPercent],
      accounts[0]
    );
    AHATokenStake = await deploy(
      stakeContract,
      [AHAToken.options.address, TetherToken.options.address],
      accounts[0]
    );
  });

  describe('AHAToken', () => {
    it('deploys successfully', () => {
      assert.ok(AHAToken.options.address);
    });

    it('has mint checkpoints', () => {
      let totalSupply;

      const wait = checkpointsArgs[2].secondsFromNow * 1000;
      const amountToMint = maxSupply * 0.062;

      const checkpoints = checkpointsArgs.map(
        ({ secondsFromNow, note, pointOnePercent }) => [
          secondsInTheFuture(secondsFromNow),
          note,
          pointOnePercent,
        ]
      );

      return useMethodsOn(AHAToken, [
        {
          method: 'addCheckpoints',
          args: [checkpoints],
          account: accounts[0],
        },
        {
          method: 'totalSupply',
          account: accounts[0],
          onReturn: (amount) => {
            // We want to record the initial supply minted on deployment
            totalSupply = parseInt(amount);
          },
        },
        {
          method: 'mint',
          args: [accounts[0], amountToMint],
          account: accounts[0],
          catch: (error) => {
            // The contract shouldn't allow us to mint if we haven't passed enought
            // checkpoints to allow us to mint the given amount
            assert.strictEqual(
              error,
              'AHAToken: mint amount exceding allowed amount'
            );
          },
        },
        {
          // We wait for a few checkpoints to pass before we can actually mint
          wait,
        },
        {
          // We mint the amount which is allowed now
          method: 'mint',
          args: [accounts[0], amountToMint],
          account: accounts[0],
        },
        {
          method: 'totalSupply',
          account: accounts[0],
          onReturn: (amount) => {
            // We check that the total supply of the token is correct after mint
            assert.strictEqual(parseInt(amount), totalSupply + amountToMint);
          },
        },
      ]);
    });
  });

  describe('AHATokenStake', () => {
    it('allows users to stake and receive rewards', () => {
      const eventCode = 'First stake';
      const saleDurationS = 5;
      const totalReward = 10000000;
      const usersToStake = 5;
      const minStake = 100;
      const maxStake = 1000;
      const stakeAmounts = newArray(usersToStake, () =>
        randomInt(minStake, maxStake)
      );
      const userRewards = [];

      return useMethodsOn(AHAToken, [
        ...newArray(usersToStake, (i) => ({
          // We first transfer a random amount of staking tokens to each user
          // partaking in the staking event
          method: 'transfer',
          args: [accounts[i + 1], stakeAmounts[i]],
          account: accounts[0],
        })),
        ...newArray(usersToStake, (i) => ({
          // Each user will need to individually approve the funds
          // they want to stake towards the staking contract
          method: 'approve',
          args: [AHATokenStake.options.address, stakeAmounts[i]],
          account: accounts[i + 1],
        })),
      ])
        .then(() =>
          useMethodsOn(TetherToken, {
            // The owner approves the reward tokens towards the staking contract
            method: 'approve',
            args: [AHATokenStake.options.address, totalReward],
            account: accounts[0],
          })
        )
        .then(() =>
          useMethodsOn(AHATokenStake, [
            {
              // The owner deposits the event reward
              method: 'depositEventReward',
              args: [eventCode, totalReward],
              account: accounts[0],
            },
            {
              // Owner starts the event sale. They must provide start and end time
              // of the sale in UNIX time. If the start time is 0, the sale will
              // start immediately
              method: 'setSaleStartEnd',
              args: [eventCode, 0, secondsInTheFuture(saleDurationS)],
              account: accounts[0],
            },
            ...newArray(usersToStake, (i) => ({
              // Each user stakes their staking token once the sale has started
              method: 'stake',
              args: [eventCode, stakeAmounts[i]],
              account: accounts[i + 1],
            })),
            ...newArray(usersToStake, (i) => ({
              // We check each user's stake amount through
              // a public method on our staking contract
              method: 'getUserStaked',
              args: [eventCode, accounts[i + 1]],
              account: accounts[0],
              onReturn: (userStake) => {
                // And we check that the amount we received is equal to the
                // amount the user initially staked
                assert.strictEqual(parseInt(userStake), stakeAmounts[i]);
              },
            })),
            {
              // We wait until the sale ends
              wait: saleDurationS * 1000, // ms
            },
            ...newArray(usersToStake, (i) => ({
              // Each user will unstake and doing so will claim the rewards
              method: 'unstake',
              args: [eventCode],
              account: accounts[i + 1],
            })),
          ])
        )
        .then(() =>
          useMethodsOn(TetherToken, [
            ...newArray(usersToStake, (i) => ({
              // We check the balance of each user who partook in the staking event
              method: 'balanceOf',
              args: [accounts[i + 1]],
              account: accounts[0],
              onReturn: (balance) => {
                // And record the balances in an array
                userRewards.push(parseInt(balance));
              },
            })),
            {
              then: () => {
                const [stakeOrder, rewardOrder] = [
                  stakeAmounts,
                  userRewards,
                ].map((array) =>
                  [...array]
                    // We order the user stake amounts and the each reward amount
                    // from lowest to highest
                    .sort((a, b) => a - b)
                    .map((amount) =>
                      array.findIndex((_amount) => _amount === amount)
                    )
                );
                const totalRewardGiven = userRewards.reduce(
                  (total, current) => total + current
                );

                stakeOrder.forEach((originalIndex, index) => {
                  // And we expect that the user rewards are ordered
                  // exactly like the stake amounts. Meaning that the user who staked
                  // the least amount of staking tokens will have the least amount of
                  // reward tokens and vice-versa
                  assert.strictEqual(originalIndex, rewardOrder[index]);
                });
                // We check that the total reward given to all users is close to the
                // initial total reward added to the staking contract.
                // The reason we do not expect idential amounts is because the calculations
                // for rewards are done using only integers and there will always be some
                // small amount of tokens which are not distributed. This number is very low though
                // (e.g. reward is 10,000,000 tokens and 2 are left over)
                assert(
                  totalReward - totalRewardGiven < rewardDifferenceThreshold
                );
              },
            },
          ])
        );
    });
  });
});

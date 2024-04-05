const { formatArgs } = require('./debug-utils');
const ganache = require('ganache-cli');
const Web3 = require('web3');

const useMethodsOn = (contractInstance, methodArgs) => {
  const methods = Array.isArray(methodArgs) ? methodArgs : [methodArgs];

  if (methods.length === 0) return Promise.resolve();

  const recursiveFunction = (methodIndex, promise) =>
    promise.then(async (previousReturnValue) => {
      if (!methods[methodIndex]) return previousReturnValue;
      
      const {
        method,
        args = [],
        account,
        onReturn,
        wait = null,
        then = null,
        catch: catchCallback,
      } = methods[methodIndex];

      if (wait) {
        const waitPromise = new Promise((resolve) => {
          setTimeout(() => resolve(), wait);
        });
        return recursiveFunction(methodIndex + 1, waitPromise);
      }

      if (then) {
        then();
        return recursiveFunction(methodIndex + 1, Promise.resolve());
      }

      if (!contractInstance.methods[method])
        throw new Error(`Unknown method called ${method}`);

      const requestInstance = contractInstance.methods[method](...args)
        [onReturn ? 'call' : 'send']({
          from: account,
          gas: '1000000000',
        })
        .catch((err) => {
          if (!catchCallback) {
            throw new Error(
              `Calling method ${method}${formatArgs(args)} ${err}`
            );
          }
          catchCallback(Object.values(err.results)[0].reason);
        });

      onReturn && onReturn(await requestInstance, await previousReturnValue);
      return recursiveFunction(methodIndex + 1, requestInstance);
    });

  return recursiveFunction(0, Promise.resolve());
};

const useWeb3 = () => {
  const web3 = new Web3(
    ganache.provider({
      gasLimit: 1000000000000,
    })
  );
  const deploy = ({ abi, evm, bytecode }, args, account) =>
    new web3.eth.Contract(abi)
      .deploy({
        data: evm ? evm.bytecode.object : bytecode,
        arguments: args,
      })
      .send({
        from: account,
        gas: '1000000000',
      });

  const getAccounts = async () => await web3.eth.getAccounts();

  return {
    deploy,
    getAccounts,
  };
};

module.exports = {
  useMethodsOn,
  useWeb3,
};

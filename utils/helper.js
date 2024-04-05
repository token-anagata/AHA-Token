const secondsInTheFuture = (seconds) => Math.floor(Date.now() / 1000) + seconds;

const randomInt = (min, max) => {
  const diff = max - min;
  return Math.ceil(Math.random() * diff) + min;
};

const timeInSecs = () => Math.round(Date.now() / 1000);

const newArray = (length, callback) => {
  const array = [];
  for (let i = 0; i < length; i++) array.push(callback(i));
  return array;
};

module.exports = {
  secondsInTheFuture,
  randomInt,
  timeInSecs,
  newArray,
};

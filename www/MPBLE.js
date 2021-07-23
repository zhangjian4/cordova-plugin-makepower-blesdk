var exec = require("cordova/exec");

exports.setType = function (type, success, error) {
  exec(success, error, "MPBLE", "setType", [type]);
};

exports.bleConnect = function (
  macAddress,
  secretKey,
  secretLock,
  userId,
  isKeyDevice,
  success,
  error
) {
  exec(success, error, "MPBLE", "bleConnect", [
    macAddress,
    secretKey,
    secretLock,
    userId,
    isKeyDevice,
  ]);
};

exports.disConnect = function (success, error) {
  exec(success, error, "MPBLE", "disConnect", []);
};

exports.getBleInfo = function (success, error) {
  exec(success, error, "MPBLE", "getBleInfo", []);
};

exports.initKey = function (success, error) {
  exec(success, error, "MPBLE", "initKey", []);
};

exports.setBleClock = function (time, success, error) {
  exec(success, error, "MPBLE", "setBleClock", [time]);
};

exports.initLockCode = function (lockCode, success, error) {
  exec(success, error, "MPBLE", "initLockCode", [lockCode]);
};

exports.getLockCode = function (success, error) {
  exec(success, error, "MPBLE", "getLockCode", []);
};

exports.getKeyCode = function (success, error) {
  exec(success, error, "MPBLE", "getKeyCode", []);
};

exports.getLockState = function (success, error) {
  exec(success, error, "MPBLE", "getLockState", []);
};

exports.openLock = function (lockCode, startTime, endTime, success, error) {
  exec(success, error, "MPBLE", "openLock", [lockCode, startTime, endTime]);
};

exports.setTask = function (
  lockCodes,
  areas,
  startTime,
  endTime,
  offLineTime,
  success,
  error
) {
  exec(success, error, "MPBLE", "setTask", [
    lockCodes,
    areas,
    startTime,
    endTime,
    offLineTime,
  ]);
};

exports.readLog = function (success, error) {
  exec(success, error, "MPBLE", "readLog", []);
};

exports.removeLog = function (success, error) {
  exec(success, error, "MPBLE", "removeLog", []);
};

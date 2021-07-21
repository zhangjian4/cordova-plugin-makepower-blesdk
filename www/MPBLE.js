var exec = require('cordova/exec');

exports.setType = function (type, success, error) {
    exec(success, error, 'MPBLE', 'setType', [type]);
};

exports.bleConnect = function (macAddress,secretKey,secretLock,userId,isKeyDevice, success, error) {
    exec(success, error, 'MPBLE', 'bleConnect', [macAddress,secretKey,secretLock,userId,isKeyDevice]);
};

exports.disConnect = function (success, error) {
    exec(success, error, 'MPBLE', 'disConnect', []);
};

exports.getLockCode = function (success, error) {
    exec(success, error, 'MPBLE', 'getLockCode', []);
};

exports.openLock=function (lockCode,success, error) {
    exec(success, error, 'MPBLE', 'openLock', [lockCode]);
};

package cc.makepower.blesdk;

import android.bluetooth.BluetoothDevice;

import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.megster.cordova.ble.central.BLECentralPlugin;
import com.megster.cordova.ble.central.Peripheral;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.apache.cordova.LOG;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TimeZone;

import cc.makepower.blesdk.bean.BleInfoEntity;
import cc.makepower.blesdk.bean.LockStateEntity;
import cc.makepower.blesdk.bean.LogEntity;
import cc.makepower.blesdk.bean.ResultBean;

/**
 * This class echoes a string called from JavaScript.
 */
public class MPBLE extends CordovaPlugin implements SdkMethodInterCallBack {
    private SdkMethodInterFace bleEntity;
    private static final String BLECONNECT = "bleConnect";
    private static final String DISCONNECT = "disConnect";
    private static final String GETBLEINFO = "getBleInfo";
    private static final String INITKEY = "initKey";
    private static final String SETBLECLOCK = "setBleClock";
    private static final String INITLOCKCODE = "initLockCode";
    private static final String GETLOCKCODE = "getLockCode";
    private static final String GETKEYCODE = "getKeyCode";
    private static final String GETLOCKSTATE = "getLockState";
    private static final String OPENLOCK = "openLock";
    private static final String SETTASK = "setTask";
    private static final String READLOG = "readLog";
    private static final String REMOVELOG = "removeLog";
    private String type = null;
    private Map<String, CallbackContext> callbackContextMap = new HashMap<>();
    private Peripheral device;
    private static final String LOG_TAG = "MPBLE";

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        try {
            if (action.equals("setType")) {
                String type = args.getString(0);
                this.setType(type);
                callbackContext.success();
                return true;
            } else if (this.bleEntity == null) {
                throw new RuntimeException("未设置协议类型");
            }
            callbackContextMap.put(action, callbackContext);
            switch (action) {
                case BLECONNECT: {
                    String macAddress = args.getString(0);
                    this.device = getDevice(macAddress);
                    String secretKey = args.getString(1);
                    String secretLock = args.getString(2);
                    String userId = args.getString(3);
                    Boolean isKeyDevice = args.getBoolean(4);
                    bleEntity.bleConnect(device.getDevice(), cordova.getContext(), secretKey, secretLock, userId, isKeyDevice);

                    return true;
                }
                case DISCONNECT: {
                    bleEntity.disConnect();
                    // 重新创建实例,不然下次会连不上
                    bleEntity = createEntity(type);
                    return true;
                }
                case GETBLEINFO: {
                    bleEntity.getBleInfo();
                    return true;
                }
                case INITKEY: {
                    this.bleEntity.initKey();
                    return true;
                }
                case SETBLECLOCK: {
                    Date currentDate = toDate(args.get(0));
                    this.bleEntity.setBleClock(currentDate);
                    return true;
                }
                case INITLOCKCODE: {
                    String lockCode = args.getString(0);
                    this.bleEntity.initLockCode(lockCode);
                    return true;
                }
                case GETLOCKCODE: {
                    this.bleEntity.getLockCode();
                    return true;
                }
                case GETKEYCODE: {
                    this.bleEntity.getKeyCode();
                    return true;
                }
                case GETLOCKSTATE: {
                    this.bleEntity.getLockState();
                    return true;
                }
                case OPENLOCK: {
                    String lockCode = args.getString(0);
                    Date startTime = toDate(args.get(1));
                    Date endTime = toDate(args.get(2));
                    this.bleEntity.openLock(lockCode, startTime, endTime);
                    return true;
                }
                case SETTASK: {
                    List<String> lockCodes = toStringList(args.getJSONArray(0));
                    List<String> areas = toStringList(args.getJSONArray(1));
                    Date startTime = toDate(args.get(2));
                    Date endTime = toDate(args.get(3));
                    int offLineTime = args.getInt(4);
                    this.bleEntity.setTask(lockCodes, areas, startTime, endTime, offLineTime);
                    return true;
                }
                case READLOG: {
                    this.bleEntity.readLog();
                    return true;
                }
                case REMOVELOG: {
                    this.bleEntity.removeLog();
                    return true;
                }
            }
        } catch (Exception e) {
            LOG.e(LOG_TAG, e.getMessage(), e);
            callbackContextMap.remove(action);
            callbackContext.error(e.getMessage());
            return true;
        }
        return false;
    }


    public void setType(String type) {
        if (bleEntity != null) {
            try {
                bleEntity.disConnect();
            } catch (Exception e) {
                LOG.e(LOG_TAG, e.getMessage(), e);
            }
        }
        bleEntity = createEntity(type);
        this.type = type;
    }

    private SdkMethodInterFace createEntity(String type) {
        if ("zjtt".equals(type)) {
            return new cc.makepower.sdk.zje.BleBase(this);
        } else if ("hc08".equals(type)) {
            return new cc.makepower.sdk.hc.BleBase(this);
        } else if ("yisuo".equals(type)) {
            return new cc.makepower.sdk.yisuo.BleBase(this);
        } else {
            try {
                Class<?> clazz = Class.forName("com." + type + ".android.blesdk.BleBase");
                Constructor constructor = clazz.getConstructor(SdkMethodInterCallBack.class);
                return (SdkMethodInterFace) constructor.newInstance(this);
            } catch (ClassNotFoundException e) {
                throw new RuntimeException("协议不存在");
            } catch (Exception e) {
                throw new RuntimeException("实例创建失败:" + e.getMessage(), e);
            }
        }
    }


    public void executeCallback(String actionName, ResultBean resultBean) {
        LOG.d("MPBLE Callback", actionName + ":" + resultBean.isRet() + "," + resultBean.getMsg());
        CallbackContext callbackContext = callbackContextMap.remove(actionName);
        if (callbackContext != null) {
            if (resultBean.isRet()) {
                Object data = resultBean.getObj();
                if (data == null) {
                    callbackContext.success();
                } else if (data instanceof String) {
                    callbackContext.success((String) data);
                } else {
                    try {
                        Gson gson = new GsonBuilder().setDateFormat("yyyy-MM-dd HH:mm:ss").create();
                        String json = gson.toJson(data);
                        if (data instanceof List) {
                            callbackContext.success(new JSONArray(json));
                        } else {
                            callbackContext.success(new JSONObject(json));
                        }
                    } catch (Exception e) {
                        LOG.e(LOG_TAG, e.getMessage(), e);
                        callbackContext.success();
                    }
                }
            } else {
                callbackContext.error(resultBean.getMsg());
            }
        }
    }

    @Override
    public void bleConnectCallBack(ResultBean resultBean) {
        if (device != null && resultBean.isRet()) {
            setConnected(device, true);
        }
        executeCallback(BLECONNECT, resultBean);
    }

    @Override
    public void disConnectCallBack(ResultBean resultBean) {
        if (device != null) {
            setConnected(device, false);
        }
        executeCallback(DISCONNECT, resultBean);
    }

    @Override
    public void getLockCodeCallBack(ResultBean<String> resultBean) {
        executeCallback(GETLOCKCODE, resultBean);
    }

    @Override
    public void getKeyCodeCallBack(ResultBean<String> resultBean) {
        executeCallback(GETKEYCODE, resultBean);
    }

    @Override
    public void getBleInfoCallBack(ResultBean<BleInfoEntity> resultBean) {
        executeCallback(GETBLEINFO, resultBean);
    }

    @Override
    public void getLockStateCallBack(ResultBean<LockStateEntity> resultBean) {
        executeCallback(GETLOCKSTATE, resultBean);
    }

    @Override
    public void setBleClockCallBack(ResultBean resultBean) {
        executeCallback(SETBLECLOCK, resultBean);
    }

    @Override
    public void openLockCallBack(ResultBean resultBean) {
        executeCallback(OPENLOCK, resultBean);
    }

    @Override
    public void setTaskCallBack(ResultBean resultBean) {
        executeCallback(SETTASK, resultBean);
    }

    @Override
    public void initKeyCallBack(ResultBean<String> resultBean) {
        executeCallback(INITKEY, resultBean);
    }

    @Override
    public void initLockCodeCallBack(ResultBean<String> resultBean) {
        executeCallback(INITLOCKCODE, resultBean);
    }

    @Override
    public void readLogCallBack(ResultBean<List<LogEntity>> resultBean) {
        executeCallback(READLOG, resultBean);
    }

    @Override
    public void removeLogCallBack(ResultBean resultBean) {
        executeCallback(REMOVELOG, resultBean);
    }

    private Peripheral getDevice(String mac) {
        Peripheral peripheral = null;
        try {
            BLECentralPlugin ble = (BLECentralPlugin) webView.getPluginManager().getPlugin("BLE");
            Field peripheralsField = BLECentralPlugin.class.getDeclaredField("peripherals");
            peripheralsField.setAccessible(true);
            Map<String, Peripheral> peripherals = (Map<String, Peripheral>) peripheralsField.get(ble);
            peripheral = peripherals.get(mac);
        } catch (Exception e) {
            throw new RuntimeException(e.getMessage(), e);
        }
        if (peripheral == null) {
            throw new RuntimeException("未找到蓝牙设备");
        }
        return peripheral;
    }

    private void setConnected(Peripheral peripheral, boolean connected) {
        try {
            Field field = Peripheral.class.getDeclaredField("connected");
            field.setAccessible(true);
            field.set(peripheral, connected);
        } catch (Exception e) {
            LOG.e(LOG_TAG, e.getMessage(), e);
        }
    }

    private List<String> toStringList(JSONArray jsonArray) {
        List<String> list = new ArrayList<>();
        for (int i = 0; i < jsonArray.length(); i++) {
            try {
                list.add(jsonArray.getString(i));
            } catch (JSONException e) {
                throw new RuntimeException(e.getMessage(), e);
            }
        }
        return list;
    }

    private Date toDate(Object dateStr) {
        if (dateStr == null || "".equals(dateStr)) {
            return null;
        }
        if (dateStr instanceof String) {
            DateFormat format = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
            try {
                return format.parse((String) dateStr);
            } catch (ParseException e) {
                TimeZone tz = TimeZone.getTimeZone("UTC");
                format = new SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'");
                format.setTimeZone(tz);
                try {
                    return format.parse((String) dateStr);
                } catch (ParseException parseException) {
                    throw new RuntimeException(e.getMessage(), e);
                }
            }
        }
        return null;
    }
}

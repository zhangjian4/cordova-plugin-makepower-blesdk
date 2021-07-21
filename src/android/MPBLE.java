package cc.makepower.blesdk;

import android.bluetooth.BluetoothDevice;

import com.megster.cordova.ble.central.BLECentralPlugin;
import com.megster.cordova.ble.central.Peripheral;

import org.apache.cordova.CordovaActivity;
import org.apache.cordova.CordovaInterfaceImpl;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.apache.cordova.LOG;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Constructor;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
    private static final String GETLOCKCODE = "getLockCode";
    private static final String OPENLOCK = "openLock";
    private static final String DISCONNECT = "disConnect";
    private String type = null;
    private Map<String, CallbackContext> callbackContextMap = new HashMap<>();

    @Override
    public boolean execute(String action, JSONArray args, CallbackContext callbackContext) throws JSONException {
        try {
            if (action.equals("setType")) {
                String type = args.getString(0);
                this.setType(type, callbackContext);
                callbackContext.success();
                return true;
            } else if (this.bleEntity == null) {
                throw new RuntimeException("未设置协议类型");
            } else {
                callbackContextMap.put(action, callbackContext);
                if (action.equals(BLECONNECT)) {
                    String macAddress = args.getString(0);
                    String secretKey = args.getString(1);
                    String secretLock = args.getString(2);
                    String userId = args.getString(3);
                    Boolean isKeyDevice = args.getBoolean(4);
                    this.bleConnect(macAddress, secretKey, secretLock, userId, isKeyDevice);
                    return true;
//            this.bleEntity.bleConnect();
                } else if (action.equals(DISCONNECT)) {
                    bleEntity.disConnect();
                    // 重新创建实例,不然下次会连不上
                    bleEntity = createEntity(type);
                    return true;
                } else if (action.equals(GETLOCKCODE)) {
                    this.bleEntity.getLockCode();
                    return true;
                } else if (action.equals(OPENLOCK)) {
                    String lockCode = args.getString(0);
                    this.bleEntity.openLock(lockCode, new Date(), new Date(System.currentTimeMillis() + 5000));
                    return true;
                }

            }
        } catch (Exception e) {
            LOG.e("MPBLE", e.getMessage(), e);
            callbackContextMap.remove(action);
            callbackContext.error(e.getMessage());
            return true;
        }
        return false;
    }

    public void setType(String type, CallbackContext callbackContext) {
        if (bleEntity != null) {
            try {
                bleEntity.disConnect();
            } catch (Exception e) {
                LOG.e("MPBLE", e.getMessage(), e);
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


    public void bleConnect(String macAddress, String secretKey, String secretLock, String userId, boolean isKeyDevice) {
        try {
            BLECentralPlugin ble = (BLECentralPlugin) webView.getPluginManager().getPlugin("BLE");
            Field peripheralsField = BLECentralPlugin.class.getDeclaredField("peripherals");
            peripheralsField.setAccessible(true);
            Map<String, Peripheral> peripherals = (Map<String, Peripheral>) peripheralsField.get(ble);
            Peripheral peripheral = peripherals.get(macAddress);
            BluetoothDevice device = peripheral.getDevice();
            if (device == null) {
                throw new RuntimeException("未找到蓝牙设备");
            }
            bleEntity.bleConnect(device, cordova.getContext(), secretKey, secretLock, userId, isKeyDevice);
        } catch (Exception e) {
            throw new RuntimeException(e.getMessage(), e);
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
                    callbackContext.success();
                }
            } else {
                callbackContext.error(resultBean.getMsg());
            }
        }
    }

    @Override
    public void bleConnectCallBack(ResultBean resultBean) {
        executeCallback(BLECONNECT, resultBean);
    }

    @Override
    public void disConnectCallBack(ResultBean resultBean) {
        executeCallback(DISCONNECT, resultBean);
    }

    @Override
    public void getLockCodeCallBack(ResultBean<String> resultBean) {
        executeCallback(GETLOCKCODE, resultBean);
    }

    @Override
    public void getKeyCodeCallBack(ResultBean<String> resultBean) {
        System.out.println(resultBean);
    }

    @Override
    public void getBleInfoCallBack(ResultBean<BleInfoEntity> resultBean) {
        System.out.println(resultBean);
    }

    @Override
    public void getLockStateCallBack(ResultBean<LockStateEntity> resultBean) {
        System.out.println(resultBean);
    }

    @Override
    public void setBleClockCallBack(ResultBean resultBean) {
        System.out.println(resultBean);
    }

    @Override
    public void openLockCallBack(ResultBean resultBean) {
        executeCallback(OPENLOCK, resultBean);
    }

    @Override
    public void setTaskCallBack(ResultBean resultBean) {
        System.out.println(resultBean);
    }

    @Override
    public void initKeyCallBack(ResultBean<String> resultBean) {
        System.out.println(resultBean);
    }

    @Override
    public void initLockCodeCallBack(ResultBean<String> resultBean) {
        System.out.println(resultBean);
    }

    @Override
    public void readLogCallBack(ResultBean<List<LogEntity>> resultBean) {
        System.out.println(resultBean);
    }

    @Override
    public void removeLogCallBack(ResultBean resultBean) {
        System.out.println(resultBean);
    }
}

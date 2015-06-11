//
//  SSCM.h
//  QQMSFContact
//
//  Created by wstt on 12-8-20.
//
//

#import <Foundation/Foundation.h>
#import "SSCMDef.h"

typedef enum
{
	SSCM_STATE_QUICK_START = 0, //快启动
	SSCM_STATE_SLOW_START,      //慢启动
	SSCM_STATE_STABLE           //稳定态
} SSCMState;

//0.09是角度为5度的slope，即tan(5)，这里暂定该值为拐点
//#define SSCM_SLOPE_POINT 0.09

//最多确认次数
//#define SSCM_MAX_CONFIRM_CNT 2

//SSCM：Segment Size Calculation Module分片大小计算模块
@interface SSCM : NSObject
{
    BOOL        _initFlag;      //初始化标识，第一次为true，后续都为false
    int         _state;         //状态标识，SSCMState
    float       _slope;         //斜率
    NET_TYPE    _networkType;   //网络类型，分片计算模型对应不同的网络类型，分片大小计算算法完全不同，由上层模块调用时记录
    
    NSTimeInterval _T;   //最近一次分片发送完成的耗时，由上层模块设置
    
    int     _S1;         //首片大小
    int     _Sn;         //最近的分片大小
    int     _So;         //上一次的分片大小
    float   _V1;         //首片的实时速度
    float   _Vn;         //最新一次的实时速度
    float   _Vo;         //上一分片大小的平滑速度
    float   _Vstable;    //stable状态下的基准速率
    
    /*
	 * 单增多确认原则，即_confirmNum达到配置的上限时，_switchFlag标志置位，便于下次计算切换状态，切换后_switchFlag标志清零
	 */
    BOOL    _switchFlag; //切换标志
    int     _confirmNum; //不在对应状态下的计数，即需要改变状态的确认次数
    
    /*
	 * unStableNum:在稳定状态下连续出现不稳定值（不符合本状态要求的值）的次数
	 * 对应对比_SFiStableUsn变量值；
	 */
	int     _unStableNum;
    
    // 对应鱼翅参数
    int     _SFiStableUsn;  //在稳定态下，允许出现的连续不稳定值的最大次数；为了尽量不改变稳定态，这个值比非稳定态的值要大一点。是一个常量（3）,后台配置下发
    double  _SFiSlowRate;   //慢增长率,后台配置下发
    double  _SFiQuikeRate;  //快增长率,后台配置下发
    double  _SFiSlopePoi;   //拐点,后台配置下发
    
    // 总次数和range回退保护
    int _pkgCnt;
    int _pkgMaxCnt;
    unsigned int _uploadRangeLen;
    int  _rangeErrCnt;
}

@property NET_TYPE networkType;
@property int Sn;


// 在重试时调用，用于清空原有的数据
- (void) initParam;


// 发送分片时，调用该接口获取分片大小
- (NSUInteger) getPkgSizeByNetType:(NSUInteger)netType fileSize:(NSUInteger)fileSize transferedSize:(NSUInteger)transferedSize;

// 分片发送完成时，调用该接口设置该分片消耗的时间
- (void) setPkgSendT:(NSTimeInterval)pkgSendT;

// 设置返回range
- (void) setRangeLen:(unsigned int)rangeLen;

// 判断总次数和回退是否合法，合法返回YES，异常返回NO 表示停止发送
- (BOOL) isValid;

@end

// 安装命令，用于安装packbag，xxx为包名，replace选项为若未安装则进行在线安装；
// 若已安装，则替换为新版本
*ssc install xxx，
*ssc install xxx,repalce

*查找命令，用于查找是否安装了包，xxx为包名
*findit xxx

*导入数据，这个手动点击导入可能更加方便
import excel "C:\UserData\Desktop\data.xlsx", sheet("Sheet1") firstrow clear

*声明全局变量（非必要）
local varlist "y x1 x2 x3 x4 x5"

*描述性统计分析
sum2docx `varlist' using 描述性统计.docx,replace ///
	stats(N mean(%9.2f) sd(%9.3f) min(%9.2f) median(%9.2f) max(%9.2f)) ///
	title(Descriptive statistics)
	
*声明面板数据（id为个体，time为年份，根据自己的数据情况修改）
xtset id time

*hausman检验（fe,re）
*fe是固定效应，re是随机效应
xtreg y x1 x2 x3 x4 x5,fe
est store fe

xtreg y x1 x2 x3 x4 x5,re
est store re

hausman fe re,constant

esttab fe re using hausman.rtf, ///
	replace star( * 0.10 ** 0.05 *** 0.01 ) nogaps compress ///
	b(%20.3f) se(%7.2f)  ///
	r2(%9.3f) ar2 aic bic obslast scalars(F)  ///
	mtitles("固定效应" "随机效应" ) ///
	title(hausman test)
	


*个体固定效应回归
xtreg y x1 x2 x3 x4 x5,fe
est store m1

*随机效应回归
xtreg y x1 x2 x3 x4 x5,re
est store m2

*双向固定效应回归
xtreg y x1 x2 x3 x4 x5 i.time,fe i(time)
est store m3

*时间效应回归
xtreg y x1 x2 x3 x4 x5 i.time,fe
est store m4

*输出结果并导出到表格“regression result”
esttab m1 m2 m3 m4 using result1.rtf, ///
	replace star( * 0.10 ** 0.05 *** 0.01 ) nogaps compress ///
	b(%20.3f) se(%7.2f)  ///
	r2(%9.3f) ar2 aic bic obslast scalars(F)  ///
	mtitles("个体固定" "随机" "双向固定" "时间固定" ) ///
	title( regression result)
	
	
*稳健性检验
xtreg y1 x1 x2 x3 x4 x5,fe
est store m5

xtreg y z1 x2 x3 x4 x5,fe
est store m5

esttab m5 m6 using result2.rtf, ///
	replace star( * 0.10 ** 0.05 *** 0.01 ) nogaps compress ///
	b(%20.3f) se(%7.2f)  ///
	r2(%9.3f) ar2 aic bic obslast scalars(F)  ///
	mtitles("y1" "z1" ) ///
	title( regression result2)


*内生性问题
*使用前请先安装xtabond2命令
xtabond2 y L(1/2).y x1 x2 x3 x4 x5,gmm(L.y x4) iv(x1 x2 x3 x5) nolevel robust small
est store m7

esttab m7 using result3.rtf, ///
	replace star( * 0.10 ** 0.05 *** 0.01 ) nogaps compress ///
	b(%20.3f) se(%7.2f)  ///
	r2(%9.3f) ar2 aic bic obslast scalars(F)  ///
	mtitles("差分GMM") ///
	title( regression result3)


*异质性分析
*对于虚拟变量进行异质性分析
*例如判断国企和非国企有无异质性，把企业类型type设置为国企代表1，非国企为0.
xtreg y x1 x2 x3 x4 x5 i.time if type==1,fe
est store m8

xtreg y x1 x2 x3 x4 x5 i.time if type==0,fe

est store m9

esttab m8 m9 using result4.rtf, ///
	replace star( * 0.10 ** 0.05 *** 0.01 ) nogaps compress ///
	b(%20.3f) se(%7.2f)  ///
	r2(%9.3f) ar2 aic bic obslast scalars(F)  ///
	mtitles("type1" "type0") ///
	title( regression result4)

*对于一个连续变量进行异质性分析
*例如按企业规模（size）分为大型企业和中小企业
*需要先对数据按照是否大于中位数/平均数进行拆分

gen company_size = 0
egen company_med = median( size )
replace company_size = 1 if  >= company_med

xtreg y x1 x2 x3 x4 x5 i.time if company_size==1,fe
est store m10

xtreg y x1 x2 x3 x4 x5 i.time if company_size==0,fe

est store m11

esttab m10 m11 using result7.rtf, ///
	replace star( * 0.10 ** 0.05 *** 0.01 ) nogaps compress ///
	b(%20.3f) se(%7.2f)  ///
	r2(%9.3f) ar2 aic bic obslast scalars(F)  ///
	mtitles("major" "medium-sized") ///
	title( regression result5)
	
*中介效应


*调节效应

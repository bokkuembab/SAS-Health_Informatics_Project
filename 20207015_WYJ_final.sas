/*
 * 20207015 위예진
 * 2021년 헬스인포메틱스 과목 기말 프로젝트
 * 주제: 지인과 연락빈도, 친목여가활동 여부에 따른 주관적 스트레스와 삶의 만족도
 * 종속변수: 삶의 만족도
 * 관심변수: 지인과 연락빈도, 친목/여가활동 여부
 * 통제변수: 성별, 나이, 소득수준, 경제활동 여부, 주관적 스트레스, 주관적 건강수준, 수면장애, 혼인상태, 1주일 운동시간
*/

/****Data management****/
data a;
set chs19_all;
run;

data b;
set a;


/*** 종속변수 ***/
/* Satisfaction(삶의 만족도) 변수 생성
 * 삶의 만족도 변수(qoc_07z1) 사용
 * 1-5: 0(불만족), 6-10: 1(만족), 응답거부/모름: 삭제*/
if qoc_07z1 in (1,2,3,4,5) then Satisfaction=0;
else if qoc_07z1 in (6,7,8,9,10) then Satisfaction=1;
else delete;


/*** 관심변수 ***/
/* Contact(지인과 연락빈도) 변수 생성
 * 친척/이웃/친구와 연락 빈도(enb_01z1, enb_02z1, enb_03z1) 사용
 * 사분위 생성*/
con=0;
if enb_01z1=1 then con=con;
else if enb_01z1=2 then con=con+1;
else if enb_01z1=3 then con=con+2;
else if enb_01z1=4 then con=con+4;
else if enb_01z1=5 then con=con+8;
else if enb_01z1=6 then con=con+16;
else delete;

if enb_02z1=1 then con=con;
else if enb_02z1=2 then con=con+1;
else if enb_02z1=3 then con=con+2;
else if enb_02z1=4 then con=con+4;
else if enb_02z1=5 then con=con+8;
else if enb_02z1=6 then con=con+16;
else delete;

if enb_03z1=1 then con=con;
else if enb_03z1=2 then con=con+1;
else if enb_03z1=3 then con=con+2;
else if enb_03z1=4 then con=con+4;
else if enb_03z1=5 then con=con+8;
else if enb_03z1=6 then con=con+16;
else delete;
run;

/*한달동안 지인과 연락횟수 사분위 확인*/
proc univariate data=b;
var con; run;

data c;
set b;
if con>32 then Contact=0;
else if con<33 and con>18 then Contact=1;
else if con<19 and con>9 then Contact=2;
else Contact=3;

/* Activity(외부 활동) 변수 생성
 * 종교/친목/여가레저/자선단체 활동(enb_04z1, enb_05z1, enb_06z1, enb_07z1) 사용
 * 예라고 답한 수가 1-4개: 0, 0개: 1 
 * 새로운 외부 활동 범주형 변수를 생성 */
act=0;
if enb_04z1=1 then act=act+1;
else if enb_04z1=2 then act=act;
else delete;
if enb_05z1=1 then act=act+1;
else if enb_05z1=2 then act=act;
else delete;
if enb_06z1=1 then act=act+1;
else if enb_06z1=2 then act=act;
else delete;
if enb_07z1=1 then act=act+1;
else if enb_07z1=2 then act=act;
else delete;

if act in (1,2,3,4) then Activity=0;
else if act=0 then Activity=1;
else delete;


/*** 통제변수 ***/
/* Income(소득수준) 변수 생성 
 * 가구소득(fma_24z2)을 활용
 * 500만원 이상: 0, 300-500만원: 1, 100-300만원: 2, 100만원 미만: 3
 * 응답거부, 모름은 삭제 */
if fma_12z1 in (7,9) then delete;
else if fma_12z1=1 and fma_13z1 not in (77777,99999) then inc=fma_13z1/12;
else if fma_12z1=2 and fma_14z1 not in (77777,99999) then inc=fma_14z1;
else delete;

if inc>=500 then Income=0;
else if inc>=300 and inc<500 then Income=1;
else if inc>=100 and inc<300 then Income=2;
else Income=3;


/* Economy(경제활동여부) 변수 생성 
 * 경제활동여부(soa_01z1)을 활용
 * 예: 0, 아니오: 1, 응답거부/모름: 삭제 */
if soa_01z1=1 then Economy=0;
else if soa_01z1=2 then Economy=1;
else delete;

/* Stress(주관적 스트레스) 변수 생성
 * 주관적 스트레스 변수(mta_01z1) 사용
 * 거의안느낌: 0, 조금: 1, 대단히많이/많이: 2, 응답거부/모름: 삭제*/
if mta_01z1=4 then Stress=0;
else if mta_01z1=3 then Stress=1;
else if mta_01z1 in (1,2) then Stress=2;
else delete;

/* SelfHealth(주관적 건강수준) 변수 생성
 * 주관적 건강수준 변수(qoa_01z1) 사용
 * 매우좋음/좋음: 0, 보통: 1, 나쁨/매우나쁨: 2, 응답거부/모름: 삭제 */
if qoa_01z1 in (1,2) then SelfHealth=0;
else if qoa_01z1 in (3) then SelfHealth=1;
else if qoa_01z1 in (4,5) then SelfHealth=2;
else delete;

/* SleepLoss(수면장애) 변수 생성 
 * 수면장애(mtb_07c1)을 활용
 * 전혀 아니다: 0, 여러날: 1, 일주일이상/거의매일: 2, 응답거부/모름: 삭제 */
if mtb_07c1=1 then SleepLoss=0;
else if mtb_07c1=2 then SleepLoss=1;
else if mtb_07c1 in (3,4) then SleepLoss=2;
else delete;

/* Marry(혼인상태) 변수 생성 
 * 혼인상태(sod_02z2)을 활용
 * 배우자 있음: 0, 이혼/사별/별거/미혼: 1, 응답거부/모름: 삭제 */
if sod_02z2=1 then Marry=0;
else if sod_02z2 in (2,3,4,5) then Marry=1;
else delete;

/* Exercise(1주일 운동시간) 변수 생성 
 * 격렬한 신체활동 일수/시간(시)/(분)(pha_04z1,pha_05z1,pha_06z1): hard 변수
 * 중등도 신체활동 일수/시간(시)/(분)(pha_07z1,pha_08z1,pha_09z1): normal 변수
 * hard, normal의 시간 더해서 새로운 일주일 운동시간(분) 연속형 변수를 생성
 * 응답거부/모름: 삭제 */
/*hard 변수*/
hard=0;
if pha_04z1>8 then delete;
else if pha_05z1 not in (77,99) and pha_06z1 not in (77,99) then hard=(pha_05z1*60+pha_06z1)*pha_04z1;
else delete;
/*normal 변수*/
normal=0;
if pha_07z1>8 then delete;
else if pha_08z1 not in (77,99) and pha_09z1 not in (77,99) then normal=(pha_08z1*60+pha_09z1)*pha_07z1;
else delete;
/*hard+normal*/
Exercise=hard+normal;
run;

/*최종 데이터 저장*/
data finalPJ_data;
set c;
keep Stress Satisfaction Contact Activity sex age Income Economy SelfHealth SleepLoss Marry Exercise;
run;






/****Data analysis****/
/*finalPJ_data*/
/*종속변수: 삶의 만족도*/
/*변수들의 Univariate 분석: 명목형변수-빈도,백분율, 연속형변수-평균, 표준편차*/
proc freq data=finalPJ_data;
table Satisfaction Contact Activity sex Income Economy Stress SelfHealth SleepLoss Marry; run;

proc means data=finalPJ_data;
var age Exercise; run;


/*By-variate 분석, 통계적 유의성 검정*/
proc freq data=finalPJ_data;
table (Contact Activity sex Income Economy Stress SelfHealth SleepLoss Marry)*Satisfaction/chisq nocol norow; run;

proc ttest data=finalPJ_data;
class Satisfaction; var age Exercise; run;


/*Multi-variate 분석, 변수 간 영향 분석*/
proc logistic data=finalPJ_data;
class Contact(ref='0') Activity(ref='0') sex Income(ref='0') Economy(ref='0') Stress(ref='0') SelfHealth(ref='0') SleepLoss(ref='0') Marry(ref='0');
model Satisfaction (event='1')=Contact Activity sex age Income Economy Stress SelfHealth SleepLoss Marry Exercise;
run;






































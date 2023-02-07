/**
 * 파	일	명 		: ltsPrm080.xfdl 				<br>
 * 작	성	자 		: --						    <br>
 * 작	성	일 		: 2015.10.23					<br>
 *													<br>
 * 설		명 		: 채권관리 Report				<br>
 *---------------------------------------------------------------------------------------<br>
 *  변경일     변경자  변경내역					<br>
 *---------------------------------------------------------------------------------------<br>
 
 *---------------------------------------------------------------------------------------<br>
 * @namespace
 * @name ltsPrm080
 */
//=======================================================================================
// Common Lib Include
//--------------------------------------------------------------------------------------- 
include "lib::comLib.xjs";

//=======================================================================================
// 1. 화면전역변수선언
//---------------------------------------------------------------------------------------
var objWorkFrame = gv_workAreaSet.getActiveFrame();
var objDiv = objWorkFrame.form.divComArea;
//=======================================================================================
// 2.FORM EVENT 영역
//---------------------------------------------------------------------------------------

/**
 * 설명: 폼로딩 초기화 함수(validation채크및 공통코드)
 * @param  없음
 * @return 없음
 * @memberOf ltsCa090
 */
function cfnInitOnload()
{	
	//공통코드(biztype:)	
	gfnSetInitForm(this); // ctrl+shift+F1이 눌리도록
	
	//공통코드(biztype:)
	var oComcodeSetList = [
		{code:"KPC_SPART", dsName:"dsKPC_SPART", useYn:"Y", selecttype:"A", objid: "divSearch.cboSPART"},
		{code:"VKGRP", dsName:"dsVKGRP", useYn:"Y", selecttype:"S", objid: "divSearch.cboVKGRP"},
		{code:"ZVTWEG", dsName:"dsZVTWEG", useYn:"Y", selecttype:"A", objid: "divSearch.cboVTWEG"}
    ];
	gfnGetSapCommonCode(oComcodeSetList);	
	
	//vaildate 체크 목록 설정
	var oValidateSetList = [
		{objid:"divSearch.BUDAT", valid:"title:기준일,req:true"},	// 검색영역:기준년월
	];
	gfnSetVaildate(oValidateSetList);
	
	//그리드 버튼(그리드ID, 콜백함수)
	divResult.divGridList.cfnSetCommButton(divResult.grdList,false,false,false,false,true);
	
	//그리드contextMenu
	gfnSetGridContextMenu(divResult.grdList);	
	
	//gfnGetOrgCombo("S", "dsORGHK", "divSearch.cboORGHK");	//부서콤보 생성
	
	//필수 입력항목 설정.
	//fnSetDynamicValidation();
	
	cfnInitForm();
}

function cfnInitForm()
{
/**
 * 설명: 폼 초기화 함수(폼의 초기화: 검색영역, 그리드)
 * @param  없음
 * @return 없음
 * @memberOf ltsPso210
 */
	dsMaster.clearData();
	dsMaster.addRow();
	//dsMaster.setColumn(0, "IV_GUBUN", "B");
	dsbond_detail.clearData();
	
	divSearch.cboVTWEG.index = 1;	//유통채널 초기값 '내수'
	divSearch.cboSPART.index = 0;
	
	divSearch.edtKUNNR_NM.value = "";
	divSearch.edtKUNNR.value = "";
	divSearch.edtZZKUNNR_ENDNM.value = "";
	divSearch.edtZZKUNNR_END.value = "";
	
	divSearch.BUDAT.value = gfnGetLastDate(gfnToday());
	divSearch.rdoStatus.index = "1";
	
	divSearch.edtPERNRNM.value = gfnGetUserInfo("ENAME");
	
	//divSearch.chkVKGRP.value = "X";
	divSearch.chkKKBER.value = "X";
	divSearch.chkEKUNNR.value = "X";
	//divSearch.chkPERNR.value = "X";
	
	//처음 로그인한 사용자의 VKGRP 가져오도록 하는 함수
	fnSearchSalesInfo();
	
	if(gdsEmpInfo.getColumn(0, "SALEM") == 'X')
	{
		if(gdsEmpInfo.getColumn(0, "XTM") == 'X')
		{
//			divSearch.cboVKGRP.enable = false;
		}
		else
		{
			divSearch.edtPERNRNM.enable = false;
			divSearch.edtIKENID.enable = false;
//			divSearch.cboVKGRP.enable = false;
			divSearch.btnPERNRClear.enable = false;
			divSearch.edtPERNRCall.enable = false;	
		}
	}
	
	objDiv.btnStopCancel.enable = false;
}

//=======================================================================================
// 3.공통 호출함수
//---------------------------------------------------------------------------------------
/**
 * 설명: 전처리함수
 * @param  없음
 * @return 없음
 * @memberOf ltsCa090
 */
function cfnBeforeTran(sTranId) 
{	
	fnSetDynamicValidation();

	if(sTranId=="cfnSearch")
	{	
		if(gfnIsNull(divSearch.BUDAT.value)){
		gfnAlert("기준일은 필수 입력 사항입니다.");
		return false;
		}
	}
}

function cfnGetCombo()
{

}

/**
 * 설명: 조회 메소드
 * @param  없음
 * @return 없음
 * @memberOf ltsPrm080
 */
function cfnSearch()
{	
	var sTranId			= "cfnSearch";
	var sInDS 			= "";
	var sOutDS 			= "dsbond_detail=T_LIST";	
	var sContextPath 	= "/jco/JcoController/";
	var sServelet 		= "getJcoData.xp?FUNCTION_NAME=Z_LTSP_IF0370";
	var sSendData  		= "IV_PTYPE='R'";
	for(var i=0; i<dsMaster.colcount; i++)
	{
		sSendData  		+= " " + dsMaster.getColID(i)+"="+gfnSetQuote(dsMaster.getColumn(0, dsMaster.getColID(i)));
	}

	var sCallBackFn		= "";
	
	trace(sSendData);
	gfnSapTranN(sTranId, sInDS, sOutDS, sContextPath, sServelet, sSendData);

}

/**
 * 설명: 저장 함수
 * @param  없음
 * @return 없음
 * @memberOf ltsCa090
 */
function cfnSave()
{	
	
}

/**
 * 설명: 삭제 함수
 * @param  없음
 * @return 없음
 * @memberOf ltsCa090
 */
function cfnDelete()
{
	
}

/**
 * 설명: 신규처리 함수
 * @param  없음
 * @return 없음
 * @memberOf ltsCa090
 */
function cfnNew(obj:Button,  e:ClickEventInfo)
{
//폼초기화 함수
	cfnInitForm();
}

//=======================================================================================
// 4.CallBack 처리
//---------------------------------------------------------------------------------------
/**
 * 설명: CallBack 처리
 * @param  sTranId
 * @param  nErrorCode
 * @param  sErrorMsg
 * @return 없음
 * @memberOf ltsLm103
 */
function cfnCallback(sTranId, nErrorCode, sErrorMsg) 
{
	if(sTranId == "cfnSearch")
	{	
		gfnSetAlertMsgUd("-1");
		fnSetGridForCheck();
		if (dsMaster.getColumn(0, "IV_GUBUN") == "B" )
		{
			objDiv.btnStopCancel.enable = true;
		}
		else
		{
			objDiv.btnStopCancel.enable = false;
		}
	}
	
	if(sTranId == "fnSearchSalesInfo") //처음 로그인한 사용자의 VKGRP 가져오도록 함
	{
		divSearch.cboVKGRP.value = dsList.getColumn(0, "VKGRP");
		divSearch.edtIKENID.value = dsList.getColumn(0, "EMPNO");
		divSearch.edtPERNR.value = dsList.getColumn(0, "PERNR");
		gfnSetAlertMsgUd("-1");
	}	
}

//=======================================================================================
// 5. 공통옵션
//---------------------------------------------------------------------------------------

/**
 * 설명: 그리드 공통버튼 전처리함수
 * @param  없음
 * @return 없음
 * @memberOf ltsPrm080
 */
function cfnBeforeGrid(objGrd, type, obj:Button,  e:ClickEventInfo)
{
	if(objGrd.name=="grdList"){
		switch (type)
		{
			case "CLEARROW":	// 행초기화
				//내용기술(return true or false)
				break;
				
			case "ADDROW":		// 행추가
				//validate return false; row가 추가되지 안는상태
				
				//내용기술(return true or false)
				break;
			
			case "INSERTROW":	// 행삽입
				//내용기술(return true or false)
				break;
			
			case "DELROW":		// 행삭제
				//내용기술(return true or false)
				break;
			
			case "COPYROW":		// 행복사
				//내용기술(return true or false)
				break;
			
			case "EXDOWN":		// 엑셀 다운로드
				break;	
		}	
	}
}

//=======================================================================================
// 6.사용자 정의함수
//---------------------------------------------------------------------------------------
function fnSetDynamicValidation()
{
// 	var oValidateSetList = [
// 	{objid:"divSearch.edtKUNNR", valid:"title:stcKUNNR,req:true"}];		// 검색영역:조회범위
// 
// 	gfnSetVaildate(oValidateSetList);
}

/**
 * 설명: 임직원 팝업
 * @param  
 * @return 
 * @memberOf ltsLm001
 */
function fnGetEMPINFO()
{
	var objSend        = {};                         // Parameter : Obj
    objSend.sname      = divSearch.edtPERNRNM.value; // 담당자명
    
    if(!gfnIsNull(divSearch.cboVKGRP.value))
    {
		objSend.dptnm	   = dsVKGRP.getColumn(divSearch.cboVKGRP.index, "CDNAM");
	}
	
	var retVal = gfnltsOp227_P01(objSend);	

    if (retVal!= null)
    {
        //임직원 반영
        divSearch.edtIKENID.value   = retVal.dsCostomerList.getColumn(0, "EMPNO");
        divSearch.edtPERNRNM.value = retVal.dsCostomerList.getColumn(0, "SNAME");
        divSearch.edtPERNR.value = retVal.dsCostomerList.getColumn(0, "PERNR");
    }
}

/**
 * 설명: 고객사 팝업
 * @param  
 * @return 
 * @memberOf ltsCa095
 */
 function fnOpenPopup(objBtn)
 {
	if(gfnIsNull(divSearch.cboVTWEG.value)){
		gfnAlert("IOS140");	//유통경로를 선택해 주세요
		return;		
	}
	
// 	if(gfnIsNull(divSearch.cboSPART.value)){
// 		gfnAlert("IOS157");	//제품군을 선택해 주세요
// 		return;		
// 	}
	
	var objSend        = {};
	objSend.id         = "admin";
	
	var edtCustomer_NM = divSearch.edtKUNNR_NM.value;
	
	objSend.custname    = gfnIsNullBlank(edtCustomer_NM); // 고객사
	objSend.formId 	   = "ltsPrm090";
	objSend.vtweg 	   = divSearch.cboVTWEG.value;	//유통
	objSend.spart 	   = divSearch.cboSPART.value;	//제품군
	objSend.ktokd	   = "KTOKD_003";
	objSend.vkgrp      = divSearch.cboVKGRP.value;
	objSend.pernr      = divSearch.edtPERNR.value;
	objSend.pernrnm    = divSearch.edtPERNRNM.value;
	objSend.empno      = divSearch.edtIKENID.value;
	
	objSend.viewType   = "S";    // 단수개:S, 복수개:M
	
	var strId       = "scmOtcGlts151_P01";			//Dialog ID
	var strURL      = "LTS.OP::ltsOp151_P01.xfdl";	//Form URL
	var nTop        = -1;							//Form Top
	var nLeft       = -1;							//Form Left
	var nWidth      = 999;							//Form Width
	var nHeight     = 509;							//Form Height
	var bShowTitle  = true;							//Form Title 을 표시 할지 여부
	var strAlign    = "-1";					 	    //Dialog 의 위치
	var strArgument = {avDataDictNo:"", avDsCond:dsCUSTRANGE, avArySend:"", avObjSend:objSend}; //Dialog 로 전달될 Argument
	var isModeless = false;							// true 면 Dialog 를 Modeless로 띄운다.
	var winOption = {};								//window option
		winOption.resizable = false;				//팝업창의 리싸이징이 가능(true: 확대, 최소화가 없어진다)
		winOption.autosize = true;					//팝업창의 크기에 맞게 변경
		
	var retVal = gfnDialog(strId, strURL, nTop, nLeft, nWidth, nHeight, bShowTitle, strAlign, strArgument, isModeless, winOption);

	if(retVal != null) 
	{
 		if (retVal.dsCostomerList.rowcount > 0)
 		{
			divSearch.edtKUNNR_NM.value = retVal.dsCostomerList.getColumn(0, "KUNNR_NM");
			divSearch.edtKUNNR.value = retVal.dsCostomerList.getColumn(0, "KUNNR");
			//divSearch.edtZZKUNNR_ENDNM.value = retVal.dsCostomerList.getColumn(0, "KUNNR_NM");
			//divSearch.edtZZKUNNR_END.value = retVal.dsCostomerList.getColumn(0, "KUNNR");
 		}
	}
 }
 
 function fnSearchSalesInfo()
{
	//데이터 초기화
	dsList.clearData();
	
	var sTranId			= "fnSearchSalesInfo";
	var sInDS 			= "";
	var sOutDS 			= "dsList=ET_STAFFLIST";	
	var sContextPath 	= "/jco/JcoController/";
	var sServelet 		= "getJcoData.xp?FUNCTION_NAME=Z_LTS_IFS0068";
	var sSendData		= "";
		sSendData		+= "IV_DPTNM="+gdsOrghk.getColumn(0,"ORGHK_NM");
		sSendData		+= " IV_SNAME="+gfnGetUserInfo("ENAME");
		//sSendData		+= " IV_SALESM='" + lvSalesM + "'";

	var sCallBackFn		= "";

	gfnSapTranN(sTranId, sInDS, sOutDS, sContextPath, sServelet, sSendData, sCallBackFn);
}

 /**
 * 설명: End고객 팝업
 * @param 없음
 * @return 없음
 * @memberOf ltsLm113_T01
 */
function fnGetKUNZ1(){
	if(gfnIsNull(divSearch.edtKUNNR.value)){
		gfnAlert("IOS174");	//판매처를 선택해 주세요
		return;
		
	}
	if(gfnIsNull(divSearch.cboVTWEG.value)){
		gfnAlert("IOS140");	//유통경로를 선택해 주세요
		return;		
	}
	
// 	if(gfnIsNull(divSearch.cboSPART.value)){
// 		gfnAlert("IOS157");	//제품군을 선택해 주세요
// 		return;		
// 	}	
	
	var objSend = {};
	//objSend.name1Gp 	= divSearch.edtKUNNR_NM.value;
	objSend.viewType 	= "S"; // 단수개:S, 복수개:M
	objSend.parvw		= "Z1"; //파트너 역할
	objSend.kunag		= divSearch.edtKUNNR.value;		//판매처 코드
	objSend.vtweg		= divSearch.cboVTWEG.value;		//유통경로 코드
	objSend.spart		= divSearch.cboSPART.value;		//제품군 코드
				
	var retVal = gfnltsLm120_P01(objSend);
	if (retVal){
 		divSearch.edtZZKUNNR_END.value =  retVal.dsCostomerList.getColumn(0,"KUNNR");
 		divSearch.edtZZKUNNR_ENDNM.value = retVal.dsCostomerList.getColumn(0,"KUNNR_NM"); 		
	}
}

//체크박스 상태에 따른 그리드 설정
function fnSetGridForCheck(){
	
	//var vkgrp = dsMaster.getColumn(0, "IP_VKGRP");
	var kkber = dsMaster.getColumn(0, "IP_KKBER");
	var ekunnr = dsMaster.getColumn(0, "IP_EKUNNR");
	//var pernr = dsMaster.getColumn(0, "IP_PERNR");
    //divResult.grdList.setRealColSize(0 , 24, true);
//	divResult.grdList.setRealColSize(divResult.grdList.getBindCellIndex("body","VKGRP_T"), 80, true);
// 	//divResult.grdList.setRealColSize(divResult.grdList.getBindCellIndex("body","PERNR"), 80, true);
// 	divResult.grdList.setRealColSize(divResult.grdList.getBindCellIndex("body","PERNR_T"), 80, true);
// 	divResult.grdList.setRealColSize(divResult.grdList.getBindCellIndex("body","ZSKUNNR_END"), 100, true);
// 	divResult.grdList.setRealColSize(divResult.grdList.getBindCellIndex("body","EKUNNR"), 100, true);
// 	divResult.grdList.setRealColSize(divResult.grdList.getBindCellIndex("body","EKUNNR_T"), 150, true);
// 	divResult.grdList.setRealColSize(divResult.grdList.getBindCellIndex("body","KKBER_T"), 100, true);

	if(kkber <> 'X')
	{
		divResult.grdList.setRealColSize(divResult.grdList.getBindCellIndex("body","KKBER_T"), 0, true);
	}
	if(ekunnr <> 'X')
	{
		divResult.grdList.setRealColSize(divResult.grdList.getBindCellIndex("body","EKUNNR"), 0, true);	
		divResult.grdList.setRealColSize(divResult.grdList.getBindCellIndex("body","EKUNNR_T"), 0, true);	
	}
}

function fnSum(obj)
{
	var sum = 0;

	for(var i=0; i<dsbond_detail.rowcount; i++)
	{
		if (gfnIsNull(dsbond_detail.getColumn(i, obj)))
		{
			sum += 0;
		}
		else
		{
			sum += Number(dsbond_detail.getColumn(i, obj).replace(",",""));
		}	
	}

	return sum;
}

function fnStopCancel()
{
	var tf = false;
	for(var i=0; i<dsbond_detail.rowcount; i++)
		{
			if (dsbond_detail.getColumn(i, "rChk") != "" ) 
			{
				var tf = true;
				var objSend        = {};                         // Parameter : Obj
				objSend.pernrnm    = dsbond_detail.getColumn(i,"PERNR_T");
				objSend.pernr      = dsbond_detail.getColumn(i,"PERNR");
				objSend.kunnrnm    = dsbond_detail.getColumn(i,"NAME1");
				objSend.kunnr      = dsbond_detail.getColumn(i,"KUNNR");
				objSend.kkber      = dsbond_detail.getColumn(i,"KKBER");
				objSend.kkbernm    = dsbond_detail.getColumn(i,"KKBER_T");
				objSend.amtbala    = dsbond_detail.getColumn(i,"AMT_RESB");
				objSend.dayover    = dsbond_detail.getColumn(i,"DAY_CASH");
				objSend.vkgrpnm    = dsbond_detail.getColumn(i,"VKGRP_T");
			}
			
			
		}
	trace("tf>>>" + tf);
	if (tf == true)
	{    
	var strId 		= "ltsPrm150_P01";				// Dialog ID
	var strURL 		= "LTS.PRM::ltsPrm150_P01.xfdl";// Form URL
	var nTop 		= -1;							// Form Top
	var nLeft 		= -1;							// Form Left
	var nWidth 		= 320;							// Form Width
	var nHeight 	= 270;							// Form Height
	var bShowTitle 	= true;							// Form Title 을 표시 할지 여부
	var strAlign 	= "-1";							// Dialog 의 위치
	var strArgument = {avObjSend:objSend}; 			// Dialog 로 전달될 Argument
	var isModeless 	= false;						// true 면 Dialog 를 Modeless로 띄운다.
	var winOption 	= {};							// window option
		//winOption.titletext = "test";				// 팝업창의 title의 text를 변경
		//winOption.showtitlebar = true;			// 팝업창의 titlebar visible처리
		winOption.resizable = false;				// 팝업창의 리싸이징이 가능(true: 확대, 최소화가 없어진다)
		winOption.autosize = true;					// 팝업창의 크기에 맞게 변경

	return gfnDialog(strId, strURL, nTop, nLeft, nWidth, nHeight, bShowTitle, strAlign, strArgument, isModeless, winOption);
	}
	else
	{
		if (dsbond_detail.rowcount == 0)
		{
				var objSend        = {};                         // Parameter : Obj
				
				if (gfnIsNull(divSearch.edtPERNRNM.value)||gfnIsNull(divSearch.edtIKENID.value)||
				 gfnIsNull(divSearch.edtKUNNR_NM.value)||gfnIsNull(divSearch.edtKUNNR.value)||gfnIsNull(divSearch.cboSPART.value))
				{
					gfnAlert("조회결과가 없을 경우 해지 요청할 조건을 모두 입력하세요. \n\n(담당자, 판매처, 제품군, 영업그룹)");
				}
				else
				{
					objSend.pernrnm    = divSearch.edtPERNRNM.value;
					objSend.pernr      = divSearch.edtIKENID.value;
					objSend.kunnrnm    = divSearch.edtKUNNR_NM.value;
					objSend.kunnr      = divSearch.edtKUNNR.value;
					if (divSearch.cboSPART.value =='6A')
					{
						objSend.kkber      = 'K50A';
						objSend.kkbernm    = 'KPC-ETC';
					}
					else if (divSearch.cboSPART.value =='6B')
					{
						objSend.kkber      = 'K50B';
						objSend.kkbernm    = 'KPC-OTC';
					}
					else
					{
						objSend.kkber      = 'K50Z';
						objSend.kkbernm    = 'KPC-기타';				
					}	
					
					objSend.amtbala    = 0;
					objSend.dayover    = 0;
					objSend.vkgrpnm    = dsVKGRP.getColumn( dsVKGRP.findRow("CDITM", divSearch.cboVKGRP.value ), "CDNAM");
					
					var strId 		= "ltsPrm150_P01";				// Dialog ID
					var strURL 		= "LTS.PRM::ltsPrm150_P01.xfdl";// Form URL
					var nTop 		= -1;							// Form Top
					var nLeft 		= -1;							// Form Left
					var nWidth 		= 320;							// Form Width
					var nHeight 	= 270;							// Form Height
					var bShowTitle 	= true;							// Form Title 을 표시 할지 여부
					var strAlign 	= "-1";							// Dialog 의 위치
					var strArgument = {avObjSend:objSend}; 			// Dialog 로 전달될 Argument
					var isModeless 	= false;						// true 면 Dialog 를 Modeless로 띄운다.
					var winOption 	= {};							// window option
						//winOption.titletext = "test";				// 팝업창의 title의 text를 변경
						//winOption.showtitlebar = true;			// 팝업창의 titlebar visible처리
						winOption.resizable = false;				// 팝업창의 리싸이징이 가능(true: 확대, 최소화가 없어진다)
						winOption.autosize = true;					// 팝업창의 크기에 맞게 변경

					return gfnDialog(strId, strURL, nTop, nLeft, nWidth, nHeight, bShowTitle, strAlign, strArgument, isModeless, winOption);
			}
			
		}
		else
		{
			gfnAlert("해지 요청할 데이터를 선택하세요.");
			return false;
		}
	}

}
//=======================================================================================
// 7.이벤트처리 
//---------------------------------------------------------------------------------------

function divSearch_edtPERNRCall_onclick(obj:Button,  e:ClickEventInfo)
{
	fnGetEMPINFO();
}

function divSearch_btnPERNRClear_onclick(obj:Button,  e:ClickEventInfo)
{
	divSearch.edtPERNRNM.value = "";
	divSearch.edtIKENID.value = "";
	divSearch.edtPERNR.value = "";
}

function divSearch_btnKUNNRCall_onclick(obj:Button,  e:ClickEventInfo)
{
	fnOpenPopup();
}

function divSearch_btnKUNNRClear_onclick(obj:Button,  e:ClickEventInfo)
{
	divSearch.edtKUNNR_NM.value = "";
	divSearch.edtKUNNR.value = "";
}

function divSearch_btnZZKUNNR_ENDCall_onclick(obj:Button,  e:ClickEventInfo)
{
	fnGetKUNZ1();
}

function divSearch_btnZZKUNNR_ENDClear_onclick(obj:Button,  e:ClickEventInfo)
{
	divSearch.edtZZKUNNR_ENDNM.value = "";
	divSearch.edtZZKUNNR_END.value = "";	
}

function divSearch_btnMATNRClear_onclick(obj:Button,  e:ClickEventInfo)
{
	divSearch.edtMATNR_NM.value = "";
	divSearch.edtMATNR.value = "";
}

function divSearch_edtPERNRNM_onkeydown(obj:Edit, e:KeyEventInfo)
{
	if (e.keycode == 13) {
        divSearch.edtPERNRNM.enableevent = false;
        fnGetEMPINFO();
        divSearch.edtPERNRNM.enableevent = true;
    }	
}

function divSearch_edtKUNNR_NM_onkeydown(obj:Edit, e:KeyEventInfo)
{
	if (e.keycode == 13) {
        divSearch.edtKUNNR_NM.enableevent = false;
        fnOpenPopup();
        divSearch.edtKUNNR_NM.enableevent = true;
    }	
}

function divSearch_edtZZKUNNR_ENDNM_onkeydown(obj:Edit, e:KeyEventInfo)
{
	if (e.keycode == 13) {
        divSearch.edtZZKUNNR_ENDNM.enableevent = false;
        fnGetKUNZ1();
        divSearch.edtZZKUNNR_ENDNM.enableevent = true;
    }	
}

function divSearch_edtKUNNR_NM_ontextchanged(obj:Edit,  e:TextChangedEventInfo)
{
	divSearch.edtKUNNR.value = "";
	divSearch.edtZZKUNNR_ENDNM.value = "";
	divSearch.edtZZKUNNR_END.value = "";
}

function divResult_grdList_oncellclick(obj:Grid, e:GridClickEventInfo)
{
	if(e.cell == 0)
	{	
		var CHK = dsbond_detail.getColumn(e.row, "rChk");
		//한번에 한 row만 선택가능 
		for(var i=0; i<dsbond_detail.rowcount; i++)
			{
				dsbond_detail.setColumn(i, "rChk", "");
			}
		//기존에 체크한것 다시선택했다면 체크해제
		if ( CHK == 0 )
		{
			dsbond_detail.setColumn(e.row, "rChk", "");
		}
		else
		{
			dsbond_detail.setColumn(e.row, "rChk", 1);
		}
	}
}

function dsMaster_oncolumnchanged(obj:Dataset, e:DSColChangeEventInfo)
{
	if (dsMaster.getColumn(0, "IV_GUBUN") == "A")
		{
			objDiv.btnStopCancel.enable = false;
		}
	if(e.columnid == "IV_VTWEG" ||  e.columnid == "IV_SPART" ||  
	   e.columnid == "IV_VKGRP" ||  e.columnid == "IV_PERNR" || e.columnid == "IV_KUNNR")
		{
				objDiv.btnStopCancel.enable = false;			
		}
	
		
}


/**
 * 시	스	템		: 코오롱프로세스혁신 업무포탈<br>
 * 업	무	명 		: ltsPop540		 				<br>
 * 파	일	명 		: ltsPop540.xfdl 				<br>
 * 작	성	자 		: dwsss						<br>
 * 작	성	일 		: 2016.01.21					<br>
 *													<br>
 * 설		명 		: 단가 계약 리스트 조회		<br>
 *---------------------------------------------------------------------------------------<br>
 *  변경일     변경자  변경내역					<br>
 *---------------------------------------------------------------------------------------<br>
 
 *---------------------------------------------------------------------------------------<br>
 * @namespace
 * @name ltsPop540
 */

//=======================================================================================
// Common Lib Include
//--------------------------------------------------------------------------------------- 
include "lib::comLib.xjs";

//=======================================================================================
// 1. 화면전역변수선언
//---------------------------------------------------------------------------------------


//=======================================================================================
// 2.FORM EVENT 영역
//---------------------------------------------------------------------------------------

/**
 * 설명: 폼로딩 초기화 함수(validation체크및 공통코드)
 * @param  없음
 * @return 없음
 * @memberOf ltsCa090
 */
function cfnInitOnload()
{	
	trace("cfnInitOnload()		");

	//공통코드(biztype:)	
	//gfnSetInitForm(this); // ctrl+shift+F1이 눌리도록

	var sBUKRS 	= gfnGetUserInfo("BUKRS");	//회사
	
	if (gfnIsNull(sBUKRS))
	{	
		sBUKRS = "*";
	}			
	
	//판매조직				
	var oSearchHelpCond = [	
	{sHlpName:"ZLTS_H_TVKO", sHlpField:"VKORG", low:"*", dsName:"dsVKORGCbo", code:"VKORG", data:"VTEXT", selecttype:"", objid: "divSearch.cboVKORG"}
   ,{sHlpName:"ZLTS_H_TVKO", sHlpField:"BUKRS", low:sBUKRS	}		
	];
	gfnGetSearchHelpCbo(oSearchHelpCond, false);	
	
	
	//제품그룹
	var oSearchHelpCond03 = [
	{sHlpName:"ZLTSP_ZMATKL", sHlpField:"ZMATKL",low:"*", dsName:"dsZMATKL", code:"ZMATKL", data:"ZMATKL_NM", selecttype:"A", objid: "divSearch.cboMATKL"}
	];
	gfnGetSearchHelpCbo(oSearchHelpCond03, false);

	
	//공통코드(biztype:)
	var oComcodeSetList = [
		{code:"VKGRP", 			dsName:"dsVKGRP", 		useYn:"Y", selecttype:"A", 	objid: "divSearch.cboVKGRP"}
		,{code:"ZVTWEG", 		dsName:"dsZVTWEG", 		useYn:"Y", selecttype:"A", 	objid: "divSearch.cboVTWEG"}
		,{code:"KPC_SPART", 	dsName:"dsKPC_SPART", 	useYn:"Y", selecttype:"A", 	objid: "divSearch.cboSPART"}
		,{code:"APVLSTATUS", 	dsName:"dsAPSTT",  		useYn:"Y", selecttype:"A",  objid: "divSearch.cboAPSTT"}  
		,{code:"APVLSTATUS", 	dsName:"dsAPSTT2",  	useYn:"Y", selecttype:"A",  objid: "divSearch.cboAPSTT2"}  
		,{code:"QTTYPE", 		dsName:"dsQTTYPE",  	useYn:"Y", selecttype:"A",  objid: "divSearch.cboQTTYPE"} 
		,{code:"APVLSTATUS", 	dsName:"dsGrdApstt",  	useYn:"Y", selecttype:"B",  objid: "divResult.grdList", bindcolumn:"APSTT_SA"}
		,{code:"APVLSTATUS", 	dsName:"dsGrdApstt",  	useYn:"Y", selecttype:"B",  objid: "divResult.grdList", bindcolumn:"APSTT_DT"}
		,{code:"ZTYPE", 		dsName:"dsZTYPE", 		useYn:"Y", selecttype:"B", 	objid: "divResult.grdList", bindcolumn:"ZTYPE"}
		,{code:"ZPAYMENT", 		dsName:"dsZPAYMENT", 	useYn:"Y", selecttype:"B", 	objid: "divResult.grdList", bindcolumn:"ZPAYMENT"}
		,{code:"ZMETHOD", 		dsName:"dsGrdZMETHOD",  useYn:"Y", selecttype:"B",  objid: "divResult.grdList", bindcolumn:"ZMETHOD"}  
		,{code:"ZQTTYP", 		dsName:"dsGrdZQTTYP",  	useYn:"Y", selecttype:"B",  objid: "divResult.grdList", bindcolumn:"ZQTTYP"}  
		,{code:"QTTYPE", 		dsName:"dsGrdQTTYPE",  	useYn:"Y", selecttype:"B",  objid: "divResult.grdList", bindcolumn:"QTTYPE"}  
    ];
	gfnGetSapCommonCode(oComcodeSetList);	
	
	//그리드 버튼(그리드ID, 콜백함수)
	divResult.divGridList.cfnSetCommButton(divResult.grdList,false,false,false,false,true);
	
	//그리드contextMenu
	gfnSetGridContextMenu(divResult.grdList);	
	
	// 기간달력binding
	//divSearch.divDate.fnSetBind("dsMaster", "IV_QTDAT_FR", "IV_QTDAT_TO", this);
}

/**
 * 설명: 공통코드처리후 호출함수
 * @param  없음
 * @return 없음
 * @memberOf ltsCa094
 */
function cfnCommonCodeCallBackSap()
{
	trace("cfnCommonCodeCallBackSap		");
	//OTC팀의 경우 gdsOrghk에 여러팀의 이름이 나와 사원검색이 불가하여 필터링 걸어줌.
	gdsOrghk.filter("DOCTY == 'PC' && ORGHK == "+ gfnGetUserInfo("ORGHK")+"");
	
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

function gfnGetFirstDates(strDate) 
{

    var s = "";

    if (strDate == null) 
    {
	    s = getToday().substr(0,6) + "01";  //금일 월의 1일으로 세팅 

    } else {
	    var date = new Date(parseInt(strDate.substr(0, 4)), parseInt(strDate.substr(4, 2)) - 1, 1);
	    s = (new Date(date)).getFullYear()
	      + (((new Date(date)).getMonth() + 1)+ "").padLeft(2, '0')
	      + ((new Date(date)).getDate() + "").padLeft(2, '0');
	    trace(" view s:     "+ s);
    }
	return (s);
}

function cfnInitForm()
{
	trace("InitForm	qtdat_fr		"+divSearch.QTDAT_FR.value);
	trace("InitForm	qtdat_to		"+divSearch.QTDAT_TO.value);
	
	dsMaster.clearData();
	dsMaster.addRow();
	
	divSearch.QTDAT_FR.value = gfnGetFirstDates(gfnToday());  //추가: 해당 달 1일
	divSearch.QTDAT_TO.value = gfnGetLastDate(gfnToday());   //추가: 해당 달 마지막일
	
	divSearch.cboVTWEG.value = "";
	divSearch.cboSPART.value = "";
	divSearch.edtKUNNR_NM.value = "";
	divSearch.edtKUNNR.value = "";
	
	divSearch.cboVTWEG.index = 1;	//유통채널 초기값 '내수'
	divSearch.cboSPART.index = 0;
	
	divSearch.cboVKGRP.index = 0;
	divSearch.cboAPSTT.index = 0;
	divSearch.cboAPSTT2.index = 0;
	
	divSearch.cboVKORG.value = gfnGetUserInfo("VKORG");
	
	divSearch.chkZQTTYP4.value = "P06";
	divSearch.chkZQTTYP3.value = "P05";
	divSearch.chkZQTTYP0.value = "P02";
	divSearch.chkZQTTYP1.value = "P03";
	divSearch.chkZQTTYP2.value = "P04";
	
	
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
	trace("cfnBeforeTran		");
	if(sTranId=="cfnSearch")
	{
	}
}


/**
 * 설명: 조회 메소드
 * @param  없음
 * @return 없음
 * @memberOf ltsCa090
 */
function cfnSearch()  //조회버튼 눌렀을 때 
{
	trace("cfnSearch		");
	//데이터 초기화
	//dsKEYM_LIST.clearData();
	
 	/*var aPeriod 	= divSearch.divDate.fnGetDay();*/
 	var sStartDt 	= divSearch.QTDAT_FR.value;
 	var sEndDt 		= divSearch.QTDAT_TO.value;
 	trace("aPeriod[0]:	"+sStartDt+"     "+"aPeriod[1]:		"+sEndDt);
			
	var sTranId			= "cfnSearch";
	var sInDS 			= "";
	var sOutDS 			= "dsDetail=T_LIST";	
	var sContextPath 	= "/jco/JcoController/";
	var sServelet 		= "getJcoData.xp?FUNCTION_NAME=Z_LTSP_IF0401";
	var sSendData		= "";
	
	var ZQTTYP = "";
	for(var i=0; i<5; i++)
	{
		if(eval("divSearch.chkZQTTYP"+i).value != false)
		{
			ZQTTYP += (gfnIsNull(ZQTTYP))? eval("divSearch.chkZQTTYP"+i).value:(","+eval("divSearch.chkZQTTYP"+i).value);
		}
	}
	sSendData += " IV_ZQTTYP="+gfnSetQuote(ZQTTYP);
	
	for(var i=0; i<dsMaster.colcount; i++)
	{
		sSendData  		+= " " + dsMaster.getColID(i)+"="+gfnSetQuote(gfnTrim(dsMaster.getColumn(0, dsMaster.getColID(i))));
	}
	
	var sCallBackFn		= "";
	
	trace("cfnSearch.SendData ==> " + sSendData);

	gfnSapTranN(sTranId, sInDS, sOutDS, sContextPath, sServelet, sSendData, sCallBackFn);

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
	trace("cfnNew		");
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
	trace("cfnCallback				"+divSearch.QTDAT_FR.value);
	if(sTranId == "fnSearchSalesInfo")
	{
		trace("saleinfo				"+divSearch.QTDAT_FR.value);
		gfnSetAlertMsgUd("-1");
		cfnInitForm();
	}
	else if(sTranId == "cfnSearch")
	{	
	trace("cfnsearch				"+divSearch.QTDAT_FR.value);
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
 * @memberOf ltsLm103
 */
function cfnBeforeGrid(objGrd, type, obj:Button,  e:ClickEventInfo)
{
	if(objGrd.name=="grdList"){
		switch (type)
		{
			case "CLEARROW":	// 행초기화
				break;
				
			case "ADDROW":		// 행추가
				//validate return false; row가 추가되지 안는상태
				
				break;
			
			case "INSERTROW":	// 행삽입
				break;
			
			case "DELROW":		// 행삭제
				break;
			
			case "COPYROW":		// 행복사
				break;
			
			case "EXDOWN":		// 엑셀 다운로드
				break;	
		}	
	}
}

//=======================================================================================
// 6.사용자 정의함수
//---------------------------------------------------------------------------------------




//=======================================================================================
// 7.이벤트처리 
//---------------------------------------------------------------------------------------

//판매처 팝업 시작

function divSearch_edtKUNNR_NM_onkeydown(obj:Edit, e:KeyEventInfo)
{
	if (e.keycode == 13) {
        divSearch.edtKUNNR_NM.enableevent = false;
        fnOpenPopup();
        divSearch.edtKUNNR_NM.enableevent = true;
    }else{
		divSearch.edtKUNNR.value = "";
    }
}

function divResult_btnKUNNRClear_onclick(obj:Button,  e:ClickEventInfo)
{
	divSearch.edtKUNNR_NM.value = "";
	divSearch.edtKUNNR.value = "";
}

function divResult_btnKUNNRCall_onclick(obj:Button,  e:ClickEventInfo)
{
	fnOpenPopup();	
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
		gfnAlert("IOS140");	//유통채널을 선택해 주세요
		return;		
	}
	
	if(gfnIsNull(divSearch.cboSPART.value)){
		gfnAlert("IOS157");	//제품군을 선택해 주세요
		return;		
	}
	
	var objSend        = {};
	objSend.id         = "admin";
	
	var edtCustomer_NM = divSearch.edtKUNNR_NM.value;
	
	objSend.custname    = gfnIsNullBlank(edtCustomer_NM); // 고객사
	objSend.formId 	   = "ltsPso210";
	objSend.vtweg 	   = divSearch.cboVTWEG.value;	//유통
	objSend.spart 	   = divSearch.cboSPART.value;	//제품군
	objSend.ktokd	   = "KTOKD_003";
	objSend.vkgrp      = divSearch.cboVKGRP.value;
	
	objSend.viewType   = "S";    // 단수개:S, 복수개:M
	
	var strId       = "scmOtcGlts151_P01";			//Dialog ID
	var strURL      = "LTS.OP::ltsOp151_P01.xfdl";	//Form URL
	var nTop        = -1;							//Form Top
	var nLeft       = -1;							//Form Left
	var nWidth      = 999;							//Form Width
	var nHeight     = 509;							//Form Height
	var bShowTitle  = true;							//Form Title 을 표시 할지 여부
	var strAlign    = "-1";					 	    //Dialog 의 위치
	var strArgument = {avDataDictNo:"", avDsCond:"", avArySend:"", avObjSend:objSend}; //Dialog 로 전달될 Argument
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
 		}
	}
 }
 
 //판매처 팝업 End




//End고객(병원) -start
function divResult_edtZZKUNNR_ENDNM_onkeydown(obj:Edit, e:KeyEventInfo)
{
	if (e.keycode == 13) {
        divSearch.edtZZKUNNR_ENDNM.enableevent = false;
        fnGetKUNZ1();
        divSearch.edtZZKUNNR_ENDNM.enableevent = true;
    }
    else{
		divSearch.edtZZKUNNR_END.value = "";
		divSearch.edtADDR_END.value = "";
    }
}



function divResult_edtZZKUNNR_ENDNM_canchange(obj:Edit,  e:ChangeEventInfo)
{
	divSearch.edtZZKUNNR_END.value = "";
}

function divResult_btnZZKUNNR_ENDClear_onclick(obj:Button,  e:ClickEventInfo)
{
	divSearch.edtZZKUNNR_ENDNM.value = "";
	divSearch.edtZZKUNNR_END.value = "";
}


function divResult_btnZZKUNNR_END_onclick(obj:Button,  e:ClickEventInfo)
{
	fnGetKUNZ1();
}


/**
 * 설명: End고객(병원) 팝업
 * @param 없음
 * @return 없음
 * @memberOf ltsLm113_T01
 */
function fnGetKUNZ1()
{
	if(gfnIsNull(divSearch.edtKUNNR.value)){
		gfnAlert("IOS174");	//판매처(도매)를 선택해 주세요
		return;
		
	}
 	if(gfnIsNull(divSearch.cboVTWEG.value)){
 		gfnAlert("IOS140");	//유통채널를 선택해 주세요
 		return;		
 	}

	var objSend = {};
	objSend.name1Gp 	= divSearch.edtZZKUNNR_ENDNM.value;
	objSend.viewType 	= "S"; // 단수개:S, 복수개:M
	objSend.parvw		= "Z1"; //파트너 역할
	objSend.kunag		= divSearch.edtKUNNR.value;		//판매처 코드
	objSend.vtweg		= divSearch.cboVTWEG.value;		//유통채널 코드
	//objSend.spart		= divSearch.cboSPART.value;		//제품군 코드
				
	var retVal = gfnltsLm120_P01(objSend);
	if (retVal)
	{
 		divSearch.edtZZKUNNR_END.value =  retVal.dsCostomerList.getColumn(0,"KUNNR");
 		divSearch.edtZZKUNNR_ENDNM.value = retVal.dsCostomerList.getColumn(0,"KUNNR_NM"); 	
 		divSearch.edtADDR_END.value = retVal.dsCostomerList.getColumn(0, "ORT01")+" "+retVal.dsCostomerList.getColumn(0, "STRAS");
	}
}
//End고객(병원) - end


//담당자 팝업 Start
function divSearch_edtSLNUM_NM_onkeydown(obj:Edit, e:KeyEventInfo)
{
	if (e.keycode == 13)
	{
        divSearch.edtSLNUM_NM.enableevent = false;
        fnGetEMPINFO();
        divSearch.edtSLNUM_NM.enableevent = true;
    }
    else{
		divSearch.edtSLNUM.value = "";
    }
}

function divSearch_btnSLNUMClear_onclick(obj:Button,  e:ClickEventInfo)
{
	divSearch.edtSLNUM_NM.value = "";
	divSearch.edtSLNUM.value = "";
}


function divSearch_btnSLNUMCall_onclick(obj:Button,  e:ClickEventInfo)
{
	fnGetEMPINFO();
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
    objSend.sname      = divSearch.edtSLNUM_NM.value; // 담당자명
    if(!gfnIsNull(divSearch.cboVKGRP.value))
    {
		objSend.dptnm	   = dsVKGRP.getColumn(dsVKGRP.findRow("CDITM", divResult.cboVKGRP.value), "CDNAM");
	}
	var retVal = gfnltsOp227_P01(objSend);	

    if (retVal!= null)
    {
        //임직원 반영
        divSearch.edtSLNUM.value   = retVal.dsCostomerList.getColumn(0, "IKENID");
        divSearch.edtSLNUM_NM.value = retVal.dsCostomerList.getColumn(0, "SNAME");
    }
}
//담당자 팝업 End


//유통담당자 팝업 Start
function divSearch_edtSLNUM_DT_NM_onkeydown(obj:Edit, e:KeyEventInfo)
{
	if (e.keycode == 13)
	{
        divSearch.edtSLNUM_DT_NM.enableevent = false;
        fnGetEMPINFO2();
        divSearch.edtSLNUM_DT_NM.enableevent = true;
    }
    else{
		divSearch.edtSLNUM.value = "";
    }
}


function divSearch_btnSLNUMDTClear_onclick(obj:Button,  e:ClickEventInfo)
{
	divSearch.edtSLNUM_DT_NM.value = "";
	divSearch.edtSLNUM_DT.value = "";
}

function divSearch_btnSLNUMDTCall_onclick(obj:Button,  e:ClickEventInfo)
{
	fnGetEMPINFO2();
}

/**
 * 설명: 임직원 팝업
 * @param  
 * @return 
 * @memberOf ltsLm001
 */
function fnGetEMPINFO2()
{
	var objSend        = {};                         // Parameter : Obj
    objSend.sname      = divSearch.edtSLNUM_DT_NM.value; // 담당자명
    if(!gfnIsNull(divSearch.cboVKGRP.value))
    {
		objSend.dptnm	   = dsVKGRP.getColumn(dsVKGRP.findRow("CDITM", divSearch.cboVKGRP.value), "CDNAM");
	}
	var retVal = gfnltsOp227_P01(objSend);	

    if (retVal!= null)
    {
        //임직원 반영
        divSearch.edtSLNUM_DT.value   = retVal.dsCostomerList.getColumn(0, "IKENID");
        divSearch.edtSLNUM_DT_NM.value = retVal.dsCostomerList.getColumn(0, "SNAME");
    }
}
//유통 담당자 - end

function divResult_grdList_oncelldblclick(obj:Grid, e:GridClickEventInfo)
{
	var sUrl   = "";
	var sZQTTYP = dsDetail.getColumn(e.row, "ZQTTYP");	
	
	// P06  1   OTC 직납
    // P05	2	직납
	// P02	3	간납
	// P03	4	입찰국공립
	// P04	5	저가구매
	switch(sZQTTYP)
	{
	    case "P06" : sUrl = "LTS.POP::ltsPop512"; break;
		case "P05" : sUrl = "LTS.POP::ltsPop511"; break;
		case "P02" : sUrl = "LTS.POP::ltsPop510"; break;		
		case "P03" : sUrl = "LTS.POP::ltsPop520"; break;
		case "P04" : sUrl = "LTS.POP::ltsPop530"; break;
	}	
	
	var pREDNO = dsDetail.getColumn(e.row, "QTDNO");
	var aParam = [pREDNO];				//gvScreeParams에 저장
	var sType = "RELOAD";		

	gfnRedirectForm(sUrl, aParam, sType);	
}

function divSearch_QTDAT_FR_onchanged(obj:Calendar, e:ChangeEventInfo)  //없으면 안됨.
{
 	
 	trace("user_select_fr:			   	"+dsMaster.getColumn(dsMaster.rowposition, "IV_QTDAT_FR"));
 	
 	var firstDate = dsMaster.getColumn(dsMaster.rowposition, "IV_QTDAT_FR");
 	trace("selected_Y				" + firstDate.substr(0,4));
 	trace("selected_M				" + firstDate.substr(4,2));
 	trace("selected_D				" + firstDate.substr(6,2));
 	
 	var date = new Date(firstDate.substr(0,4), firstDate.substr(4,2)-1, firstDate.substr(6,2));
 	trace("date:		"+date);
 	
 	var s = (new Date(date)).getFullYear()
 	      + (((new Date(date)).getMonth() + 1)+ "").padLeft(2, '0')
 	      + ((new Date(date)).getDate() + "").padLeft(2, '0');
 	
 	if ((new Date(date)).getMonth()+1 == 1)
 	{
 		divSearch.QTDAT_FR.value = (new Date(date)).getFullYear()
 	      + "01"
 	      + ((new Date(date)).getDate() + "").padLeft(2, '0');
 	}
 	trace("after_Select:		"+ s);
 	
 	trace("QTDAT_FR:			"+divSearch.QTDAT_FR.value);
 	
 }


function divSearch_QTDAT_TO_onchanged(obj:Calendar, e:ChangeEventInfo)
{
	 trace("user_select_to:			   	"+dsMaster.getColumn(dsMaster.rowposition, "IV_QTDAT_TO"));
 	
 	var lastDate = dsMaster.getColumn(dsMaster.rowposition, "IV_QTDAT_TO");
 	trace("selected_Y				" + lastDate.substr(0,4));
 	trace("selected_M				" + lastDate.substr(4,2));
 	trace("selected_D				" + lastDate.substr(6,2));
 	
 	var date = new Date(lastDate.substr(0,4), lastDate.substr(4,2)-1, lastDate.substr(6,2));
 	trace("date:		"+date);
 	
 	var s = (new Date(date)).getFullYear()
 	      + (((new Date(date)).getMonth() + 1)+ "").padLeft(2, '0')
 	      + ((new Date(date)).getDate() + "").padLeft(2, '0');
 	
 	if ((new Date(date)).getMonth()+1 == 1)
 	{
 		divSearch.QTDAT_TO.value = (new Date(date)).getFullYear()
 	      + "01"
 	      + ((new Date(date)).getDate() + "").padLeft(2, '0');
 	}
 	trace("after_Select:		"+ s);
 	
 	trace("QTDAT_TO:			"+divSearch.QTDAT_TO.value);

}

function dsMaster_oncolumnchanged(obj:Dataset, e:DSColChangeEventInfo)
{
	trace("<dsMaster_oncolumnchanged> ");
	
	/*from date 설정*/
	var firstDate = dsMaster.getColumn(dsMaster.rowposition, "IV_QTDAT_FR");
// 	trace("selected_Y				" + firstDate.substr(0,4));
// 	trace("selected_M				" + firstDate.substr(4,2));
// 	trace("selected_D				" + firstDate.substr(6,2));
	var date = new Date(firstDate.substr(0,4), firstDate.substr(4,2)-1, firstDate.substr(6,2));
	
	var s = (new Date(date)).getFullYear()
	      + (((new Date(date)).getMonth() + 1)+ "").padLeft(2, '0')
	      + ((new Date(date)).getDate() + "").padLeft(2, '0');
	      
	
	divSearch.QTDAT_FR.value = s;
	trace("QTDAT_FR:			"+divSearch.QTDAT_FR.value);
	
	
	/*to date 설정*/
	var LastDate = dsMaster.getColumn(dsMaster.rowposition, "IV_QTDAT_TO");
// 	trace("selected_Y				" + LastDate.substr(0,4));
// 	trace("selected_M				" + LastDate.substr(4,2));
// 	trace("selected_D				" + LastDate.substr(6,2));
	var date = new Date(LastDate.substr(0,4), LastDate.substr(4,2)-1, LastDate.substr(6,2));
	
	var l = (new Date(date)).getFullYear()
	      + (((new Date(date)).getMonth() + 1)+ "").padLeft(2, '0')
	      + ((new Date(date)).getDate() + "").padLeft(2, '0');
	      
	divSearch.QTDAT_TO.value = l;
	trace("QTDAT_TO:			"+divSearch.QTDAT_TO.value);
	
	check_QTDAT_FR_isBigger(s,l);

}

function dsMaster_onrowsetchanged(obj:Dataset, e:DSRowsetChangeEventInfo)
{
	trace("<dsMaster_onrowsetchanged> ");
	
	/*from date 설정*/
	var firstDate = dsMaster.getColumn(dsMaster.rowposition, "IV_QTDAT_FR");
// 	trace("selected_Y				" + firstDate.substr(0,4));
// 	trace("selected_M				" + firstDate.substr(4,2));
// 	trace("selected_D				" + firstDate.substr(6,2));
	var date = new Date(firstDate.substr(0,4), firstDate.substr(4,2)-1, firstDate.substr(6,2));
	
	var s = (new Date(date)).getFullYear()
	      + (((new Date(date)).getMonth() + 1)+ "").padLeft(2, '0')
	      + ((new Date(date)).getDate() + "").padLeft(2, '0');
	      
	divSearch.QTDAT_FR.value = s;
	
	/*to date 설정*/
	var LastDate = dsMaster.getColumn(dsMaster.rowposition, "IV_QTDAT_TO");
// 	trace("selected_Y				" + LastDate.substr(0,4));
// 	trace("selected_M				" + LastDate.substr(4,2));
// 	trace("selected_D				" + LastDate.substr(6,2));
	var date = new Date(LastDate.substr(0,4), LastDate.substr(4,2)-1, LastDate.substr(6,2));
	
	var l = (new Date(date)).getFullYear()
	      + (((new Date(date)).getMonth() + 1)+ "").padLeft(2, '0')
	      + ((new Date(date)).getDate() + "").padLeft(2, '0');
	      
	divSearch.QTDAT_TO.value = l;
	trace("QTDAT_TO:			"+divSearch.QTDAT_TO.value);

}

function check_QTDAT_FR_isBigger(Date_fr, Date_to)
{
	//trace(Date_fr+"     "+Date_to);
	var objAlert = new Alert();
	objAlert.init("Alert", 10, 10, 100, 100);

	if (Date_fr > Date_to)
	{
		alert("시작일자가 종료일자보다 큽니다.");
		sleep(100);  //본인이 입력한 날짜값 보여줄 시간 ->근데 안됨.
		divSearch.QTDAT_FR.value = gfnGetFirstDates(gfnToday());  //다시 해당일 1일로 자동세팅
		divSearch.QTDAT_TO.value = gfnGetLastDates(gfnToday());  //다시 해당일 마지막일로 자동세팅		
	}
}





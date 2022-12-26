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
 * 설명: 폼로딩 초기화 함수(validation채크및 공통코드)
 * @param  없음
 * @return 없음
 * @memberOf ltsPca410
 */
function cfnInitOnload()
{	
	//그리드 버튼(그리드ID, 콜백함수)
	divResult.divGridMaster.cfnSetCommButton(divResult.grdList,false,false,false,false,true);
	
	//공통코드(biztype:)
	var oComcodeSetList = [
	   {code:"ZDMNOTICE", dsName:"dsNOTICECLS", useYn:"Y", selecttype:"A",  objid: "divSearch.cboNTCLS"} 						// 조회결과Grid:업무구분
	  ,{code:"ZDMNTCLVL", dsName:"dsNOTICELVL", useYn:"Y", selecttype:"A",  objid: "divSearch.cboNTLVL"} 						// 조회결과Grid:중요도
	  ,{code:"ZDMNOTICE", dsName:"dsGrdNOTICECLS", useYn:"Y", selecttype:"",  objid: "divResult.grdList", bindcolumn:"NTCLS"} 	// 그리드결과Grid:업무구분
	  ,{code:"ZDMNTCLVL", dsName:"dsGrdNOTICELVL", useYn:"Y", selecttype:"",  objid: "divResult.grdList", bindcolumn:"NTLVL"} 	// 그리드결과Grid:중요도	  	 
    ];
	gfnGetSapCommonCode(oComcodeSetList); //페이지 오픈할때 DB에서 공통코드를 가지고 온다.
	
	//그리드contextMenu
	gfnSetGridContextMenu(divResult.grdList);
}

/**
 * 설명: 공통코드처리후 호출함수
 * @param  없음
 * @return 없음
 * @memberOf ltsPca410
 */
function cfnCommonCodeCallBackSap()
{
	cfnInitForm();
}

/**
 * 설명: 폼 초기화 함수(폼의 초기화: 검색영역, 그리드)
 * @param  없음
 * @return 없음
 * @memberOf ltsPca410
 */
function cfnInitForm()
{	
 	divSearch.cboNTCLS.value      = "";		//업무구분
 	divSearch.cboNTLVL.value      = "";		//중요도
 	divSearch.edtTITLE.value	  = "";		//제목
 	divSearch.edtKUNAG.value      = "";		//대리점코드
 	divSearch.edtKUNAGNM.value    = "";		//대리점명
 	divSearch.chkXVALID.value 	  = " ";	//유효기간체크
 	
 	
 	divSearch.divERDAT.fnSetDay((""+gfnToday()).substr(0, 6)+"01", gfnToday());
	
	dsList.clearData();
}

//=======================================================================================
// 3.공통 호출함수
//---------------------------------------------------------------------------------------
/**
 * 설명: 전처리함수
 * @param  없음
 * @return 없음
 * @memberOf ltsPca410
 */
function cfnBeforeTran(sTranId) 
{
	if(sTranId=="cfnSearch"){

	}
}

/**
 * 설명: 조회처리 함수
 * @param  없음
 * @return 없음
 * @memberOf ltsPca410
 */
function cfnSearch()
{
 	var aPeriod 	= divSearch.divERDAT.fnGetDay();
 	var sStartDt 	= aPeriod[0];
 	var sEndDt 		= aPeriod[1];
	
	var sTranId			= "cfnSearch";
	var sInDS 			= "";
	var sOutDS 			= "dsList=T_NTLIST";	
	var sContextPath 	= "/jco/JcoController/";
	var sServelet 		= "getJcoData.xp?FUNCTION_NAME=Z_LTS_IFS6281";
	var sSendData  		= "";
 		sSendData	   += "IV_NTCLS="      + gfnWrapQuote(divSearch.cboNTCLS.value)   	//업무구분
  		               +  " IV_NTLVL="     + gfnWrapQuote(divSearch.cboNTLVL.value)   	//중요도
  		               +  " IV_KUNAG="     + gfnWrapQuote(divSearch.edtKUNAG.value)   	//판매처
  		               +  " IV_TITLE="     + gfnWrapQuote(divSearch.edtTITLE.value)   	//제목
		               +  " IV_XVALID="   + gfnWrapQuote(divSearch.chkXVALID.value)		//유효기간체크
 		               +  " IV_ERDATF="     + gfnWrapQuote(sStartDt)  					//등록일 TO
 		               +  " IV_ERDATT="     + gfnWrapQuote(sEndDt);   					//등록일 FROM 	              

	var sCallBackFn		= "";
	trace("cfnSearch.sSendData=====>"+sSendData);
	gfnSapTranN(sTranId, sInDS, sOutDS, sContextPath, sServelet, sSendData);
}

/**
 * 설명: 저장 함수
 * @param  없음
 * @return 없음
 * @memberOf ltsPca410
 */
function cfnSave()
{	
	// 해당내용 기술
}

/**
 * 설명: 삭제 함수
 * @param  없음
 * @return 없음
 * @memberOf ltsPca410
 */
function cfnDelete()
{
	// 해당내용 기술
}

/**
 * 설명: 신규처리 함수
 * @param  없음
 * @return 없음
 * @memberOf ltsPca410
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
 * @memberOf ltsPca410
 */
function cfnCallback(sTranId, nErrorCode, sErrorMsg) //Q: 파라미터 3개 들어오는데 왜 하나만 쓰는건지
{
	if(sTranId == "cfnSearch"){
		gfnSetAlertMsgUd("-1");			
	}else if(sTranId == "cfnSave"){
	}
}


//=======================================================================================
// 5. 공통옵션
//---------------------------------------------------------------------------------------

/**
 * 설명: 그리드 공통버튼 전처리함수
 * @param  없음
 * @return 없음
 * @memberOf ltsPca410
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

				break;
			
			case "EXDOWN":		// 엑셀 다운로드
				break;
			
		}
		
	}
}

/**
 * 설명: 화면 종료전 함수
 * @param  없음
 * @return 없음
 * @memberOf ltsPca410
 */
function cfnBeforeClose()
{
	if((dsList.rowcount > 0 && gfnIsUpdateSap(dsList)))  // 세션 종료시 수정여부 체크하는 함수. 수정 사항이 없어야 세션이 종료되는 듯함.
	{
		return false;
	}
	return true;

}

//=======================================================================================
// 6.사용자 정의함수
//---------------------------------------------------------------------------------------
/**
 * 설명: 고객사 팝업
 * @param strArgument
 * @return Dataset
 * @memberOf ltsPca410
 */
 function fnOpenPopup()
 {
	var objSend        = {};
	objSend.id         = "admin";
	
	objSend.custname    = gfnIsNullBlank(divSearch.edtKUNAGNM.value);     // 고객사
	objSend.formId 	   = "ltsPso200";
	objSend.vtweg 	   = "10";	//유통
	objSend.ktokd	   = "KTOKD_003";
	objSend.vkgrp      =  gfnGetUserInfo("VKGRP");	
	objSend.spart	   = "";
// 	objSend.pernr      = divResult.edtPERNR.value;//담당자
// 	objSend.pernrnm    = divResult.edtPERNRNM.value;//담당자 이름
// 	objSend.empno      = divResult.edtEMPNO.value;	//담당자 사번

	objSend.viewType   = "S";    // 단수개:S, 복수개:M
	
	var strId       = "ltsPso000_P01";			//Dialog ID
	var strURL      = "LTS.PSO::ltsPso000_P01.xfdl";	//Form URL
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

	if(retVal != null)   //gfnDialog가 반환값이 있다면
	{
 		if (retVal.dsCostomerList.rowcount > 0)   //고객 리스트 개수가 0 이상일 때
 		{
 		    divSearch.edtKUNAG.value   = retVal.dsCostomerList.getColumn(0, "KUNNR");  //박스 값을 kunnr로 채움
 		    divSearch.edtKUNAGNM.value = retVal.dsCostomerList.getColumn(0, "KUNNR_NM");  //박스 값을 kunnr_nm으로 채움
 		}
	}
 }
 
//=======================================================================================
// 7.이벤트처리 
//---------------------------------------------------------------------------------------
/**
 * 설명: 화면간 이동
 * @param  pDOCTY
 * @param  sDOCNO
 * @return 없음
 * @memberOf ltsPca410
 */
function divResult_grdList_oncelldblclick(obj:Grid, e:GridClickEventInfo)
{
	var sSEQNO = dsList.getColumn(e.row, "SEQNO"); // 등록번호

    fn_openForm( sSEQNO );
}

/**
 * 설명: 화면간 이동
 * @param  pParam1
 * @param  pParam2
 * @return 없음
 * @memberOf ltsPca410
 */
function fn_openForm(pParam1)
{
	sUrl   = "LTS.PCA::ltsPca400";		
	
	//화면간의 parameter 들의 전달 (문서번호, 문서종류)
	var aParam = [pParam1];	//gvScreeParams에 저장
	var sType = "CALL";
	var sCallFunc = "fnRefresh";	//호출함수명

	gfnRedirectForm(sUrl, aParam, sType, sCallFunc);
}

/**
 * 설명: 고객사 팝업
 * @param  obj:Button
 * @param  e:ClickEventInfo
 * @return 
 * @memberOf ltsPca410
 */
function btnKUNAGCall_onclick(obj:Button,  e:ClickEventInfo)
{
	fnOpenPopup();	
}

/**
 * 설명: 에디트 클리어
 * @param  obj:Edit
 * @param  e:ChangeEventInfo
 * @return 없음
 * @memberOf ltsPca410
 */
function divSearch_edtKUNAGNM_canchange(obj:Edit,  e:ChangeEventInfo)
{
	if (gfnIsNull(e.postvalue))  //NULL 일때 참임 근데 파라미터 e.postvalue는 어디서 오는건지?
	{
	    divSearch.edtKUNAG.value = "";
	}else{
        fnOpenPopup();  //고객사 팝업
    }	    	
}

/**
 * 설명: 고객사명 삭제버튼
 * @param  obj:Button
 * @param  e:ClickEventInfo
 * @return
 * @memberOf ltsPca410
 */
function btnKUNAGNMClear_onclick(obj:Button,  e:ClickEventInfo)  //Q: 이렇게 생긴 파라미터들이 많은데 의미가 뭔지.그럼 사용자 정의 함수가 아닌것인지.
{
    divSearch.edtKUNAGNM.value = "";
    divSearch.edtKUNAG.value    = "";	// 박스 값 모두 빈값으로 세팅
}

function divSearch_edtKUNAGNM_onkeydown(obj:Edit, e:KeyEventInfo)
{
    // 팝업버튼으로 호출시 oncolumnchanged이벤트 중복방지(oncolumnchanged이벤트 내부는 제외)
    if (e.keycode == 13) { //Q: keycode 상수값은 어디서 볼수 있는지? 의미를 모르겠음.
        divSearch.edtKUNAGNM.enableevent = false;
        fnOpenPopup();
        divSearch.edtKUNAGNM.enableevent = true;
    }			
}

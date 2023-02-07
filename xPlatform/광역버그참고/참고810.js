 /**
 * 시	스	템		: 코오롱프로세스혁신 업무포탈						<br>
 * 업	무	명 		: 영업 	 					    				<br>
 * 파	일	명 		: ltsPop810.xfdl	 		     			   	<br>
 * 작	성	자 		: 안순범											<br>
 * 작	성	일 		: 2018.03.26									<br>
 *																	<br>
 * 설		명 		: 공지사항조회			 					<br>
 *---------------------------------------------------------------------------------------<br>
 *  변경일     변경자  변경내역														 <br>
 *---------------------------------------------------------------------------------------<br>
 *  2018.03.26  안순범 최초 프로그램 작성											 <br>     
 * 
 *---------------------------------------------------------------------------------------<br>
 * @namespace
 * @name ltsPop810
 */

//=======================================================================================
// Common Lib Include
//--------------------------------------------------------------------------------------- 
include "lib::comLib.xjs";
include "lib::comRexpert.xjs";
//=======================================================================================
// 1. 화면전역변수선언
//---------------------------------------------------------------------------------------
var E_URL = "";							//전자결재URL

//=======================================================================================
// 2.FORM EVENT 영역
//---------------------------------------------------------------------------------------

/**
 * 설명: 폼로딩 초기화 함수(validation채크및 공통코드)
 * @param  없음
 * @return 없음
 * @memberOf ltsPpa730
 */
function cfnInitOnload()
{
 	

 	//판매조직	
 	var sBUKRS 	= gfnGetUserInfo("BUKRS");	//회사
	if (gfnIsNull(sBUKRS))
	{
		sBUKRS = "*";
	}				
		//공통코드(biztype:)
	var oComcodeSetList = [
		{code:"KPCNTYPE", dsName:"dsKPCNTYPE", useYn:"Y", selecttype:"A", objid: "divSearch.cboNTYPE"}
		,{code:"KPCNTYPE", dsName:"dsKPCNTYPE2", useYn:"Y", selecttype:"", objid: "divResult.grdList", bindcolumn:"NTYPE"}	

    ];
	gfnGetSapCommonCode(oComcodeSetList);		
	
	cfnInitForm();
		
}

/**
 * 설명: 공통코드처리후 호출함수
 * @param  없음
 * @return 없음
 * @memberOf ltsPpa730
 */
function cfnCommonCodeCallBackSap()
{
	cfnInitForm();
}

/**
 * 설명: 폼 초기화 함수(폼의 초기화: 검색영역, 그리드)
 * @param  없음
 * @return 없음
 * @memberOf ltsPpa730
 */
function cfnInitForm()
{	
  	dsDetail.clearData();	
	divSearch.divDate.fnSetDay(gfnAddDate(gfnToday(),-365), gfnToday());
	trace(divSearch.divDate.Calendar01.value);
	
	divSearch.edtSANUM_NM.value = "";
	divSearch.chkLVORM.value = "";
	divSearch.chkVAILD.value = "";
	var aParams = gfnGetScreenParams();
	if (!gfnIsNull(aParams))
	{
		//dsMaster.setColumn(0, "STDNO", aParams[0]);
		cfnSearch();
	}
}

//=======================================================================================
// 3.공통 호출함수
//---------------------------------------------------------------------------------------
/**
 * 설명: 전처리함수
 * @param  없음
 * @return 없음
 * @memberOf ltsPpa730dh 
 */
function cfnBeforeTran(sTranId) 
{
 	var msg = "";
 	
	if(sTranId=="cfnSearch")
	{
	}
	
	if(!gfnIsNull(msg))
 	{
		gfnAlert(msg);
		return false;
 	}
}

/**
 * 설명: 조회처리 함수
 * @param  없음
 * @return 없음
 * @memberOf ltsPpa730
 */
function cfnSearch()
{
	//데이터 초기화	
	var sTranId			= "cfnSearch";
	var sInDS 			= "";
	var sOutDS 			= "dsDetail=T_ZLTSP0710";	
	var sContextPath 	= "/jco/JcoController/";
	var sServelet 		= "getJcoData.xp?FUNCTION_NAME=Z_LTSP_IF0710";
	var sSendData		= "";
 		sSendData		+= " IV_PTYPE='R'";
 		sSendData		+= " IV_NTYPE="+divSearch.cboNTYPE.value;
 		sSendData		+= " IV_FRMDT="+divSearch.divDate.Calendar01.value;
 		sSendData		+= " IV_TODT="+divSearch.divDate.Calendar00.value;
 		sSendData		+= " IV_SANUM_NM="+divSearch.edtSANUM_NM.value;
 		sSendData		+= " IV_LVORM="+divSearch.chkLVORM.value;
 		sSendData		+= " IV_VAILD="+divSearch.chkVAILD.value;
        
/* 	var sCallBackFn		= "";*/
	
	trace("cfnSearch.SendData ==> " + sSendData);
	gfnSapTranN(sTranId, sInDS, sOutDS, sContextPath, sServelet, sSendData);
}

/**
 * 설명: 저장 함수
 * @param  없음
 * @return 없음
 * @memberOf ltsPpa730
 */
function cfnSave()
{	
	
}

/**
 * 설명: 삭제 함수
 * @param  없음
 * @return 없음
 * @memberOf ltsPpa730
 */
function cfnDelete()
{
	// 해당내용 기술
}

/**
 * 설명: 신규처리 함수
 * @param  없음
 * @return 없음
 * @memberOf ltsPpa730
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
 * @memberOf ltsPpa730
 */
function cfnCallback(sTranId, nErrorCode, sErrorMsg) 
{
	//그리드 해더 체크박스 클리어
	if(sTranId == "cfnSearch")
	{
		gfnSetAlertMsgUd("-1");	
        
		if(dsDetail.rowcount == 0)
		{
			gfnAlert("조회 데이타가 없습니다.");
			return false;
		}
		

	}
}


//=======================================================================================
// 5. 공통옵션
//---------------------------------------------------------------------------------------

/**
 * 설명: 그리드 공통버튼 전처리함수
 * @param  없음
 * @return 없음
 * @memberOf ltsPpa730
 */
function cfnBeforeGrid(objGrd, type, obj:Button,  e:ClickEventInfo)
{
	if(objGrd.name=="grdSelList"){
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
				//내용기술(return true or false)
				break;
			
		}
		
	}
}
/**
 * 설명: 화면 종료전 함수
 * @param  없음
 * @return 없음
 * @memberOf ltsPpa730
 */
function cfnBeforeClose()
{

	if(gfnIsUpdateSap(dsDetail))
	{
		return false;
	}
	return true;

}

//=======================================================================================
// 6.사용자 정의함수
//---------------------------------------------------------------------------------------
function gfnNullToZero(arg)
{
	var ret = 0;
	if(gfnIsNull(arg))
	{
		ret = 0;
	}else{
		ret = Number(gfnTrim(arg));
	}
	//trace(ret);
	return ret;
}


//=======================================================================================
// 7.이벤트처리 
//---------------------------------------------------------------------------------------

function divResult_grdList_onheadclick(obj:Grid, e:GridClickEventInfo)
{
	if (e.cell==0)
    {
        gfnSetGridCheckAll(obj, e);
    }
}


function divResult_grdList_oncelldblclick(obj:Grid, e:GridClickEventInfo)
{
	var sColumn = obj.getCellProperty( "Body", e.cell, "text" );

	if(gfnIsNull(sColumn)){
		return;
	}
	sColumn = sColumn.substr(5);

	if (sColumn == "NOTICENO"){	//자재 
		var sUrl = "LTS.POP::ltsPop800";
		var pNOTICENO = dsDetail.getColumn(e.row, "NOTICENO"); // trace("pNOTICENO: "+pNOTICENO);
		//var pSANUMNM = dsDetail.getColumn(e.row, "SANUM_NM");
		var aParam = [pNOTICENO/*, pSANUMNM*/];				//gvScreeParams에 저장
		var sType = "CALL"; 			//RELOAD(폼reload) or CALL(함수호출)
		var sCallFunc = "cfnInitForm";	//호출함수명

		gfnRedirectForm(sUrl, aParam, sType, sCallFunc);
	}
	//gfnGoSapGuiEx("ZCOR3540", "P_KOKRS=K083"+";P_BUKRS=K083"+";P_GJAHR=2016"+";P_MONAT=09"+"S_WERKS-LOW="+gfnWrapQuote(divSearch.cboPLANT.value)+";");	//Sap Gui호출 

}

function divSearch_staORGHK_onclick(obj:Static,  e:ClickEventInfo)
{
	
}

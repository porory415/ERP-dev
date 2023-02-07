 /**
 * 시    스    템         : PI process
 * 업    무    명         : 영업                      <br>
 * 파    일    명         : ltsLm121.xfdl             <br>
 * 작    성    자         : 윤조현                    <br>
 * 작    성    일         : 2022.12.20                <br>
 *                                                 	 <br>
 * 설        명         : 샘플주문 리스트 조회        <br>
 *---------------------------------------------------------------------------------------<br>
 *  변경일     변경자  변경내역                       <br>
 *---------------------------------------------------------------------------------------<br>
 * @namespace
 * @name ltsLm121
 */

//=======================================================================================
// Common Lib Include
//--------------------------------------------------------------------------------------- 
include "lib::comLib.xjs";

//=======================================================================================
// 1. 화면전역변수선언
//---------------------------------------------------------------------------------------
var E_VBELN = "";
//=======================================================================================
// 2.FORM EVENT 영역
//---------------------------------------------------------------------------------------

/**
 * 설명: 폼로딩 초기화 함수(validation채크및 공통코드)
 * @param  없음
 * @return 없음
 * @memberOf ltsLm121
 */
function cfnInitOnload()
{
    //vaildate 체크 목록 설정
    var oValidateSetList = [
        {objid:"divSearch.divVDAT.Calendar01",valid:"title:staVDAT,req:true"},	// 검색영역:납품예정일(From)
        {objid:"divSearch.divVDAT.Calendar00",valid:"title:staVDAT,req:true"},  // 검색영역:납품예정일(To)
    ];
    
    gfnSetVaildate(oValidateSetList);
    
    //그리드 버튼(그리드ID, 콜백함수)
    divResult.divGridMaster.cfnSetCommButton(divResult.grdList,false,false,false,false,true);

    //공통코드(biztype:)
    var oComcodeSetList = [
         {code:"SMAUART"   ,dsName:"dsSMAUART"       ,useYn:"Y", selecttype:"A", objid: "divSearch.cboSMART"}	// 검색영역:샘플유형
        //,{code:"SMREASON"  ,dsName:"dsSMREASON"      ,useYn:"Y", selecttype:"A", objid: "divSearch.cboSMRSN"}	// 검색영역:샘플사유
        ,{code:"SMAUART"   ,dsName:"dsGridSMAUART"   ,useYn:"Y", selecttype:"S", objid: "divResult.grdList", bindcolumn:"SMART",   keyColumn:"CDITM"}	// 결과그리드영역:샘플유형
        ,{code:"APVLSTATUS",dsName:"dsGridAPVLSTATUS",useYn:"Y", selecttype:"S", objid: "divResult.grdList", bindcolumn:"APSTT",   keyColumn:"CDITM"}	// 결과그리드영역:STATUS
        ,{code:"VTWEG"     ,dsName:"dsVTWEG"         ,useYn:"Y", selecttype:"S", objid: "divResult.grdList", bindcolumn:"VTWEG",   keyColumn:"CDITM"}	// 결과그리드영역:유통경로
        ,{code:"LMSTAGE", 	dsName:"dsSTAGE", 		useYn:"Y", selecttype:"S", objid: "divSearch.cboSTAGE3"} 					// 검색영역:영업기회단계
    ];
    gfnGetSapCommonCode(oComcodeSetList); //페이지 오픈할때 DB에서 공통코드를 가지고 온다.

    //그리드contextMenu
    gfnSetGridContextMenu(divResult.grdList);
}

/**
 * 설명: 공통코드처리후 호출함수
 * @param  없음
 * @return 없음
 * @memberOf ltsLm121
 */
function cfnCommonCodeCallBackSap()
{
    fnSMRSN(); // 샘플사유
    cfnInitForm();
}

/**
 * 설명: 폼 초기화 함수(폼의 초기화: 검색영역, 그리드)
 * @param  없음
 * @return 없음
 * @memberOf ltsLm121
 */
function cfnInitForm()
{
    //최근수정일자 필수 입력 표시 css 적용
    //divSearch.divAEDT.fnSetClass("cal_WF_Essential");
    divSearch.divVDAT.fnSetClass("cal_WF_Essential");
    divSearch.divAEDT.fnSetDay("", "");	
	divSearch.divVDAT.fnSetDay(gfnToday(), gfnAddDate(gfnToday(), +7));
	
	//샘플오더 로직 체크 조회
	fnSampleLogic();
}

//=======================================================================================
// 3.공통 호출함수
//---------------------------------------------------------------------------------------
/**
 * 설명: 전처리함수
 * @param  없음
 * @return 없음
 * @memberOf ltsLm121
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
 * @memberOf ltsLm121
 */
function cfnSearch()  
{
    //데이터 초기화
    dsSMLIST.clearData();

    var sAEDT    = divSearch.divAEDT.fnGetDay();
    var sAEDTF   = sAEDT[0];
    var sAEDTT   = sAEDT[1];
    
    var sVDAT    = divSearch.divVDAT.fnGetDay();
    var sVDATF   = sVDAT[0];
    var sVDATT   = sVDAT[1];
    
    var sTranId      = "cfnSearch";
    var sInDS        = "";
    var sOutDS       = "dsSMLIST=ET_SMLIST";
    var sContextPath = "/jco/JcoController/";
    var sServelet    = "getJcoData.xp?FUNCTION_NAME=Z_LTS_IFS0055";
    var sSendData    = "";
        sSendData   += "IV_SMDNO="    + gfnWrapQuote(divSearch.edtSMDNO.value)      // 샘플주문문서번호
                    += " IV_OWNDATA=" + gfnWrapQuote(divSearch.chkOwnData.value)	// 내문서만조회
                    +  " IV_SMART="   + gfnWrapQuote(divSearch.cboSMART.value)      // 샘플유형
                    +  " IV_KUNAG="   + gfnWrapQuote(divSearch.edtKUNAG.value)      // 판매처
                    +  " IV_MATNR="   + gfnWrapQuote(divSearch.edtMATNR.value)      // 자재 번호
                    +  " IV_SMRSN="   + gfnWrapQuote(divSearch.cboSMRSN.value)      // 샘플사유
                    +  " IV_AEDTF="   + gfnWrapQuote(sAEDTF)                        // 최근수정일FROM
                    +  " IV_AEDTT="   + gfnWrapQuote(sAEDTT)                        // 최근수정일TO
                    +  " IV_VDATF="   + gfnWrapQuote(sVDATF)                        // 납품예정일FROM
                    +  " IV_VDATT="   + gfnWrapQuote(sVDATT)                        // 납품예정일TO
                    +  " IV_XAPVL_A=" + gfnWrapQuote(divSearch.chkXAPVL_A.value)    // 문서작성중
                    +  " IV_XAPVL_B=" + gfnWrapQuote(divSearch.chkXAPVL_B.value)    // 결재상신
                    +  " IV_XAPVL_C=" + gfnWrapQuote(divSearch.chkXAPVL_C.value)    // 결재진행중
                    +  " IV_XAPVL_D=" + gfnWrapQuote(divSearch.chkXAPVL_D.value)    // 결재승인
                    +  " IV_XAPVL_Z=" + gfnWrapQuote(divSearch.chkXAPVL_Z.value)    // 결재반려
                    +  " IV_STAGE="   + gfnWrapQuote(divSearch.cboSTAGE3.value)  	// 영업기회Stage	2016.08.05
                    +  " IV_OWNDEPT="  	+ gfnWrapQuote(divSearch.chkOwnDept.value);	// 내부서 2019.04.23 
    var sCallBackFn = "";
    gfnSapTranN(sTranId, sInDS, sOutDS, sContextPath, sServelet, sSendData);
}


/**
 * 설명: 저장 함수
 * @param  없음
 * @return 없음
 * @memberOf ltsLm121
 */
function cfnSave()
{    
    // 해당내용 기술
}

/**
 * 설명: 삭제 함수
 * @param  없음
 * @return 없음
 * @memberOf ltsLm121
 */
function cfnDelete()
{
    // 해당내용 기술
}

/**
 * 설명: 신규처리 함수
 * @param  없음
 * @return 없음
 * @memberOf ltsLm121
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
 * @memberOf ltsLm121
 */
function cfnCallback(sTranId, nErrorCode, sErrorMsg) 
{
    if(sTranId == "cfnSearch"){
        gfnSetAlertMsgUd("-1");  //안한다는거(?)
    }else if(sTranId == "cfnSave"){
    }else if(sTranId == "fnSampleSearch"){
        gfnSetAlertMsgUd("-1");
        fnSetData();
    }else if(sTranId == "fnSalesOrderSave"){
		// 첫번째 param : TCODE
		// 두번째 param : parameter(다건인경우 ";" 으로 구분하여 전달)
		//gfnGoSapGuiEx("VA02", "VBAK-VBELN="+E_VBELN);
        gfnSetAlertMsgUd("-1");
		if (!gfnIsNull(E_VBELN)) {
		    fnSampleSave();  // 저장하면 데이타 사라져서 막음.
		    dsSMLIST.setColumn(dsSMLIST.rowposition, "VBELN", E_VBELN);
		}
    }else if(sTranId == "fnSampleSave"){
        gfnSetAlertMsgUd("-1");
        gfnGoSapGuiEx("VA03", "VBAK-VBELN="+E_VBELN);   // SAP 호출
        cfnSearch();
	}else if(sTranId == "fnSMRSN"){                     // 샘플사유 조회
		gfnSetAlertMsgUd("-1");	
		dsSMRSN.insertRow(0);
		dsSMRSN.setColumn(0, "AUART", "");
		dsSMRSN.setColumn(0, "AUGRU", "");
		dsSMRSN.setColumn(0, "AUGRU_TEXT", "- 전체 -" );
		divSearch.cboSMRSN.index = 0;
	}else if(sTranId == "fnSampleSearch2"){
		trace("vbeln" + E_VBELN );
		gfnSetAlertMsgUd("-1");
		if (!gfnIsNull(E_VBELN)) {
		    fnSampleSave();  // 저장하면 데이타 사라져서 막음.
		    dsSMLIST.setColumn(dsSMLIST.rowposition, "VBELN", E_VBELN);
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
 * @memberOf ltsLm121
 */
function cfnBeforeGrid(objGrd, type, obj:Button,  e:ClickEventInfo)   //따로 로직이 없으면 기본 기능만 수해앟게 됨
{
    if(objGrd.name=="grdList"){
        switch (type)
        {
            case "CLEARROW":    // 행초기화
                //내용기술(return true or false)
                break;
                
            case "ADDROW":        // 행추가
                //validate return false; row가 추가되지 안는상태
                
                //내용기술(return true or false)
                break;
            
            case "INSERTROW":    // 행삽입
                //내용기술(return true or false)
                break;
            
            case "DELROW":        // 행삭제
                //내용기술(return true or false)
                break;
            
            case "COPYROW":        // 행복사
                //내용기술(return true or false)
                break;
            
            case "EXDOWN":        // 엑셀 다운로드
                gfnSetExcelDownData(divResult.grdList);
                return false;
                break;
        }
    }
}

/**
 * 설명: 화면 종료전 함수
 * @param  없음
 * @return 없음
 * @memberOf ltsLm121
 */
function cfnBeforeClose()
{
    if((dsSMLIST.rowcount > 0 && gfnIsUpdateSap(dsSMLIST)))
    {
        return false;
    }
    return true;

}

//=======================================================================================
// 6.사용자 정의함수
//---------------------------------------------------------------------------------------
/**
 * 설명: 샘플오더 고객사별 Logic 제어 기준 정보 관리
 * @param  없음
 * @return 없음
 * @memberOf ltsLm120
 */
function fnSampleLogic()
{
	//데이터 초기화
  	dsLOGIC.clearData();

	var sTranId			= "fnSampleLogic";
	var sInDS 			= "";
	var sOutDS 			= "dsLOGIC=ET_LOGIC";
	var sContextPath 	= "/jco/JcoController/";
	var sServelet 		= "getJcoData.xp?FUNCTION_NAME=Z_LTS_IFS0050";
	var sSendData		= "";
	var sCallBackFn		= "";

	gfnSapTranY(sTranId, sInDS, sOutDS, sContextPath, sServelet, sSendData, sCallBackFn);
}

/**
 * 설명: 샘플사유
 * @param  없음
 * @return 없음
 * @memberOf ltsLm120_P02
 */
 
function fnSMRSN()
{
	//데이터 초기화
  	dsSMRSN.clearData();

	var sTranId			= "fnSMRSN";
	var sInDS 			= "";
	var sOutDS 			= "dsSMRSN=ET_REASON";
	var sContextPath 	= "/jco/JcoController/";
	var sServelet 		= "getJcoData.xp?FUNCTION_NAME=Z_LTS_IFS0064";
	var sSendData		= " IV_GRPCD=SM1"
		        		+ " IV_AUART=";
	var sCallBackFn		= "";

	gfnSapTranN(sTranId, sInDS, sOutDS, sContextPath, sServelet, sSendData, sCallBackFn);
}

/**
 * 설명: 고객사 팝업
 * @param  
 * @return 
 * @memberOf ltsLm121
 */
function fnCustPopUp()
{
    var objSend        = {};                         // Parameter : Obj
    objSend.viewType   = "S";                        // 단수개:S, 복수개:M
    objSend.zeltsCdGrp = "C99";                      // 조회범위
    objSend.name1Gp    = divSearch.edtKUNAGNM.value; // 고객사명
    
    var retVal = gfnltsOp151_P01(objSend);           // 고객사 팝업 호출
    
    if (retVal != null) {
        if (retVal.dsCostomerList.rowcount > 0) {
            divSearch.edtKUNAG.value   = retVal.dsCostomerList.getColumn(0, "KUNNR");
            divSearch.edtKUNAGNM.value = retVal.dsCostomerList.getColumn(0, "KUNNR_NM");
        }
    }
}
 
/**
 * 설명: 제품 팝업
 * @param  
 * @return 
 * @memberOf ltsLm121
 */ 
 function fnGoodsPopUp()
{
    var objSend        = {};                         // Parameter : Obj  
    objSend.matnr      = "";                         // 조회범위
    objSend.deskey     = divSearch.edtMATNRNM.value; // 제품명
    objSend.viewType   = "S";                        // 단수개:S, 복수개:M
    
    var retVal = gfnltsOp152_P01(objSend);           // 제품 팝업 호출
    
    if (retVal != null) {
        if (retVal.dsCostomerList.rowcount > 0) {
            divSearch.edtMATNR.value   = retVal.dsCostomerList.getColumn(0, "MATNR");
            divSearch.edtMATNRNM.value = retVal.dsCostomerList.getColumn(0, "MAKTX");
        }
    }
}


/**
 * 설명: S/O 처리하기 위한 조회처리 함수
 * @param  없음
 * @return 없음
 * @memberOf ltsLm121
 */
function fnSampleSearch(pSMDNO)
{
	//데이터 초기화
 	dsSMMASTER.clearData();
  	dsSMITEM.clearData();
  	dsSMTEXT.clearData();

	var sTranId			= "fnSampleSearch";
	var sInDS 			= "";
	var sOutDS 			= "dsSMMASTER=T_SMMASTER dsSMITEM=T_SMITEM dsSMTEXT=T_SMTEXT";
	var sContextPath 	= "/jco/JcoController/";
	var sServelet 		= "getJcoData.xp?FUNCTION_NAME=Z_LTS_IFR0047";
	var sSendData		= " IV_PTYPE=R"
		        		+ " IV_SMDNO="+gfnWrapQuote(pSMDNO);

	var sCallBackFn		= "";

	gfnSapTranN(sTranId, sInDS, sOutDS, sContextPath, sServelet, sSendData, sCallBackFn);
	
}

/**
 * 설명: S/O 처리하기 위한 조회처리 함수(3본부)
 * @param  없음
 * @return 없음
 * @memberOf ltsLm121
 */
function fnSampleSearch2(pSMDNO)
{
	//데이터 초기화
 	dsSMMASTER.clearData();
  	dsSMITEM.clearData();
  	dsSMTEXT.clearData();

	var sTranId			= "fnSampleSearch2";
	var sInDS 			= "";
	var sOutDS 			= "dsSMMASTER=T_SMMASTER";
	var sContextPath 	= "/jco/JcoController/";
	var sServelet 		= "getJcoData.xp?FUNCTION_NAME=Z_LTS_IFS0086";
	var sSendData		= " IV_SMDNO="+gfnWrapQuote(pSMDNO);

	var sCallBackFn		= "";

	gfnSapTranN(sTranId, sInDS, sOutDS, sContextPath, sServelet, sSendData, sCallBackFn);

}

/**
 * 설명: S/O 처리하기 위한 Dataset Setting
 * @param  없음
 * @return 없음
 * @memberOf ltsLm121
 */
function fnSetData()
{
	dsHEAD.clearData(); 	
 	dsITEM.clearData();
 	dsTEXT.clearData();
 	
 	gfnGridRowAdd(dsHEAD);

	dsHEAD.applyChange(); 
    
    
    // 샘플관리의 정보로 Set
    dsHEAD.setColumn(0, "VKORG",     dsSMMASTER.getColumn(0,"VKORG"));   // 판매조직
    dsHEAD.setColumn(0, "VKGRP",     dsSMMASTER.getColumn(0,"VKGRP"));   // 영업그룹  
    dsHEAD.setColumn(0, "AUART",     dsSMMASTER.getColumn(0,"SMART"));   // 오더유형 (샘플유형)
    dsHEAD.setColumn(0, "VTWEG",     dsSMMASTER.getColumn(0,"VTWEG"));   // 유통경로
    dsHEAD.setColumn(0, "SPART",     dsSMMASTER.getColumn(0,"SPART"));   // 제품군
    dsHEAD.setColumn(0, "KUNAG",     dsSMMASTER.getColumn(0,"KUNAG"));   // 판매처
    dsHEAD.setColumn(0, "KUNWE",     dsSMMASTER.getColumn(0,"KUNWE"));   // 납품처
    dsHEAD.setColumn(0, "KUNEN",     dsSMMASTER.getColumn(0,"KUNZ1"));   // End고객
    dsHEAD.setColumn(0, "KUNZ2",     dsSMMASTER.getColumn(0,"KUNZ2"));   // 영업사원 2019.09.16 추가 
    dsHEAD.setColumn(0, "AUGRU",     dsSMMASTER.getColumn(0,"SMRSN"));   // 오더사유 (샘플사유)
    dsHEAD.setColumn(0, "ZZLTSTYPE", "SM");                              // 문서유형 (샘플:SM)
    dsHEAD.setColumn(0, "ZZLTSDOC",  dsSMMASTER.getColumn(0,"SMDNO"));   // 문서번호
    dsHEAD.setColumn(0, "ZZLMDNO",   dsSMMASTER.getColumn(0,"LMDNO"));   // 영업기회번호
    dsHEAD.setColumn(0, "WAERS",   	 dsSMMASTER.getColumn(0,"WAERK"));   // 통화
    dsHEAD.setColumn(0, "INCO1",   	 dsSMMASTER.getColumn(0,"INCO1"));   // 인도조건
    dsHEAD.setColumn(0, "ZTERM",   	 dsSMMASTER.getColumn(0,"ZTERM"));   // 지급조건
    dsHEAD.setColumn(0, "AUTOPR",    dsSMMASTER.getColumn(0,"AUTOPR"));  // 구매PR(PR자동생성)
    dsHEAD.setColumn(0, "BSTKD",     dsSMMASTER.getColumn(0,"BSTKD"));   // PO번호
       
      
    var nCnt   = dsSMITEM.rowcount;
    var sSmart = dsSMMASTER.getColumn(0,"SMART");  // 샘플유형(유상,무상)
    
    // Item 껀수 만큼 자료 생성.
    for(var i=0; i < nCnt; i++) {
		//데이터셋 Row 추가
		var nRow = dsITEM.addRow();
		
		dsITEM.setColumn(nRow, "rStatus", gvConst.DATASET_ROW_CREATE);           // rStatus 값을 C로 설정(추가상태)
		dsITEM.setColumn(nRow, "MATNR",   dsSMITEM.getColumn(i, "MATNR"));       // 제품코드
		dsITEM.setColumn(nRow, "VRKME",   dsSMITEM.getColumn(i, "VRKME"));       // 수량단위
		dsITEM.setColumn(nRow, "KWMENG",  dsSMITEM.getColumn(i, "KWMENG"));      // 수량
		dsITEM.setColumn(nRow, "EDATU",   dsSMITEM.getColumn(i, "VDATU"));       // 납품예정일
		dsITEM.setColumn(nRow, "ZZLMDNO", dsSMITEM.getColumn(i, "LMDNO"));       // 영업기회번호
		dsITEM.setColumn(nRow, "ZZSEQNO", dsSMITEM.getColumn(i, "SEQNO_LM"));    // 영업기회제품순번
		dsITEM.setColumn(nRow, "CHARG",   dsSMITEM.getColumn(i, "CHARG"));       // 20151110추가 배치 
		dsITEM.setColumn(nRow, "ZZGRADE", dsSMITEM.getColumn(i, "ZZGRADE"));     // 등급 2019-08-13
		dsITEM.setColumn(nRow, "WERKS",   dsSMITEM.getColumn(i, "WERKS"));       // 플랜트 2019-10-01
		dsITEM.setColumn(nRow, "ZZDLVDIR",dsSMITEM.getColumn(i, "ZZDLVDIR"));    // 납품지시코드 2020-01-20  
		
		
		// 유상샘플만 금액 처리 한다.
		if (sSmart == "ZFD1") {
		
			if(dsSMITEM.getColumn(i,"PPR001") == 0){
				dsITEM.setColumn(nRow, "KOEIN1",     dsSMITEM.getColumn(i, "CPR001"));      // 통화
				dsITEM.setColumn(nRow, "KSCHL1",     "ZPR0");  // 할인사유
				dsITEM.setColumn(nRow, "KBETR1",     dsSMITEM.getColumn(i, "PPR002"));     // 할인금액			
				dsITEM.setColumn(nRow, "KPEIN1",     dsSMITEM.getColumn(i, "KPEIN"));     // 할인금액단위수량
				dsITEM.setColumn(nRow, "KMEIN1",     dsSMITEM.getColumn(i, "KMEIN"));     // 할인금액단위
			}else{
				dsITEM.setColumn(nRow, "KOEIN1",     dsSMITEM.getColumn(i, "CPR001"));      // 통화
				dsITEM.setColumn(nRow, "KSCHL1",     dsSMITEM.getColumn(i, "DIS_RESAON"));  // 할인사유
				dsITEM.setColumn(nRow, "KBETR1",     dsSMITEM.getColumn(i, "DIS_AMT"));     // 할인금액			
				dsITEM.setColumn(nRow, "KPEIN1",     dsSMITEM.getColumn(i, "KPEIN"));     // 할인금액단위수량
				dsITEM.setColumn(nRow, "KMEIN1",     dsSMITEM.getColumn(i, "KMEIN"));     // 할인금액단위
			}
		}	
    }
    
    //특별출하조건 set
	var sZTEXT; 
	for(var i=0; i < dsSMTEXT.rowcount; i++) {
		if(dsSMTEXT.getColumn(i, "CDITM") == "Z001"){
			//데이터셋 Row 추가
			var nRow = dsTEXT.addRow();
			sZTEXT = dsSMTEXT.getColumn(i, "ZTEXT");
			dsTEXT.setColumn(nRow, "TEXT_LINE",     sZTEXT);  //틀별출하조건 Text
		
		}
		
	}
    
    
    // S/O 저장
    fnSalesOrderSave();
}

/**
 * 설명: S/O 저장 처리 함수
 * @param  없음
 * @return 없음
 * @memberOf ltsLm121
 */
function fnSalesOrderSave()
{
	var sTranId			= "fnSalesOrderSave";
	var sInDS 			= "T_HEAD=dsHEAD T_ITEM=dsITEM T_TEXT=dsTEXT";
	var sOutDS 			= "";
	var sContextPath 	= "/jco/JcoController/";
	var sServelet 		= "getJcoData.xp?FUNCTION_NAME=Z_LTS_IFR0048";
	var sSendData		= "";	
	var sCallBackFn		= "";
	
	gfnSapTranN(sTranId, sInDS, sOutDS, sContextPath, sServelet, sSendData, sCallBackFn);
}

/**
 * 설명: Sample S/O 처리 번호 저장 함수
 * @param  없음
 * @return 없음
 * @memberOf ltsLm121
 */
function fnSampleSave()
{
	var sSMDNO          = dsSMMASTER.getColumn(0, "SMDNO"); 
	
	trace("smdno"  + sSMDNO);
	trace("vbelnsave" + E_VBELN);
	
	var sTranId			= "fnSampleSave";
	var sInDS 			= "";
	var sOutDS 			= "";
	var sContextPath 	= "/jco/JcoController/";
	var sServelet 		= "getJcoData.xp?FUNCTION_NAME=Z_LTS_IFR0063";
	var sSendData		= " IV_SMDNO=" + gfnWrapQuote(sSMDNO)
                        + " IV_VBELN=" + gfnWrapQuote(E_VBELN);
	var sCallBackFn		= "";

	gfnSapTranN(sTranId, sInDS, sOutDS, sContextPath, sServelet, sSendData, sCallBackFn);
}

//=======================================================================================
// 7.이벤트처리 
//---------------------------------------------------------------------------------------
/**
 * 설명: 판매처 팝업
 * @param  obj:Button
 * @param  e:ClickEventInfo
 * @return
 * @memberOf ltsLm121
 */
function btnKUNAGCall_onclick(obj:Button,  e:ClickEventInfo)
{
    fnCustPopUp();
}

/**
 * 설명: 판매처명칭 변경 됬을 경우 처리
 * @param  obj:Button
 * @param  e:ClickEventInfo
 * @return
 * @memberOf ltsLm121
 */
function edtKUNAGNM_canchange(obj:Edit,  e:ChangeEventInfo)
{
    if (gfnIsNull(e.postvalue)) {
        divSearch.edtKUNAG.value = "";
    }else{
        fnCustPopUp();
    }
}

function edtKUNAGNM_onkeydown(obj:Edit, e:KeyEventInfo)
{
    // 팝업버튼으로 호출시 oncolumnchanged이벤트 중복방지(oncolumnchanged이벤트 내부는 제외)
    if (e.keycode == 13) {
        divSearch.edtKUNAGNM.enableevent = false;
        fnCustPopUp();
        divSearch.edtKUNAGNM.enableevent = true;
    }
}

/**
 * 설명: 판매처명 삭제버튼
 * @param  obj:Button
 * @param  e:ClickEventInfo
 * @return
 * @memberOf ltsLm121
 */
function btnKUNAGNMClear_onclick(obj:Button,  e:ClickEventInfo)
{
    divSearch.edtKUNAGNM.value = "";
    divSearch.edtKUNAG.value   = "";
    divSearch.edtKUNAGNM.setFocus();
}

/**
 * 설명: 제품 팝업
 * @param  obj:Button
 * @param  e:ClickEventInfo
 * @return
 * @memberOf ltsLm121
 */
function btnMATNRCall_onclick(obj:Button,  e:ClickEventInfo)
{
    fnGoodsPopUp();
}

/**
 * 설명: 제품명 변경 됬을 경우 처리
 * @param  obj:Button
 * @param  e:ClickEventInfo
 * @return
 * @memberOf ltsLm121
 */
function edtMATNRNM_canchange(obj:Edit,  e:ChangeEventInfo)
{
    if (gfnIsNull(e.postvalue)) {
        divSearch.edtMATNR.value = "";
    }else{
        fnGoodsPopUp();
    }
}

function edtMATNRNM_onkeydown(obj:Edit, e:KeyEventInfo)
{
    // 팝업버튼으로 호출시 oncolumnchanged이벤트 중복방지(oncolumnchanged이벤트 내부는 제외)
    if (e.keycode == 13) {
        divSearch.edtMATNRNM.enableevent = false;
        fnGoodsPopUp();
        divSearch.edtMATNRNM.enableevent = true;
    }
}

/**
 * 설명: 제품명 삭제버튼
 * @param  obj:Button
 * @param  e:ClickEventInfo
 * @return
 * @memberOf ltsLm121
 */
function btnMATNRNMClear_onclick(obj:Button,  e:ClickEventInfo)
{
    divSearch.edtMATNRNM.value = "";
    divSearch.edtMATNR.value   = "";
    divSearch.edtMATNRNM.setFocus();
}

/**
 * 설명: 그리드 S/O 클릭시 주문생성 화면으로 이동.
 * @param  obj:Button
 * @param  e:ClickEventInfo
 * @return
 * @memberOf ltsLm121
 */
function divResult_grdList_oncellclick(obj:Grid, e:GridClickEventInfo)
{			
	var sColText = obj.getCellProperty( "body", e.cell, "text" );
	var sColId = sColText.split(":")[1];
	if(sColId == "VBELN" ) {
		var sVBELN = dsSMLIST.getColumn(e.row, "VBELN");  // S/O 번호
		var sAPSTT = dsSMLIST.getColumn(e.row, "APSTT");  // 결재상태 (D00:승인)
		if (!gfnIsNull(sVBELN) || sAPSTT != "D00") {
			return;
		}
		
		var sVKORG = gdsEmpInfo.getColumn(0,"VKORG");
		var sSMART = dsSMLIST.getColumn(0,"SMART");
		var sBUKRS= dsSMLIST.getColumn(0,"BUKRS");
		var sMsg = "주문생성 하시겠습니까?";
		
		//샘플 오더 생성 Logic체크 2018-08-27
		for(var i=0; i<dsLOGIC.rowcount; i++)
		{
			if(sBUKRS == dsLOGIC.getColumn(i, "BUKRS") && sVKORG == dsLOGIC.getColumn(i, "VKORG") && sSMART == dsLOGIC.getColumn(i, "SMART")){
				sMsg = "영업포탈에서 오더 생성 후 SAP에서 수정 불가합니다. \n주문생성 하시겠습니까?";
			}
		}
		
		
		if (gfnConfirm("IOS014", sMsg)) {
			//2015.02.25 추가 

				if(sVKORG == '1130') {
					var sSMDNO = dsSMLIST.getColumn(e.row, "SMDNO");			
					var strId       = "ltsLm113_P03";			    //Dialog ID
					var strURL      = "LTS.LM::ltsLm113_P03.xfdl";	//Form URL
					var nTop        = -1;							//Form Top
					var nLeft       = -1;							//Form Left
					var nWidth      = 966;							//Form Width
					var nHeight     = 509;							//Form Height
					var bShowTitle  = true;							//Form Title 을 표시 할지 여부
					var strAlign    = "-1";					 	    //Dialog 의 위치
					var strArgument = {avObjSend:sSMDNO}; //Dialog 로 전달될 Argument
					var isModeless = false;							// true 면 Dialog 를 Modeless로 띄운다.
					var winOption = {};								//window option
						winOption.resizable = false;				//팝업창의 리싸이징이 가능(true: 확대, 최소화가 없어진다)
						winOption.autosize = true;					//팝업창의 크기에 맞게 변경
						
					var retVal = gfnDialog(strId, strURL, nTop, nLeft, nWidth, nHeight, bShowTitle, strAlign, strArgument, isModeless, winOption);
					fnSampleSearch2(sSMDNO); //3본부용 
				
			} else{
				var sSMDNO = dsSMLIST.getColumn(e.row, "SMDNO");  // 문서번호
				fnSampleSearch(sSMDNO);
			}
		}
	}	
}

/**
 * 설명: 그리드 더블 클릭시 샘플주문관리 화면으로 이동.
 * @param  obj:Grid
 * @param  e:GridClickEventInfo
 * @return
 * @memberOf ltsLm121
 */
function divResult_grdList_oncelldblclick(obj:Grid, e:GridClickEventInfo)
{		
	var sColumn = obj.getCellProperty( "Body", e.cell, "text" );
	
	if(gfnIsNull(sColumn)){
		return;
	}
	sColumn = sColumn.substr(5);
	

	if (sColumn == "KUNAG_NM"){			//판매처
		var sUrl   = "LTS.CA::ltsCa091";
		var pKUNAG = dsSMLIST.getColumn(e.row, "KUNAG");
		var aParam = [pKUNAG];				//gvScreeParams에 저장
		var sType = "CALL";
		var sCallFunc = "fnRefresh";	//호출함수명
		
		gfnRedirectForm(sUrl, aParam, sType, sCallFunc);					
	}else if (sColumn == "KUNWE_NM"){	//납품처
		var sUrl   = "LTS.CA::ltsCa091";
		var pKUNAG = dsSMLIST.getColumn(e.row, "KUNWE");
		var aParam = [pKUNAG];				//gvScreeParams에 저장
		var sType = "CALL";
		var sCallFunc = "fnRefresh";	//호출함수명
		
		gfnRedirectForm(sUrl, aParam, sType, sCallFunc);					
	}else if (sColumn == "KUNZ1_NM"){	//End고객
		var sUrl   = "LTS.CA::ltsCa091";
		var pKUNAG = dsSMLIST.getColumn(e.row, "KUNZ1");
		var aParam = [pKUNAG];				//gvScreeParams에 저장
		var sType = "CALL";
		var sCallFunc = "fnRefresh";	//호출함수명
		
		gfnRedirectForm(sUrl, aParam, sType, sCallFunc);						
	}else if (sColumn == "LMDNO"){		//영업기회
		var sDocNo 	= dsSMLIST.getColumn(e.row, "LMDNO");
		if (sDocNo)
		{
			var sUrl 	= "LTS.LM::ltsLm107";
			var oParam 	= {docno:sDocNo,parenturl:"ltsLm121"};
			var aParam 	= [oParam];	// gvScreeParams에 저장
			
			gfnRedirectForm(sUrl, aParam, "CALL", "fnRefresh");
		}		
	}else{	
		var sSMDNO    = dsSMLIST.getColumn(e.row, "SMDNO");
		var sKUNAG    = dsSMLIST.getColumn(e.row, "KUNAG");
		var sKUNAG_NM = dsSMLIST.getColumn(e.row, "KUNAG_NM");
		var sAPSTT    = dsSMLIST.getColumn(e.row, "APSTT");	// 결재상태 추가 2016.05.04
		fnOpenForm(sSMDNO,sAPSTT);
	} 	
}

/**
 * 설명: 샘플주문 화면으로 이동
 * @param  
 * @return 
 * @memberOf ltsLm121
 */
function fnOpenForm(pParam, pParam2)
{
	var sUrl   = "LTS.LM::ltsLm120";
	var pSMDNO = pParam;
	var pAPSTT = pParam2;
	
	var aParam = [pSMDNO, pAPSTT];				//gvScreeParams에 저장
	var sType = "RELOAD";						// CALL -> RELOAD로 변경 
	//var sCallFunc = "fnRefresh";	//호출함수명
	var sCallFunc = "";
	
	gfnRedirectForm(sUrl, aParam, sType, sCallFunc);
}

/**
 * 설명: 신규품의등록 버튼 샘플주문관리 화면으로 이동.
 * @param  obj:Button
 * @param  e:ClickEventInfo
 * @return
 * @memberOf ltsLm121
 */
function divResult_btnCreate_onclick(obj:Button,  e:ClickEventInfo)
{
	fnOpenForm("");	
}

function divSearch_chkXAPVL_B_onclick(obj:CheckBox,  e:ClickEventInfo)
{
	
}

function divSearch_chkXAPVL_A_onclick(obj:CheckBox,  e:ClickEventInfo)
{
	
}

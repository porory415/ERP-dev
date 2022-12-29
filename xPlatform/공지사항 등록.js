/*---------------------------------------------------------------------------------------<br>
* @namespace
* @name ltsPca400
*/

//=======================================================================================
// Common Lib Include
//--------------------------------------------------------------------------------------- 
    include "lib::comLib.xjs";
//=======================================================================================
// 1. 화면전역변수선언
//---------------------------------------------------------------------------------------
var lvObjSend={};
var lvDsFileInfo;				//파일정보
var lvDsFileData;				//파일데이터
var lvFileCnt = 0, lvCurCnt = 0;//파일Cnt
var lvFileID;					//파일ID
//=======================================================================================
// 2.FORM EVENT 영역
//---------------------------------------------------------------------------------------
/**
* 설명: 폼로딩 초기화 함수(validation채크및 공통코드)
* @param  없음
* @return 없음
* @memberOf ltsPca400
*/
function cfnInitOnload()
{   
    gfnClearFileInfoSap(); // 파일전송Dataset 초기화처리
        
    //TODO : dsRollback 데이셋은 메인에 만들어 두었습니다.
    //TODO : dsRollback에 대한 format설정	
    //TODO : upload하는 화면 onload이벤트에 아래 스크립트 추가
    //TODO : this.dsRollback.copyData(_gdsDefaultFormatFileInfoUpper);	
    this.dsRollback.copyData(_gdsDefaultFormatFileInfoUpper);	 //dsRollback에 대한 format설정 //인자가 데이터셋임...
        
   //vaildate 체크 목록 설정
   var oValidateSetList = [
       {objid:"divResult.cboNTCLS", valid:"title:stcSUBJT,req:true"}  	// 업무구분
      ,{objid:"divResult.cboNTLVL", valid:"title:stcKTOKD_NM,req:true"}  	// 중요도 
      ,{objid:"divResult.edtTITLE", valid:"title:stcKUNAG_NM,req:true"}  	// 제목	   	   
      ,{objid:"divResult.grdList", valid:"colNm:KUNAG,req:true"}			// 그리드영역:대리점코드
      ,{objid:"divResult.grdList02", valid:"colNm:FNAME,req:true"}			// 그리드영역:첨부파일	   
   ];
   
   gfnSetVaildate(oValidateSetList);
   
   //그리드 공통 버튼
   divResult.divGridList.cfnSetCommButton(divResult.grdList,true,false,true,true,false); //상단 거래처 추가 그리드
   divResult.divGridList02.cfnSetCommButton(divResult.grdList02,true,false,true,true,false);  //하단 첨부파일 그리드
   
   //sap용 textArea설정
   var oTextAreaSetList = [
        {dsName:"dsText", cdgrp:"TEXTID", cditm:"T0006", bindDsName:"dsText01", objid:"divResult.divZTEXT.txtZTEXT"}
   ];
   gfnSetTextAreaSap(oTextAreaSetList);
   
   //공통코드(biztype:)
   var oComcodeSetList = [
       {code:"ZDMNOTICE",     dsName:"dsNOTICECLS", useYn:"Y", selecttype:"S", objid: "divResult.cboNTCLS"}	//업무구분
      ,{code:"ZDMNTCLVL",     dsName:"dsNOTICELVL", useYn:"Y", selecttype:"S", objid: "divResult.cboNTLVL"} 	//중요도
   ];
   gfnGetSapCommonCode(oComcodeSetList);
   
   //그리드contextMenu
   gfnSetGridContextMenu(divResult.grdList);
   gfnSetGridContextMenu(divResult.grdList02);
}

/**
* 설명: 공통코드처리후 호출함수
* @param  없음
* @return 없음
* @memberOf ltsPca400
*/
function cfnCommonCodeCallBackSap()
{
   cfnInitForm();
}

/**
* 설명: 폼 초기화 함수(폼의 초기화: 검색영역, 그리드)
* @param  없음
* @return 없음
* @memberOf ltsPca400
*/
function cfnInitForm()  //초기화 버튼인듯
{
   var aParams = gfnGetScreenParams();
   
   if (!gfnIsNull(aParams))  //인자: 널 여부 체크 후 출력물 출력
   {
       if (!gfnIsNull(aParams[0].docno)){
           lvObjSend.SEQNO    = aParams[0].docno;
       }else{
           lvObjSend.SEQNO    = aParams[0];
       }	
   }
   
   if(!gfnIsNull(lvObjSend.SEQNO))
   {
       lvObjSend.Ptype = "R";
       cfnSearch();		
   }
   else
   {
       fnClear();	//화면내용 Clear
   }			
}

//=======================================================================================
// 3.공통 호출함수
//---------------------------------------------------------------------------------------
/**
* 설명: 전처리함수
* @param  없음
* @return 없음
* @memberOf ltsPca400
*/
function cfnBeforeTran(sTranId) //등록에서 공지내용 입력 후 저장 없이 조회탭으로 이동시. 변경사항은 지워짐.
{
   if(sTranId=="cfnSearch"){  //더블클릭 시
       if(gfnIsUpdateSap(dsNOTICELIST) || gfnIsUpdateSap(dsNOTICEAGLIST) || gfnIsUpdateSap(dsText01) || gfnIsUpdateSap(dsATTACH))
       {
           return gfnConfirm("QOS021");	//변경사항이 있습니다.\n그래도 조회하시겠습니까?
       }


   }else if(sTranId=="cfnSave"){
       //데이터 변경여부
       if(!gfnIsUpdateSap(dsNOTICELIST)&&!gfnIsUpdateSap(dsNOTICEAGLIST)&&!gfnIsUpdateSap(dsText01) && !gfnIsUpdateSap(dsATTACH)){
           gfnAlert("IOS012"); //변경된 내용이 없습니다.
           return false;
       }		
   }
}

/**
* 설명: 조회 메소드
* @param  없음
* @return 없음
* @memberOf ltsPca400
*/
function cfnSearch()  
{
   var sTranId			= "cfnSearch";
   var sInDS 			= "";
   var sOutDS 			= "dsNOTICELIST=T_NOTICELIST dsNOTICEAGLIST=T_NOTICEAGLIST dsText=T_NOTICETEXT dsATTACH=T_NOTICEATTACH";	
   var sContextPath 	= "/jco/JcoController/";
   var sServelet 		= "getJcoData.xp?FUNCTION_NAME=Z_LTS_IFS6280";
   var sSendData		= "";
       sSendData		+= "IV_SEQNO="+gfnWrapQuote(lvObjSend.SEQNO);
       sSendData		+= " IV_PTYPE="+gfnWrapQuote(lvObjSend.Ptype);
       
   var sCallBackFn		= "";

   gfnSapTranN(sTranId, sInDS, sOutDS, sContextPath, sServelet, sSendData, sCallBackFn);
}

/**
* 설명: 저장 함수
* @param  없음
* @return 없음
* @memberOf ltsPca400
*/
function cfnSave()
{
   //TODO : upload처리 전에 this.dsRollback (Dataset)을 초기화 
   //TODO : this.dsRollback.clearData();
    this.dsRollback.clearData();
   
   
   lvDsFileInfo 	= gfnGetUploadInfoDs();
   lvDsFileData	= gfnGetUploadDataDs();
   lvRowCnt 		= lvDsFileInfo.rowcount;

   if (lvRowCnt > 0)
   {
       fnProcUpload(0);	//파일업로드
   }else{
       fnSave();			//저장
   }  
   
}

/**
* 설명: 삭제 함수
* @param  없음
* @return 없음
* @memberOf ltsPca400
*/
function cfnDelete()
{
   // 해당내용 기술
}

/**
* 설명: 신규처리 함수
* @param  없음
* @return 없음
* @memberOf ltsPca400
*/
function cfnNew(obj:Button,  e:ClickEventInfo)
{
   fnClear();	//화면내용 Clear		
}


//=======================================================================================
// 4.CallBack 처리
// 프로그래밍에서 콜백함수란 객체가 나를 부를 때까지 내 할일을 하고 있는 것. 비동기 방식의 함수.
//---------------------------------------------------------------------------------------
/**
* 설명: CallBack 처리
* @param  sTranId
* @param  nErrorCode
* @param  sErrorMsg
* @return 없음
* @memberOf ltsPca400
*/
function cfnCallback(sTranId, nErrorCode, sErrorMsg) 
{
   if(gfnGetSvcRtn()[0] == "E" || nErrorCode == -9)	//TODO : 에러처리 gfnGetSvcRtn()[0] : 에러코드 ,gfnGetSvcRtn()[1] : 에러메시지
   {			
       if(sTranId == "cfnSave"){									
           gfnAlert(gfnGetSvcRtn()[1]);		
       
           //TODO : 저장TR 완료후에 callback함수에서 
           //TODO : 에러발생 : gfnRollbackProc(this.dsRollback, "callback함수명")  
           gfnRollbackProc(this.dsRollback, "fnUploadRollback")  
           
           return;
       }
   }
   else
   {	
       if(sTranId == "cfnSearch"){
           gfnSetAlertMsgUd("-1");	
           lvFileID = dsATTACH.getColumn(0,"FILEID");	//파일ID
       }else if(sTranId == "cfnSave"){
           //TODO : 저장TR 완료후에 callback함수에서 
           //TODO : 정상처리 : dsRollback clear처리
            this.dsRollback.clearData();

           
           //재조회를 위해 문서번호 저장
           lvObjSend.SEQNO = divResult.edtSEQNO.value;	
           
           lvObjSend.Ptype = "R"
           lvFileID = dsATTACH.getColumn(0,"FILEID");	//파일ID
           
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
* @memberOf ltsPca400
*/
function cfnBeforeGrid(objGrd, type, obj:Button,  e:ClickEventInfo)
{
   if (objGrd.name=="grdList02")
   {
       switch (type)
       {
           case "CLEARROW":	// 행초기화
               // 파일관련(info, data) 데이터 초기화
               gfnClearFileInfoSap();
               
               // 체크된 row를 대상으로 처리되며, 체크되어 있지 않은 경우 현재Row를 기준으로 처리???
               gfnClearRow(objGrd);		// 체크박스, 정렬, 엑셀다운로드 등의 기능이 있음.		
               return false;
               break;
               
           case "ADDROW":		// 행추가
               if(dsATTACH.rowcount >= 5){
                   gfnAlert("IOS087");	//문서 첨부는 5건이하만 가능합니다.
                   return false;
               }
               gfnGridRowAdd(dsATTACH);
               return false;
               break;
           
           case "INSERTROW":	// 행삽입
               // 내용기술(return true or false)
               break;
           
           case "DELROW":		// 행삭제
               // 내용기술(return true or false)
               
               // 체크박스에 선택된 건에 대해서 모두 처리해야함.
               for (var i=0, nRowCnt=dsATTACH.rowcount; i<nRowCnt; i++)
               {
                   var bChecked = dsATTACH.getColumn(i, "rChk");
                   if (bChecked)
                   {
                       /////////////////////////////////////////////////////////////////////////////////////////////
                       // seq : 등록등으로 발생하는 sequence, seqno : 조회된 seq데이터
                       /////////////////////////////////////////////////////////////////////////////////////////////
                   
                       // 파일관리 테이블 데이터 삭제처리
                       // 조회된 데이터의 경우 >> _seq : 컬럼미설정, FNAME & DOKNR : 컬럼설정
                       // 수정된 데이터의 경우 >> _seq, FNAME : 컬럼설정, DOKNR : 컬럼미설정
                       
                       // 수정하려면 dataset의 FILEID 값을 가지고 처리
                       var sFileId  = dsATTACH.getColumn(i, "FILEID");
                       var nSeqNo 	= dsATTACH.getColumn(i, "SEQNO");
                       var nSeq 	= dsATTACH.getColumn(i, "_seq");
                       var sFileNm  = dsATTACH.getColumn(i, "FNAME");
                       var sDoknr 	= dsATTACH.getColumn(i, "DOKNR");
                       
                   gfnTrace("checked i=" + i + " , " + sFileId + " , " + nSeqNo + " , " + nSeq + " , " + sFileNm);
                       
                       // fileid의 경우 조회후의 값은 정의할수 있으나, 그후 변경된 부분은 정의할 수 없음.
                       if (nSeq)
                       {
                           nSeq = gfnDeleteFileSap({seq:nSeq}); // single인경우 0설정
                           dsATTACH.setColumn(i, "_seq", "");
                           dsATTACH.setColumn(i, "FNAME", "");
                       }
                       else
                       {
                           if (sFileId && nSeqNo && sDoknr)
                           {
                               var sDoknr = dsATTACH.getColumn(i, "DOKNR");
                               
                               var oFileInfo = {seq:nSeq,fileid:sFileId,seqno:nSeqNo,doknr:sDoknr};
                               nSeq = gfnDeleteFileSap(oFileInfo); // single인경우 0설정(등록되는 경우)								
                           }							
                       }
                   }
               }
               return true;
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
* @memberOf ltsPca400
*/
function cfnBeforeClose() 
{
   if(gfnIsUpdateSap(dsNOTICELIST) || gfnIsUpdateSap(dsNOTICEAGLIST) || gfnIsUpdateSap(dsText01) || gfnIsUpdateSap(dsATTACH))
   
   {
       return false;
   }
   return true;

}

//=======================================================================================
// 6.사용자 정의함수
//---------------------------------------------------------------------------------------

//=======================================================================================
// 7.이벤트처리 
//---------------------------------------------------------------------------------------

/**
* 설명: 전체선택
* @param  obj:Grid
* @param  e:GridClickEventInfo
* @return 없음
* @memberOf ltsPca400
*/
function grdList_onheadclick(obj:Grid, e:GridClickEventInfo)
{
   if(e.cell==0)
   {
       gfnSetGridCheckAll(obj, e);
   }
}

/**
* 설명: 데이터셋 Row상태 관리(상태값을 위해서 항상 넣어준다.)
* @param  Dataset
* @param  DSColChangeEventInfo
* @return 없음
* @memberOf ltsPca400
*/
function dsNOTICELIST_oncolumnchanged(obj:Dataset, e:DSColChangeEventInfo)
{
   gfnDatasetOnColChangedSap(obj, e);
}

/**
* 설명: 데이터셋 Row상태 관리(상태값을 위해서 항상 넣어준다.)
* @param  Dataset
* @param  DSColChangeEventInfo
* @return 없음
* @memberOf ltsPca400
*/
function dsNOTICEAGLIST_oncolumnchanged(obj:Dataset, e:DSColChangeEventInfo)
{
   gfnDatasetOnColChangedSap(obj, e);
}

/**
* 설명: 데이터셋 Row상태 관리(상태값을 위해서 항상 넣어준다.)
* @param  Dataset
* @param  DSColChangeEventInfo
* @return 없음
* @memberOf ltsPca400
*/
function dsText_oncolumnchanged(obj:Dataset, e:DSColChangeEventInfo)
{
   gfnDatasetOnColChangedSap(obj, e);
}

/**
* 설명: 데이터셋 Row상태 관리(상태값을 위해서 항상 넣어준다.)
* @param  Dataset
* @param  DSColChangeEventInfo
* @return 없음
* @memberOf ltsPca400
*/

function dsAttach_oncolumnchanged(obj:Dataset, e:DSColChangeEventInfo)
{
    var nSeq = obj.getColumn(e.row, "_seq");
   // DESCRIPTION 저장 안된 row는 여기서 저장
   if (obj.getRowType(e.row) == 2 && !gfnIsEmpty(nSeq))
   {
       gfnUpdateFileDescSap({seq:nSeq,desc:obj.getColumn(e.row, "DESCRIPTION")});
       // 필요하면 DESCRIPTION 입력란을 막아준다.
   }

   gfnDatasetOnColChangedSap(obj, e);
}

function divResult_grdList_onheadclick(obj:Grid, e:GridClickEventInfo)
{
   if(e.cell==0)
   {
       gfnSetGridCheckAll(obj, e);		
   }else{
       ///gfnGridSort함수는 gfnSetGridContextMenu함수와 같이 사용불가 둘중 하나만 사용가능
       gfnGridSort(obj, e);	
   }
}

/**
* 설명: 파일업로드
* @param  Grid
* @param  GridMouseEventInfo
* @return 없음
* @memberOf ltsPca400
*/
function divResult_grdList02_onexpandup(obj:Grid, e:GridMouseEventInfo)
{
   // 파일 첨부처리
   var oVirtualFile = gfnOpenDialogSap();
   if (oVirtualFile)
   {
       // 등록여부 확인용
       var sFileNm 	= oVirtualFile.filename;
       var sOrgFileNm 	= gfnTrim(dsATTACH.getColumn(e.row, "FNAME"));
       if (sOrgFileNm && (sFileNm != sOrgFileNm))
       {
           return gfnAlert("IOS173");	//파일은 수정은 불가능하며, 추가/삭제만 가능합니다.
       }
       
       dsATTACH.setColumn(e.row, "FNAME", sFileNm);
       var sFileId  = gfnTrim(dsATTACH.getColumn(e.row, "FILEID"));  //파일아이디 // 공백제거, 널체크, 구분자제거 기능.
       var nSeq 	= gfnTrim(dsATTACH.getColumn(e.row, "_seq"));
       var nSeqNo 	= gfnTrim(dsATTACH.getColumn(e.row, "SEQNO"));	 //문서번호	
       var sDoknr 	= gfnTrim(dsATTACH.getColumn(e.row, "DOKNR"));
       var sDesc	= gfnTrim(dsATTACH.getColumn(e.row, "DESCRIPTION"));
       // 수정에 대한 처리제외
       if (sFileId)
       {
           nSeq = gfnUpdateFileSap(oVirtualFile, {seq:nSeq,fileid:sFileId,seqno:nSeqNo,doknr:sDoknr,desc:sDesc});			
       }
       else
       {
           nSeq = gfnAddFileSap(oVirtualFile, {seq:nSeq,desc:sDesc});										
       }
       
       
       dsATTACH.setColumn(e.row, "_seq", nSeq);
   }		
}

/**
* 설명: 파일다운로드
* @param  Grid
* @param  GridClickEventInfo
* @return 없음
* @memberOf ltsPca400
*/
function divResult_grdList02_oncelldblclick(obj:Grid, e:GridClickEventInfo)
{
   if (e.cell >= 0)
   {
       // 파일ID를 가지고 doknr를 찾는함수
       var sBindText = gfnTrim(obj.getCellProperty("body", e.cell, "text"))
       if (sBindText.indexOf("bind:") == 0)
       {
           sBindText = sBindText.slice(5);
           if (sBindText == "FNAME")
           {
               var sDocnr = gfnGetDoknr(dsATTACH, {fileid:"DOKNR",row:e.row});
               var sFName = gfnGetFName(dsATTACH, {fileid:"FNAME",row:e.row});
               gfnFileDownloadSap({doknr:sDocnr,fname:sFName});
           }
       }
   }			
} 

/**
* 설명: 파일업로드 처리
* @param  nRow
* @return 없음
* @memberOf ltsPca400
*/
function fnProcUpload(nRow)
{
   lvDsFileInfo._seq = "";
   lvDsFileInfo.filter("");
   lvDsFileData.filter("");
   
    var sFildId = gfnTrim(lvDsFileInfo.getColumn(nRow, "fileid")); 	
    var rSeq 	= gfnTrim(lvDsFileInfo.getColumn(nRow, "rSeq"));
   
   if (rSeq)
   {
       var sFilter = "rSeq=='" + rSeq + "'";
       if (sFildId)
       {
           sFilter += " && fileid=='" + sFildId + "'";
       }
       
       lvDsFileInfo._seq = rSeq;
       lvDsFileInfo.filter(sFilter);
       lvDsFileData.filter(sFilter);
       
       lvDsFileInfo.setColumn(0,"fileid", lvFileID);	//FILEID 셋팅

       gfnFileProcSap("fnUploadCallback"); // <- filter initialize
   }
   else
   {
       gfnTrace("파일저장Dataset의 정보[rSeq]를 확인하세요. " + lvDsFileInfo.saveCSV());
   }
   
   lvCurCnt++;
}


/**
* 설명: 파일업로드 콜백
* @param  sTranId
* @param  nErrorCode
* @param  sErrorMsg
* @return 없음
* @memberOf ltsPca400
*/
function fnUploadCallback(sTranId, nErrorCode, sErrorMsg)
{
   gfnSetAlertMsgUd(-1);

   // 업로드후 리턴된정보 반환함수
   var oReturn 	= gfnGetRecvInfoSap();
   var oDsFileInfo = oReturn.fileinfo; 	// 파일정보dataset
   var oDsResult 	= oReturn.result;		// 결과dataset
   var sResult 	= oDsResult.getColumn(0, "mtype");
   

   if(lvCurCnt == 1){
       lvFileID = oDsFileInfo.getColumn(0,"fileid");	//파일ID		
   }		
   
   if (sResult == "S")
   {
       var sFildId = oDsFileInfo.getColumn(0, "fileid");
       var rSeq 	= lvDsFileInfo._seq;
       if (rSeq)
       {
           //TODO: upload후 callback에서 반환된 fileinfo(Dataset)의 row를 rollback(Dataset)에 copy처리
           //TODO: this.dsRollback.appendData(oDsFileInfo) // Rollback용 Data생성
           this.dsRollback.appendData(oDsFileInfo)
           
           // rSeq값으로 그리드를 tracking
           if (lvCurCnt <= lvRowCnt-1)
           {				
               fnProcUpload(lvCurCnt);
           }
           else
           {				 				
                dsNOTICELIST.setColumn(0, "FILEID", sFildId);
               var sDelFlag = false;	//파일첨부 전체삭제플래그
               for(var i=0;i<dsATTACH.rowcount;i++){
                   if(dsATTACH.getColumn(i, "rStatus") != "D"){
                       sDelFlag = true;
                   }
               }
               
               if(sDelFlag == false){		
                   dsNOTICELIST.setColumn(0, "FILEID", "");	//메인데이터셋 FILEID 초기화
               } 				
                
                gfnClearFileInfoSap();		// Dataset초기화
               lvCurCnt = 0;													
                fnSave();					//저장
           }
       }
   }
   else
   {
       lvCurCnt = 0;											//파일Cnt초기화
       //TODO: upload함수 callback함수의 반환값이 "S"가아닌경우 rollback함수 호출
       //TODO: gfnRollbackProc(this.dsRollback, "callback함수명");
       gfnRollbackProc(this.dsRollback, "fnUploadRollback");
       
       gfnAlert(oDsResult.getColumn(0, "message"));
   }
}



/**
* 설명: 저장 함수
* @param  없음
* @return 없음
* @memberOf ltsPca400
*/
function fnSave(){
   if(gfnIsNull(dsNOTICELIST.getColumn(0, "VALDT"))){
       dsNOTICELIST.setColumn(0, "VALDT", "99991231")
   }

   var sTranId			= "cfnSave";
   var sInDS 			= "T_NOTICELIST=dsNOTICELIST T_NOTICEAGLIST=dsNOTICEAGLIST:U T_NOTICETEXT=dsText:U";
   var sOutDS 			= "dsNOTICELIST=T_NOTICELIST dsNOTICEAGLIST=T_NOTICEAGLIST dsText=T_NOTICETEXT dsATTACH=T_NOTICEATTACH";	
   var sContextPath 	= "/jco/JcoController/";
   var sServelet 		= "getJcoData.xp?FUNCTION_NAME=Z_LTS_IFS6280";
   var sSendData		= "";
   var sSapType;
   
   //수정일경우
   if(lvObjSend.Ptype == "R"){ //ZTEXT
       sSapType = "U";
       sSendData		+= "IV_SEQNO="+divResult.edtSEQNO.value;
       
   
   //신규일경우
   }else if(lvObjSend.Ptype == "C"){
       sSapType = "C";
   
   }
   
   sSendData		+= " IV_PTYPE="+sSapType;
   var sCallBackFn		= "";

   gfnSapTranN(sTranId, sInDS, sOutDS, sContextPath, sServelet, sSendData, sCallBackFn,true, false);	//파일업로드exception 처리시 true, flase 옵션추가로 에러메시지 표시
}

/**
* 설명: 재조회처리(init함수호출)
* @param  없음
* @return 없음
* @memberOf ltsPca400
*/
function fnRefresh(){
   cfnInitForm();
}

function divResult_divGita_grdList04_ontextchange(obj:Grid, e:GridEditTextChangeEventInfo)
{
   if (e.col == 5)
   {
       if (e.posttext.length > 40)
       {
           gfnAlert("IOS048");	//40글자까지 입력 가능합니다.
       }
   }
}

/**
* 설명: 화면 내용 Clear
* @param  없음
* @return 없음
* @memberOf ltsPca400
*/
function fnClear(){
   gfnClearFileInfoSap();  // 파일전송Dataset 초기화처리
   lvFileID = "";		   // 파일ID초기화
   lvObjSend.Ptype = "C";
   dsNOTICELIST.clearData();
   dsATTACH.clearData();
   dsNOTICEAGLIST.clearData();
   dsText.clearData();
   dsText01.clearData();
   
   gfnGridRowAdd(dsNOTICELIST);
   gfnGridRowAdd(dsText01);
   
   
   dsText.applyChange();
   dsText01.applyChange();
   dsNOTICELIST.applyChange();	
           
   divResult.cboNTCLS.value = "";
   divResult.cboNTLVL.value = "";
}


/**
* 설명: 고객리스트 팝업호출
* @param strArgument
* @return Dataset
* @memberOf ltsPca400
*/
function divResult_grdList_onexpanddown(obj:Grid, e:GridMouseEventInfo)
{
   if (e.cell == 3)
   {           	
       var objSend        = {};
       objSend.id         = "admin";
       
       objSend.custname    = gfnIsNullBlank("");     // 고객사
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

       if(retVal != null) 
       {
           if (retVal.dsCostomerList.rowcount > 0)
           {
               dsNOTICEAGLIST.setColumn(e.row, "KUNAG",    retVal.dsCostomerList.getColumn(0,"KUNNR"));
               dsNOTICEAGLIST.setColumn(e.row, "KUNAG_NM", retVal.dsCostomerList.getColumn(0,"KUNNR_NM"));
               dsNOTICEAGLIST.setColumn(e.row, "ORT01",    retVal.dsCostomerList.getColumn(0,"ORT01"));
               dsNOTICEAGLIST.setColumn(e.row, "STRAS", 	retVal.dsCostomerList.getColumn(0,"STRAS"));
               dsNOTICEAGLIST.setColumn(e.row, "REPRE_NM", retVal.dsCostomerList.getColumn(0,"J_1KFREPRE"));
           }
       }
   }
}


//TODO: callback함수 만들기
//TODO: rollback callback함수 완료후 clear처리
//TODO: this.dsRollback.clearData();
//TODO: 메시지 안나타나게 하기 -> gfnSetAlertMsgUd("-1");

/**
* 설명: 파일업로드 exception
* @param  sTranId
* @param  nErrorCode
* @param  sErrorMsg
* @return 없음
* @memberOf ltsCa098
*/
function fnUploadRollback(){		
   this.dsRollback.clearData();	//rollback callback함수 완료후 clear처리
   gfnSetAlertMsgUd("-1"); //메시지안나타나게하기 
}

<%
/* =================================================================
 * 작성일 : 2018.07
 * 작성자 : 이정윤
 * 상세설명 : Cf-Deployment Network 정보 관리 화면
 * =================================================================
 */ 
%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>
<%@ taglib prefix="spring" uri = "http://www.springframework.org/tags" %>

<script type="text/javascript">
var text_required_msg = '<spring:message code="common.text.vaildate.required.message"/>';//을(를) 입력하세요.
var select_required_msg='<spring:message code="common.select.vaildate.required.message"/>';//을(를) 선택하세요.
var text_cidr_msg='<spring:message code="common.text.validate.cidr.message"/>';//CIDR 대역을 확인 하세요.
var text_ip_msg = '<spring:message code="common.text.validate.ip.message"/>';//IP을(를) 확인 하세요.
var networkConfigInfo = "";//네트워크 정보
var iaas = "";
var resourceLayout = {
        layout2: {
            name: 'layout2',
            padding: 4,
            panels: [
                { type: 'left', size: '65%', resizable: true, minSize: 300 },
                { type: 'main', minSize: 300 }
            ]
        },
        /********************************************************
         *  설명 : 네트워크 정보 목록 Grid
        *********************************************************/
        grid: {
            name: 'network_Grid',
            header: '<b>Network 정보</b>',
            method: 'GET',
                multiSelect: false,
            show: {
                    selectColumn: true,
                    footer: true},
            style: 'text-align: center',
            columns:[
                   { field: 'recid', hidden: true },
                   { field: 'id', hidden: true },
                   { field: 'networkName', caption: '네트워크 명', size:'150px', style:'text-align:center;' },
                   { field: 'iaasType', caption: '인프라 환경 타입', size:'150px', style:'text-align:center;' ,render: function(record){ 
                       if(record.iaasType.toLowerCase() == "aws"){
                           return "<img src='images/iaasMgnt/aws-icon.png' width='80' height='30' />";
                       }else if (record.iaasType.toLowerCase() == "openstack"){
                           return "<img src='images/iaasMgnt/openstack-icon.png' width='90' height='35' />";
                       }
                   }},
                   { field: 'publicStaticIp', caption: 'Public IP', size:'150px', style:'text-align:center;'},
                   { field: 'subnetId1', caption: '서브넷 ID', size:'150px', style:'text-align:center;'},
                   { field: 'securityGroup1', caption: '보안그룹', size:'150px', style:'text-align:center;'},
                   { field: 'subnetRange1', caption: '서브넷 주소 범위', size:'150px', style:'text-align:center;'},
                   { field: 'subnetGateway1', caption: '게이트웨이 ', size:'150px', style:'text-align:center;'},
                   { field: 'subnetDns1', caption: 'DNS', size:'150px', style:'text-align:center;'},
                   { field: 'subnetReservedFrom1', caption: '할당 제외 대역 시작점 IP', size:'150px', style:'text-align:center;'},
                   { field: 'subnetReservedTo1', caption: '~ 끝점 IP', size:'150px', style:'text-align:center;'},
                   { field: 'subnetStaticFrom1', caption: '할당 제외 대역 시작점 IP', size:'150px', style:'text-align:center;'},
                   { field: 'subnetStaticTo1', caption: '~ 끝점 IP', size:'150px', style:'text-align:center;'},
                   { field: 'subnetId2', caption: '서브넷 ID 2', size:'150px', style:'text-align:center;'},
                   { field: 'securityGroup2', caption: '보안그룹 2', size:'150px', style:'text-align:center;'},
                   { field: 'subnetRange2', caption: '서브넷 주소 범위 2', size:'150px', style:'text-align:center;'},
                   { field: 'subnetGateway2', caption: '게이트웨이 2 ', size:'150px', style:'text-align:center;'},
                   { field: 'subnetDns2', caption: 'DNS', size:'150px', style:'text-align:center;'},
                   { field: 'subnetReservedFrom2', caption: '할당 제외 대역 시작점 IP', size:'150px', style:'text-align:center;'},
                   { field: 'subnetReservedTo2', caption: '~ 끝점 IP', size:'150px', style:'text-align:center;'},
                   { field: 'subnetStaticFrom2', caption: '할당 제외 대역 시작점 IP', size:'150px', style:'text-align:center;'},
                   { field: 'subnetStaticTo2', caption: '~ 끝점 IP', size:'150px', style:'text-align:center;'}

                   ],
            onSelect : function(event) {
                event.onComplete = function() {
                    $('#deleteBtn').attr('disabled', false);
                    settingNetworkInfo();
                    return;
                }
            },
            onUnselect : function(event) {
                event.onComplete = function() {
                    resetForm();
                    $('#deleteBtn').attr('disabled', true);
                    return;
                }
            },onLoad:function(event){
                if(event.xhr.status == 403){
                    location.href = "/abuse";
                    event.preventDefault();
                }
            },onError : function(event) {
            },
        form: { 
            header: 'Edit Record',
            name: 'regPopupDiv',
            fields: [
                { name: 'recid', type: 'text', html: { caption: 'ID', attr: 'size="10" readonly' } },
                { name: 'fname', type: 'text', required: true, html: { caption: 'First Name', attr: 'size="40" maxlength="40"' } },
                { name: 'lname', type: 'text', required: true, html: { caption: 'Last Name', attr: 'size="40" maxlength="40"' } },
                { name: 'email', type: 'email', html: { caption: 'Email', attr: 'size="30"' } },
                { name: 'sdate', type: 'date', html: { caption: 'Date', attr: 'size="10"' } }
            ],
            actions: {
                Reset: function () {
                    this.clear();
                },
                Save: function () {
                    var errors = this.validate();
                    if (errors.length > 0) return;
                    if (this.recid == 0) {
                        w2ui.grid.add($.extend(true, { recid: w2ui.grid.records.length + 1 }, this.record));
                        w2ui.grid.selectNone();
                        this.clear();
                    } else {
                        w2ui.grid.set(this.recid, this.record);
                        w2ui.grid.selectNone();
                        this.clear();
                    }
                }
            }
        }
    }
}

$(function(){
    $('#network_Grid').w2layout(resourceLayout.layout2);
    w2ui.layout2.content('left', $().w2grid(resourceLayout.grid));
    w2ui['layout2'].content('main', $('#regPopupDiv').html());
    doSearch();
    
    $("#deleteBtn").click(function(){
        if($("#deleteBtn").attr('disabled') == "disabled") return;
        var selected = w2ui['network_Grid'].getSelection();
        if( selected.length == 0 ){
            w2alert("선택된 정보가 없습니다.", "네트워크  삭제");
            return;
        }
        else {
            var record = w2ui['network_Grid'].get(selected);
            w2confirm({
                title        : "네트워크 정보",
                msg            : "네트워크 정보 ("+record.networkName + ")을 삭제하시겠습니까?",
                yes_text    : "확인",
                no_text        : "취소",
                yes_callBack: function(event){
                    deleteHbCfDeploymentNetworkConfigInfo(record.recid, record.networkName);
                },
                no_callBack    : function(){
                    w2ui['network_Grid'].clear();
                    doSearch();
                }
            });
        }
    });
});




/********************************************************
 * 설명 : 네트워크  수정 정보 설정 
 * 기능 : settingNetworkInfo
 *********************************************************/
function settingNetworkInfo(){
    var selected = w2ui['network_Grid'].getSelection();
    var record = w2ui['network_Grid'].get(selected);
    if(record == null) {
        w2alert("네트워크 정보 설정 중 에러가 발생 했습니다.");
        return;
    }
    iaas = record.iaasType;
    $("input[name=networkInfoId]").val(record.recid);
    $("input[name=networkName]").val(record.networkName);
    $("select[name=iaasType]").val(record.iaasType);
    setNetworkInfo(record);
}

/********************************************************
 * 설명 : 인프라 환경에 따른 네트워크 정보 설정
 * 기능 : setNetworkInfo
 *********************************************************/
function setNetworkInfo(networkInfo){
    for(var i=0; i <networkInfo.length; i++){
        if( (networkInfo[i].net).toLowerCase() == "external" ){
                $(".w2ui-msg-body input[name='publicStaticIp']").val(networkInfo[i].publicStaticIp); 
        } else {
            if(networkInfo[i].seq  > 1)  settingNetwork(networkInfo[i].seq );
            var seq = networkInfo[i].seq;
            
            //기본 네트워크 정보
            $(".w2ui-msg-body input[name='subnetId_"+seq+"']").val(networkInfo[i].subnetId);
            $(".w2ui-msg-body input[name='securityGroup_"+seq+"']").val(networkInfo[i].securityGroup);
            $(".w2ui-msg-body input[name='subnetRange_"+seq+"']").val(networkInfo[i].subnetRange); 
            $(".w2ui-msg-body input[name='subnetGateway_"+seq+"']").val(networkInfo[i].subnetGateway);
            $(".w2ui-msg-body input[name='subnetDns_"+seq+"']").val(networkInfo[i].subnetDns);
            $(".w2ui-msg-body input[name='subnetReservedFrom_"+seq+"']").val(networkInfo[i].subnetReservedFrom);
            $(".w2ui-msg-body input[name='subnetReservedTo_"+seq+"']").val(networkInfo[i].subnetReservedTo);
            $(".w2ui-msg-body input[name='subnetStaticFrom_"+seq+"']").val(networkInfo[i].subnetStaticFrom);
            $(".w2ui-msg-body input[name='subnetStaticTo_"+seq+"']").val(networkInfo[i].subnetStaticTo);
            $(".w2ui-msg-body input[name='networkName_"+seq+"']").val(networkInfo[i].networkName);
            $(".w2ui-msg-body input[name='availabilityZone_"+seq+"']").val(networkInfo[i].availabilityZone);
        }
    }
}


/********************************************************
 * 설명 : 네트워크 정보 목록 조회
 * 기능 : doSearch
 *********************************************************/
function doSearch() {
    networkConfigInfo="";//네트워크 정보
    iaas = "";
    resetForm();
    
    w2ui['network_Grid'].clear();
    w2ui['network_Grid'].load('/deploy/hbCfDeployment/networkConfig/list');
    doButtonStyle(); 
}

/********************************************************
 * 설명 : 초기 버튼 스타일
 * 기능 : doButtonStyle
 *********************************************************/
function doButtonStyle() {
    $('#deleteBtn').attr('disabled', true);
}

/********************************************************
 * 설명 : 네트워크 정보 등록
 * 기능 : registHbCfDeploymentNetworkConfigInfo
 *********************************************************/
function registHbCfDeploymentNetworkConfigInfo(){
    w2popup.lock("등록 중입니다.", true);
    networkConfigInfo = {
            id                     : $("input[name=networkInfoId]").val(),
            iaasType               : $("select[name=iaasType]").val(),
            networkName            : $("input[name=networkName]").val(),
            publicStaticIp         : $("input[name=publicStaticIp]").val(),
            subnetId1               : $("input[name=subnetId1]").val(),
            securityGroup1          : $("input[name=securityGroup1]").val(),
            subnetRange1            : $("input[name=subnetRange1").val(),
            subnetGateway1          : $("input[name=subnetGateway1]").val(),
            subnetDns1              : $("input[name=subnetDns1]").val(),
            subnetReservedFrom1     : $("input[name=subnetReservedFrom1]").val(),
            subnetReservedTo1       : $("input[name=subnetReservedTo1]").val(),
            subnetStaticFrom1     : $("input[name=subnetStaticFrom1]").val(),
            subnetStaticTo1       : $("input[name=subnetStaticTo1]").val(),
            subnetId2               : $("input[name=subnetId2]").val(),
            securityGroup2          : $("input[name=securityGroup2]").val(),
            subnetRange2            : $("input[name=subnetRange2").val(),
            subnetGateway2          : $("input[name=subnetGateway2]").val(),
            subnetDns2              : $("input[name=subnetDns2]").val(),
            subnetReservedFrom2     : $("input[name=subnetReservedFrom2]").val(),
            subnetReservedTo2       : $("input[name=subnetReservedTo2]").val(),
            subnetStaticFrom2     : $("input[name=subnetStaticFrom2]").val(),
            subnetStaticTo2       : $("input[name=subnetStaticTo2]").val(),
    }
    
    $.ajax({
        type : "PUT",
        url : "/deploy/hbCfDeployment/networkConfig/save",
        contentType : "application/json",
        async : true,
        data : JSON.stringify(networkConfigInfo),
        success : function(data, status) {
            doSearch();
        },
        error : function( e, status ) {
            w2popup.unlock();
            var errorResult = JSON.parse(e.responseText);
            w2alert(errorResult.message, "네트워크 정보 저장");
        }
    });
}

/********************************************************
 * 설명 : 네트워크 정보 삭제
 * 기능 : deleteHbCfDeploymentNetworkConfigInfo
 *********************************************************/
function deleteHbCfDeploymentNetworkConfigInfo(id, networkName){
    w2popup.lock("삭제 중입니다.", true);
    networkInfo = {
        id : id,
        networkName : networkName
    }
    $.ajax({
        type : "DELETE",
        url : "/deploy/hbCfDeployment/networkConfig/delete",
        contentType : "application/json",
        async : true,
        data : JSON.stringify(networkInfo),
        success : function(status) {
            w2popup.unlock();
            w2popup.close();
            doSearch();
        }, error : function(request, status, error) {
            w2popup.unlock();
            w2popup.close();
            var errorResult = JSON.parse(request.responseText);
            w2alert(errorResult.message);
        }
    });
}


/********************************************************
 * 설명 : 네트워크 화면 설정
 * 기능 : settingNetwork
 *********************************************************/
 function settingNetwork( index ){
     if( iaas.toLowerCase() == 'aws' || iaas.toLowerCase() == "openstack" ){
         addInternalNetworkInputs('#defaultNetworkInfoDiv_1', "#defaultNetworkInfoForm" );
     }
 }
 
 /********************************************************
  * 설명 : 네트워크 입력 추가
  * 기능 : addInternalNetworkInputs
  *********************************************************/
  function addInternalNetworkInputs(preDiv, form){
     w2popup.lock("Internal 네트워크 추가 중", true);

     $(""+preDiv+ " div div a.btn.btn-info.btn-sm.addInternal").hide();
     
     var index = Number(preDiv.split("_")[1])+1;
     var div= preDiv.split("_")[0] + "_"+ index;
     var body_div= "<div class='panel-body'>";
     var field_div_label="<div class='w2ui-field'>"+"<label style='text-align: left; width: 36%; font-size: 11px;'>";
     var text_style="type='text' style='display:inline-blcok; width:70%;'";
     var html= "<div class='panel' style='margin-top:2%;'>";
         html+= "<div  style='position:relative; margin-left:15px; margin-top:10px;'>";
         html+=    "<b>Internal 네트워크</b>";
         html+=    "<div style='position: absolute;right: 10px; top: 2px;'>";
         html+=        '<span class="btn btn-info btn-sm" onclick="delInternalNetwork(\''+preDiv+'\', '+index+');">삭제</span>';
         html+=    "</div>";
         html+= "</div>";
         html+= body_div;
             html+= field_div_label + "서브넷 아이디" + "</label>"; 
             html+="<div style=' width: 60%;'>"+"<input name='subnetId_"+index+"'" + text_style +" placeholder='서브넷 아이디를 입력하세요.'/>"+"</div></div>";
             
             html+= field_div_label + "보안 그룹" + "</label>"; 
             html+= "<div style=' width: 60%;'>"+"<input name='securityGroup_"+index+"'" + text_style +" placeholder='예) bosh-security, cf-security'/>"+"</div></div>";
             
             
             if( iaas.toLowerCase() == "aws" ){
                 html+= field_div_label + "가용 영역" + "</label>"; 
                 html+= "<div style=' width: 60%;'>"+"<input name='availabilityZone_"+index+"'" + text_style +" placeholder='예) us-west-2'/>"+"</div></div>";
             }
         html+= field_div_label + "서브넷 범위" + "</label>"; 
         html+= "<div style=' width: 60%;'>"+"<input name='subnetRange_"+index+"'" + text_style +" placeholder='예) 10.0.0.0/24'/>" + "</div></div>";
         
         html+= field_div_label + "게이트웨이" + "</label>"; 
         html+= "<div style=' width: 60%;'>"+ "<input name='subnetGateway_"+index+"'" + text_style +" placeholder='예) 10.0.0.1'/>" + "</div></div>";
         
         html+= field_div_label + "DNS" + "</label>"; 
         html+= "<div style=' width: 60%;'>"+ "<input name='subnetDns_"+index+"'" + text_style +" placeholder='예) 8.8.8.8'/>" + "</div></div>";
        
         html+= field_div_label + "IP할당 제외 대역" + "</label>"; 
         html+=     "<div style=' width: 60%;'>";
         html+=         "<input name='subnetReservedFrom_"+index+"' type='text' style='display:inline-block; width:32%;' placeholder='예) 10.0.0.10' />";
         html+=         "<span style='width: 4%; text-align: center;'>&nbsp;&ndash; &nbsp;</span>";
         html+=         "<input name='subnetReservedTo_"+index+"' type='text' style='display:inline-block; width:32%;' placeholder='예) 10.0.0.20' />";
         html+=     "</div></div>";
         
         html+= field_div_label + "IP할당 대역(최소 20개)" + "</label>"; 
         html+=     "<div style=' width: 60%;'>"+"<input name='subnetStaticFrom_"+index+"' type='text' style='display:inline-block; width:32%;' placeholder='예) 10.0.0.10' />";
         html+=         "<span style='width: 4%; text-align: center;'>&nbsp;&ndash; &nbsp;</span>";
         html+=         "<input name='subnetStaticTo_"+index+"' type='text' style='display:inline-block; width:32%;' placeholder='예) 10.0.0.20'/>";
         html+=     "</div>";
         html+= "</div></div></div>";
         $(".w2ui-msg-body "+ div).show();
         $(form + " "+ div).css('display','block');
         $(form + " "+ div).html(html);
         
         createInternalNetworkValidate(index);
 }
  /********************************************************
   * 설명 : 네트워크 유효성 추가
   * 기능 : createInternalNetworkValidate
   *********************************************************/
  function createInternalNetworkValidate(index){
     var subnet_message = "서브넷 아이디";
     var zone_message = "가용 영역";
     $("[name*='subnetId_"+index+"']").rules("add", {
         required: function(){
             return checkEmpty($(".w2ui-msg-body input[name='subnetId_"+index+"']").val());
         }, messages: {required: subnet_message+text_required_msg}
     });
     $("[name*='subnetRange_"+index+"']").rules("add", {
         required: function(){
             return checkEmpty($(".w2ui-msg-body input[name='subnetRange_"+index+"']").val());
         },ipv4Range : function(){
             return $(".w2ui-msg-body input[name='subnetRange_"+index+"']").val();  
         }, messages: {required: "서브넷 범위"+text_required_msg}
     });
     
     $("[name*='subnetGateway_"+index+"']").rules("add", {
         required: function(){
             return checkEmpty($(".w2ui-msg-body input[name='subnetGateway_"+index+"']").val());
         },ipv4: function(){
             return $(".w2ui-msg-body input[name='subnetGateway_"+index+"']").val();  
         }, messages: {required: "게이트웨이"+text_required_msg}
     });
     
     $("[name*='subnetDns_"+index+"']").rules("add", {
         required: function(){
             return checkEmpty($(".w2ui-msg-body input[name='subnetDns_"+index+"']").val());
         },ipv4: function(){
              if( index > 0 ){
                 var list = [];
                 for(i=0; i< index; i++){
                	 
                 list =+ $(".w2ui-msg-body input[name='subnetDns_"+index+"']").val();
                 }
                 var flag = true;
                 for( var i=0; i<list.length; i++ ){
                     var val = validateIpv4(list[i]);
                     if( !val ) flag = false;
                 }
                 if( !flag ) return "";
                 else return list[0];
             }else{
                 return $(".w2ui-msg-body input[name='subnetDns_"+index+"']").val();
             } 
         }, messages: {required: "DNS"+text_required_msg}
     });
     
     $("[name*='subnetReservedFrom_"+index+"']").rules("add", {
         required: function(){
             return checkEmpty($(".w2ui-msg-body input[name='subnetReservedFrom_"+index+"']").val());
         },ipv4: function(){
             return $(".w2ui-msg-body input[name='subnetReservedFrom_"+index+"']").val();  
         }, messages: {required: "IP 할당 제외 대역"+text_required_msg}
     });
     
     $("[name*='subnetReservedTo_"+index+"']").rules("add", {
         required: function(){
             return checkEmpty($(".w2ui-msg-body input[name='subnetReservedTo_"+index+"']").val());
         },ipv4: function(){
             return $(".w2ui-msg-body input[name='subnetReservedTo_"+index+"']").val();  
         }, messages: {required: "IP 할당 제외 대역"+text_required_msg}
     });
     
      $("[name*='subnetStaticFrom_"+index+"']").rules("add", {
         required: function(){
             return checkEmpty($(".w2ui-msg-body input[name='subnetStaticFrom_"+index+"']").val());
         },ipv4: function(){
             return $(".w2ui-msg-body input[name='subnetStaticFrom_"+index+"']").val();  
         }, messages: {required: "IP 할당 대역"+text_required_msg}
     }); 
     
      $("[name*='subnetStaticTo_"+index+"']").rules("add", {
         required: function(){
             return checkEmpty($(".w2ui-msg-body input[name='subnetStaticTo_"+index+"']").val());
         },ipv4: function(){
             return $(".w2ui-msg-body input[name='subnetStaticTo_"+index+"']").val();  
         }, messages: {required: "IP 할당 대역"+text_required_msg}
     }); 
     if( iaas.toLowerCase() == 'aws' || iaas.toLowerCase() == 'google' ){
         $("[name*='availabilityZone_"+index+"']").rules("add", {
             required: function(){
                 return checkEmpty($(".w2ui-msg-body input[name='availabilityZone_"+index+"']").val());
             }, messages: {required: zone_message + text_required_msg}
         });
     }

     w2popup.unlock();
 }

 /********************************************************
  * 설명 : ipv4 유효성 체크
  * 기능 : validateIpv4
  *********************************************************/
 function validateIpv4(params){
     return /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test(params);
 }

/********************************************************
 * 설명 : 화면 리사이즈시 호출
 *********************************************************/
$( window ).resize(function() {
    setLayoutContainerHeight();
});

/********************************************************
 * 설명 : Lock 팝업 메세지 Function
 * 기능 : lock
 *********************************************************/
function lock (msg) {
    w2popup.lock(msg, true);
}
/********************************************************
 * 설명 : 다른 페이지 이동 시 호출 Function
 * 기능 : clearMainPage
 *********************************************************/
function clearMainPage() {
    $().w2destroy('layout2');
    $().w2destroy('network_Grid');
}
/********************************************************
 * 설명 : 네트워크 정보 리셋
 * 기능 : resetForm
 *********************************************************/
function resetForm(status){
    $(".panel-body").find("p").remove();
    $(".panel-body").children().children().children().css("borderColor", "#bbb");
    $("input[name=networkName]").val("");
    $("select[name=iaasType]").val("");
    $("select[name=publicStaticIp]").val("");
    $("input[name=subnetId_1]").val("");
    $("input[name=securityGroup_1]").val("");
    $("input[name=subnetRange_1]").val("");
    $("input[name=subnetGateway_1]").val("");
    $("input[name=subnetDns_1]").val("");
    $("input[name=subnetReservedFrom_1]").val("");
    $("input[name=subnetReservedTo_1]").val("");
    $("input[name=subnetStaticFrom_1]").val("");
    $("input[name=subnetStaticTo_1]").val("");
    $("input[name=availabilityZone_1]").val("");
    $("input[name=subnetId_2]").val("");
    $("input[name=securityGroup_2]").val("");
    $("input[name=subnetRange_2]").val("");
    $("input[name=subnetGateway_2]").val("");
    $("input[name=subnetDns_2]").val("");
    $("input[name=subnetReservedFrom_2]").val("");
    $("input[name=subnetReservedTo_2]").val("");
    $("input[name=subnetStaticFrom_2]").val("");
    $("input[name=subnetStaticTo_2]").val("");
    $("input[name=availabilityZone_2]").val("");
    
    if(status=="reset"){
        w2ui['network_Grid'].clear();
        //$("select[name='']").html("<option value=''>CF Deployment 버전을 선택하세요.</option>");
        doSearch();
    }
    document.getElementById("defaultNetworkInfoForm").reset();
}

/********************************************************
 * 설명 : 네트워크 입력 삭제
 * 기능 : delNetwork
 *********************************************************/
function delInternalNetwork(preDiv, index){
     var div= preDiv.split("_")[0] + "_"+ index;
     var form = preDiv.split("Div")[0]+"Form";
     $(form + " "+ div).html("");
     $(""+preDiv+ " div div a.btn.btn-info.btn-sm.addInternal").css("display","block");
}

</script>

<div id="main">
    <div class="page_site">이종 CF Deployment > <strong>Network 정보 관리</strong></div>
    <!-- 사용자 목록-->
    <div class="pdt20">
        <div class="title fl"> 네트워크 정보 목록</div>
    </div>
    <div id="network_Grid" style="width:100%;  height:700px;"></div>
</div>

<div id="regPopupDiv" hidden="true" >
    <form id="defaultNetworkInfoForm" action="POST">
 <input type="hidden" name="networkInfoId" />
    
        <div class="w2ui-page page-0" style="">
           <div class=" panel-network">
               <div class="panel-heading"><b>네트워크 정보</b></div>
                <div class="panel-body" >
                <div class="panel">    
                <div style="margin-left:15px; margin-top:10px;"><b>네트워크 기본 설정 </b></div>
                  <div class="panel-body">
                    <div class="w2ui-field">
                       <label style="text-align: left;width:36%;font-size:11px;">클라우드 인프라 환경 </label> 
                       <div>
                           <select class="form-control" name="iaasType" style="width: 100%; font-size: 12px !important; height: 28px !important;">
                               <option value="">인프라 환경을 선택하세요.</option>
                               <option value="aws">AWS</option>
                               <option value="openstack">Openstack</option>
                           </select>
                       </div>
                    </div>
                    <div class="w2ui-field">
                        <label style="text-align: left;width:36%;font-size:11px;">Network 별칭</label> 
                        <div style=" width: 60%;">
                            <input name="networkName" type="text" style="display:inline-blcok; width:70%;" placeholder="예) net 1"/>
                        </div>
                    </div> 
                  </div>
                </div>
                </div>
			</div>
		</div>
        <div class="w2ui-page page-0" style="margin-top:15px;padding:0 3%;">
            <div class="panel" style="margin-bottom:10px;">    
                <div  style="margin-left:15px; margin-top:10px;"><b>External 네트워크</b></div>
                <div class="panel-body">
                    <div class="w2ui-field">
                        <label style="text-align: left;width:36%;font-size:11px;">CF API TARGET IP</label> 
                        <div style=" width: 60%;">
                            <input name="publicStaticIp" type="text" style="display:inline-blcok; width:70%;" placeholder="예) 10.0.0.20"/>
                        </div>
                    </div>
                </div>
            </div>
            <div class="panel" id="defaultNetworkInfoDiv_1">
                <div style="position:relative; margin-left:15px; margin-top:10px;">
                    <b>Internal 네트워크</b>
                    <div style="position: absolute;right: 10px;top: 5px;">
                        <a class="btn btn-info btn-sm addInternal" onclick="addInternalNetworkInputs('#defaultNetworkInfoDiv_1', '#defaultNetworkInfoForm');">추가</a>
                    </div>
                </div>
                <div class="panel-body">
                    <div class="w2ui-field">
                        <label style="text-align: left;width:36%;font-size:11px;">서브넷 아이디</label>
                        <div style=" width: 60%;">
                            <input name="subnetId1" type="text"  style="display:inline-blcok; width:70%;" placeholder="서브넷 아이디를 입력하세요."/>
                        </div>
                    </div>
                    <div class="w2ui-field">
                        <label style="text-align: left;width:36%;font-size:11px;">보안 그룹</label>
                        <div style=" width: 60%;">
                            <input name="securityGroup1" type="text"  style="display:inline-blcok; width:70%;" placeholder="예) bosh-security, cf-security"/>
                        </div>
                    </div>
                    <div class="w2ui-field" hidden="true" id="availabilityZoneDiv">
                        <label style="text-align: left;width:36%;font-size:11px;">가용 영역</label>
                        <div style=" width: 60%;">
                            <input name="availabilityZone1" type="text"  style="display:inline-blcok; width:70%;" placeholder="예) us-west-2"/>
                        </div>
                    </div>
                    <div class="w2ui-field">
                        <label style="text-align: left;width:36%;font-size:11px;">서브넷 범위</label>
                        <div style=" width: 60%;">
                            <input name="subnetRange1" type="text"  style="display:inline-blcok; width:70%;" placeholder="예) 10.0.0.0/24"/>
                        </div>
                    </div>
                    <div class="w2ui-field">
                        <label style="text-align: left;width:36%;font-size:11px;">게이트웨이</label>
                        <div style=" width: 60%;">
                            <input name="subnetGateway1" type="text"  style="display:inline-blcok; width:70%;" placeholder="예) 10.0.0.1"/>
                        </div>
                    </div>
                    <div class="w2ui-field">
                        <label style="text-align: left;width:36%;font-size:11px;">DNS</label>
                        <div style=" width: 60%;">
                            <input name="subnetDns1" type="text"  style="display:inline-blcok; width:70%;" placeholder="예) 8.8.8.8"/>
                        </div>
                    </div>
                    <div class="w2ui-field">
                        <label style="text-align: left; width: 36%; font-size: 11px;">IP할당 제외 대역</label>
                        <div style=" width: 60%;">
                            <input name="subnetReservedFrom1" type="text" style="display:inline-block; width:32%;" placeholder="예) 10.0.0.100" />
                            <span style="width: 4%; text-align: center;">&nbsp;&ndash; &nbsp;</span>
                            <input name="subnetReservedTo1"  type="text" style="display:inline-block; width:32%;" placeholder="예) 10.0.0.106" />
                        </div>
                    </div>
                    <div class="w2ui-field">
                        <label style="text-align: left; width: 36%; font-size: 11px;">IP할당 대역(최소 20개)</label>
                        <div style=" width: 60%;">
                            <input name="subnetStaticFrom1"  type="text" style="display:inline-block; width:32%;" placeholder="예) 10.0.0.100" />
                            <span style="width: 4%; text-align: center;">&nbsp;&ndash; &nbsp;</span>
                            <input name="subnetStaticTo1" type="text" style="display:iinline-block; width:32%;" placeholder="예) 10.0.0.106" />
                        </div>
                    </div>
                </div>
            </div>
            <div  id="defaultNetworkInfoDiv_2" hidden="true"></div>
            <div  id="defaultNetworkInfoDiv_3" hidden="true"></div>
        </div>
    </form>
    <div id="regPopupBtnDiv" style="text-align: center; margin-top: 5px;">
        <span id="installBtn" onclick="$('#defaultNetworkInfoForm').submit();" class="btn btn-primary">등록</span>
        <span id="resetBtn" onclick="resetForm('reset');" class="btn btn-info">취소</span>
        <span id="deleteBtn" class="btn btn-danger">삭제</span>
    </div>
</div>

<script>
$(function() {
    $.validator.addMethod( "ipv4", function( value, element, params ) {
        return /^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$/.test(params);
    }, text_ip_msg );
    
    $.validator.addMethod( "ipv4Range", function( value, element, params ) {
        return /^((\b|\.)(0|1|2(?!5(?=6|7|8|9)|6|7|8|9))?\d{1,2}){4}(-((\b|\.)(0|1|2(?!5(?=6|7|8|9)|6|7|8|9))?\d{1,2}){4}|\/((0|1|2|3(?=1|2))\d|\d))\b$/.test(params);
    }, text_cidr_msg );
    
    $("#defaultNetworkInfoForm").validate({
        ignore : [],
        //onfocusout: function(element) {$(element).valid()},
        rules: {
            networkName: { 
                required: function(){
                    return checkEmpty( $("input[name='networkName']").val() );
                }
            }, iaasType: { 
                required: function(){
                    return checkEmpty( $("select[name='iaasType']").val() );
                }
            }, publicStaticIp: { 
                required: function(){
                    return checkEmpty( $("input[name='publicStaticIp']").val() );
                }, 
                ipv4 : function(){
                    return $("input[name='publicStaticIp']").val();
                }
            }, subnetId1: { 
                required: function(){
                    return checkEmpty( $("input[name='subnetId1']").val() );
                }
            }, securityGroup1: { 
                required: function(){
                    return checkEmpty( $("input[name='securityGroup1']").val() );
                }
            }, subnetRange1: { 
                required: function(){
                    return checkEmpty( $("input[name='subnetRange1']").val() );
                }, 
                ipv4Range : function(){
                    return $("input[name='subnetRange1']").val();
                }
            }, subnetGateway1: { 
                required: function(){
                    return checkEmpty( $("input[name='subnetGateway1']").val() );
                }
            }, subnetDns: { 
                required: function(){
                    return checkEmpty( $("input[name='subnetDns1']").val() );
                },
                ipv4 : function(){
                    return $("input[name='subnetDns1']").val();
                }
            }, subnetReservedFrom1: { 
                required: function(){
                    return checkEmpty( $("input[name='subnetReservedFrom1']").val() );
                }, 
                ipv4 : function(){
                    return $("input[name='subnetReservedFrom1']").val();
                }
            }, subnetReservedTo1: { 
                required: function(){
                    return checkEmpty( $("input[name='subnetReservedTo1']").val() );
                }, 
                ipv4 : function(){
                    return $("input[name='subnetReservedTo1']").val();
                }
            }, subnetStaticFrom1: { 
                required: function(){
                    return checkEmpty( $("input[name='subnetStaticFrom_1']").val() );
                }, 
                ipv4 : function(){
                    return $("input[name='subnetStaticFrom_1']").val();
                }
            }, subnetStaticTo1: { 
                required: function(){
                    return checkEmpty( $("input[name='subnetStaticTo1']").val() );
                }, 
                ipv4 : function(){
                    return $("input[name='subnetStaticTo1']").val();
                }
            }
        }, messages: {
               networkName: { 
                required:  "네트워크  별칭"+text_required_msg,
            }, iaasType: { 
                required:  "클라우드 인프라 환경 타입"+select_required_msg,
            }, publicStaticIp: { 
                ipv4 : text_ip_msg,
            }, subnetId1: { 
                required:  "서브넷 아이디 "+text_required_msg,
            }, securityGroup1: { 
                required:  "보안 그룹 "+text_required_msg,
            }, subnetRange1: { 
                required:  "서브넷 주소 범위 "+text_required_msg,
                ipv4Range : text_cidr_msg
            }, subnetGateway1: { 
                required:  "게이트웨이 "+text_required_msg,
            }, subnetDns1: { 
                required:  "DNS "+text_required_msg,
                ipv4 : text_ip_msg
            }, subnetReservedFrom1: { 
                required:  "IP 할당 제외 대역"+text_required_msg,
                ipv4 : text_ip_msg
            }, subnetReservedTo1: { 
                required:  "IP 할당 제외 대역 "+text_required_msg,
                ipv4 : text_ip_msg
            }, subnetStaticFrom1: { 
                required:  "IP 할당 대역"+text_required_msg,
                ipv4 : text_ip_msg
            }, subnetStaticTo1: { 
                required:  "IP 할당 대역 "+text_required_msg,
                ipv4 : text_ip_msg
            }
        }, unhighlight: function(element) {
            setHybridSuccessStyle(element);
        },errorPlacement: function(error, element) {
            //do nothing
        }, invalidHandler: function(event, validator) {
            var errors = validator.numberOfInvalids();
            if (errors) {
                setHybridInvalidHandlerStyle(errors, validator);
            }
        }, submitHandler: function (form) {
            registHbCfDeploymentNetworkConfigInfo();
        }
    });
});


</script>
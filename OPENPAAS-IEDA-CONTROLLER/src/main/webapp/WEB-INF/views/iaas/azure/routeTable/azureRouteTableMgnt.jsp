<%
/* =================================================================
 * 작성일 : 2018.06.16
 * 상세설명 : Azure Route Table 관리 화면
 * =================================================================
 */ 
%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags"%>
<%@ taglib prefix = "spring" uri = "http://www.springframework.org/tags" %>

<script>
var save_lock_msg = '<spring:message code="common.save.data.lock"/>';//등록 중 입니다.
var detail_rg_lock_msg='<spring:message code="common.search.detaildata.lock"/>';//상세 조회 중 입니다.
var text_required_msg='<spring:message code="common.text.vaildate.required.message"/>';//을(를) 입력하세요.
var select_required_msg='<spring:message code="common.select.vaildate.required.message"/>';//을(를) 선택하세요.
var delete_confirm_msg ='<spring:message code="common.popup.delete.message"/>';//삭제 하시겠습니까?
var delete_lock_msg= '<spring:message code="common.delete.data.lock"/>';//삭제 중 입니다.
var accountId ="";
var bDefaultAccount = "";

$(function() {
    
    bDefaultAccount = setDefaultIaasAccountList("azure");
    
    $('#azure_routeTableGrid').w2grid({
        name: 'azure_routeTableGrid',
        method: 'GET',
        msgAJAXerror : 'Azure 계정을 확인해주세요.',
        header: '<b>Virtual Route Table 목록</b>',
        multiSelect: false,
        show: {    
                selectColumn: true,
                footer: true},
        style: 'text-align: center',
        columns    : [
                     {field: 'recid',     caption: 'recid', hidden: true}
                   , {field: 'accountId',     caption: 'accountId', hidden: true}
                   , {field: 'routeTableId',     caption: 'RouteTableId', hidden: true}
                   , {field: 'routeTableName', caption: 'RouteTable Name', size: '50%', style: 'text-align:center', render : function(record){
                       if(record.routeTableName == null || record.routeTableName == ""){
                           return "-"
                       }else{
                           return record.routeTableName;
                       }}
                   }
                   , {field: 'resourceGroupName', caption: 'Resource Group', size: '50%', style: 'text-align:center'}
                   , {field: 'location', caption: 'Location', size: '50%', style: 'text-align:center'}
                   , {field: 'subscriptionName', caption: 'Subscription', size: '50%', style: 'text-align:center'}
                   , {field: 'azureSubscriptionId', caption: 'Subscription ID', size: '50%', style: 'text-align:center'}
                   , {field: 'associations', caption: 'Associations', size: '50%', style: 'text-align:center'}
                   ],
        onSelect: function(event) {
            event.onComplete = function() {
                $('#deleteBtn').attr('disabled', false);
                $('#addSubnetBtn').attr('disabled', false);
                var accountId =  w2ui.azure_routeTableGrid.get(event.recid).accountId;
                var routeTableName = w2ui.azure_routeTableGrid.get(event.recid).routeTableName;
                doSearchRouteTableSubnetsInfo(accountId, routeTableName); 
            }
        },
        onUnselect: function(event) {
            event.onComplete = function() {
                $('#deleteBtn').attr('disabled', true);
                $('#addSubnetBtn').attr('disabled', true);
                w2ui['azure_rtSubnetsGrid'].clear();
            }
        },
           onLoad:function(event){
            if(event.xhr.status == 403){
                location.href = "/abuse";
                event.preventDefault();
            }
        }, onError:function(evnet){
        }
    });
    
    $('#azure_rtSubnetsGrid').w2grid({
        name: 'azure_rtSubnetsGrid',
        method: 'GET',
        msgAJAXerror : 'Azure 계정을 확인해주세요.',
        header: '<b>Route Table의 Subnets 목록</b>',
        multiSelect: false,
        show: {    
                selectColumn: false,
                footer: true},
        style: 'text-align: center',
        columns    : [
                     {field: 'recid',     caption: 'recid', hidden: true}
                   , {field: 'routeTableName',     caption: 'routeTableName',  size: '50%', style: 'text-align:center'}
                   , {field: 'subnetName', caption: 'Subnet Name', size: '50%', style: 'text-align:center'}
                   , {field: 'subnetAddressRange', caption: 'Subnet Address Range', size: '50%', style: 'text-align:center'}
                   , {field: 'networkName', caption: 'Virtural Network Name', size: '50%', style: 'text-align:center'}
                   , {field: 'securityGroupName', caption: 'Security Group', size: '50%', style: 'text-align:center'}
                   ],
        onSelect: function(event) {
            event.onComplete = function() {
                $('#deleteSubnetBtn').attr('disabled', false);
            }
        },
        onUnselect: function(event) {
            event.onComplete = function() {
                $('#deleteSubnetBtn').attr('disabled', true);
            }
        },
           onLoad:function(event){
            if(event.xhr.status == 403){
                location.href = "/abuse";
                event.preventDefault();
            }
        }, onError:function(evnet){
        }
    });
    
    /********************************************************
     * 설명 : Azure Route Table  생성 버튼 클릭
    *********************************************************/
    $("#addBtn").click(function(){
       if($("#addBtn").attr('disabled') == "disabled") return;
       w2popup.open({
           title   : "<b>Azure Route Table  생성</b>",
           width   : 580,
           height  : 350,
           modal   : true,
           body    : $("#registPopupDiv").html(),
           buttons : $("#registPopupBtnDiv").html(),
           onOpen  : function () {
        	   w2popup.lock(detail_rg_lock_msg, true);
               setAzureSubscription();
               setAzureResourceGroupList();
               w2popup.unlock();
           },
           onClose : function(event){
            w2popup.unlock();
            accountId = $("select[name='accountId']").val();
            w2ui['azure_routeTableGrid'].clear();
            w2ui['azure_rtSubnetsGrid'].clear();
            doSearch();
           }
       });
    });
    
    /********************************************************
    * 설명 : Azure Route Table 삭제 버튼 클릭
   *********************************************************/
    $("#deleteBtn").click(function(){
        if($("#deleteBtn").attr('disabled') == "disabled") return;
        var selected = w2ui['azure_routeTableGrid'].getSelection();        
        if( selected.length == 0 ){
            w2alert("선택된 정보가 없습니다.", "Route Table  삭제");
            return;
        }
        else {
            var record = w2ui['azure_routeTableGrid'].get(selected);
            w2confirm({
                title   : "<b>Route Table  삭제</b>",
                msg     : "Route Table  (" + record.routeTableName +") 를<br/>"
                                       +"<strong><font color='red'> 삭제 하시 겠습니까?</strong><red>"   ,
                yes_text : "확인",
                no_text : "취소",
                height : 250,
                yes_callBack: function(event){
                    w2utils.lock($("#layout_layout_panel_main"), delete_lock_msg, true);
                    deleteAzureRouteTableInfo(record);
                },
                no_callBack    : function(){
                    w2ui['azure_routeTableGrid'].clear();
                    w2ui['azure_rtSubnetsGrid'].clear();
                    accountId = record.accountId;
                    doSearch();
                }
            });
        }
    });
    
    /********************************************************
     * 설명 : Azure Route Table Subnet 연결 버튼 클릭
    *********************************************************/
    $("#addSubnetBtn").click(function(){
         if($("#addSubnetBtn").attr('disabled') == "disabled") return;
        
       w2popup.open({
           title   : "<b>Azure Route Table Subnet 연결</b>",
           width   : 580,
           height  : 300,
           modal   : true,
           body    : $("#addSubnetPopupDiv").html(),
           buttons : $("#addSubnetPopupBtnDiv").html(),
           onOpen  : function () {
               setAzureNetworkNameList();
           },
           onClose : function(event){
            accountId = $("select[name='accountId']").val();
            w2ui['azure_routeTableGrid'].clear();
            w2ui['azure_rtSubnetsGrid'].clear();
            w2popup.unlock();
            doSearch();
           }
       });
    });
    
    /********************************************************
     * 설명 : Azure Route Table Subnet 연결 해제 버튼 클릭
    *********************************************************/
     $("#deleteSubnetBtn").click(function(){
         if($("#deleteSubnetBtn").attr('disabled') == "disabled") return;
         var selected = w2ui['azure_rtSubnetsGrid'].getSelection();        
         if( selected.length == 0 ){
             w2alert("선택된 정보가 없습니다.", "Subnet 연결 해제");
             return;
         }
         else {
             var record = w2ui['azure_rtSubnetsGrid'].get(selected);
             w2confirm({
                 title   : "<b>Azure Route Table Subnet 연결 해제</b>",
                 msg     : "Route Table Subnet (" + record.subnetName +") 연결을<br/>"
                                        +"<strong><font color='red'> 해제 하시 겠습니까?</strong><red>"   ,
                 yes_text : "확인",
                 no_text : "취소",
                 height : 250,
                 yes_callBack: function(event){
                     w2utils.lock($("#layout_layout_panel_main"), '', true);
                     deleteSubnet(record);
                 },
                 no_callBack    : function(){
                     w2ui['azure_routeTableGrid'].clear();
                     w2ui['azure_rtSubnetsGrid'].clear();
                     accountId = record.accountId;
                     doSearch();
                 }
             });
         }
     });
    
});

/********************************************************
 * 설명 : Azure Route Table  정보 목록 조회 Function 
 * 기능 : doSearch
 *********************************************************/
function doSearch() {
    w2ui['azure_routeTableGrid'].load("<c:url value='/azureMgnt/routeTable/list/'/>"+accountId);
    doButtonStyle();
    accountId = "";
}

/********************************************************
 * 설명 : 해당 Azure RouteTable에 대한 Subnets List 조회 Function 
 * 기능 : doSearchRouteTableSubnetsInfo
 *********************************************************/
function doSearchRouteTableSubnetsInfo(accountId, routeTableName){
    w2utils.lock($("#layout_layout_panel_main"), detail_rg_lock_msg, true);
    w2ui['azure_rtSubnetsGrid'].load("<c:url value='/azureMgnt/routeTable/list/subnets/'/>"+accountId+"/"+routeTableName);
    w2utils.unlock($("#layout_layout_panel_main"));
}

/********************************************************
 * 설명 : Azure RouteTable 생성
 * 기능 : saveAzureRouteTableInfo
 *********************************************************/
function saveAzureRouteTableInfo(){
    w2popup.lock(save_lock_msg, true);
    var rgInfo = {
        accountId : $("select[name='accountId']").val(),
        routeTableName : $(".w2ui-msg-body input[name='routeTableName']").val(),
        resourceGroupName : $(".w2ui-msg-body select[name='resourceGroupName'] :selected").text(),
        location : $(".w2ui-msg-body select[name='resourceGroupName'] :selected").val(),    
        azureSubscriptionId : $(".w2ui-msg-body input[name='azureSubscriptionId']").val(),
    }
    
    $.ajax({
        type : "POST",
        url : "/azureMgnt/routeTable/save",
        contentType : "application/json",
        async : true,
        data : JSON.stringify(rgInfo),
        success : function(status) {
            w2popup.unlock();
            accountId = rgInfo.accountId;
            w2ui['azure_routeTableGrid'].clear();
            w2ui['azure_rtSubnetsGrid'].clear();
            doSearch();
            w2popup.close();
        }, error : function(request, status, error) {
            w2popup.unlock();
            var errorResult = JSON.parse(request.responseText);
            w2alert(errorResult.message);
        }
    });
}

/********************************************************
 * 설명 : Azure Route Table  Subnet 연결
 * 기능 : addNewSubnet
 *********************************************************/
function addNewSubnet(){
    w2popup.lock(save_lock_msg, true);
    var selected = w2ui['azure_routeTableGrid'].getSelection();
    var record = w2ui['azure_routeTableGrid'].get(selected);
    var rgInfo = {
        accountId : $("select[name='accountId']").val(),
        resourceGroupName : record.resourceGroupName,
        routeTableName : record.routeTableName,
        location : record.location,
        networkName : $(".w2ui-msg-body #addSubnetForm select[name='networkName'] :selected").val(),
        subnetName : $(".w2ui-msg-body #addSubnetForm select[name='subnetName'] :selected").val(),
        securityGroup : $(".w2ui-msg-body #addSubnetForm select[name='securityGroup'] :selected").val(),
}
    $.ajax({
        type : "POST",
        url : "/azureMgnt/routeTable/subnet/save",
        contentType : "application/json",
        async : true,
        data : JSON.stringify(rgInfo),
        success : function(status) {
            w2popup.unlock();
            w2popup.close();
            accountId = rgInfo.accountId;
            doSearch();
        }, error : function(request, status, error) {
            w2popup.unlock();
            var errorResult = JSON.parse(request.responseText);
            w2alert(errorResult.message);
        }
    });
}



/********************************************************
 * 기능 : setAzureResourceGroupList
 * 설명 : 해당 Supscription 에 대한  Azure 리소스 그룹 목록 조회 기능
 *********************************************************/
 function setAzureResourceGroupList(){
	 w2popup.lock('', true);
     accountId = $("select[name='accountId']").val();
     $.ajax({
            type : "GET",
            url : '/azureMgnt/resourceGroup/list/groupInfo/'+accountId,
            contentType : "application/json",
            dataType : "json",
            success : function(data, status) {
                var result = "";
                if(data.total != 0){
                            result = "<option value=''>리소스 그룹을 선택하세요.</option>";
                  for(var i=0; i<data.total; i++){
                    if(data.records != null){
                            result += "<option value='" +data.records[i].location + "' >";
                            result += data.records[i].resourceGroupName;
                            result += "</option>";
                    }
                  }
                }else{
                    result = "<option value=''>리소스 그룹이 존재 하지 않습니다.</option>"
                }
                $("#resourceGroupInfoDiv #resourceGroupInfo").html(result);
                w2popup.unlock();
            },
            error : function(request, status, error) {
                w2popup.unlock();
                var errorResult = JSON.parse(request.responseText);
                w2alert(errorResult.message);
            }
        });
 }
 
 /********************************************************
  * 기능 : setAzureNetworkNameList
  * 설명 : 해당 ResourceGroup 에 대한  Azure NetworkName 목록 조회 기능
  *********************************************************/
  function setAzureNetworkNameList(){
 	 w2popup.lock('', true);
      var accountId = $("select[name='accountId']").val();
      var selected = w2ui['azure_routeTableGrid'].getSelection();  
      var record = w2ui['azure_routeTableGrid'].get(selected);
      var resourceGroupName = record.resourceGroupName;
     
      $.ajax({
             type : "GET",
             url : '/azureMgnt/routeTable/list/networkName/'+accountId+"/"+ resourceGroupName,
             contentType : "application/json",
             dataType : "json",
             success : function(data, status) {
                 var result = "";
                 if(data.length != 0){
                             result = "<option value=''>Network를 선택하세요.</option>";
                   for(var i=0; i<data.length; i++){
                     if(data[i] != null){
                             result += "<option value='" +data[i].toString() + "' >";
                             result += data[i].toString();
                             result += "</option>";
                     }
                   }
                 }else{
                     result = "<option value=''>Network가 존재 하지 않습니다.</option>"
                 }
                 $("#networkNameInfoDiv #networkNameInfo").html(result);
                 w2popup.unlock();
             },
             error : function(request, status, error) {
                 w2popup.unlock();
                 var errorResult = JSON.parse(request.responseText);
                 w2alert(errorResult.message);
             }
         });
  }
 
  /********************************************************
   * 기능 : setAzureSubnetNameList
   * 설명 : 해당 NetworkName 에 대한 Route Table에 연결 가능 한 Azure SubnetName 목록 조회 기능
   *********************************************************/
   function setAzureSubnetNameList(networkName){
  	 w2popup.lock('', true);
       var accountId = $("select[name='accountId']").val();
       var selected = w2ui['azure_routeTableGrid'].getSelection();  
       var record = w2ui['azure_routeTableGrid'].get(selected);
       var resourceGroupName = record.resourceGroupName;
      
       $.ajax({
              type : "GET",
              url : '/azureMgnt/routeTable/list/subnetName/'+accountId+"/"+ resourceGroupName+"/"+ networkName,
              contentType : "application/json",
              dataType : "json",
              success : function(data, status) {
                  var result = "";
                	  if(data.length != 0){
                                   result = "<option value=''>Subnet를 선택하세요.</option>";
                         for(var i=0; i<data.length; i++){
                           if(data[i] != null){
                                   result += "<option value='" +data[i].toString() + "' >";
                                   result += data[i].toString();
                                   result += "</option>";
                           }
                         }
                       }else{
                           result = "<option value=''>연결 가능 한 Subnet이 없습니다.</option>"
                       }
                  $("#subnetNameInfoDiv #subnetNameInfo").html(result);
                  w2popup.unlock();
              },
              error : function(request, status, error) {
                  w2popup.unlock();
                  var errorResult = JSON.parse(request.responseText);
                  w2alert(errorResult.message);
              }
          });
   }

/********************************************************
 * 기능 : setAzureSecurityGroupList
 * 설명 : 해당 NetworkName 에 대한 Route Table에 연결 가능 한 Azure SecurityGroup 목록 조회 기능
 *********************************************************/
function setAzureSecurityGroupList(networkName){
    w2popup.lock('', true);
    var accountId = $("select[name='accountId']").val();
    var selected = w2ui['azure_routeTableGrid'].getSelection();
    var record = w2ui['azure_routeTableGrid'].get(selected);
    var resourceGroupName = record.resourceGroupName;

    $.ajax({
        type : "GET",
        url : '/azureMgnt/securityGroup/list/'+accountId+'/resourceGroup/'+resourceGroupName,
        contentType : "application/json",
        dataType : "json",
        success : function(data, status) {
            var result = "";
            if(data.length != 0){
                result = "<option value=''>SecurityGroup을 선택하세요.</option>";
                for(var i=0; i<data.length; i++){
                    if(data[i] != null){
                        result += "<option value='" +data[i].toString() + "' >";
                        result += data[i].toString();
                        result += "</option>";
                    }
                }
            }else{
                result = "<option value=''>선택 가능 한 SecurityGroup이 없습니다.</option>"
            }
            $("#securityGroupInfoDiv #securityGroupInfo").html(result);
            w2popup.unlock();
        },
        error : function(request, status, error) {
            w2popup.unlock();
            var errorResult = JSON.parse(request.responseText);
            w2alert(errorResult.message);
        }
    });
}


/********************************************************
 * 기능 : setAzureSubscription
 * 설명 : Azure Subscription 정보 조회 기능
 *********************************************************/
function setAzureSubscription(){
	 w2popup.lock('', true);
    accountId = $("select[name='accountId']").val();
    $.ajax({
           type : "GET",
           url : '/azureMgnt/network/list/subscriptionInfo/'+accountId, //common  으로 변경
           contentType : "application/json",
           dataType : "json",
           success : function(data, status) {
               var result = "";
               if(data != null){
                           result  += "<input name='azureSubscriptionId' style='display: none;' value='"+data.azureSubscriptionId+"' />";
                           result  += "<input name='' style='width: 300px;' value='"+data.subscriptionName+"' disabled/>";
               }
               $('#subscriptionInfoDiv #subscriptionInfo').html(result);
               w2popup.unlock();
           },
           error : function(request, status, error) {
               w2popup.unlock();
               var errorResult = JSON.parse(request.responseText);
               w2alert(errorResult.message);
           }
       });
} 

/********************************************************
 * 설명 : Azure ResourceGroup Onchange 이벤트 기능
 * 기능 : azureResourceGroupOnchange
 *********************************************************/
 function azureResourceGroupOnchange(slectedvalue){
    accountId = $("select[name='accountId']").val();
    $('#locationInfoDiv #locationInfo').html(slectedvalue);
    $('#locationInfoDiv #locationVal').html(slectedvalue);
 }
 
 /********************************************************
  * 설명 : Azure azureNetworkName Onchange 이벤트 기능
  * 기능 : azureNetworkNameOnchange
  *********************************************************/
  function azureNetworkNameOnchange(slectedvalue){
     accountId = $("select[name='accountId']").val();
     if(! slectedvalue == "" || ! slectedvalue == null){
         $('.w2ui-msg-body #subnetNameInfoField').css('display', 'block');
         $('.w2ui-msg-body #securityGroupInfoField').css('display', 'block');
         setAzureSubnetNameList(slectedvalue);
         setAzureSecurityGroupList(slectedvalue);
     }else{
         $('.w2ui-msg-body #subnetNameInfoField').css('display', 'none');
         $('.w2ui-msg-body #securityGroupInfoField').css('display', 'none');
     }
  }
 
 /********************************************************
  * 설명 : Azure RouteTable 삭제
  * 기능 :  deleteAzureRouteTableInfo
  *********************************************************/
 function  deleteAzureRouteTableInfo(record){
     w2popup.lock(delete_lock_msg, true);
     var rgInfo = {
             accountId : record.accountId,
             routeTableName : record.routeTableName,
             resourceGroupName : record.resourceGroupName
     }
     $.ajax({
         type : "DELETE",
         url : "/azureMgnt/routeTable/delete",
         contentType : "application/json",
         async : true,
         data : JSON.stringify(rgInfo),
         success : function(status) {
             accountId = rgInfo.accountId;
             w2ui['azure_routeTableGrid'].clear();
             w2ui['azure_rtSubnetsGrid'].clear();
             doSearch();
             w2utils.unlock($("#layout_layout_panel_main"));
         }, error : function(request, status, error) {
        	 w2utils.unlock($("#layout_layout_panel_main"));
             var errorResult = JSON.parse(request.responseText);
             w2alert(errorResult.message);
         }
     });
 }
 
 /********************************************************
  * 설명 : Azure RouteTable Subnet 연결 해제
  * 기능 : deleteSubnet
  *********************************************************/
 function  deleteSubnet(record){
     w2popup.lock('', true);
     var selectedrtable = w2ui['azure_routeTableGrid'].getSelection();
     var rtableRecord = w2ui['azure_routeTableGrid'].get(selectedrtable);
     var rgInfo = {
             accountId : rtableRecord.accountId,
             routeTableName : rtableRecord.routeTableName,
             resourceGroupName : rtableRecord.resourceGroupName,
             location : rtableRecord.location,
             subnetName : record.subnetName,
             networkName: record.networkName
     }
     $.ajax({
         type : "DELETE",
         url : "/azureMgnt/routeTable/subnet/delete",
         contentType : "application/json",
         async : true,
         data : JSON.stringify(rgInfo),
         success : function(status) {
             w2popup.unlock();
             w2utils.unlock($("#layout_layout_panel_main"));
             accountId = rgInfo.accountId;
             w2ui['azure_routeTableGrid'].clear();
             w2ui['azure_rtSubnetsGrid'].clear();
             w2popup.close();
             doSearch();
         }, error : function(request, status, error) {
             w2popup.unlock();
             var errorResult = JSON.parse(request.responseText);
             w2alert(errorResult.message);
         }
     });
 }
 
/********************************************************
 * 설명 : 초기 버튼 스타일
 * 기능 : doButtonStyle
 *********************************************************/
function doButtonStyle() {
    $('#deleteBtn').attr('disabled', true);
    $('#addSubnetBtn').attr('disabled', true);
    $('#deleteSubnetBtn').attr('disabled', true);
}

/****************************************************
 * 기능 : clearMainPage
 * 설명 : 다른페이지 이동시 호출
*****************************************************/
function clearMainPage() {
    $().w2destroy('azure_routeTableGrid');
    $().w2destroy('azure_rtSubnetsGrid');
}

/****************************************************
 * 기능 : resize
 * 설명 : 화면 리사이즈시 호출
*****************************************************/
$( window ).resize(function() {
  setLayoutContainerHeight();
});

</script>
<style>
.trTitle {
     background-color: #f3f6fa;
     width: 180px;
 }
td {
    width: 280px;
}
 
</style>
<div id="main">
     <div class="page_site pdt20">인프라 관리 > Azure 관리 > <strong>Azure Route Table 관리 </strong></div>
     <div id="azureMgnt" class="pdt20">
        <ul>
            <li>
                <label style="font-size: 14px;">Azure 관리 화면</label> &nbsp;&nbsp;&nbsp; 
                <div class="dropdown" style="display:inline-block;">
                    <a href="#" class="dropdown-toggle iaas-dropdown" data-toggle="dropdown" aria-expanded="false">
                        &nbsp;&nbsp;Route Table 관리<b class="caret"></b>
                    </a>
                    <ul class="dropdown-menu alert-dropdown">
                        <sec:authorize access="hasAuthority('AZURE_RESOURCE_GROUP_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/azureMgnt/resourceGroup"/>', 'Azure Resource Group');">Resource Group 관리</a></li>
                        </sec:authorize>
                        <sec:authorize access="hasAuthority('AZURE_NETWORK_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/azureMgnt/network"/>', 'Azure Virtual Network');">Virtual Network 관리</a></li>
                        </sec:authorize>                        
                        <sec:authorize access="hasAuthority('AZURE_STORAGE_ACCOUNT_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/azureMgnt/storageAccount"/>', 'Azure Storage Account');"> Storage Account 관리</a></li>
                        </sec:authorize>
                        <sec:authorize access="hasAuthority('AZURE_PUBLIC_IP_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/azureMgnt/publicIp"/>', 'Azure Public IP');">Public IP 관리</a></li>
                        </sec:authorize>
                         <sec:authorize access="hasAuthority('AZURE_STORAGE_ACCESS_KEY_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/azureMgnt/storageAccessKey"/>', 'Azure Key Pair');">Key Pair 관리</a></li>
                        </sec:authorize>
                        <sec:authorize access="hasAuthority('AZURE_SECURITY_GROUP_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/azureMgnt/securityGroup"/>', 'Azure Security Group');">Security Group 관리</a></li>
                        </sec:authorize>
                    </ul>
                </div>
            </li>
            
            <li>
                <label style="font-size: 14px">Azure 계정 명</label>
                &nbsp;&nbsp;&nbsp;
                <select name="accountId" id="setAccountList" class="select" style="width: 300px; font-size: 15px; height: 32px;" onchange="setAccountInfo(this.value, 'azure')">
                </select>
                <span id="doSearch" onclick="setDefaultIaasAccount('noPopup','azure');" class="btn btn-info" style="width:80px" >선택</span>
            </li>
        </ul>
    </div>
    
    <div class="pdt20">
        <div class="title fl">Azure Route Table 목록</div>
        <div class="fr"> 
        <sec:authorize access="hasAuthority('AZURE_ROUTE_TABLE_CREATE')">
            <span id="addBtn" class="btn btn-primary" style="width:120px">생성</span>
        </sec:authorize>
        <sec:authorize access="hasAuthority('AZURE_ROUTE_TABLE_DELETE')">
            <span id="deleteBtn" class="btn btn-danger" style="width:120px">삭제</span>
        </sec:authorize>
        </div>
    </div>
    
    <!-- RouteTable 정보 목록 그리드 -->
    <div id="azure_routeTableGrid" style="width:100%; height:305px"></div>

    <!-- RouteTable 생성 팝업 -->
    <div id="registPopupDiv" hidden="true">
        <form id="azureRouteTableForm" action="POST" style="padding:5px 0 5px 0;margin:0;">
            <div class="panel panel-info" style="height: 240px; margin-top: 7px;"> 
                <div class="panel-heading"><b>Azure RouteTable 생성 정보</b></div>
                <div class="panel-body" style="padding:20px 10px; height:220px; overflow-y:auto;">
                    <input type="hidden" name="accountId"/>
                    <div class="w2ui-field">
                        <label style="width:36%;text-align: left; padding-left: 20px;">RouteTable Name</label>
                        <div>
                            <input name="routeTableName" type="text"   maxlength="100" style="width: 300px; margin-top: 1px;" placeholder="RouteTable 명을 입력하세요."/>
                        </div>
                    </div>
                    <div class="w2ui-field">
                        <label style="width:36%;text-align: left; padding-left: 20px;">Resource Group</label>
                         <div id="resourceGroupInfoDiv">
                            <select id="resourceGroupInfo" name="resourceGroupName" onClick = "azureResourceGroupOnchange(this.value, 'selected')" class="select" style="width:300px; font-size: 15px; height: 32px;"></select>
                        </div>
                    </div>
                    <div class="w2ui-field">
                        <label style="width:36%;text-align: left; padding-left: 20px;">Location</label>
                         <div id="locationInfoDiv">
                         <div id="locationInfo" style="width:300px; font-size: 14px; height: 26px; border: 1px solid #ccc; border-radius:2px; padding-left:5px; line-height:26px; background-color: #eee; color:#777 !important;" >리소스 그룹의 리전 명</div>
                                <input id ="locationVal" name="location" hidden="true" readonly='readonly' style="width:300px; font-size: 15px; height: 32px;"/> 
                        </div>
                    </div>
                    <div class="w2ui-field">
                        <label style="width:36%;text-align: left; padding-left: 20px;">Subscription</label>
                        <div id="subscriptionInfoDiv">
                            <div id="subscriptionInfo"><input style="width:300px;" placeholder="Loading..."/></div>
                        </div>
                    </div>
                </div>
            </div>
        </form> 
    </div>
    
    <div id="registPopupBtnDiv" hidden="true">
         <button class="btn" id="registBtn" onclick="$('#azureRouteTableForm').submit();">확인</button>
         <button class="btn" id="popClose"  onclick="w2popup.close();">취소</button>
    </div>
    
    <div class="pdt20" >
        <div class="title fl">선택 한 Azure RouteTable에 대한 Subnets 정보 목록</div>
    </div>
    <div class="fr"> 
        <sec:authorize access="hasAuthority('AZURE_SUBNET_CREATE')">
            <span id="addSubnetBtn" class="btn btn-primary" style="width:120px">Subnet 연결 </span>
            </sec:authorize>
        <sec:authorize access="hasAuthority('AZURE_SUBNET_DELETE')">
            <span id="deleteSubnetBtn" class="btn btn-danger" style="width:120px">Subnet 해제 </span>
        </sec:authorize>
        </div>
    
    <div id="azure_rtSubnetsGrid" style="width:100%; min-height:200px; top:0px;"></div>
    
    <!-- RouteTable Subnet 연결 팝업 -->
    <div id="addSubnetPopupDiv" hidden="true">
        <form id="addSubnetForm" action="POST" style="padding:5px 0 5px 0;margin:0;">
            <div class="panel panel-info" style="height: 190px; margin-top: 7px;">
                <div class="panel-heading"><b>Azure Route Table Subnet 연결</b></div>
                <div class="panel-body" style="padding:20px 10px; height:170px; overflow-y:auto;">
                    <input type="hidden" name="accountId"/>
                    <div class="w2ui-field">
                            <label style="width:36%;text-align: left; padding-left: 20px;">Network</label>
                        <div id="networkNameInfoDiv">
                            <select id="networkNameInfo" name="networkName" onClick="azureNetworkNameOnchange(this.value, 'selected')" class="select" style="width:300px; font-size: 15px; height: 32px;"></select>
                        </div>
                    </div>
                    <div class="w2ui-field " id="subnetNameInfoField" style="display: none;">
                            <label style="width:36%;text-align: left; padding-left: 20px;">Subnet</label>
                        <div id="subnetNameInfoDiv">
                           <select id="subnetNameInfo" name="subnetName" class="select" style="width:300px; font-size: 15px; height: 32px;"></select>
                        </div>
                    </div>
                    <div class="w2ui-field " id="securityGroupInfoField" style="display: none;">
                        <label style="width:36%;text-align: left; padding-left: 20px;">SecurityGroup</label>
                        <div id="securityGroupInfoDiv">
                            <select id="securityGroupInfo" name="securityGroup" class="select" style="width:300px; font-size: 15px; height: 32px;"></select>
                        </div>
                    </div>
                    
                </div>
            </div>
        </form> 
    </div>
    
    <div id="addSubnetPopupBtnDiv" hidden="true">
         <button class="btn" id="registBtn" onclick="$('#addSubnetForm').submit();">확인</button>
         <button class="btn" id="popClose"  onclick="w2popup.close();">취소</button>
    </div>
    
</div>

<div id="registAccountPopupDiv"  hidden="true">
    <input name="codeIdx" type="hidden"/>
    <div class="panel panel-info" style="margin-top:5px;" >    
        <div class="panel-heading"><b>azure 계정 별칭 목록</b></div>
        <div class="panel-body" style="padding:5px 5% 10px 5%;height:65px;">
            <div class="w2ui-field">
                <label style="width:30%;text-align: left;padding-left: 20px; margin-top: 20px;">azure 계정 별칭</label>
                <div style="width: 70%;" class="accountList"></div>
            </div>
        </div>
    </div>
</div>

<div id="registAccountPopupBtnDiv" hidden="true">
    <button class="btn" id="registBtn" onclick="setDefaultIaasAccount('popup','azure');">확인</button>
    <button class="btn" id="popClose"  onclick="w2popup.close();">취소</button>
</div>

<script>
$(function() {
    
    $("#azureRouteTableForm").validate({
        ignore : "",
        onfocusout: true,
        rules: {
            routeTableName : {
                required : function(){
                    return checkEmpty( $(".w2ui-msg-body input[name='routeTableName']").val() );
                }
            }, 
            resourceGroupName: { 
                required: function(){
                    return checkEmpty( $(".w2ui-msg-body select[name='resourceGroupName']").val() );
                }
            }, 
        }, messages: {
            routeTableName: { 
                 required:  "Route Table Name" + text_required_msg
            }, 
            resourceGroupName: { 
                required:  "Resource Group Name "+ select_required_msg
                
            },
        }, unhighlight: function(element) {
            setSuccessStyle(element);
        },errorPlacement: function(error, element) {
            //do nothing
        }, invalidHandler: function(event, validator) {
            var errors = validator.numberOfInvalids();
            if (errors) {
                setInvalidHandlerStyle(errors, validator);
            }
        }, submitHandler: function (form) {
        	saveAzureRouteTableInfo();
        }
    });
    
    $("#addSubnetForm").validate({
        ignore : "",
        onfocusout: true,
        rules: {
            subnetName: {
                required: function(){
                    return checkEmpty( $(".w2ui-msg-body #addSubnetForm select[name='subnetName'] :selected").val() );
                }
            },
            securityGroup: {
                required: function(){
                    return checkEmpty( $(".w2ui-msg-body #addSubnetForm select[name='securityGroup'] :selected").val() );
                }
            },
        }, messages: {
            subnetName: {
                required:  "Subnet "+select_required_msg

            },
            securityGroup: {
                required:  "Security Group "+select_required_msg

            },
        }, unhighlight: function(element) {
            setSuccessStyle(element);
        },errorPlacement: function(error, element) {
            //do nothing
        }, invalidHandler: function(event, validator) {
            var errors = validator.numberOfInvalids();
            if (errors) {
                setInvalidHandlerStyle(errors, validator);
            }
        }, submitHandler: function (form) {
            addNewSubnet();
        }
    });
   
});

</script>
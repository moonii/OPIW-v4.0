<%
/* =================================================================
 * 작성일 : 2018.04.16
 * 작성자 : 이정윤 
 * 상세설명 : Azure Network 관리 화면
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
var delete_confirm_msg ='<spring:message code="common.popup.delete.message"/>';//삭제 하시겠습니까?
var delete_lock_msg= '<spring:message code="common.delete.data.lock"/>';//삭제 중 입니다.
var text_cidr_msg='<spring:message code="common.text.validate.cidr.message"/>';//CIDR 대역을 확인 하세요.
var accountId ="";
var bDefaultAccount = "";


$(function() {
    
    bDefaultAccount = setDefaultIaasAccountList("azure");
    
    $('#azure_vnetGrid').w2grid({
        name: 'azure_vnetGrid',
        method: 'GET',
        msgAJAXerror : 'Azure 계정을 확인해주세요.',
        header: '<b>Virtual Network 목록</b>',
        multiSelect: false,
        show: {    
                selectColumn: true,
                footer: true},
        style: 'text-align: center',
        columns    : [
                     {field: 'recid',     caption: 'recid', hidden: true}
                   , {field: 'accountId',     caption: 'accountId', hidden: true}
                   , {field: 'networkId',     caption: 'networkId', hidden: true}
                   , {field: 'networkName', caption: 'Network Name', size: '50%', style: 'text-align:center', render : function(record){
                       if(record.networkName == null || record.networkName == ""){
                           return "-"
                       }else{
                           return record.networkName;
                       }}
                   }
                   , {field: 'subscriptionName', caption: 'Subscription', size: '50%', style: 'text-align:center'}
                   , {field: 'azureSubscriptionId', caption: 'Subscription ID', size: '50%', style: 'text-align:center'}
                   , {field: 'resourceType', caption: 'Type', size: '50%', style: 'text-align:center'}
                   , {field: 'location', caption: 'Location', size: '50%', style: 'text-align:center'}
                   , {field: 'resourceGroupName', caption: 'Resource Group', size: '50%', style: 'text-align:center'}
                   //, {field: 'dnsServer', caption: 'DNS Servers', size: '50%', style: 'text-align:center'}
                   , {field: 'networkAddressSpaceCidr', caption: 'Address Space', size: '50%', style: 'text-align:center'}
                   ],
        onSelect: function(event) {
            event.onComplete = function() {
                $('#deleteBtn').attr('disabled', false);
                var accountId =  w2ui.azure_vnetGrid.get(event.recid).accountId;
                var networkName = w2ui.azure_vnetGrid.get(event.recid).networkName;
                var location = w2ui.azure_vnetGrid.get(event.recid).location;
                doSearchNetworkSubnetsInfo(accountId, networkName); 
            }
        },
        onUnselect: function(event) {
            event.onComplete = function() {
                $('#deleteBtn').attr('disabled', true);
                w2ui['azure_subnetsGrid'].clear();
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
    
    $('#azure_subnetsGrid').w2grid({
        name: 'azure_subnetsGrid',
        method: 'GET',
        msgAJAXerror : 'Azure 계정을 확인해주세요.',
        header: '<b>Virtual Network의 Subnets 목록</b>',
        multiSelect: false,
        show: {    
                selectColumn: false,
                footer: true},
        style: 'text-align: center',
        columns    : [
                     {field: 'recid',     caption: 'recid', hidden: true}
                   //, {field: 'accountId',     caption: 'accountId', hidden: true}
                   , {field: 'subnetName', caption: 'Subnet Name', size: '50%', style: 'text-align:center'}
                   , {field: 'subnetAddressRangeCidr', caption: 'Address Range', size: '50%', style: 'text-align:center'}
                   , {field: 'subnetAddressesCnt', caption: 'Available Addresses', size: '50%', style: 'text-align:center'}
                   , {field: 'securityGroupName', caption: 'Security Group', size: '50%', style: 'text-align:center'}
                   ],
        onSelect: function(event) {
            event.onComplete = function() {
            }
        },
        onUnselect: function(event) {
            event.onComplete = function() {
                
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
     * 설명 : Azure Network 생성 버튼 클릭
    *********************************************************/
    $("#addBtn").click(function(){
       if($("#addBtn").attr('disabled') == "disabled") return;
       w2popup.open({
           title   : "<b>Azure Network 생성</b>",
           width   : 580,
           height  : 450,
           modal   : true,
           body    : $("#registPopupDiv").html(),
           buttons : $("#registPopupBtnDiv").html(),
           onOpen  : function () {
               setAzureSubscription();
               setAzureResourceGroupList();
           },
           onClose : function(event){
            w2popup.unlock();
            accountId = $("select[name='accountId']").val();
            w2ui['azure_vnetGrid'].clear();
            w2ui['azure_subnetsGrid'].clear();
            doSearch();
           }
       });
    });
    
    /********************************************************
    * 설명 : Azure Network 삭제 버튼 클릭
   *********************************************************/
    $("#deleteBtn").click(function(){
        if($("#deleteBtn").attr('disabled') == "disabled") return;
        var selected = w2ui['azure_vnetGrid'].getSelection();        
        if( selected.length == 0 ){
            w2alert("선택된 정보가 없습니다.", "Network 삭제");
            return;
        }
        else {
            var record = w2ui['azure_vnetGrid'].get(selected);
            w2confirm({
                title   : "<b>Network 삭제</b>",
                msg     : "Virtual Network (" + record.networkName +") 를<br/>"
                                       +"<strong><font color='red'> 삭제 하시 겠습니까?</strong><red>"   ,
                yes_text : "확인",
                no_text : "취소",
                height : 250,
                yes_callBack: function(event){
                     deleteAzureNetworkInfo(record);
                },
                no_callBack    : function(){
                    w2ui['azure_vnetGrid'].clear();
                    w2ui['azure_subnetsGrid'].clear();
                    accountId = record.accountId;
                    doSearch();
                }
            });
        }
    });
    
});

/********************************************************
 * 설명 : Azure Network 정보 목록 조회 Function 
 * 기능 : doSearch
 *********************************************************/
function doSearch() {
    w2ui['azure_vnetGrid'].load("<c:url value='/azureMgnt/network/list/'/>"+accountId);
    doButtonStyle();
    accountId = "";
}

/********************************************************
 * 설명 : 해당 Azure Network에 대한 Subnets List 조회 Function 
 * 기능 : doSearchNetworkSubnetsInfo
 *********************************************************/
function doSearchNetworkSubnetsInfo(accountId, networkName){
    w2utils.lock($("#layout_layout_panel_main"), detail_rg_lock_msg, true);
    w2ui['azure_subnetsGrid'].load("<c:url value='/azureMgnt/network/list/subnets/'/>"+accountId+"/"+networkName);
    w2utils.unlock($("#layout_layout_panel_main"));
}

/********************************************************
 * 설명 : Azure Network 생성
 * 기능 : saveAzureNetworkInfo
 *********************************************************/
function saveAzureNetworkInfo(){
    w2popup.lock(save_lock_msg, true);
    var rgInfo = {
        accountId : $("select[name='accountId']").val(),
        networkName : $(".w2ui-msg-body input[name='networkName']").val(),
        networkAddressSpaceCidr : $(".w2ui-msg-body input[name='networkAddressSpaceCidr']").val(),
        resourceGroupName : $(".w2ui-msg-body select[name='resourceGroupName'] :selected").text(),
        location : $(".w2ui-msg-body select[name='resourceGroupName']").val(),    
        subnetName : $(".w2ui-msg-body input[name='subnetName']").val(),
        subnetAddressRangeCidr : $(".w2ui-msg-body input[name='subnetAddressRangeCidr']").val(),
        azureSubscriptionId : $(".w2ui-msg-body input[name='azureSubscriptionId']").val(),
    }
    
    $.ajax({
        type : "POST",
        url : "/azureMgnt/network/save",
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
     accountId = $("select[name='accountId']").val();
     $.ajax({
            type : "GET",
            url : '/azureMgnt/resourceGroup/list/groupInfo/'+accountId,
            contentType : "application/json",
            dataType : "json",
            success : function(data, status) {
                var result = "";
                var locationInfo ="";
                var intInfo = 0;
                for(var i=0; i<data.total; i++){
                    if(data.records != null){
                            result += "<option value='" +data.records[i].location + "' >";
                            result += data.records[i].resourceGroupName;
                            result += "</option>";
                    }
                }
                $("#resourceGroupInfoDiv #resourceGroupInfo").html(result);
                
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
 * 설명 : 해당 Network의 Azure Subscription 정보 조회 기능
 *********************************************************/
function setAzureSubscription(){
    accountId = $("select[name='accountId']").val();
    $.ajax({
           type : "GET",
           url : '/azureMgnt/resourceGroup/save/subscription/list/'+accountId,
           contentType : "application/json",
           dataType : "json",
           success : function(data, status) {
               var result = "";
               if(data != null){
                           result  += "<input name='azureSubscriptionId' style='display: none;' value='"+data.azureSubscriptionId+"' />";
                           result  += "<input name='' style='width: 300px;' value='"+data.subscriptionName+"' disabled/>";
               }
               $('#subscriptionInfoDiv #subscriptionInfo').html(result);
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
  * 설명 : Azure Network 삭제
  * 기능 :  deleteAzureNetworkInfo
  *********************************************************/
 function  deleteAzureNetworkInfo(record){
     w2popup.lock(delete_lock_msg, true);
     var rgInfo = {
             accountId : record.accountId,
             networkId : record.networkId,
             networkName : record.name,
             location : record.location
     }
     $.ajax({
         type : "DELETE",
         url : "/azureMgnt/network/delete",
         contentType : "application/json",
         async : true,
         data : JSON.stringify(rgInfo),
         success : function(status) {
             w2popup.unlock();
             w2popup.close();
             accountId = rgInfo.accountId;
             w2ui['azure_vnetGrid'].clear();
             w2ui['azure_subnetsGrid'].clear();
             doSearch();
         }, error : function(request, status, error) {
             w2popup.unlock();
             w2ui['azure_vnetGrid'].clear();
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
}

/****************************************************
 * 기능 : clearMainPage
 * 설명 : 다른페이지 이동시 호출
*****************************************************/
function clearMainPage() {
    $().w2destroy('azure_vnetGrid');
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
     <div class="page_site pdt20">인프라 관리 > azure 관리 > <strong>azure Network 관리 </strong></div>
     <div id="azureMgnt" class="pdt20">
        <ul>
            <li>
                <label style="font-size: 14px;">Azure 관리 화면</label> &nbsp;&nbsp;&nbsp; 
                <div class="dropdown" style="display:inline-block;">
                    <a href="#" class="dropdown-toggle iaas-dropdown" data-toggle="dropdown" aria-expanded="false">
                        &nbsp;&nbsp;Virtual Network 관리<b class="caret"></b>
                    </a>
                    <ul class="dropdown-menu alert-dropdown">
                        <sec:authorize access="hasAuthority('AZURE_RESOURCE_GROUP_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/azureMgnt/resourceGroup"/>', 'Azure Resource Group');">Resource Group 관리</a></li>
                        </sec:authorize>
                        <sec:authorize access="hasAuthority('AZURE_SUBNET_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/azureMgnt/subnet"/>', 'Azure Subnet');">Subnet 관리</a></li>
                        </sec:authorize>
                        <sec:authorize access="hasAuthority('AZURE_STORAGE_ACCOUNT_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/azureMgnt/storageAccount"/>', 'Azure Storage Account');"> Storage Account 관리</a></li>
                        </sec:authorize>
                         <sec:authorize access="hasAuthority('AZURE_STORAGE_ACCESS_KEY_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/azureMgnt/storageAccessKey"/>', 'Azure Storage Access Key');"> Storage Access Key 관리</a></li>
                        </sec:authorize>
                        <sec:authorize access="hasAuthority('AZURE_STORAGE_CONTAINER_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/azureMgnt/storageContainer"/>', 'Azure Storage Container');">Storage Container 관리</a></li>
                        </sec:authorize>
                        <sec:authorize access="hasAuthority('AZURE_PUBLIC_IP_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/azureMgnt/publicIp"/>', 'Azure Public IP');">Public IP 관리</a></li>
                        </sec:authorize>
                        <sec:authorize access="hasAuthority('AZURE_SECURITY_GROUP_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/azureMgnt/securityGroup"/>', 'Azure Security Group');">Security Group 관리</a></li>
                        </sec:authorize>
                        <sec:authorize access="hasAuthority('AZURE_ROUTE_TABLE_MENU')">
                            <li><a href="javascript:goPage('<c:url value="/azureMgnt/routeTable"/>', 'Azure Route Tablee');">Route Table 관리</a></li>
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
        <div class="title fl">Azure Network 목록</div>
        <div class="fr"> 
        <sec:authorize access="hasAuthority('AZURE_NETWORK_CREATE')">
            <span id="addBtn" class="btn btn-primary" style="width:120px">생성</span>
            </sec:authorize>
        <sec:authorize access="hasAuthority('AZURE_NETWORK_DELETE')">
            <span id="deleteBtn" class="btn btn-danger" style="width:120px">삭제</span>
        </sec:authorize>
        </div>
    </div>
    
    <!-- Virtual Network 정보 목록 그리드 -->
    <div id="azure_vnetGrid" style="width:100%; height:305px"></div>

    <!-- Network 생성 팝업 -->
    <div id="registPopupDiv" hidden="true">
        <form id="azureRGForm" action="POST" style="padding:5px 0 5px 0;margin:0;">
            <div class="panel panel-info" style="height: 350px; margin-top: 7px;"> 
                <div class="panel-heading"><b>Azure Network 생성 정보</b></div>
                <div class="panel-body" style="padding:20px 10px; height:340px; overflow-y:auto;">
                    <input type="hidden" name="accountId"/>
                    <div class="w2ui-field">
                        <label style="width:36%;text-align: left; padding-left: 20px;">Network Name</label>
                        <div>
                            <input name="networkName" type="text"   maxlength="100" style="width: 300px; margin-top: 1px;" placeholder="Network 태그 명을 입력하세요."/>
                        </div>
                    </div>
                    <div class="w2ui-field">
                        <label style="width:36%;text-align: left; padding-left: 20px;">Network 주소 공간</label>
                        <div>
                            <input name="networkAddressSpaceCidr" type="text" maxlength="100" style="width: 300px; margin-top: 1px;" placeholder="Network  Address Space CIDR를 입력하세요."/>
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
                         <div id="locationInfo" style="width:300px; font-size: 15px; height: 28px; border: 1px solid #ccc; border-radius:2px; padding-left:5px; line-height:28px; color:#777 !important;" ></div>
                           <input id ="locationVal" name="location" hidden="true" readonly='readonly'  style="width:300px; font-size: 15px; height: 32px;"/> 
                        </div>
                    </div>
                    <div class="w2ui-field">
                        <label style="width:36%;text-align: left; padding-left: 20px;">Subnet Name</label>
                        <div>
                            <input name="subnetName" type="text"   maxlength="100" style="width: 300px; margin-top: 1px;" placeholder="Subnet 명을 입력하세요."/>
                        </div>
                    </div>
                     <div class="w2ui-field">
                        <label style="width:36%;text-align: left; padding-left: 20px;">Subnet 주소 범위</label>
                        <div>
                            <input name="subnetAddressRangeCidr" type="text"   maxlength="100" style="width: 300px; margin-top: 1px;" placeholder="Subnet Address Range CIDR를 입력하세요."/>
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
         <button class="btn" id="registBtn" onclick="$('#azureRGForm').submit();">확인</button>
         <button class="btn" id="popClose"  onclick="w2popup.close();">취소</button>
    </div>
    
    <div class="pdt20" >
        <div class="title fl">선택 한 Azure Network에 대한 Subnets 정보 목록</div>
    </div>
    
    <div id="azure_subnetsGrid" style="width:100%; min-height:200px; top:0px;"></div>
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
    $.validator.addMethod( "ipv4Range", function( value, element, params ) {
        return /^((\b|\.)(0|1|2(?!5(?=6|7|8|9)|6|7|8|9))?\d{1,2}){4}(-((\b|\.)(0|1|2(?!5(?=6|7|8|9)|6|7|8|9))?\d{1,2}){4}|\/((0|1|2|3(?=1|2))\d|\d))\b$/.test(params);
    }, text_cidr_msg );
    
    $("#azureRGForm").validate({
        ignore : "",
        onfocusout: true,
        rules: {
            networkName : {
                required : function(){
                    return checkEmpty( $(".w2ui-msg-body input[name='networkName']").val() );
                }
            }, 
            networkAddressSpaceCidr : { 
                required: function(){
                    return checkEmpty( $(".w2ui-msg-body input[name='networkAddressSpaceCidr']").val() );
                }, 
                ipv4Range : function(){
                    return $(".w2ui-msg-body input[name='networkAddressSpaceCidr']").val();
                }
            }, 
            resourceGroupName: { 
                required: function(){
                    return checkEmpty( $(".w2ui-msg-body select[name='resourceGroupName']").val() );
                }
            }, 
            subnetName: { 
                required: function(){
                    return checkEmpty( $(".w2ui-msg-body input[name='subnetName']").val() );
                }
            }, 
            subnetAddressRangeCidr : { 
                required: function(){
                    return checkEmpty( $(".w2ui-msg-body input[name='subnetAddressRangeCidr']").val() );
                }, 
                ipv4Range : function(){
                    return $(".w2ui-msg-body input[name='subnetAddressRangeCidr']").val();
                }
            }
        }, messages: {
            networkName: { 
                 required:  "Network Name" + text_required_msg
            }, 
            networkAddressSpaceCidr: { 
                required:  "Network Address Space CIDR "+text_required_msg
               ,ipv4Range : text_cidr_msg
               
            }, 
            resourceGroupName: { 
                required:  "ResourceGroup Name "+text_required_msg
                
            },
            subnetName: { 
                required:  "Subnet Name "+text_required_msg
                
            },
            subnetAddressRangeCidr: { 
                required:  "Subnet Address Range CIDR"+text_required_msg
               ,ipv4Range : text_cidr_msg
                
            }
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
            saveAzureNetworkInfo();
        }
    });
});
</script>
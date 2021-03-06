<%@page language="java" contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<%@include file="../../../common/dqdp_common.jsp" %>
<jsp:include page="../../../common/dqdp_vars.jsp">
    <jsp:param name="permission" value="roleList"></jsp:param>
    <jsp:param name="mustPermission" value="permissionAdd"></jsp:param>
    <jsp:param name="dict" value=""></jsp:param>
</jsp:include>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title>新增权限</title>
    <link href="${baseURL}/themes/${style}/css/common.css" rel="stylesheet" type="text/css"/>
    <script src="${baseURL}/js/do1/common/jquery-1.6.3.min.js"></script>
    <script src="${baseURL}/js/do1/common/common.js?ver=<%=jsVer%>"></script>
    <script src="${baseURL}/js/3rd-plug/jquery/jquery.form.js"></script>
    <script src="${baseURL}/js/do1/common/HashMap.js"></script>
    <script src="../js/CheckboxTable.js"></script>
    <style type="text/css">
    .btnQuery {
    border: medium none;
    color: #FFFFFF;
    cursor: pointer;
    height: 24px;
    line-height: 24px;
    padding-bottom: 3px;
    width: 68px;
     }
    </style>
</head>

<body style="background: #f6ebe5;">
<form action="${baseURL}/permissionmgr/permissionmgr!addPermission.action" method="post" id="permission_add">
     <div class="searchWrap">
            <div class="title">
                <h2 class="icon1">新增权限</h2>
            </div>
        </div>
    <table class="tableCommon mt5" width="100%" border="0" cellspacing="0" cellpadding="0">

        <tbody>
            <tr>
                <td width="120" class="tdBlue"><span><font color="red">*</font></span>权限名称</td>
                <td width="280">
                    <input class="form120px" name="permissionMgrVO.permissionName" type="text"
                           valid="{must:true,tip:'权限名称',fieldType:'pattern', regex:'^.{1,20}$'}"/>
                    
                    请控制在20个字以内
                </td>
                <td width="120" class="tdBlue"><span><font color="red">*</font></span>权限代码</td>
                <td width="280">
                    <input class="form120px" name="permissionMgrVO.permissionCode" type="text"
                           valid="{must:true,tip:'权限代码',fieldType:'pattern', regex:'^.{1,20}$'}"/>
                    
                    请控制在20个字符以内
                </td>
            </tr>
            <tr>
                <td width="120" class="tdBlue">组件名称</td>
                <td width="280"><input class="form120px" name="permissionMgrVO.component" type="text"
                                       valid="{must:false,tip:'组件名称',fieldType:'pattern', regex:'^.{1,30}$'}"/>请控制在30个字符以内
                </td>
                <td width="120" class="tdBlue">模块名称</td>
                <td width="280"><input class="form120px" name="permissionMgrVO.modelName" type="text"
                                       valid="{must:false,tip:'模块名称',fieldType:'pattern', regex:'^.{1,30}$'}"/>请控制在30个字符以内
                </td>
            </tr>
            <tr>
                <td width="100" class="tdBlue">
                    备注
                </td>
                <td colspan="3">
                    <textarea name="permissionMgrVO.memo" id="memo" style="width: 950px;height:70px"></textarea>
                    <br/>请控制在500字以内
                </td>
            </tr>
            <tr>
                <td width="100" height="70px" class="tdBlue">
                    角色
                </td>
                <td colspan="3">
                    <div id="role_list"></div>
                    <input type="hidden" name="permissionMgrVO.roleIds" id="roleIds" value="">
                </td>
            </tr>
        </tbody>
    </table>
</form>

<div class="toolBar">
    <div align="center">
        <input class="btnQuery" id="save" type="button" value="保存"/>
        <input class="btnQuery" type="button" onclick="javascript:history.back();" value="返 回"/>
    </div>
</div>

<!--工具栏 end-->

<script type="text/javascript">

    var roleMap = new HashMap();

    function selectRole() {
        window.open('roleSelect.jsp'+'?dqdp_csrf_token='+dqdp_csrf_token, '角色选择', 'height=480, width=700, toolbar=no,scrollbars=yes, menubar=no, resizable=yes,location=no, status=no');
    }

    function getRoleMap() {
        return roleMap;
    }

    $(document).ready(function () {
        listRole();
    });

    function listRole() {
        $.ajax({
            url:"${baseURL}/role/role!ajaxSearchRole.action",
            type:"post",
            data: {'dqdp_csrf_token': dqdp_csrf_token},
            dataType:"json",
            success:function (result) {
                if ("0" == result.code) {
                    var roleTable = new CheckboxTable({
                        data:result.data.pagerData,
                        colsCount:8,
                        checkboxName:"roleName",
                        checkboxValue:"roleId"
                    });
                    roleTable.createTable("role_list");
                } else {
                    alert(data.desc);
                }
            },
            error:function () {
                alert("通讯错误");
            }
        });
    }

    function updateRole() {
        var roleIdArray = roleMap.keys();
        var roleNameStr = '';
        for (var i = 0; i < roleIdArray.length; i++) {
            roleNameStr += roleMap.get(roleIdArray[i]) + ",";
        }
        $('#rolename_list').html(roleNameStr);
        $('#roleIds').val(roleIdArray.join(","));
    }

    $('#save').click(function () {
        var roleIds = "";
        $.each($('[name$=Ids]'), function () {
            if ($(this).prop("checked"))
                roleIds += $(this).val() + ",";
        });
        $("#roleIds").val(roleIds);
        var checkDqdp = new Dqdp();
        if (checkDqdp.submitCheck('permission_add')) {
            if (checkMemoLength()) { // 提交数据
                $('#permission_add').ajaxSubmit({
                    dataType:'json',
                    data: {'dqdp_csrf_token': dqdp_csrf_token},
                    success:function (result) {
                        if ("0" == result.code) {
                            alert('新增权限成功');
                            window.location.href=("permissionList.jsp"+'?dqdp_csrf_token='+dqdp_csrf_token);
                        } else {
                            alert(result.desc);
                        }
                    },
                    error:function () {
                        alert('新增权限失败，请稍候再试');
                    }
                });
            } else {
                alert('备注字数超出指定长度，请控制在500字以内！')
            }
        }
    });

    function checkMemoLength() {
        return $('#memo').val().length < 500;
    }
</script>

</body>
</html>

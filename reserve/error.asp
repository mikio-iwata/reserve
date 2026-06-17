<% @LANGUAGE = "VBScript" CodePage=932 %>
<% Option Explicit %>
<% Response.Buffer = True %>
<% Response.CodePage = 932 %>
<% Response.Charset = "shift_jis" %>
<% Session.CodePage = 932 %>
<%
'--------------------------------------------------------------
' 更新履歴
' 日付				更新者				更新内容
'--------------------------------------------------------------
' 2019/04/12		l-inter			SQLインジェクション XSS対策
'--------------------------------------------------------------
%>
<!--#include file="../../../inc/check_secure_programming.asp"-->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=shift_jis">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ハオ中国語アカデミー　予約・キャンセルシステム</title>
<link href="etc/style.css" rel="stylesheet" type="text/css">
</head>
<body>
<div id="main">
<h1><img src="images/form_header_mini.gif" width="500" height="34" alt="ハオ中国語アカデミー"></h1>
<h2>予約・キャンセルシステム</h2>
<table id="formtable" class="stack-table">
  <tr>
    <td class="error-visual" align="center"><img src="images/sorry.gif" width="61" height="122" alt=""></td>
    <td><p>大変申し訳ありません。<br><%= ChkSecXss(Request.QueryString("Message")) %></p></td>
  </tr>
</table>
  <table id="formtable" align="center">
    <tr>
      <td class="action-row" height="100"><a href="javascript:history.back();"><img src="images/back.gif" width="105" height="49" alt="戻る" border="0"></a><a href="javascript:window.close();"><img src="images/close.gif" width="105" height="49" alt="閉じる" border="0"></a></td>
    </tr>
  </table>
</div>
</body>
</html>

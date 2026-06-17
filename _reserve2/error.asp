<% @LANGUAGE = "VBScript" CodePage=932 %>
<% Option Explicit %>
<% Response.Buffer = True %>
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
<%
Dim DisplayMessage
DisplayMessage = ChkSecXss(Request.QueryString("Message"))
DisplayMessage = Replace(DisplayMessage, "&lt;br&gt;", "<br>")
DisplayMessage = Replace(DisplayMessage, "&lt;BR&gt;", "<br>")
DisplayMessage = Replace(DisplayMessage, "&lt;br /&gt;", "<br>")
DisplayMessage = Replace(DisplayMessage, "&lt;BR /&gt;", "<br>")
%><!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=shift_jis">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ハオ中国語アカデミー　予約・キャンセルシステム</title>
<link href="etc/style.css" rel="stylesheet" type="text/css">
</head>
<body>
<div id="main">
  <h1 class="site-header"><img src="images/header-img_135080.jpg" width="1350" height="80" alt="ハオ中国語アカデミー"></h1>
  <h2>予約・キャンセルシステム</h2>
  <div class="page-shell">
    <div class="error-card">
      <img src="images/sorry.gif" width="61" height="122" alt="ご案内">
      <div class="error-card-body">
        <p class="error-text">大変申し訳ありません。<br><%= DisplayMessage %></p>
        <div class="action-row error-actions">
          <a href="javascript:history.back();" class="btn btn-neutral">戻る</a>
          <a href="javascript:window.close();" class="btn btn-neutral">閉じる</a>
        </div>
      </div>
    </div>
  </div>
</div>
</body>
</html>


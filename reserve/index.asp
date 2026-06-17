<% @LANGUAGE = "VBScript" CodePage=932 %>
<% Option Explicit %>
<% Response.Buffer = True %>
<% Session.CodePage = 932 %>
<!--#INCLUDE FILE="etc\include.inc"-->
<%
'************************************************************************
'　このページが呼び出された時点で、まずコースに関するセッションをクリア
'************************************************************************
Session.Contents.Remove("ThisCourse")'			コースＣＤ
Session.Contents.Remove("ThisCourseName")'		コース名
Session.Contents.Remove("ThisCourseType")'		コース種別
Session.Contents.Remove("ThisNoRsvtime")'		コース予約期限時間
Session.Contents.Remove("CourseNumber")'		有効回数があるコースの数

'************************************************************************
'　このページのフォームはこのページを呼び出す
'************************************************************************
'◆ページのサブミットの判定
Select Case Request.Form("Action")
  Case "Submit"

'◆フォーム入力チェック
    If Request.Form("SelectCourse") = "" Then
      LogEvent = "エラー：コース選択画面でコースが選択されませんでした。IDは" & Uid
      Call LogRecord()
      Response.Redirect ErrorAsp & "?Message=" & Server.UrlEncode("コースが選択されていません。")


'◆入力内容を、配列SelectCourseに格納し、それをセッションに格納
    Else
      Dim SelectCourse
	  SelectCourse = Split(Request.Form("SelectCourse"), ",")

      Session.Contents("ThisCourse") = SelectCourse(0)'		コースＣＤ
      Session.Contents("ThisCourseName") = SelectCourse(1)'	コース名
      Session.Contents("ThisCourseType") = SelectCourse(2)'	コース種別
      Session.Contents("ThisNoRsvtime") = SelectCourse(3)'	コース予約期限時間
      Session.Contents("CourseNumber") = 2'			有効回数があるコースの数


'◆メイン画面にリダイレクト
      LogEvent = "コースが選択されました。IDは" & Uid & "、コースCDは" & Session.Contents("ThisCourse")
      Call LogRecord()
      Response.Redirect MainAsp

    End If

  Case Else
'************************************************************************
'　当該ユーザのにおいて、有効回数を保持しているコースの情報を抽出
'　　抽出情報：コース名、コースＣＤ、コース種別（ＰＬ／ＧＬ）、予約制限時間
'　　テーブル：les, course, cls_mst_course
'************************************************************************
    SQL = "SELECT coursen, course.course, course_type, norsvtime "
    SQL = SQL & "FROM (les INNER JOIN course ON les.course = course.course) INNER JOIN cls_mst_course ON course.course = cls_mst_course.course "
    SQL = SQL & "WHERE les.id = '" & Uid & "' AND les.course IN (" & CourseGroup & ") AND expired > '" & Now() & "' "
    SQL = SQL & "GROUP BY coursen, course.course, course_type, norsvtime;"


    Set rs = Server.CreateObject("ADODB.Recordset")
      rs.Open SQL, cn, 3, 2

'◆コースがない場合にはエラー画面にリダイレクト
      If rs.EOF Then
	LogEvent = "エラー：このアプリケーションで予約できるコースの有効回数がありません。IDは" & Uid
	Call LogRecord()
	Response.Redirect ErrorAsp & "?Message=" & Server.UrlEncode("このシステムで予約･キャンセルできる回数がないようです。")


'◆コースが１つしかない場合にはコースの情報をセッションに格納してメイン画面にしてリダイレクト
      ElseIf rs.RecordCount = 1 Then
	Session.Contents("ThisCourse") = rs("course").value'		コースＣＤ
	Session.Contents("ThisCourseName") = rs("coursen").value'	コース名
	Session.Contents("ThisCourseType") = rs("course_type").value'	コース種別
	Session.Contents("ThisNoRsvtime") = rs("norsvtime").value'	コース予約期限時間
	Session.Contents("CourseNumber") = 1'				有効回数があるコースの数

	Response.Redirect MainAsp

'◆コースが２つ以上あるときは、コース選択画面表示
      Else
%>
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
<h2>レッスン予約システム―コースの選択</h2>
<form action="<%= IndexAsp %>" method="post">
<table id="formtable">
  <tr>
    <td><p>予約・キャンセルしたいコースを選択し「次へ」ボタンを押してください。</p></td>
  </tr>
  <tr>
    <td class="SelectCourse">

<%    Do Until rs.EOF %>
      <label class="course-option"><input type="radio" name="SelectCourse" value="<%=rs("course").value %>,<%=rs("coursen").value %>,<%=rs("course_type").value %>,<%=rs("norsvtime").value %>"> <span><%=rs("coursen").value %></span></label>

<%      rs.MoveNext
      Loop
%>
    <input type="hidden" name="Action" value="Submit">
    </td>
  </tr>
  <tr>
    <td class="action-row mobile-reverse-actions"><a href="javascript:window.close();"><img src="images/close.gif" width="105" height="49" alt="閉じる" border="0"></a><input type="image" src="images/next.gif" width="105" height="49" alt="次へ" border="0"></td>
  </tr>
</table>
<table id="formtable">
  <tr>
    <td height="20" valign="bottom"><img src="images/dot_gray.gif" width="500" height="1"></td>
  </tr>
  <tr>
    <td class="copyright">Copyright 2007 HAO Chinese Academy. All rights reserved.</td>
  </tr>
</table>
</form>
</body>
</html>
<%
      End If
'************************************************************
'　データベース切断
'************************************************************
  rs.Close
Set rs = Nothing
End Select
Set cn = Nothing
%>

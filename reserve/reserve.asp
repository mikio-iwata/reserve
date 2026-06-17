<% @LANGUAGE = "VBScript" %>
<% Option Explicit %>
<% Response.Buffer = True %>
<%
'--------------------------------------------------------------
' 更新履歴
' 日付				更新者				更新内容
'--------------------------------------------------------------
' 2019/04/12		l-inter			SQLインジェクション XSS対策
' 2021/12/20		l-inter			予約済みの判定にコースを追加
' 2025/01/14		l-inter			予約ログ出力機能追加
'--------------------------------------------------------------
%>
<!--#INCLUDE FILE="etc\include.inc"-->
<!--#include file="../../../inc/check_secure_programming.asp"-->
<%
'予約ログファイルパス指定
CONST str_LRC_LOG_DIRECTRY = "D:\Inetpub\haolog\lesson_reserve_cancel.log"
'************************************************************************
'　このページのフォームはこのページを呼び出す
'************************************************************************
'◆ページのサブミットの判定
If Request.Form("action") = "Reserve" Then
  Call Reservation()
End If
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=shift_jis">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ハオ中国語アカデミー　予約・キャンセルシステム</title>
<link href="etc/style.css" rel="stylesheet" type="text/css" media="all">
<link href="etc/calendar.css" rel="stylesheet" type="text/css"  media="all">
<script type="text/javascript" language="javascript" src="etc/calendar.js"></script>
</head>
<body>
<div id="mainR">
<h1><img src="images/form_header_wide.gif" width="600" height="34" alt="ハオ中国語アカデミー"></h1>
<h3>レッスンの予約―<span class="blue"><%= Session.Contents("ThisCourseName") %></span></h3>
<table id="formtable" class="stack-table">
  <tr>
    <td class="calendar-cell" align="center" valign="top"><script type="text/javascript">ShowCalendar();</script></td>
    <td class="calendar-copy" valign="top">
<%
'************************************************************
'　ＧＥＴで渡された値の取得
'************************************************************
Dim ClassYear
    ClassYear = Request.QueryString("ClassYear")
Dim ClassMonth
    ClassMonth = Request.QueryString("ClassMonth")
Dim ClassDate
    ClassDate = Request.QueryString("ClassDate")
Dim School
    School = Request.QueryString("School")
Dim SchoolName

'************************************************************
'　学校ＣＤより学校名を検索
'************************************************************
Set rs = Server.CreateObject("ADODB.Recordset")
  SQL = "SELECT schooln FROM school WHERE cd = '" & ChkSecSql(School) & "'"
  rs.Open SQL, cn, 3, 2
  If rs.EOF Then

    LogEvent = "データベースエラー：テーブルschoolより学校名が取得できませんでした。IDは" & Uid
    Call LogRecord()
    Response.Redirect "error.asp?Message=" & Server.UrlEncode("学校名を取得できませんでした。<br>恐れ入りますが事務局までご連絡下さい。")

  Else
    SchoolName = rs("schooln").Value
  End If
  rs.Close
Set rs = Nothing


'************************************************************
'　カレンダーが最初に表示された場合には、まず日付を選択
'************************************************************
If Int(ClassDate) < 1 Or Int(ClassDate) > 31 Then
%>
      <table id="formtable">
	<tr>
	  <td><p>
<% If ClassYear = "" Then %>
	  <span class="strong"><%= ChkSecXss(SchoolName) %></span>が選択されました。<br>
<% End If %>
	    左のカレンダーより予約希望の日付をクリックしてください。<br></p>
	  </td>
	</tr>
      </table>
      <table id="formtable" align="center">
	<tr>
	  <td class="action-row back-button-row" height="100"><a href="<%= MainAsp %>"><img src="images/back.gif" width="105" height="49" alt="戻る" border="0"></a></td>
	</tr>
      </table>
<% Else %>

      <table id="formtable">
	<tr>
	  <td><p><span class="strong"><%= ChkSecXss(Message) %></span></p><p><span class="strong"><%= ChkSecXss(ClassYear) %>年<%= ChkSecXss(ClassMonth) %>月<%= ChkSecXss(ClassDate) %>日(<%= WeekdayName(Weekday(DateSerial(ClassYear, ClassMonth, ClassDate)), True) %>)　<%= ChkSecXss(SchoolName) %></span>で開講予定の<font color = "blue"><%= Session.Contents("ThisCourseName") %> </font>は
<%
'************************************************************
'　指定されたレッスンを取得
'************************************************************
Set rs = Server.CreateObject("ADODB.Recordset")

  Select Case Session.Contents("ThisCourseType")

'◆マンツーマン系コースの場合（教師を表示する場合）
    Case "1"

      SQL = "SELECT class_buffer, stime, etime, total, cname "
      SQL = SQL & "FROM cls_mirror INNER JOIN cls_mst_teacher ON cls_mirror.tid = cls_mst_teacher.teacher_id "
      SQL = SQL & "WHERE course = '" & Session.Contents("ThisCourse") & "' And (stime Between '" & DateSerial(ClassYear, ClassMonth, ClassDate) & "' And '" & DateAdd("d", 1, DateSerial(ClassYear, ClassMonth, ClassDate)) & "') And schoolcd = '" & School & "' And del_flag = '0' And cls_mirror.flag = '0' "
      SQL = SQL & "ORDER BY stime, tid;"


'◆グループ系コースの場合（テキストとレッスン番号を表示する場合）

    Case "2"

      SQL = "SELECT class_buffer, stime, etime, total, text_name, lesson_name "
      SQL = SQL & "FROM (cls_mirror LEFT JOIN cls_lno_mst ON (cls_mirror.lno = cls_lno_mst.lno) AND (cls_mirror.course = cls_lno_mst.course)) LEFT JOIN cls_text_mst ON (cls_mirror.textid = cls_text_mst.textid) AND (cls_mirror.course = cls_text_mst.course) "
      SQL = SQL & "WHERE cls_mirror.course = '" & Session.Contents("ThisCourse") & "' And (stime Between '" & DateSerial(ClassYear, ClassMonth, ClassDate) & "' And '" & DateAdd("d", 1, DateSerial(ClassYear, ClassMonth, ClassDate)) & "') And schoolcd = '" & School & "' And cls_mirror.flag = '0' "
      SQL = SQL & "ORDER BY stime, cls_mirror.textid; "


    Case Else
      LogEvent = "セッションエラー：セッションよりCourseTypeが取得できませんでした。IDは" & Uid
      Call LogRecord()
      Response.Redirect "error.asp?Message=" & Server.UrlEncode("コース種別を取得できませんでした。<br>恐れ入りますが事務局までご連絡下さい。")

  End Select

  rs.Open SQL, cn, 3, 2
  If rs.EOF Then
%>
	    ありません。<br></p>
	  </td>
	</tr>
      </table>
      <table id="formtable" align="center">
	<tr>
	  <td class="action-row back-button-row" height="100"><a href="<%= MainAsp %>"><img src="images/back.gif" width="105" height="49" alt="戻る" border="0"></a></td>
	</tr>
      </table>
<%
  Else

'◆当該の日付、コース、学校において開講コースが見つかった
'　当該の日付、コースにおいて自分が予約しているレッスンを検索し配列に格納
'    SQL = "SELECT cls.class, stime "
'    SQL = SQL & "FROM les INNER JOIN cls ON (cls.class = les.class) AND (les.course = cls.course) "
'    SQL = SQL & "WHERE id = '" & Uid & "' AND cls.course = '" & Session.Contents("ThisCourse") & "' AND (stime Between '" & DateSerial(ClassYear, ClassMonth, ClassDate) & "' And '" & DateAdd("d", 1, DateSerial(ClassYear, ClassMonth, ClassDate)) & "')"

'　コース条件を外し、とにかくこの日で予約をとっている全てのコースを対象にするが、重くなる原因かも。
    'SQL = "SELECT cls.class, stime, etime "
    'SQL = "SELECT cls.class, stime, etime, les.course "
    SQL = "SELECT cls.class, stime, etime, les.course, tid "
    SQL = SQL & "FROM les INNER JOIN cls ON (cls.class = les.class) AND (les.course = cls.course) "
    SQL = SQL & "WHERE id = '" & Uid & "' AND (stime Between '" & DateSerial(ClassYear, ClassMonth, ClassDate) & "' And '" & DateAdd("d", 1, DateSerial(ClassYear, ClassMonth, ClassDate)) & "')"

    Dim rs2
    Dim ReservedClass
    Set rs2 = Server.CreateObject("ADODB.Recordset")
      rs2.Open SQL, cn, 3, 2

'     予約クラスがない場合には、とりあえずの配列を作成
      If rs2.EOF Then
	'Redim ReservedClass(0,2)
	Redim ReservedClass(0,3)

      Else
	'ReDim ReservedClass(rs2.RecordCount - 1, 2)
	ReDim ReservedClass(rs2.RecordCount - 1, 3)
	i = 0
	Do Until rs2.EOF
          ReservedClass(i, 0) = rs2("class").value
          ReservedClass(i, 1) = rs2("stime").value
          ReservedClass(i, 2) = rs2("etime").value
          ReservedClass(i, 3) = rs2("course").value
	  rs2.MoveNext
	  i = i + 1
	Loop
      End If
      rs2.Close
    Set rs2 = Nothing
%>
	下記のとおりです。ご予約希望のクラスを選択し「予約」ボタンを押してください。<br><br>ただし、下記のクラスはご予約できません。<br>　　・クラスの始まる<%= Session.Contents("ThisNoRsvtime") %>時間前を過ぎたクラス<br>　　・満席のクラス<br>　　・ご予約済クラスと同じ時間に開講されるクラス</p>
	  </td>
	</tr>
      </table>
<form action="<%= ReserveAsp %>?ClassYear=<%= ChkSecXss(ClassYear) %>&ClassMonth=<%= ChkSecXss(ClassMonth) %>&ClassDate=<%= ChkSecXss(ClassDate) %>&School=<%= ChkSecXss(School) %>" method="post">
      <table class="lesson-list" border="0" cellspacing="0" cellpadding="0" align="center">
	<tr class="lesson-header">
	  <td width="30" align="left"></td>
	  <td width="100" align="left">レッスン時刻</td>
<%
    Select Case Session.Contents("ThisCourseType")
      Case "1"
	Response.Write("<td>教師名</td>")
      Case "2"
	Response.Write("<td>テキスト＆レッスン</td>")
    End Select
%>
	  <td></td>
	</tr>
<%
    LessonStime = ""
    Do Until rs.EOF
      If LessonStime <> rs("stime").value Then
	Response.Write("<tr class=""lesson-divider""><td height=20 colspan=4 align=center><img src=""images/dot_gray.gif"" width=""250"" height=""1""></td></tr>")
      End If

      Response.Write("    <tr>")

      LessonStime = rs("stime").value
      LessonEtime = rs("etime").value
      ClsTotal = rs("total").value
      ClsCd = rs("class_buffer").value

      Select Case Session.Contents("ThisCourseType")
	Case "1"
	  LessonTeacher = rs("cname").value
	Case "2"
'	  LessonTeacher = rs("text_name").value & rs("lesson_name").value
	  LessonTeacher = rs("text_name").value & "　" & rs("lesson_name").value
      End Select
%>
	  <td>
<%
'◆予約可能（レッスン時間を切っていない、残席が０でない）場合のみラジオボタン表示
    If (LessonStime > DateAdd("h", Session.Contents("ThisNoRsvtime"), Now())) And (ClsTotal > 0) Then
%>
		<input type="radio" name="ReserveCls" value="<%= ChkSecXss(ClsCd) %>"
<%
'◆予約済クラスと表示クラスがカブっている場合はラジオボタンをDisAbledにする
      For i = 0 To Ubound(ReservedClass)
'	If ReservedClass(i, 1) = LessonStime Then
	If NOT (LessonStime >= ReservedClass(i, 2) OR LessonEtime <= ReservedClass(i, 1)) Then
	  Response.Write(" disabled")
	  Exit For
	End If
      Next
%>>
<% End If %>
	  </td>
	  <td><%= Hour(LessonStime) %>:<%= Right("0" & Minute(LessonStime), 2) %>～<%= Hour(LessonEtime) %>:<%= Right("0" & Minute(LessonEtime), 2) %></td>
	  <td><%= ChkSecXss(LessonTeacher) %></td>
	  <td>
<%
'◆当該クラスをのCDが予約済レッスンと同じ場合には予約済ボタン表示
      For i = 0 To Ubound(ReservedClass)
		'If ReservedClass(i, 0) = ClsCd Then
		If ReservedClass(i, 0) = ClsCd AND ReservedClass(i, 3) = Session.Contents("ThisCourse") Then
		  Response.Write("<img src=images/booked.gif width=60 height=16 alt=予約済>")
		  Exit For
		End If
      Next
%>
	  </td>
	</tr>
<%
      rs.MoveNext
    Loop
%>
      </table>
      <table id="formtable" align="center">
	<tr>
	  <td class="action-row"><a href="<%= MainAsp %>"><img src="images/back.gif" width="105" height="49" alt="戻る" border="0"></a><input type="image" src="images/reserve.gif" width="105" height="49" alt="予約" border="0"></td>
	</tr>
<input type="hidden" name="action" value="Reserve">
</form>
      </table>
<%
  End If
  rs.Close
Set rs = Nothing
End If
%>
    </td>
  </tr>
</table>
<table id="formtable">
  <tr>
    <td height="20" valign="bottom"><img src="images/dot_gray.gif" width="600" height="1"></td>
  </tr>
  <tr>
    <td class="copyright">Copyright 2007 HAO Chinese Academy. All rights reserved.</td>
  </tr>
</table>
</div>
</body>
</html>
<%
'************************************************************
'　データベース切断
'************************************************************
cn.Close
Set cn = Nothing

'************************************************************
'　予約時に実行
'************************************************************
Private Function Reservation()
'◆入力値の確認
    If Request.Form("ReserveCls") = "" Then

      LogEvent = "エラー：予約するクラスが選択されていないようです。IDは" & Uid & "、コースは" & Session.Contents("ThisCourse")
      Call LogRecord()
      Response.Redirect ErrorAsp & "?Message=" & Server.UrlEncode("予約するクラスが選択されていないようです。")


    Else
      SelectedCls = Request.Form("ReserveCls")

'◆ClassMirror上で、予約可能なクラスかどうか確認、当該のクラスの終了時刻、残席を取得
      Set rs = Server.CreateObject("ADODB.Recordset")

      'SQL = "Select total, etime FROM cls_mirror WHERE class_buffer = '" & ChkSecSql(SelectedCls) & "' And course = '" & Session.Contents("ThisCourse") & "' And stime > '" & DateAdd("h", Int(Session.Contents("ThisNoRsvtime")), Now()) & "'"
      SQL = "Select total, stime, etime, tid FROM cls_mirror WHERE class_buffer = '" & ChkSecSql(SelectedCls) & "' And course = '" & Session.Contents("ThisCourse") & "' And stime > '" & DateAdd("h", Int(Session.Contents("ThisNoRsvtime")), Now()) & "'"
      rs.Open SQL, cn, 3, 2


'◆予約可能なクラスがなかった
      If rs.EOF Then
	LogEvent = "エラー：予約しようとしたが、レッスンの予約を行うことができませんでした。予約可能時刻を過ぎている可能性があります。IDは" & Uid & "、コースは" & Session.Contents("ThisCourse")
	Call LogRecord()
        Response.Redirect "error.asp?Message=" & Server.UrlEncode("レッスンの予約を行うことができませんでした。<br>予約可能時刻を過ぎている可能性があります。")


'◆クラス残席がゼロだった
      Elseif rs("total").value = 0 Then
	LogEvent = "エラー：予約しようとしたが、レッスンの予約を行うことができませんでした。他の方に既に予約されてしまったようです。IDは" & Uid & "、コースは" & Session.Contents("ThisCourse")
	Call LogRecord()
        Response.Redirect "error.asp?Message=" & Server.UrlEncode("レッスンの予約を行うことができませんでした。<br>他の方に既に予約されてしまったようです。")

      Else
        ClsTotal = rs("total").value
        LessonStime = rs("stime").value
        LessonEtime = rs("etime").value
        Dim LessonTid
        LessonTid = Trim(rs("tid").value)
        rs.Close
        Set rs = Nothing

'◆les上の有効なデータの確認とclassの挿入
'   ※クラス：Null、Utt：-1、有効期限：予約するレッスンの終了時刻より後のレコードを
'   ※有効期限の近い順、値段の高い順に並べて最初の１個をとってくる

	Set rs = Server.CreateObject("ADODB.Recordset")
	SQL = "SELECT no FROM les "
	SQL = SQL & "WHERE id = '" & Uid & "' And course = '" & Session.Contents("ThisCourse") & "' And class is Null And utt = -1 And expired > '" & LessonEtime & "' "
	SQL = SQL & "ORDER BY expired ASC, price DESC"
	rs.Open SQL, cn, 3, 2

	If rs.EOF Then

'◆予約に有効なテーブルがLesになかった。
	LogEvent = "エラー：予約しようとしたが、レッスンの予約を行うことができませんでした。回数がないか、ご契約の有効期限を過ぎたレッスンを過ぎたレッスンが予約されたようです。IDは" & Uid & "、コースは" & Session.Contents("ThisCourse")
	Call LogRecord()
        Response.Redirect "error.asp?Message=" & Server.UrlEncode("レッスンの予約を行うことができませんでした。<br>回数がないか、ご契約の有効期限を過ぎたレッスンを過ぎたレッスンが予約されたようです。")


'◆予約処理
	Else

'　　トランザクションの開始
	  cn.BeginTrans

	  LesNo = rs("no").value
	  rs.Close
	  Set rs = Nothing


'◆lesへのクラス挿入処理
	  SQL = "UPDATE les SET class = '" & ChkSecSql(SelectedCls) & "' WHERE no = '" & LesNo & "'"
	  cn.Execute SQL
	  LogEvent = "予約にあたりLesテーブルの更新を行いました。IDは" & Uid & "、Classは" & SelectedCls & "、LesNoは" & LesNo & "、コースは" & Session.Contents("ThisCourse")
	  Call LogRecord()


'◆cls_mirrorの定員処理
	  SQL = "UPDATE cls_mirror SET total = " & ClsTotal - 1 & " WHERE class_buffer = '" & ChkSecSql(SelectedCls) & "' And Course = '" & Session.Contents("ThisCourse") & "'"
	  cn.Execute SQL
	  LogEvent = "予約にあたりcls_mirrorテーブルの更新を行いました。IDは" & Uid & "、Classは" & SelectedCls & "、コースは" & Session.Contents("ThisCourse")
	  Call LogRecord()


'◆clsの定員処理
	  SQL = "UPDATE cls SET total = " & ClsTotal - 1 & " WHERE class = '" & ChkSecSql(SelectedCls) & "' And Course = '" & Session.Contents("ThisCourse") & "'"
	  cn.Execute SQL
	  LogEvent = "予約にあたりclsテーブルの更新を行いました。IDは" & Uid & "、Classは" & SelectedCls & "、コースは" & Session.Contents("ThisCourse") & "。予約処理が完了しました"
	  Call LogRecord()

	  Message = "レッスンの予約を行いました。"

'　　トランザクションの終了
	  cn.CommitTrans

'◆予約ログ出力処理
	Dim fso
	Dim otf
	Dim strLog
	strLog = Now() & "【生徒 ID:" & Uid & "】クラス" & SelectedCls & "をStime:" & LessonStime & "、Etime:" & LessonEtime & "、Tid:" & LessonTid & "、Course:" & Session.Contents("ThisCourse") & "で作成。"
	Set fso = CreateObject("Scripting.FileSystemObject")
	'テキストファイルを追記モードで開く。ファイルが無い場合は作成、SJIS
	Set otf = fso.OpenTextFile(str_LRC_LOG_DIRECTRY, 8, True, 0)
	'文字列を書き込む
	otf.WriteLine strLog
	'テキストファイルを閉じる
	otf.Close
	Set otf = Nothing
	Set fso = Nothing

	End If

      End If

    End If
End Function
%>

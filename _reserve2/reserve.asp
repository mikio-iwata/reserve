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
' 2021/12/20		l-inter			予約済みの判定にコースを追加
' 2025/01/14		l-inter			予約ログ出力機能追加
'--------------------------------------------------------------
%>
<!--#INCLUDE FILE="etc\include.inc"-->
<!--#include file="../../../inc/check_secure_programming.asp"-->
<%
CONST str_LRC_LOG_DIRECTRY = "D:\Inetpub\haolog\lesson_reserve_cancel.log"
If Request.Form("Action") = "Reserve" Then
  Call Reservation()
End If
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=shift_jis">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ハオ中国語アカデミー　予約・キャンセルシステム</title>
<link href="etc/style.css?v=20260616b" rel="stylesheet" type="text/css" media="all">
<link href="etc/calendar.css?v=20260616a" rel="stylesheet" type="text/css" media="all">
<script type="text/javascript" language="javascript" src="etc/calendar.js?v=20260616a"></script>
</head>
<body>
<div id="mainR" class="reserve-page" style="text-align: center;">
  <h1 class="site-header"><img src="images/header-img_135080.jpg" width="1350" height="80" alt="ハオ中国語アカデミー"></h1>
  <nav class="process-breadcrumb" aria-label="進行状況">
    <ol class="process-breadcrumb-list">
      <li class="process-breadcrumb-item"><a href="<%= HomeAsp %>">ホーム</a></li>
      <li class="process-breadcrumb-separator" aria-hidden="true">＞</li>
      <li class="process-breadcrumb-item"><a href="<%= IndexAsp %>">レッスン予約システム コースの選択</a></li>
      <li class="process-breadcrumb-separator" aria-hidden="true">＞</li>
      <li class="process-breadcrumb-item"><a href="<%= MainAsp %>">予約・キャンセル</a></li>
      <li class="process-breadcrumb-separator" aria-hidden="true">＞</li>
      <li class="process-breadcrumb-item is-current">クラス選択</li>
    </ol>
  </nav>
  <div class="page-shell">
<%
Dim ClassYear
ClassYear = Request.QueryString("ClassYear")
Dim ClassMonth
ClassMonth = Request.QueryString("ClassMonth")
Dim ClassDate
ClassDate = Request.QueryString("ClassDate")
Dim School
School = Request.QueryString("School")
Dim SchoolName

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
%>
    <div class="calendar-layout calendar-layout-stacked<% If Int(ClassDate) < 1 Or Int(ClassDate) > 31 Then %> calendar-layout-intro<% End If %>">
      <div class="calendar-panel calendar-panel-stacked<% If Int(ClassDate) < 1 Or Int(ClassDate) > 31 Then %> calendar-panel-intro<% End If %>"><script type="text/javascript">ShowCalendar();</script></div>
      <div class="calendar-guide calendar-guide-stacked<% If Int(ClassDate) < 1 Or Int(ClassDate) > 31 Then %> calendar-guide-intro<% End If %>">
<%
If Int(ClassDate) < 1 Or Int(ClassDate) > 31 Then
%>
        <p class="section-title">日付を選択してください</p>
        <p class="copy-text">
<% If ClassYear = "" Then %>
          <span class="strong"><%= ChkSecXss(SchoolName) %></span> が選択されました。<br>
<% End If %>
          上のカレンダーより予約希望の日付をクリックしてください。
        </p>
        <div class="action-row">
          <a href="<%= MainAsp %>" class="btn btn-neutral">戻る</a>
        </div>
<%
Else
%>
        <p class="section-title">予約可能なクラス</p>
<% If Len(Message) > 0 Then %>
        <p class="reservation-message"><%= ChkSecXss(Message) %></p>
<% End If %>
        <p class="copy-text"><span class="strong"><%= ChkSecXss(ClassYear) %>年<%= ChkSecXss(ClassMonth) %>月<%= ChkSecXss(ClassDate) %>日(<%= WeekdayName(Weekday(DateSerial(ClassYear, ClassMonth, ClassDate)), True) %>) <%= ChkSecXss(SchoolName) %></span> で開講予定の <span class="blue"><%= Session.Contents("ThisCourseName") %></span> を表示しています。</p>
        <div class="notice-box">
          <ul class="notice-list">
            <li>クラスの始まる <%= Session.Contents("ThisNoRsvtime") %> 時間前を過ぎたクラス</li>
            <li>満席のクラス</li>
            <li>ご予約済クラスと同じ時間に開講されるクラス</li>
          </ul>
        </div>
<%
End If
%>
      </div>
    </div>

<%
If Int(ClassDate) >= 1 And Int(ClassDate) <= 31 Then
  Set rs = Server.CreateObject("ADODB.Recordset")

  Select Case Session.Contents("ThisCourseType")
    Case "1"
      SQL = "SELECT class_buffer, stime, etime, total, cname "
      SQL = SQL & "FROM cls_mirror INNER JOIN cls_mst_teacher ON cls_mirror.tid = cls_mst_teacher.teacher_id "
      SQL = SQL & "WHERE course = '" & ChkSecSql(Session.Contents("ThisCourse")) & "' And (stime Between '" & DateSerial(ClassYear, ClassMonth, ClassDate) & "' And '" & DateAdd("d", 1, DateSerial(ClassYear, ClassMonth, ClassDate)) & "') And schoolcd = '" & ChkSecSql(School) & "' And del_flag = '0' And cls_mirror.flag = '0' "
      SQL = SQL & "ORDER BY stime, tid;"
    Case "2"
      SQL = "SELECT class_buffer, stime, etime, total, text_name, lesson_name "
      SQL = SQL & "FROM (cls_mirror LEFT JOIN cls_lno_mst ON (cls_mirror.lno = cls_lno_mst.lno) AND (cls_mirror.course = cls_lno_mst.course)) LEFT JOIN cls_text_mst ON (cls_mirror.textid = cls_text_mst.textid) AND (cls_mirror.course = cls_text_mst.course) "
      SQL = SQL & "WHERE cls_mirror.course = '" & ChkSecSql(Session.Contents("ThisCourse")) & "' And (stime Between '" & DateSerial(ClassYear, ClassMonth, ClassDate) & "' And '" & DateAdd("d", 1, DateSerial(ClassYear, ClassMonth, ClassDate)) & "') And schoolcd = '" & ChkSecSql(School) & "' And cls_mirror.flag = '0' "
      SQL = SQL & "ORDER BY stime, cls_mirror.textid; "
    Case Else
      LogEvent = "セッションエラー：セッションよりCourseTypeが取得できませんでした。IDは" & Uid
      Call LogRecord()
      Response.Redirect "error.asp?Message=" & Server.UrlEncode("コース種別を取得できませんでした。<br>恐れ入りますが事務局までご連絡下さい。")
  End Select

  rs.Open SQL, cn, 3, 2
  If rs.EOF Then
%>
    <div class="section-card">
      <p class="empty-state">該当日の開講予定クラスはありません。</p>
      <div class="action-row cancel-empty-actions">
        <a href="<%= MainAsp %>" class="btn btn-neutral">戻る</a>
      </div>
    </div>
<%
  Else
    SQL = "SELECT cls.class, stime, etime, les.course, tid "
    SQL = SQL & "FROM les INNER JOIN cls ON (cls.class = les.class) AND (les.course = cls.course) "
    SQL = SQL & "WHERE id = '" & ChkSecSql(Uid) & "' AND (stime Between '" & DateSerial(ClassYear, ClassMonth, ClassDate) & "' And '" & DateAdd("d", 1, DateSerial(ClassYear, ClassMonth, ClassDate)) & "')"

    Dim rs2
    Dim ReservedClass
    Set rs2 = Server.CreateObject("ADODB.Recordset")
    rs2.Open SQL, cn, 3, 2

    If rs2.EOF Then
      Redim ReservedClass(0,3)
    Else
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
    <div class="section-card schedule-card"><form id="reserve-form" action="<%= ReserveAsp %>?ClassYear=<%= ChkSecXss(ClassYear) %>&ClassMonth=<%= ChkSecXss(ClassMonth) %>&ClassDate=<%= ChkSecXss(ClassDate) %>&School=<%= ChkSecXss(School) %>" method="post"><div class="schedule-grid">
        <table class="schedule-table">
          <thead>
            <tr>
              <th></th>
              <th>レッスン時刻</th>
              <th><% If Session.Contents("ThisCourseType") = "1" Then Response.Write("教師名") Else Response.Write("テキスト＆レッスン") End If %></th>
              <th>状態</th>
            </tr>
          </thead>
          <tbody>
<%
    Do Until rs.EOF
      LessonStime = rs("stime").value
      LessonEtime = rs("etime").value
      ClsTotal = rs("total").value
      ClsCd = rs("class_buffer").value

      Select Case Session.Contents("ThisCourseType")
        Case "1"
          LessonTeacher = rs("cname").value
        Case "2"
          LessonTeacher = rs("text_name").value & "　" & rs("lesson_name").value
      End Select
%>
            <tr>
              <td>
<%
      If (LessonStime > DateAdd("h", Session.Contents("ThisNoRsvtime"), Now())) And (ClsTotal > 0) Then
%>
                <input type="radio" id="ReserveCls_<%= ChkSecXss(ClsCd) %>" name="ReserveCls" value="<%= ChkSecXss(ClsCd) %>"
<%
        For i = 0 To Ubound(ReservedClass)
          If Not (LessonStime >= ReservedClass(i, 2) Or LessonEtime <= ReservedClass(i, 1)) Then
            Response.Write(" disabled")
            Exit For
          End If
        Next
%>
                >
<%    End If %>
              </td>
              <td data-label="レッスン時刻"><label class="schedule-choice-label" for="ReserveCls_<%= ChkSecXss(ClsCd) %>"><%= Hour(LessonStime) %>:<%= Right("0" & Minute(LessonStime), 2) %>～<%= Hour(LessonEtime) %>:<%= Right("0" & Minute(LessonEtime), 2) %></label></td>
              <td data-label="内容"><label class="schedule-choice-label" for="ReserveCls_<%= ChkSecXss(ClsCd) %>"><%= ChkSecXss(LessonTeacher) %></label></td>
              <td data-label="状態"><label class="schedule-choice-label" for="ReserveCls_<%= ChkSecXss(ClsCd) %>">
<%
      Dim IsBooked
      IsBooked = False
      For i = 0 To Ubound(ReservedClass)
        If ReservedClass(i, 0) = ClsCd And ReservedClass(i, 3) = Session.Contents("ThisCourse") Then
          IsBooked = True
          Exit For
        End If
      Next

      If IsBooked Then
        Response.Write("<span class=""status-chip"">予約済</span>")
      ElseIf ClsTotal = 0 Then
        Response.Write("<span class=""muted"">満席</span>")
      ElseIf LessonStime <= DateAdd("h", Session.Contents("ThisNoRsvtime"), Now()) Then
        Response.Write("<span class=""muted"">締切後</span>")
      Else
        Response.Write("<span class=""muted"">予約可能</span>")
      End If
%>
              </label></td>
            </tr>
<%
      rs.MoveNext
    Loop
%>
          </tbody>
        </table>
      </div><input type="hidden" name="Action" value="Reserve"></form></div><div class="section-card reserve-actions-card"><div class="action-row"><a href="<%= MainAsp %>" class="btn btn-neutral">戻る</a><button type="submit" form="reserve-form" class="btn btn-primary">予約する</button></div></div>
<%
  End If
  rs.Close
  Set rs = Nothing
End If
%>
    <p class="copyright">Copyright 2007 HAO Chinese Academy. All rights reserved.</p>
  </div>
</div>
</body>
</html>
<%
cn.Close
Set cn = Nothing

Private Function Reservation()
    If Request.Form("ReserveCls") = "" Then
      LogEvent = "エラー：予約するクラスが選択されていないようです。IDは" & Uid & "、コースは" & Session.Contents("ThisCourse")
      Call LogRecord()
      Response.Redirect ErrorAsp & "?Message=" & Server.UrlEncode("予約するクラスが選択されていないようです。")
    Else
      SelectedCls = Request.Form("ReserveCls")
      Set rs = Server.CreateObject("ADODB.Recordset")

      SQL = "Select total, stime, etime, tid FROM cls_mirror WHERE class_buffer = '" & ChkSecSql(SelectedCls) & "' And course = '" & ChkSecSql(Session.Contents("ThisCourse")) & "' And stime > '" & DateAdd("h", Int(Session.Contents("ThisNoRsvtime")), Now()) & "'"
      rs.Open SQL, cn, 3, 2

      If rs.EOF Then
        LogEvent = "エラー：予約しようとしたが、レッスンの予約を行うことができませんでした。予約可能時刻を過ぎている可能性があります。IDは" & Uid & "、コースは" & Session.Contents("ThisCourse")
        Call LogRecord()
        Response.Redirect "error.asp?Message=" & Server.UrlEncode("レッスンの予約を行うことができませんでした。<br>予約可能時刻を過ぎている可能性があります。")
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
        Set rs = Server.CreateObject("ADODB.Recordset")
        SQL = "SELECT no FROM les "
        SQL = SQL & "WHERE id = '" & ChkSecSql(Uid) & "' And course = '" & ChkSecSql(Session.Contents("ThisCourse")) & "' And class is Null And utt = -1 And expired > '" & LessonEtime & "' "
        SQL = SQL & "ORDER BY expired ASC, price DESC"
        rs.Open SQL, cn, 3, 2

        If rs.EOF Then
          LogEvent = "エラー：予約しようとしたが、レッスンの予約を行うことができませんでした。回数がないか、ご契約の有効期限を過ぎたレッスンを過ぎたレッスンが予約されたようです。IDは" & Uid & "、コースは" & Session.Contents("ThisCourse")
          Call LogRecord()
          Response.Redirect "error.asp?Message=" & Server.UrlEncode("レッスンの予約を行うことができませんでした。<br>回数がないか、ご契約の有効期限を過ぎたレッスンを過ぎたレッスンが予約されたようです。")
        Else
          cn.BeginTrans

          LesNo = rs("no").value
          rs.Close
          Set rs = Nothing

          SQL = "UPDATE les SET class = '" & ChkSecSql(SelectedCls) & "' WHERE no = '" & ChkSecSql(LesNo) & "'"
          cn.Execute SQL
          LogEvent = "予約にあたりLesテーブルの更新を行いました。IDは" & Uid & "、Classは" & SelectedCls & "、LesNoは" & LesNo & "、コースは" & Session.Contents("ThisCourse")
          Call LogRecord()

          SQL = "UPDATE cls_mirror SET total = " & ClsTotal - 1 & " WHERE class_buffer = '" & ChkSecSql(SelectedCls) & "' And Course = '" & ChkSecSql(Session.Contents("ThisCourse")) & "'"
          cn.Execute SQL
          LogEvent = "予約にあたりcls_mirrorテーブルの更新を行いました。IDは" & Uid & "、Classは" & SelectedCls & "、コースは" & Session.Contents("ThisCourse")
          Call LogRecord()

          SQL = "UPDATE cls SET total = " & ClsTotal - 1 & " WHERE class = '" & ChkSecSql(SelectedCls) & "' And Course = '" & ChkSecSql(Session.Contents("ThisCourse")) & "'"
          cn.Execute SQL
          LogEvent = "予約にあたりclsテーブルの更新を行いました。IDは" & Uid & "、Classは" & SelectedCls & "、コースは" & Session.Contents("ThisCourse") & "。予約処理が完了しました"
          Call LogRecord()

          Message = "レッスンの予約を行いました。"
          cn.CommitTrans

          Dim fso
          Dim otf
          Dim strLog
          Dim LogWriteErr
          strLog = Now() & "【生徒 ID:" & Uid & "】クラス" & SelectedCls & "をStime:" & LessonStime & "、Etime:" & LessonEtime & "、Tid:" & LessonTid & "、Course:" & Session.Contents("ThisCourse") & "で作成。"
          On Error Resume Next
          Set fso = CreateObject("Scripting.FileSystemObject")
          Set otf = fso.OpenTextFile(str_LRC_LOG_DIRECTRY, 8, True, 0)
          If Err.Number = 0 Then
            otf.WriteLine strLog
            otf.Close
          End If
          If Err.Number <> 0 Then
            LogWriteErr = Err.Number & " " & Err.Description
          End If
          Set otf = Nothing
          Set fso = Nothing
          On Error GoTo 0
          If Len(LogWriteErr) > 0 Then
            LogEvent = "予約処理は完了しましたが、予約ログ出力に失敗しました。IDは" & Uid & "、Classは" & SelectedCls & "、ログ出力先は" & str_LRC_LOG_DIRECTRY & "、エラーは" & LogWriteErr
            Call LogRecord()
          End If
        End If
      End If
    End If
End Function
%>





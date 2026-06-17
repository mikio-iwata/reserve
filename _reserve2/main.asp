<% @LANGUAGE = "VBScript" CodePage=932 %>
<% Option Explicit %>
<% Response.Buffer = True %>
<% Session.CodePage = 932 %>
<%
'--------------------------------------------------------------
' 更新履歴
' 日付				更新者				更新内容
'--------------------------------------------------------------
' 2025/01/14		l-inter			キャンセルログ出力機能追加
'--------------------------------------------------------------
%>
<!--#INCLUDE FILE="etc\include.inc"-->
<!--#include file="../../../inc/check_secure_programming.asp"-->
<%
CONST str_LRC_LOG_DIRECTRY = "D:\Inetpub\haolog\lesson_reserve_cancel.log"

Call SessionCourseCheck()

Select Case Request.Form("Action")
  Case "Reserve"
    If Request.Form("School") = "" Then
      LogEvent = "エラー：レッスン予約時に学校名が選択されていないようです。IDは" & Uid & "、コースは" & ChkSecSql(Session.Contents("ThisCourse"))
      Call LogRecord()
      Response.Redirect ErrorAsp & "?Message=" & Server.UrlEncode("学校名が選択されていないようです。")
    Else
      Response.Cookies("School") = ChkSecSql(Request.Form("School"))
      Response.Cookies("School").Expires = Date + 365
      LogEvent = "レッスンの予約にあたり希望日、スクールが選択されました。IDは" & Uid & "、コースは" & ChkSecSql(Session.Contents("ThisCourse")) & "、希望日は" & Request.Form("ClassYear") & "/" & Request.Form("ClassMonth") & "/" & Request.Form("ClassDate") & "、スクールＣＤは" & ChkSecSql(Request.Form("School")) & "です。"
      Call LogRecord()
      Response.Redirect ReserveAsp & "?School=" & Server.UrlEncode(ChkSecSql(Request.Form("School")))
    End If

  Case "Cencel"
    If Request.Form("CancelCls") = "" Then
      LogEvent = "エラー：キャンセルするクラスが選択されていないようです。IDは" & Uid & "、コースは" & ChkSecSql(Session.Contents("ThisCourse"))
      Call LogRecord()
      Response.Redirect ErrorAsp & "?Message=" & Server.UrlEncode("キャンセルするクラスが選択されていないようです。")
    Else
      SelectedCls = ChkSecSql(Request.Form("CancelCls"))
      Set rs = Server.CreateObject("ADODB.Recordset")
      SQL = "Select total, maxtotal, stime, schoolcd FROM cls_mirror WHERE class_buffer = '" & SelectedCls & "' And course = '" & ChkSecSql(Session.Contents("ThisCourse")) & "' And stime > '" & DateAdd("h", Int(Session.Contents("ThisNoRsvtime")), Now()) & "'"
      rs.Open SQL, cn, 3, 2

      If rs.EOF Then
        LogEvent = "エラー：レッスンのキャンセルを行うことができませんでした。キャンセル可能時刻を過ぎている可能性があります。IDは" & Uid & "、コースは" & ChkSecSql(Session.Contents("ThisCourse"))
        Call LogRecord()
        Response.Redirect ErrorAsp & "?Message=" & Server.UrlEncode("レッスンのキャンセルを行うことができませんでした。<br>キャンセル可能時刻を過ぎている可能性があります。")
      Elseif rs("total").value = rs("maxtotal").value Then
        LogEvent = "エラー：レッスンのキャンセルを行うことができませんでした。クラス予約人数と定員が同数。IDは" & Uid & "、コースは" & ChkSecSql(Session.Contents("ThisCourse"))
        Call LogRecord()
        Response.Redirect ErrorAsp & "?Message=" & Server.UrlEncode("レッスンのキャンセルを行うことができませんでした。<br>既にキャンセルされていないかご確認下さい。")
      Else
        ClsTotal = rs("total").value

        Dim strStime, strSchoolCd
        strStime = rs("stime").value
        strSchoolCd = rs("schoolcd").value

        rs.Close
        Set rs = Nothing

        Set rs = Server.CreateObject("ADODB.Recordset")
        SQL = "SELECT no FROM les "
        SQL = SQL & "WHERE id = '" & ChkSecSql(Uid) & "' And course = '" & ChkSecSql(Session.Contents("ThisCourse")) & "' And class = '" & SelectedCls & "' And utt = -1"
        rs.Open SQL, cn, 3, 2

        If rs.EOF Then
          LogEvent = "エラー：レッスンのキャンセルを行うことができませんでした。Lesのナンバーで該当するレコードなし。IDは" & Uid & "、コースは" & ChkSecSql(Session.Contents("ThisCourse"))
          Call LogRecord()
          Response.Redirect ErrorAsp & "?Message=" & Server.UrlEncode("レッスンのキャンセルを行うことができませんでした。<br>既にキャンセルされていないかご確認下さい。")
        Else
          cn.BeginTrans
          LesNo = rs("no").value
          rs.Close
          Set rs = Nothing

          SQL = "UPDATE les SET class = Null WHERE no = '" & ChkSecSql(LesNo) & "'"
          cn.Execute SQL
          LogEvent = "キャンセルにあたりLesテーブルの更新を行いました。IDは" & Uid & "、Classは" & SelectedCls & "、LesNoは" & LesNo & "、コースは" & ChkSecSql(Session.Contents("ThisCourse"))
          Call LogRecord()

          SQL = "UPDATE cls_mirror SET total = " & ClsTotal + 1 & " WHERE class_buffer = '" & SelectedCls & "' And Course = '" & ChkSecSql(Session.Contents("ThisCourse")) & "'"
          cn.Execute SQL
          LogEvent = "キャンセルにあたりcls_mirrorテーブルの更新を行いました。IDは" & Uid & "、Classは" & SelectedCls & "、コースは" & ChkSecSql(Session.Contents("ThisCourse"))
          Call LogRecord()

          SQL = "UPDATE cls SET total = " & ClsTotal + 1 & " WHERE class = '" & SelectedCls & "' And Course = '" & ChkSecSql(Session.Contents("ThisCourse")) & "'"
          cn.Execute SQL
          LogEvent = "キャンセルにあたりclsテーブルの更新を行いました。IDは" & Uid & "、Classは" & SelectedCls & "、コースは" & ChkSecSql(Session.Contents("ThisCourse")) & "。キャンセル処理が完了しました"
          Call LogRecord()

          Message = "レッスンのキャンセルを行いました。"

          SQL = "INSERT INTO lesson_cancel(class,course,stime,etime,tid,schoolcd,cancel_id,doer_id)"
          SQL = SQL & "SELECT class_buffer,course,stime,etime,tid,schoolcd," & ChkSecSql(Uid) & "," & ChkSecSql(Uid)
          SQL = SQL & " FROM cls_mirror WHERE class_buffer = '" & SelectedCls & "' And course = '" & ChkSecSql(Session.Contents("ThisCourse")) & "';"
          cn.Execute SQL

          Dim intNo
          intNo = 0
          Set rs = Server.CreateObject("ADODB.Recordset")
          SQL = "SELECT IDENT_CURRENT('lesson_cancel') AS NO;"
          rs.Open SQL, cn, 3, 2
          If Not rs.EOF Then
            intNo = rs("NO").value
          End If
          rs.close

          cn.CommitTrans

          Dim fso
          Dim otf
          Dim strLog
          Dim LogWriteErr
          strLog = Now() & "【生徒 ID:" & Uid & "】クラス" & SelectedCls & "より個人ＩＤ:" & Uid & "の予約をキャンセル。"
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
            LogEvent = "キャンセル処理は完了しましたが、キャンセルログ出力に失敗しました。IDは" & Uid & "、Classは" & SelectedCls & "、ログ出力先は" & str_LRC_LOG_DIRECTRY & "、エラーは" & LogWriteErr
            Call LogRecord()
          End If

          Dim strPastDateTime, strNow
          strPastDateTime = DateAdd("h", -72, strStime)
          strNow = Now()

          Dim strMailTo
          strMailTo = ""
          Set rs = Server.CreateObject("ADODB.Recordset")
          SQL = "SELECT mailaddr FROM school WHERE cd='" & ChkSecSql(strSchoolCd) & "';"
          rs.Open SQL, cn, 3, 2
          If Not rs.EOF Then
            strMailTo = rs("mailaddr").value
          End If
          rs.close

          If strMailTo <> "" Then
            Dim strMailBody
            strMailBody = ""
            Set fso = Server.CreateObject("Scripting.FileSystemObject")
            Set otf = fso.OpenTextFile(Server.Mappath("cancelmail_info.txt"), 1)
            strMailBody = otf.ReadAll
            otf.Close
            Set otf = Nothing
            Set fso = Nothing
            strMailBody = Replace(strMailBody, "%number%", intNo)
            strMailBody = Replace(strMailBody, "%entrydate%", Left(Now,16))

            Dim strSvName, strMailFrom, strSubj, bobj, rc
            strSvName = Application("MailServerAddr_heteml")
            strMailFrom = "no-repry@haonet.co.jp"
            strSubj = "レッスンキャンセル発生のお知らせ"
            Set bobj = Server.CreateObject("basp21")
            Set bobj = Nothing
          End If
        End If
      End If
    End If
End Select
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=shift_jis">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ハオ中国語アカデミー　予約・キャンセルシステム</title>
<link href="etc/style.css?v=20260616b" rel="stylesheet" type="text/css">
</head>
<body>
<div id="main" class="single-base-page">
  <h1 class="site-header"><img src="images/header-img_135080.jpg" width="1350" height="80" alt="ハオ中国語アカデミー"></h1>
  <nav class="process-breadcrumb" aria-label="進行状況">
    <ol class="process-breadcrumb-list">
      <li class="process-breadcrumb-item"><a href="<%= HomeAsp %>">ホーム</a></li>
      <li class="process-breadcrumb-separator" aria-hidden="true">＞</li>
      <li class="process-breadcrumb-item"><a href="<%= IndexAsp %>">レッスン予約システム コースの選択</a></li>
      <li class="process-breadcrumb-separator" aria-hidden="true">＞</li>
      <li class="process-breadcrumb-item is-current">予約・キャンセル</li>
    </ol>
  </nav>
  <div class="page-shell">
<% If Len(Message) > 0 Then %>
    <p class="message-box is-visible"><%= Message %></p>
<% End If %>

    <div class="section-card">
      <p class="section-title">レッスンの予約</p>
<%
Set rs = Server.CreateObject("ADODB.Recordset")
SQL = "SELECT no FROM les WHERE id = '" & ChkSecSql(Uid) & "' And course = '" & ChkSecSql(Session.Contents("ThisCourse")) & "' And class is Null And utt = -1 And expired > '" & Now() & "'"
rs.Open SQL, cn, 3, 2

If rs.EOF Then
%>
      <p class="empty-state">残回数がないため、ご予約できません。</p>
<%
  rs.Close
Else
  LessonCount = rs.RecordCount
  rs.Close
  Set rs = Nothing
%>
      <div class="info-panel">
        <p class="copy-text"><span class="blue"><%= Session.Contents("ThisCourseName") %></span> のご予約可能回数は、あと <span class="strong"><%= LessonCount %></span> 回です。受講希望の学校名を選択し、「次へ」を押してください。</p>
      </div>
      <form action="<%= MainAsp %>" method="post">
        <div class="form-field school-select-field">
          <label class="form-label" for="School">受講希望の学校</label>
          <select name="School" id="School" class="form-select">
            <option value="">----お選び下さい----</option>
<%
    Set rs = Server.CreateObject("ADODB.Recordset")
    SQL = "SELECT cls_mst_course.schoolcd, schooln "
    SQL = SQL & "FROM cls_mst_course INNER JOIN school ON cls_mst_course.schoolcd = school.cd "
    SQL = SQL & "WHERE course = '" & ChkSecSql(Session.Contents("ThisCourse")) & "' "
    SQL = SQL & "ORDER BY cls_mst_course.schoolcd;"
    rs.Open SQL, cn, 3, 2

    If rs.EOF Then
      LogEvent = "エラー：レッスンの予約を行うにあたり、このコースが開講されている学校がcls_mst_courseになかった。IDは" & Uid & "、コースは" & ChkSecSql(Session.Contents("ThisCourse"))
      Call LogRecord()
      Response.Redirect ErrorAsp & "?Message=" & Server.UrlEncode("申し訳ありませんが、事務局までご連絡下さい。")
    Else
      Do Until rs.EOF
        Response.Write("<option value=" & rs("schoolcd").value)
        If Request.Cookies("School") = Trim(rs("schoolcd").value) Then
          Response.Write(" selected")
        End If
        Response.Write(">" & rs("schooln").value & "</option>")
        rs.MoveNext
      Loop
    End If

    rs.Close
    Set rs = Nothing
%>
          </select>
          <input type="hidden" name="Action" value="Reserve">
        </div>
        <div class="action-row school-reserve-actions">
<% If Int(Session.Contents("CourseNumber")) > 1 Then %>
          <a href="<%= IndexAsp %>" class="btn btn-neutral">戻る</a>
<% End If %>
          <button type="submit" class="btn btn-primary">次へ</button>
        </div>
      </form>
<% End If %>
    </div>




    <div class="section-card">
      <p class="section-title">レッスンのキャンセル</p>
<%
Set rs = Server.CreateObject("ADODB.Recordset")

Select Case Session.Contents("ThisCourseType")
  Case "1"
    SQL = "SELECT DISTINCT class_buffer AS class, stime, etime, cname "
    SQL = SQL & "FROM les INNER JOIN cls_mirror ON (les.course = cls_mirror.course AND les.class = cls_mirror.class_buffer) INNER JOIN cls_mst_teacher ON cls_mirror.tid = cls_mst_teacher.teacher_id "
    SQL = SQL & "WHERE cls_mirror.etime > '" & Now() & "' AND les.id = '" & ChkSecSql(Uid) & "' AND les.course = '" & ChkSecSql(Session.Contents("ThisCourse")) & "' AND cls_mst_teacher.del_flag = '0' AND cls_mirror.flag='0' "
    SQL = SQL & "ORDER BY stime;"
  Case "2"
    SQL = "SELECT DISTINCT class_buffer AS class, stime, etime, text_name, lesson_name "
    SQL = SQL & "FROM les INNER JOIN ((cls_mirror LEFT JOIN cls_lno_mst ON (cls_mirror.lno = cls_lno_mst.lno) AND (cls_mirror.course = cls_lno_mst.course)) LEFT JOIN cls_text_mst ON (cls_mirror.textid = cls_text_mst.textid) AND (cls_mirror.course = cls_text_mst.course)) ON (les.class = cls_mirror.class_buffer) AND (les.course = cls_mirror.course) "
    SQL = SQL & "WHERE cls_mirror.etime > '" & Now() & "' AND les.id = '" & ChkSecSql(Uid) & "' AND les.course = '" & ChkSecSql(Session.Contents("ThisCourse")) & "' AND cls_mirror.flag='0' "
    SQL = SQL & "ORDER BY stime;"
  Case Else
    LogEvent = "セッションエラー：セッションよりCourseTypeが取得できませんでした。IDは" & Uid
    Call LogRecord()
    Response.Redirect "error.asp?Message=" & Server.UrlEncode("コース種別を取得できませんでした。<br>恐れ入りますが事務局までご連絡下さい。")
End Select

rs.Open SQL, cn, 3, 2
If rs.EOF Then
%>
      <p class="empty-state">ご予約レッスンがありませんのでキャンセルはできません。</p>
      <div class="action-row cancel-empty-actions">
<% If Int(Session.Contents("CourseNumber")) > 1 Then %>
        <a href="<%= IndexAsp %>" class="btn btn-neutral">戻る</a>
<% End If %>
      </div>
<%
Else
%>
      <p class="copy-text"><span class="blue"><%= Session.Contents("ThisCourseName") %></span> でご予約済のレッスンは下記のとおりです。キャンセルしたいレッスンを選択し、「キャンセルする」を押してください。<br>(レッスンの始まる<%= Session.Contents("ThisNoRsvtime") %>時間前を過ぎたレッスンはキャンセルできません。)</p>
      <form action="<%= MainAsp %>" method="post">
        <div class="lesson-list">
<%
  Do Until rs.EOF
    LessonStime = rs("stime").value
    LessonEtime = rs("etime").value

    Select Case Session.Contents("ThisCourseType")
      Case "1"
        LessonTeacher = "教師名: " & rs("cname").value
      Case "2"
        LessonTeacher = rs("text_name").value & " " & rs("lesson_name").value
    End Select
%>
          <div class="lesson-item<% If LessonStime <= DateAdd("h", Session.Contents("ThisNoRsvtime"), Now()) Then %> is-disabled<% End If %>">
            <label class="choice-control">
<% If LessonStime > DateAdd("h", Session.Contents("ThisNoRsvtime"), Now()) Then %>
              <input type="radio" name="CancelCls" value="<%= Trim(rs("class").value) %>">
<% Else %>
              <input type="radio" disabled="disabled">
<% End If %>
              <span>
                <span class="lesson-title"><%= Month(LessonStime) %>月<%= Day(LessonStime) %>日(<%= WeekdayName(Weekday(LessonStime), True) %>) <%= Hour(LessonStime) %>:<%= Right("0" & Minute(LessonStime), 2) %>～<%= Hour(LessonEtime) %>:<%= Right("0" & Minute(LessonEtime), 2) %></span>
                <span class="lesson-meta"><%= LessonTeacher %><% If LessonStime <= DateAdd("h", Session.Contents("ThisNoRsvtime"), Now()) Then %> / キャンセル期限を過ぎています<% End If %></span>
              </span>
            </label>
          </div>
<%
    rs.MoveNext
  Loop
%>
        </div>
        <input type="hidden" name="Action" value="Cencel">
        <div class="action-row">
          <button type="submit" class="btn btn-danger">キャンセルする</button>
        </div>
      </form>
<%
End If
rs.Close
Set rs = Nothing
%>
    </div>

    <p class="copyright">Copyright 2007 HAO Chinese Academy. All rights reserved.</p>
  </div>
</div>
</body>
</html>
<%
Set cn = Nothing
%>



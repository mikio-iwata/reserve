<% @LANGUAGE = "VBScript" CodePage=932 %>
<% Option Explicit %>
<% Response.Buffer = True %>
<% Session.CodePage = 932 %>
<%
'--------------------------------------------------------------
' 更新履歴
' 日付                更新者              更新内容
'--------------------------------------------------------------
' 2019/04/12          l-inter           SQLインジェクション XSS対策
' 2021/12/20          l-inter           予約済みの判定にコースを追加
' 2025/01/14          l-inter           予約ログ出力機能追加
' 2026/06/16          Codex             予約入口画面の学校・コース選択対応
'--------------------------------------------------------------
%>
<!--#INCLUDE FILE="etc\include.inc"-->
<!--#include file="../../../inc/check_secure_programming.asp"-->
<%
CONST str_LRC_LOG_DIRECTRY = "D:\Inetpub\haolog\lesson_reserve_cancel.log"
Select Case Request.Form("Action")
  Case "Reserve"
    Call Reservation()
  Case "Cencel"
    Call CancelReservation()
End Select
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=shift_jis">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ハオ中国語アカデミー　予約・キャンセルシステム</title>
<link href="etc/style.css?v=20260616r4c" rel="stylesheet" type="text/css" media="all">
<link href="etc/calendar.css?v=20260616r4c" rel="stylesheet" type="text/css" media="all">
<script type="text/javascript" language="javascript" src="etc/calendar.js?v=20260616r4c"></script>
</head>
<body>
<div id="mainR" class="reserve-page" style="text-align: center;">
<%
Dim ClassYear, ClassMonth, ClassDate
Dim School, SchoolName
Dim RequestedCourse
Dim SelectedCourseName, SelectedCourseType, SelectedNoRsvtime
Dim HasCourse, HasSchool, HasDate
Dim CourseOptionsHtml, SchoolOptionsHtml
Dim SelectedSchoolValid, CourseCount
Dim CoursePrompt, SchoolPrompt, IntroMessage
Dim LessonCountText, LessonTid
Dim CanShowLessonList
Dim ReservationBackLink
Dim DisplayCourseName
Dim SelectedSchoolName
Dim CourseValue
Dim CourseTypeLabel
Dim RsvLessonCount

ClassYear = Trim(Request.QueryString("ClassYear"))
ClassMonth = Trim(Request.QueryString("ClassMonth"))
ClassDate = Trim(Request.QueryString("ClassDate"))
School = Trim(Request.QueryString("School"))
RequestedCourse = Trim(Request.QueryString("Course"))
If RequestedCourse = "" Then
  RequestedCourse = Trim(Session.Contents("ThisCourse"))
End If

SelectedCourseName = ""
SelectedCourseType = ""
SelectedNoRsvtime = ""
HasCourse = False
HasSchool = False
HasDate = False
CourseOptionsHtml = "<option value="""">----お選び下さい----</option>"
SchoolOptionsHtml = "<option value="""">----お選び下さい----</option>"
SelectedSchoolValid = False
CourseCount = 0
CoursePrompt = "画面上部で受講したいコースを選択してください。"
SchoolPrompt = "画面上部で受講したい学校を選択してください。"
IntroMessage = "画面上部でコースと学校を選ぶと、カレンダーからレッスン日を選べます。"
LessonCountText = ""
CanShowLessonList = False
DisplayCourseName = "コース未選択"
SelectedSchoolName = ""
CourseTypeLabel = "--"
RsvLessonCount = 0
ReservationBackLink = ReserveAsp
If RequestedCourse <> "" Then
  ReservationBackLink = ReserveAsp & "?Course=" & Server.UrlEncode(RequestedCourse)
End If

Set rs = Server.CreateObject("ADODB.Recordset")
SQL = "SELECT coursen, course.course, course_type, norsvtime "
SQL = SQL & "FROM (les INNER JOIN course ON les.course = course.course) INNER JOIN cls_mst_course ON course.course = cls_mst_course.course "
SQL = SQL & "WHERE les.id = '" & Uid & "' AND les.course IN (" & CourseGroup & ") AND expired > '" & Now() & "' "
SQL = SQL & "GROUP BY coursen, course.course, course_type, norsvtime ORDER BY coursen;"
rs.Open SQL, cn, 3, 2

If rs.EOF Then
  rs.Close
  Set rs = Nothing
  LogEvent = "エラー：このアプリケーションで予約できるコースの有効回数がありません。IDは" & Uid
  Call LogRecord()
  Response.Redirect ErrorAsp & "?Message=" & Server.UrlEncode("このシステムで予約･キャンセルできる回数がないようです。")
End If

Do Until rs.EOF
  CourseValue = Trim(rs("course").Value)
  CourseOptionsHtml = CourseOptionsHtml & "<option value=""" & ChkSecXss(CourseValue) & """"
  If RequestedCourse <> "" And RequestedCourse = CourseValue Then
    CourseOptionsHtml = CourseOptionsHtml & " selected"
    SelectedCourseName = rs("coursen").Value
    SelectedCourseType = rs("course_type").Value
    SelectedNoRsvtime = rs("norsvtime").Value
    HasCourse = True
  End If
  CourseOptionsHtml = CourseOptionsHtml & ">" & ChkSecXss(rs("coursen").Value) & "</option>"
  CourseCount = CourseCount + 1
  rs.MoveNext
Loop
rs.Close
Set rs = Nothing

If Not HasCourse And CourseCount = 1 And RequestedCourse = "" Then
  Set rs = Server.CreateObject("ADODB.Recordset")
  SQL = "SELECT TOP 1 coursen, course.course, course_type, norsvtime "
  SQL = SQL & "FROM (les INNER JOIN course ON les.course = course.course) INNER JOIN cls_mst_course ON course.course = cls_mst_course.course "
  SQL = SQL & "WHERE les.id = '" & Uid & "' AND les.course IN (" & CourseGroup & ") AND expired > '" & Now() & "' "
  SQL = SQL & "GROUP BY coursen, course.course, course_type, norsvtime ORDER BY coursen;"
  rs.Open SQL, cn, 3, 2
  If Not rs.EOF Then
    RequestedCourse = Trim(rs("course").Value)
    SelectedCourseName = rs("coursen").Value
    SelectedCourseType = rs("course_type").Value
    SelectedNoRsvtime = rs("norsvtime").Value
    HasCourse = True
  End If
  rs.Close
  Set rs = Nothing
End If

If HasCourse Then
  Session.Contents("ThisCourse") = RequestedCourse
  Session.Contents("ThisCourseName") = SelectedCourseName
  Session.Contents("ThisCourseType") = SelectedCourseType
  Session.Contents("ThisNoRsvtime") = SelectedNoRsvtime
  DisplayCourseName = SelectedCourseName
  If SelectedCourseType = "2" Then
    CourseTypeLabel = "テキスト制"
  Else
    CourseTypeLabel = "講師制"
  End If
Else
  Session.Contents.Remove("ThisCourse")
  Session.Contents.Remove("ThisCourseName")
  Session.Contents.Remove("ThisCourseType")
  Session.Contents.Remove("ThisNoRsvtime")
  Session.Contents.Remove("CourseNumber")
End If

Set rs = Server.CreateObject("ADODB.Recordset")
If HasCourse Then
  SQL = "SELECT cls_mst_course.schoolcd, schooln "
  SQL = SQL & "FROM cls_mst_course INNER JOIN school ON cls_mst_course.schoolcd = school.cd "
  SQL = SQL & "WHERE course = '" & ChkSecSql(RequestedCourse) & "' "
  SQL = SQL & "ORDER BY cls_mst_course.schoolcd;"
Else
  SQL = "SELECT cls_mst_course.schoolcd, schooln "
  SQL = SQL & "FROM ((les INNER JOIN course ON les.course = course.course) INNER JOIN cls_mst_course ON course.course = cls_mst_course.course) INNER JOIN school ON cls_mst_course.schoolcd = school.cd "
  SQL = SQL & "WHERE les.id = '" & ChkSecSql(Uid) & "' AND les.course IN (" & CourseGroup & ") AND expired > '" & Now() & "' "
  SQL = SQL & "GROUP BY cls_mst_course.schoolcd, schooln ORDER BY cls_mst_course.schoolcd;"
End If
rs.Open SQL, cn, 3, 2

If rs.EOF And HasCourse Then
  rs.Close
  Set rs = Nothing
  LogEvent = "エラー：レッスンの予約を行うにあたり、このコースが開講されている学校がcls_mst_courseになかった。IDは" & Uid & "、コースは" & RequestedCourse
  Call LogRecord()
  Response.Redirect ErrorAsp & "?Message=" & Server.UrlEncode("申し訳ありませんが、事務局までご連絡下さい。")
End If

Do Until rs.EOF
  SchoolOptionsHtml = SchoolOptionsHtml & "<option value=""" & ChkSecXss(Trim(rs("schoolcd").Value)) & """"
  If School <> "" And School = Trim(rs("schoolcd").Value) Then
    SchoolOptionsHtml = SchoolOptionsHtml & " selected"
    SelectedSchoolValid = True
    SelectedSchoolName = rs("schooln").Value
  End If
  SchoolOptionsHtml = SchoolOptionsHtml & ">" & ChkSecXss(rs("schooln").Value) & " (" & ChkSecXss(rs("schoolcd").Value) & ")</option>"
  rs.MoveNext
Loop
rs.Close
Set rs = Nothing

If Not SelectedSchoolValid Then
  School = ""
  SelectedSchoolName = ""
End If
HasSchool = (School <> "")
SchoolName = SelectedSchoolName

If HasCourse Then
  Set rs = Server.CreateObject("ADODB.Recordset")
  SQL = "SELECT no FROM les WHERE id = '" & ChkSecSql(Uid) & "' And course = '" & ChkSecSql(RequestedCourse) & "' And class is Null And utt = -1 And expired > '" & Now() & "'"
  rs.Open SQL, cn, 3, 2
  If rs.EOF Then
    RsvLessonCount = 0
    LessonCountText = "残り回数はありません。"
  Else
    RsvLessonCount = rs.RecordCount
    LessonCountText = "残り回数はあと " & RsvLessonCount & " 回です。"
  End If
  rs.Close
  Set rs = Nothing
End If

HasDate = False
If IsNumeric(ClassYear) And IsNumeric(ClassMonth) And IsNumeric(ClassDate) Then
  If Int(ClassDate) >= 1 And Int(ClassDate) <= 31 Then
    HasDate = True
  End If
End If

If HasCourse And HasSchool And HasDate Then
  CanShowLessonList = True
End If

If HasCourse Then
  CoursePrompt = "選択中のコースは「" & SelectedCourseName & "」です。"
End If
If HasSchool Then
  SchoolPrompt = "選択中の学校は「" & SchoolName & "」です。"
ElseIf HasCourse Then
  SchoolPrompt = "学校を選ぶと、このコースで受講できる日程を表示できます。"
End If

If Not HasCourse And Not HasSchool Then
  IntroMessage = "画面上部でコースと学校を選ぶと、カレンダーからレッスン日を選べます。"
ElseIf HasCourse And Not HasSchool Then
  IntroMessage = "次に学校を選んでください。選択後にカレンダーから日付を選べます。"
ElseIf HasCourse And HasSchool And Not HasDate Then
  IntroMessage = SchoolName & " で受講する日付を、右のカレンダーから選んでください。"
ElseIf CanShowLessonList Then
  IntroMessage = ChkSecXss(ClassYear) & "年" & ChkSecXss(ClassMonth) & "月" & ChkSecXss(ClassDate) & "日(" & WeekdayName(Weekday(DateSerial(ClassYear, ClassMonth, ClassDate)), True) & ") " & ChkSecXss(SchoolName) & " で開講予定の " & ChkSecXss(SelectedCourseName) & " を表示しています。"
End If
%>
  <h1 class="site-header"><img src="images/header-img_135080.jpg" width="1350" height="80" alt="ハオ中国語アカデミー"></h1>
  <nav class="process-breadcrumb" aria-label="進行状況">
    <ol class="process-breadcrumb-list">
      <li class="process-breadcrumb-item"><a href="<%= HomeAsp %>">ホーム</a></li>
      <li class="process-breadcrumb-separator" aria-hidden="true">＞</li>
      <li class="process-breadcrumb-item is-current">レッスン予約</li>
    </ol>
  </nav>
  <div class="page-shell">
    <div class="r3-reserve-summary r3-reserve-entry-card">
      <div class="r3-summary-course">
        <span class="r3-summary-label">コース名</span>
        <strong><%= ChkSecXss(DisplayCourseName) %></strong>
        <span class="r3-summary-label">コース種別</span>
        <strong><%= ChkSecXss(CourseTypeLabel) %></strong>
      </div>
      <div class="r3-summary-count">
        <span class="r3-summary-label">残り回数</span>
        <strong><%= ChkSecXss(RsvLessonCount) %></strong><span>回</span>
      </div>
      <form class="r3-summary-school r3-entry-form" action="<%= ReserveAsp %>" method="get">
        <div class="r3-entry-fields">
          <div class="form-field">
            <label class="r3-summary-label" for="Course">コース</label>
            <div class="select-wrap">
              <select name="Course" id="Course" class="form-select" onchange="this.form.submit();">
                <%= CourseOptionsHtml %>
              </select>
            </div>
            <p class="r3-summary-note"><%= ChkSecXss(CoursePrompt) %></p>
          </div>
          <div class="form-field">
            <label class="r3-summary-label" for="School">学校</label>
            <div class="select-wrap">
              <select name="School" id="School" class="form-select" onchange="this.form.submit();">
                <%= SchoolOptionsHtml %>
              </select>
            </div>
            <p class="r3-summary-note"><%= ChkSecXss(SchoolPrompt) %></p>
          </div>
        </div>

        <div class="action-row r3-entry-actions">
          <button type="submit" class="btn btn-primary">この内容で表示</button>
        </div>
      </form>
    </div>

    <div class="calendar-layout reserve-calendar-layout<% If Not CanShowLessonList Then %> reserve-calendar-layout-intro<% End If %>">
      <div class="r3-calendar-legend reserve-calendar-guide-card">
        <p class="section-title">日付を選択してください</p>
        <p class="copy-text"><span class="strong"><%= IntroMessage %></span></p>
        <ul>
          <li><span class="r3-legend-blue">青字</span>：予約可能な日</li>
          <li><span class="r3-legend-light">オレンジ背景</span>：本日</li>
          <li><span class="r3-legend-strong">オレンジ背景（濃）</span>：選択中の日</li>
          <li><span class="r3-legend-gray">グレー</span>：過去の日</li>
        </ul>
<% If Not CanShowLessonList Then %>
        <p class="r3-summary-note">コースと学校がそろうと、カレンダーから日付を選べます。</p>
        <div class="action-row">
          <a href="<%= ReservationBackLink %>" class="btn btn-neutral">選択をリセット</a>
        </div>
<% End If %>
      </div>
      <div class="calendar-panel calendar-panel-stacked reserve-calendar-panel"><script type="text/javascript">ShowCalendar();</script></div>
    </div>

<% If CanShowLessonList Then %>
    <div class="calendar-guide calendar-guide-stacked">
      <p class="section-title">予約可能なクラス</p>
<% If Len(Message) > 0 Then %>
      <p class="reservation-message"><%= ChkSecXss(Message) %></p>
<% End If %>
      <p class="copy-text"><span class="strong"><%= IntroMessage %></span></p>
      <div class="notice-box">
        <ul class="notice-list">
          <li>クラスの始まる <%= Session.Contents("ThisNoRsvtime") %> 時間前を過ぎたクラス</li>
          <li>満席のクラス</li>
          <li>ご予約済クラスと同じ時間に開講されるクラス</li>
        </ul>
      </div>
    </div>
<%
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
        <a href="<%= ReservationBackLink %>" class="btn btn-neutral">選択を見直す</a>
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
      ReDim ReservedClass(0,3)
    Else
      ReDim ReservedClass(rs2.RecordCount - 1, 3)
      i = 0
      Do Until rs2.EOF
        ReservedClass(i, 0) = rs2("class").Value
        ReservedClass(i, 1) = rs2("stime").Value
        ReservedClass(i, 2) = rs2("etime").Value
        ReservedClass(i, 3) = rs2("course").Value
        rs2.MoveNext
        i = i + 1
      Loop
    End If
    rs2.Close
    Set rs2 = Nothing
%>
    <div class="section-card schedule-card"><form id="reserve-form" action="<%= ReserveAsp %>?Course=<%= ChkSecXss(RequestedCourse) %>&ClassYear=<%= ChkSecXss(ClassYear) %>&ClassMonth=<%= ChkSecXss(ClassMonth) %>&ClassDate=<%= ChkSecXss(ClassDate) %>&School=<%= ChkSecXss(School) %>" method="post"><div class="schedule-grid">
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
      LessonStime = rs("stime").Value
      LessonEtime = rs("etime").Value
      ClsTotal = rs("total").Value
      ClsCd = rs("class_buffer").Value

      Select Case Session.Contents("ThisCourseType")
        Case "1"
          LessonTeacher = rs("cname").Value
        Case "2"
          LessonTeacher = rs("text_name").Value & "　" & rs("lesson_name").Value
      End Select
%>
            <tr>
              <td>
<%
      If (LessonStime > DateAdd("h", Session.Contents("ThisNoRsvtime"), Now())) And (ClsTotal > 0) Then
%>
                <input type="radio" id="ReserveCls_<%= ChkSecXss(ClsCd) %>" name="ReserveCls" value="<%= ChkSecXss(ClsCd) %>"
<%
        For i = 0 To UBound(ReservedClass)
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
      For i = 0 To UBound(ReservedClass)
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
      </div><input type="hidden" name="Action" value="Reserve"></form></div><div class="section-card reserve-actions-card"><div class="action-row"><a href="<%= ReservationBackLink %>" class="btn btn-neutral">選択を見直す</a><button type="submit" form="reserve-form" class="btn btn-primary">予約する</button></div></div>
    <div class="reservation-status-wrap">
    <div class="calendar-guide calendar-guide-stacked reservation-status-guide">
      <p class="section-title">予約状況</p>
      <p class="copy-text"><span class="strong"><%= ChkSecXss(ClassYear) %>年<%= ChkSecXss(ClassMonth) %>月<%= ChkSecXss(ClassDate) %>日の予約済みレッスンです。</span></p>
    </div>
<%
    Dim rsBooked
    Dim BookedLessonTeacher
    Dim HasCancelableBooked
    HasCancelableBooked = False
    Set rsBooked = Server.CreateObject("ADODB.Recordset")
    Select Case Session.Contents("ThisCourseType")
      Case "1"
        SQL = "SELECT les.class, cls_mirror.stime, cls_mirror.etime, schooln, cname "
        SQL = SQL & "FROM ((les INNER JOIN cls_mirror ON (les.class = cls_mirror.class_buffer) AND (les.course = cls_mirror.course)) INNER JOIN school ON cls_mirror.schoolcd = school.cd) INNER JOIN cls_mst_teacher ON cls_mirror.tid = cls_mst_teacher.teacher_id "
        SQL = SQL & "WHERE les.id = '" & ChkSecSql(Uid) & "' AND les.course = '" & ChkSecSql(Session.Contents("ThisCourse")) & "' AND les.class Is Not Null AND les.utt = -1 AND (cls_mirror.stime Between '" & DateSerial(ClassYear, ClassMonth, ClassDate) & "' And '" & DateAdd("d", 1, DateSerial(ClassYear, ClassMonth, ClassDate)) & "') AND cls_mirror.schoolcd = '" & ChkSecSql(School) & "' "
        SQL = SQL & "ORDER BY cls_mirror.stime, cls_mirror.tid;"
      Case "2"
        SQL = "SELECT les.class, cls_mirror.stime, cls_mirror.etime, schooln, text_name, lesson_name "
        SQL = SQL & "FROM (((les INNER JOIN cls_mirror ON (les.class = cls_mirror.class_buffer) AND (les.course = cls_mirror.course)) INNER JOIN school ON cls_mirror.schoolcd = school.cd) LEFT JOIN cls_lno_mst ON (cls_mirror.lno = cls_lno_mst.lno) AND (cls_mirror.course = cls_lno_mst.course)) LEFT JOIN cls_text_mst ON (cls_mirror.textid = cls_text_mst.textid) AND (cls_mirror.course = cls_text_mst.course) "
        SQL = SQL & "WHERE les.id = '" & ChkSecSql(Uid) & "' AND les.course = '" & ChkSecSql(Session.Contents("ThisCourse")) & "' AND les.class Is Not Null AND les.utt = -1 AND (cls_mirror.stime Between '" & DateSerial(ClassYear, ClassMonth, ClassDate) & "' And '" & DateAdd("d", 1, DateSerial(ClassYear, ClassMonth, ClassDate)) & "') AND cls_mirror.schoolcd = '" & ChkSecSql(School) & "' "
        SQL = SQL & "ORDER BY cls_mirror.stime, cls_mirror.textid;"
    End Select
    rsBooked.Open SQL, cn, 3, 2
    If rsBooked.EOF Then
%>
    <div class="section-card reservation-status-card">
      <p class="empty-state">この日付・学校で予約済みのレッスンはありません。</p>
    </div>
<%
    Else
%>
    <div class="section-card schedule-card reservation-status-card"><form id="cancel-form" action="<%= ReserveAsp %>?Course=<%= ChkSecXss(RequestedCourse) %>&ClassYear=<%= ChkSecXss(ClassYear) %>&ClassMonth=<%= ChkSecXss(ClassMonth) %>&ClassDate=<%= ChkSecXss(ClassDate) %>&School=<%= ChkSecXss(School) %>" method="post"><div class="schedule-grid">
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
      Do Until rsBooked.EOF
        LessonStime = rsBooked("stime").Value
        LessonEtime = rsBooked("etime").Value
        ClsCd = Trim(rsBooked("class").Value)
        Select Case Session.Contents("ThisCourseType")
          Case "1"
            BookedLessonTeacher = rsBooked("cname").Value
          Case "2"
            BookedLessonTeacher = rsBooked("text_name").Value & "　" & rsBooked("lesson_name").Value
        End Select
%>
            <tr>
              <td>
<%      If LessonStime > DateAdd("h", Session.Contents("ThisNoRsvtime"), Now()) Then
          HasCancelableBooked = True
%>
                <input type="radio" id="CancelCls_<%= ChkSecXss(ClsCd) %>" name="CancelCls" value="<%= ChkSecXss(ClsCd) %>">
<%      End If %>
              </td>
              <td data-label="レッスン時刻"><label class="schedule-choice-label" for="CancelCls_<%= ChkSecXss(ClsCd) %>"><%= Hour(LessonStime) %>:<%= Right("0" & Minute(LessonStime), 2) %>～<%= Hour(LessonEtime) %>:<%= Right("0" & Minute(LessonEtime), 2) %></label></td>
              <td data-label="内容"><label class="schedule-choice-label" for="CancelCls_<%= ChkSecXss(ClsCd) %>"><%= ChkSecXss(BookedLessonTeacher) %></label></td>
              <td data-label="状態"><label class="schedule-choice-label" for="CancelCls_<%= ChkSecXss(ClsCd) %>"><% If LessonStime > DateAdd("h", Session.Contents("ThisNoRsvtime"), Now()) Then Response.Write("<span class=""status-chip"">予約済</span>") Else Response.Write("<span class=""muted"">キャンセル締切後</span>") End If %></label></td>
            </tr>
<%
        rsBooked.MoveNext
      Loop
%>
          </tbody>
        </table>
      </div><input type="hidden" name="Action" value="Cencel"></form></div><div class="section-card reserve-actions-card cancel-actions-card"><div class="action-row"><button type="submit" form="cancel-form" class="btn btn-danger"<% If Not HasCancelableBooked Then Response.Write(" disabled=""disabled""") End If %>>キャンセルする</button></div></div>
<%
    End If
    rsBooked.Close
    Set rsBooked = Nothing
%>
    </div>

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
      Elseif rs("total").Value = 0 Then
        LogEvent = "エラー：予約しようとしたが、レッスンの予約を行うことができませんでした。他の方に既に予約されてしまったようです。IDは" & Uid & "、コースは" & Session.Contents("ThisCourse")
        Call LogRecord()
        Response.Redirect "error.asp?Message=" & Server.UrlEncode("レッスンの予約を行うことができませんでした。<br>他の方に既に予約されてしまったようです。")
      Else
        ClsTotal = rs("total").Value
        LessonStime = rs("stime").Value
        LessonEtime = rs("etime").Value
        LessonTid = Trim(rs("tid").Value)
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

          LesNo = rs("no").Value
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
Private Function CancelReservation()
    Dim strStime, strSchoolCd
    Dim intNo
    Dim strPastDateTime, strNow
    Dim strMailTo
    Dim strMailBody
    Dim strSvName, strMailFrom, strSubj, bobj, rc

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

          strPastDateTime = DateAdd("h", -72, strStime)
          strNow = Now()
          strMailTo = ""
          Set rs = Server.CreateObject("ADODB.Recordset")
          SQL = "SELECT mailaddr FROM school WHERE cd='" & ChkSecSql(strSchoolCd) & "';"
          rs.Open SQL, cn, 3, 2
          If Not rs.EOF Then
            strMailTo = rs("mailaddr").value
          End If
          rs.close

          If strMailTo <> "" Then
            strMailBody = ""
            Set fso = Server.CreateObject("Scripting.FileSystemObject")
            Set otf = fso.OpenTextFile(Server.Mappath("cancelmail_info.txt"), 1)
            strMailBody = otf.ReadAll
            otf.Close
            Set otf = Nothing
            Set fso = Nothing
            strMailBody = Replace(strMailBody, "%number%", intNo)
            strMailBody = Replace(strMailBody, "%entrydate%", Left(Now,16))

            strSvName = Application("MailServerAddr_heteml")
            strMailFrom = "no-repry@haonet.co.jp"
            strSubj = "レッスンキャンセル発生のお知らせ"
            Set bobj = Server.CreateObject("basp21")
            Set bobj = Nothing
          End If
        End If
      End If
    End If
End Function
%>



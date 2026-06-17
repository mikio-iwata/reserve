<% @LANGUAGE = "VBScript" CodePage=932 %>
<% Option Explicit %>
<% Response.Buffer = True %>
<% Session.CodePage = 932 %>
<!--#INCLUDE FILE="etc\include.inc"-->
<%
Session.Contents.Remove("ThisCourse")
Session.Contents.Remove("ThisCourseName")
Session.Contents.Remove("ThisCourseType")
Session.Contents.Remove("ThisNoRsvtime")
Session.Contents.Remove("CourseNumber")

Select Case Request.Form("Action")
  Case "Submit"
    If Request.Form("SelectCourse") = "" Then
      LogEvent = "エラー：コース選択画面でコースが選択されませんでした。IDは" & Uid
      Call LogRecord()
      Response.Redirect ErrorAsp & "?Message=" & Server.UrlEncode("コースが選択されていません。")
    Else
      Dim SelectCourse
      SelectCourse = Split(Request.Form("SelectCourse"), ",")

      Session.Contents("ThisCourse") = SelectCourse(0)
      Session.Contents("ThisCourseName") = SelectCourse(1)
      Session.Contents("ThisCourseType") = SelectCourse(2)
      Session.Contents("ThisNoRsvtime") = SelectCourse(3)
      Session.Contents("CourseNumber") = 2

      LogEvent = "コースが選択されました。IDは" & Uid & "、コースCDは" & Session.Contents("ThisCourse")
      Call LogRecord()
      Response.Redirect MainAsp
    End If

  Case Else
    SQL = "SELECT coursen, course.course, course_type, norsvtime "
    SQL = SQL & "FROM (les INNER JOIN course ON les.course = course.course) INNER JOIN cls_mst_course ON course.course = cls_mst_course.course "
    SQL = SQL & "WHERE les.id = '" & Uid & "' AND les.course IN (" & CourseGroup & ") AND expired > '" & Now() & "' "
    SQL = SQL & "GROUP BY coursen, course.course, course_type, norsvtime;"

    Set rs = Server.CreateObject("ADODB.Recordset")
    rs.Open SQL, cn, 3, 2

    If rs.EOF Then
      LogEvent = "エラー：このアプリケーションで予約できるコースの有効回数がありません。IDは" & Uid
      Call LogRecord()
      Response.Redirect ErrorAsp & "?Message=" & Server.UrlEncode("このシステムで予約･キャンセルできる回数がないようです。")
    ElseIf rs.RecordCount = 1 Then
      Session.Contents("ThisCourse") = rs("course").value
      Session.Contents("ThisCourseName") = rs("coursen").value
      Session.Contents("ThisCourseType") = rs("course_type").value
      Session.Contents("ThisNoRsvtime") = rs("norsvtime").value
      Session.Contents("CourseNumber") = 1

      Response.Redirect MainAsp
    Else
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
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
  <nav class="process-breadcrumb" aria-label="進行状況">
    <ol class="process-breadcrumb-list">
      <li class="process-breadcrumb-item"><a href="<%= HomeAsp %>">ホーム</a></li>
      <li class="process-breadcrumb-separator" aria-hidden="true">＞</li>
      <li class="process-breadcrumb-item is-current">レッスン予約システム コースの選択</li>
    </ol>
  </nav>
  <div class="page-shell">
    <div class="section-card">
      <p class="lead">予約・キャンセルしたいコースを選択し、「次へ」を押してください。</p>
    </div>

    <% ' A hidden input sits before action-row, so CSS spacing uses a general sibling selector. %>
    <form action="<%= IndexAsp %>" method="post">
      <div class="course-list">
<%    Do Until rs.EOF %>
        <div class="course-item">
          <label class="choice-control">
            <input type="radio" name="SelectCourse" value="<%=rs("course").value %>,<%=rs("coursen").value %>,<%=rs("course_type").value %>,<%=rs("norsvtime").value %>">
            <span>
              <span class="choice-title"><%=rs("coursen").value %></span>
              <span class="choice-meta">コースを選択して、予約画面へ進みます。</span>
            </span>
          </label>
        </div>
<%      rs.MoveNext
      Loop
%>
      </div>
      <input type="hidden" name="Action" value="Submit">
      <div class="action-row">
        <a href="javascript:window.close();" class="btn btn-neutral">閉じる</a>
        <button type="submit" class="btn btn-primary">次へ</button>
      </div>
    </form>

    <p class="copyright">Copyright 2007 HAO Chinese Academy. All rights reserved.</p>
  </div>
</div>
</body>
</html>
<%
    End If
  rs.Close
Set rs = Nothing
End Select
Set cn = Nothing
%>

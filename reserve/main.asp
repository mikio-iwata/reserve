<% @LANGUAGE = "VBScript" %>
<% Option Explicit %>
<% Response.Buffer = True %>
<% Uid = "520010000" %>
<%
'--------------------------------------------------------------
' 更新履歴
' 日付				更新者				更新内容
'--------------------------------------------------------------
' 2025/01/14		l-inter			キャンセルログ出力機能追加
'--------------------------------------------------------------
%>
<!--#INCLUDE FILE="etc\include.inc"-->
<%
'キャンセルログファイルパス指定
CONST str_LRC_LOG_DIRECTRY = "D:\Inetpub\haolog\lesson_reserve_cancel.log"

'************************************************************************
'　選択されたコース情報に関するセッションチェック
'************************************************************************
Call SessionCourseCheck()

'************************************************************************
'　この画面で予約がサブミットされた場合
'************************************************************************
Select Case Request.Form("Action")
  Case "Reserve"

'◆Schoolが入力されているか確認
    If Request.Form("School") = "" Then

      LogEvent = "エラー：レッスン予約時に学校名が選択されていないようです。IDは" & Uid & "、コースは" & Session.Contents("ThisCourse")
      Call LogRecord()
      Response.Redirect ErrorAsp & "?Message=" & Server.UrlEncode("学校名が選択されていないようです。")


'◆入力されたSchoolをCookieに格納
    Else

      Response.Cookies("School") = Request.Form("School")
      Response.Cookies("School").Expires = Date + 365



'◆予約希望日時と学校名をＧＥＴで渡してReserve.aspににリダイレクト

      LogEvent = "レッスンの予約にあたり希望日、スクールが選択されました。IDは" & Uid & "、コースは" & Session.Contents("ThisCourse") & "、希望日は" & Request.Form("ClassYear") & "/" & Request.Form("ClassMonth") & "/" & Request.Form("ClassDate") & "、スクールＣＤは" & Request.Form("School") & "です。"
      Call LogRecord()
      Response.Redirect ReserveAsp & "?School=" & Request.Form("School")
    End If


'************************************************************************
'　この画面でキャンセルがサブミットされた場合
'************************************************************************
  Case "Cencel"

'◆キャンセルしたいクラスが選択されているか確認
    If Request.Form("CancelCls") = "" Then

      LogEvent = "エラー：キャンセルするクラスが選択されていないようです。IDは" & Uid & "、コースは" & Session.Contents("ThisCourse")
      Call LogRecord()
      Response.Redirect ErrorAsp & "?Message=" & Server.UrlEncode("キャンセルするクラスが選択されていないようです。")


'◆ClassMirror上で、キャンセル可能なクラスかどうか確認
    Else

      SelectedCls = Request.Form("CancelCls")
      Set rs = Server.CreateObject("ADODB.Recordset")

	'SQL = "Select total, maxtotal FROM cls_mirror WHERE class_buffer = '" & SelectedCls & "' And course = '" & Session.Contents("ThisCourse") & "' And stime > '" & DateAdd("h", Int(Session.Contents("ThisNoRsvtime")), Now()) & "'"
	SQL = "Select total, maxtotal, stime, schoolcd FROM cls_mirror WHERE class_buffer = '" & SelectedCls & "' And course = '" & Session.Contents("ThisCourse") & "' And stime > '" & DateAdd("h", Int(Session.Contents("ThisNoRsvtime")), Now()) & "'"
	rs.Open SQL, cn, 3, 2


'	◆キャンセル可能なクラスがなかった
	If rs.EOF Then

	  LogEvent = "エラー：レッスンのキャンセルを行うことができませんでした。キャンセル可能時刻を過ぎている可能性があります。IDは" & Uid & "、コースは" & Session.Contents("ThisCourse")
	  Call LogRecord()
          Response.Redirect ErrorAsp & "?Message=" & Server.UrlEncode("レッスンのキャンセルを行うことができませんでした。<br>キャンセル可能時刻を過ぎている可能性があります。")


'	◆クラス予約人数と定員が同数だった
	Elseif rs("total").value = rs("maxtotal").value Then

	  LogEvent = "エラー：レッスンのキャンセルを行うことができませんでした。クラス予約人数と定員が同数。IDは" & Uid & "、コースは" & Session.Contents("ThisCourse")
	  Call LogRecord()
	  Response.Redirect ErrorAsp & "?Message=" & Server.UrlEncode("レッスンのキャンセルを行うことができませんでした。<br>既にキャンセルされていないかご確認下さい。")


	Else
	  ClsTotal = rs("total").value'		そのクラスの残席数を取得

	  'クラスの開始時間を取得
	  Dim strStime,strSchoolCd
	  strStime = rs("stime").value
	  strSchoolCd =  rs("schoolcd").value

	  rs.Close
	  Set rs = Nothing


'	◆ＤＢ更新処理

	  Set rs = Server.CreateObject("ADODB.Recordset")
	    SQL = "SELECT no FROM les "
	    SQL = SQL & "WHERE id = '" & Uid & "' And course = '" & Session.Contents("ThisCourse") & "' And class = '" & SelectedCls & "' And utt = -1"
	    rs.Open SQL, cn, 3, 2

	    If rs.EOF Then

	      LogEvent = "エラー：レッスンのキャンセルを行うことができませんでした。Lesのナンバーで該当するレコードなし。IDは" & Uid & "、コースは" & Session.Contents("ThisCourse")
	      Call LogRecord()
	      Response.Redirect ErrorAsp & "?Message=" & Server.UrlEncode("レッスンのキャンセルを行うことができませんでした。<br>既にキャンセルされていないかご確認下さい。")

'◆	キャンセル処理
	    Else

'	　トランザクションの開始
	      cn.BeginTrans


	      LesNo = rs("no").value
	      rs.Close
	      Set rs = Nothing


'◆	lesでのクラス削除処理
	      SQL = "UPDATE les SET class = Null WHERE no = '" & LesNo & "'"
	      cn.Execute SQL
	      LogEvent = "キャンセルにあたりLesテーブルの更新を行いました。IDは" & Uid & "、Classは" & SelectedCls & "、LesNoは" & LesNo & "、コースは" & Session.Contents("ThisCourse")
	      Call LogRecord()


'◆	cls_mirrorの定員処理（予約人数を１増やす）
	      SQL = "UPDATE cls_mirror SET total = " & ClsTotal + 1 & " WHERE class_buffer = '" & SelectedCls & "' And Course = '" & Session.Contents("ThisCourse") & "'"
	      cn.Execute SQL
	      LogEvent = "キャンセルにあたりcls_mirrorテーブルの更新を行いました。IDは" & Uid & "、Classは" & SelectedCls & "、コースは" & Session.Contents("ThisCourse")
	      Call LogRecord()


'◆clsの定員処理（予約人数を１増やす）
	      SQL = "UPDATE cls SET total = " & ClsTotal + 1 & " WHERE class = '" & SelectedCls & "' And Course = '" & Session.Contents("ThisCourse") & "'"
	      cn.Execute SQL
	      LogEvent = "キャンセルにあたりclsテーブルの更新を行いました。IDは" & Uid & "、Classは" & SelectedCls & "、コースは" & Session.Contents("ThisCourse") & "。キャンセル処理が完了しました"
	      Call LogRecord()

	      Message = "レッスンのキャンセルを行いました。"

'◆レッスンキャンセルテーブル登録処理
			SQL = "INSERT INTO lesson_cancel(class,course,stime,etime,tid,schoolcd,cancel_id,doer_id)"
			SQL = SQL & "SELECT class_buffer,course,stime,etime,tid,schoolcd," & Uid & "," & Uid
			SQL = SQL & " FROM cls_mirror WHERE class_buffer = '" & SelectedCls & "' And course = '" & Session.Contents("ThisCourse") & "';"
			cn.Execute SQL

			'管理番号の取得
			Dim intNo
			intNo = 0
	  		Set rs = Server.CreateObject("ADODB.Recordset")
			SQL = "SELECT IDENT_CURRENT('lesson_cancel') AS NO;"
			rs.Open SQL, cn, 3, 2
			IF Not rs.EOF Then
				intNo = rs("NO").value
			End If
			rs.close

'	　トランザクションの終了
	      cn.CommitTrans

'◆キャンセルログ出力処理
			Dim fso
			Dim otf
			Dim strLog
			strLog = Now() & "【生徒 ID:" & Uid & "】クラス" & SelectedCls & "より個人ＩＤ:" & Uid & "の予約をキャンセル。"
			Set fso = CreateObject("Scripting.FileSystemObject")
			'テキストファイルを追記モードで開く。ファイルが無い場合は作成、SJIS
			Set otf = fso.OpenTextFile(str_LRC_LOG_DIRECTRY, 8, True, 0)
			'文字列を書き込む
			otf.WriteLine strLog
			'テキストファイルを閉じる
			otf.Close
			Set otf = Nothing
			Set fso = Nothing

'◆キャンセルメール送信処理、開始時間の72時間以内の場合
			'クラス開始時間の72時間前の日時を取得
			Dim strPastDateTime,strNow
			strPastDateTime = DateAdd("h", -72, strStime)
			strNow = Now()
'デバック
Response.Write "strStime：" & strStime & "<br>"
Response.Write "strPastDateTime：" & strPastDateTime & "<br>"
			
'デバック	日付縛りをコメントアウト
			'If strNow >= strPastDateTime Then	'レッスン開始時間の72時間以内の場合

				'メールToの取得
				Dim strMailTo
				strMailTo = ""
		  		Set rs = Server.CreateObject("ADODB.Recordset")
				SQL = "SELECT mailaddr FROM school WHERE cd='" & strSchoolCd & "';"
				rs.Open SQL, cn, 3, 2
				IF Not rs.EOF Then
					strMailTo = rs("mailaddr").value
				End If
				rs.close

				If strMailTo <> "" Then		'strMailToが空でなければメールの送信
				
					'メール本文の作成
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
				
					'メールの送信
					Dim strSvName,strMailFrom,strSubj,bobj,rc
					strSvName = Application("MailServerAddr_heteml")		'wwwroot/globl.asa
					strMailFrom = "no-repry@haonet.co.jp"
					strSubj = "レッスンキャンセル発生のお知らせ"
					Set bobj = Server.CreateObject("basp21")
'デバック	送信のコメントアウト
					'rc = bobj.SendMailEx(str_LRC_LOG_DIRECTRY,strSvName,strMailTo,strMailFrom,strSubj,strMailBody,"")
					Set bobj = Nothing

'デバック	メールの表示
Response.Write "strSvName：" & strSvName & "<br>"
Response.Write "strMailTo：" & strMailTo & "<br>"
Response.Write "strMailFrom：" & strMailFrom & "<br>"
Response.Write "strSubj：" & strSubj & "<br>"
Response.Write "strMailBody：<br>" & Replace(strMailBody,vbCrLf,"<br>") & "<br>"

				End If
					
'デバック	日付縛りをコメントアウト
			'End If

	    End If

	End If

    End If

End Select
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
<h2>レッスンの予約・キャンセル―<span class="blue"><%= Session.Contents("ThisCourseName") %></span></h2>
<table id="formtable">
  <tr>
    <td><br><p><span class="strong"><%= Message %></span></p>

	<p><span class="strong">●レッスンの予約</span></p><p>
<%
'************************************************************
'　残予約回数を取得
'　　条件：courseがSession.Contents("ThisCourseName")、clsがnull、uttが-1
'************************************************************
Set rs = Server.CreateObject("ADODB.Recordset")
  SQL = "SELECT no FROM les WHERE id = '" & Uid & "' And course = '" & Session.Contents("ThisCourse") & "' And class is Null And utt = -1 And expired > '" & Now() & "'"
  rs.Open SQL, cn, 3, 2


'◆回数がなければエラー画面へ
  If rs.EOF Then
    Response.Write("残回数がないので、ご予約できません。")
    rs.Close


'◆回数があれば、残回数取得
  Else

    LessonCount = rs.RecordCount
    rs.Close
Set rs = Nothing
%>
<form action="<%= MainAsp %>" method="post">
    <font color = "blue"><%= Session.Contents("ThisCourseName") %> </font>のご予約可能回数は、あと<span class="strong"><%= LessonCount %></span>回です。<br>受講希望の学校名を選択し、「次へ」ボタンを押してください。</p></td>
  </tr>
</table>
<table id="formtable" align="center">
  <tr>
    <td>
      <select name="School">
	<option value="">----お選び下さい----</option>
<%
'************************************************************
'　そのコースが開講されている学校名を取得
'************************************************************
    Set rs = Server.CreateObject("ADODB.Recordset")
      SQL = "SELECT cls_mst_course.schoolcd, schooln "
      SQL = SQL & "FROM cls_mst_course INNER JOIN school ON cls_mst_course.schoolcd = school.cd "
      SQL = SQL & "WHERE course = '" & Session.Contents("ThisCourse") & "' "
      SQL = SQL & "ORDER BY cls_mst_course.schoolcd;"
      rs.Open SQL, cn, 3, 2


'◆このコースが開講されている学校がなかった
      If rs.EOF Then
        LogEvent = "エラー：レッスンの予約を行うにあたり、このコースが開講されている学校がcls_mst_courseになかった。IDは" & Uid & "、コースは" & Session.Contents("ThisCourse")
        Call LogRecord()
        Response.Redirect ErrorAsp & "?Message=" & Server.UrlEncode("申し訳ありませんが、事務局までご連絡下さい。")


'◆学校名を表示
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
    </td>
  </tr>
  <tr>
    <td class="action-row back-button-row" height="100" valign="middle">
<%
'************************************************************
'　有効コースが２つ以上ある場合のみ戻るボタンをつける
'************************************************************
    If Int(Session.Contents("CourseNumber")) > 1 Then
%>
    <a href="<%= IndexAsp %>"><img src="images/back.gif" width="105" height="49" alt="戻る" border="0"></a>

<%  End If %>
    <input type="image" src="images/next.gif" width="105" height="49" alt="次へ" border="0"></td>
  </tr>
</table>
</form>
<% End If%>

<p id="attention"></p>

<p><br><span class="strong">●レッスンのキャンセル</span></p><p>
<%
'************************************************************
'　予約済レッスンを取得
'  11/08/27　語研 大畠変更－公開されていないクラスは表示しない
'************************************************************
Set rs = Server.CreateObject("ADODB.Recordset")

  Select Case Session.Contents("ThisCourseType")

'◆マンツーマン系コースの場合（教師を表示する場合）
    Case "1"
      SQL = "SELECT class_buffer AS class, stime, etime, cname "
      SQL = SQL & "FROM les INNER JOIN cls_mirror ON (les.course = cls_mirror.course AND les.class = cls_mirror.class_buffer) INNER JOIN cls_mst_teacher ON cls_mirror.tid = cls_mst_teacher.teacher_id "
      SQL = SQL & "WHERE cls_mirror.etime > '" & Now() & "' AND les.id = '" & Uid & "' AND les.course = '" & Session.Contents("ThisCourse") & "' AND cls_mst_teacher.del_flag = '0' AND cls_mirror.flag='0' "
      SQL = SQL & "ORDER BY stime;"


'◆グループ系コースの場合（テキストとレッスン番号を表示する場合）
    Case "2"
      SQL = "SELECT class_buffer AS class, stime, etime, text_name, lesson_name "
      SQL = SQL & "FROM les INNER JOIN ((cls_mirror LEFT JOIN cls_lno_mst ON (cls_mirror.lno = cls_lno_mst.lno) AND (cls_mirror.course = cls_lno_mst.course)) LEFT JOIN cls_text_mst ON (cls_mirror.textid = cls_text_mst.textid) AND (cls_mirror.course = cls_text_mst.course)) ON (les.class = cls_mirror.class_buffer) AND (les.course = cls_mirror.course) "
      SQL = SQL & "WHERE cls_mirror.etime > '" & Now() & "' AND les.id = '" & Uid & "' AND les.course = '" & Session.Contents("ThisCourse") & "' AND cls_mirror.flag='0' "
      SQL = SQL & "ORDER BY stime;"

    Case Else
      LogEvent = "セッションエラー：セッションよりCourseTypeが取得できませんでした。IDは" & Uid
      Call LogRecord()
      Response.Redirect "error.asp?Message=" & Server.UrlEncode("コース種別を取得できませんでした。<br>恐れ入りますが事務局までご連絡下さい。")

  End Select

  rs.Open SQL, cn, 3, 2
  If rs.EOF Then
    Response.Write("ご予約レッスンがありませんのでキャンセルはできません。</p>")
'************************************************************
'　有効コースが２つ以上ある場合のみ戻るボタンをつける
'************************************************************
    If Int(Session.Contents("CourseNumber")) > 1 Then
%>
  <table id="formtable" align="center">
    <tr>
      <td class="action-row back-button-row" height="100"><a href="<%= IndexAsp %>"><img src="images/back.gif" width="105" height="49" alt="戻る" border="0"></a></td>
    </tr>
  </table>
<%
    End If
  Else
    Response.Write("<form action=" & MainAsp & " method=post>")
    Response.Write("<font color = blue>" & Session.Contents("ThisCourseName") & "</font>でご予約済のレッスンは下記のとおりです。キャンセルしたいレッスンがあればを選択し、「キャンセル」ボタンを押してください。<br>(レッスンの始まる" & Session.Contents("ThisNoRsvtime") & "時間前を過ぎたレッスンはキャンセルできません。)</p><br>")

    Do Until rs.EOF


'◆予約済レッスンを変数に格納し表示
      LessonStime = rs("stime").value
      LessonEtime = rs("etime").value

      Select Case Session.Contents("ThisCourseType")
	Case "1"
	  LessonTeacher = "教師名:" & rs("cname").value
	Case "2"
	  LessonTeacher = rs("text_name").value & "&nbsp;" & rs("lesson_name").value
    End Select

      Response.Write("<font color = blue>　　　　　")

      If LessonStime > DateAdd("h", Session.Contents("ThisNoRsvtime"), Now()) Then
%>
	<input type="radio" name="CancelCls" value="<%= Trim(rs("class").value) %>">

<% Else %>
	&nbsp;&nbsp;&nbsp;&nbsp;
<%
      End If

      Response.Write(Month(LessonStime) & "月" & Day(LessonStime) & "日(" & WeekdayName(Weekday(LessonStime), True) & ")")
      Response.Write("　")
      Response.Write(Hour(LessonStime) & ":" & Right("0" & Minute(LessonStime), 2))
      Response.Write("～")
      Response.Write(Hour(LessonEtime) & ":" & Right("0" & Minute(LessonEtime), 2))
      Response.Write("　")
      Response.Write(LessonTeacher)
      Response.Write("</font>")
      Response.Write("<br>")

      rs.MoveNext
    Loop
%>
<table id="formtable" align="center">
  <tr>
    <td class="action-row" height="100"><input type="image" src="images/cancel.gif" width="105" height="49" alt="キャンセルする" border="0"></td>
  </tr>
</table>
	<input type="hidden" name="action" value="Cencel">
</form>
<%
  End If
  rs.Close
Set rs = Nothing
%>
<table id="formtable">
  <tr>
    <td height="20" valign="bottom"><img src="images/dot_gray.gif" width="500" height="1"></td>
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
Set cn = Nothing
%>

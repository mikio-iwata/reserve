<%
'************************************************************
'　変数定義
'************************************************************
'◆ファイル名関連
Dim IndexAsp'			初期画面（コース選択）ＡＳＰのファイル名
    IndexAsp = "index.asp"
Dim IndexAspForSmartPhone'	初期画面（コース選択）ＡＳＰのファイル名
    IndexAspForSmartPhone = "index_sp.asp"
Dim MainAsp'			予約・キャンセル決定画面ＡＳＰのファイル名
    MainAsp = "main.asp"
Dim MainAspForSmartPhone'	予約・キャンセル決定画面ＡＳＰのファイル名
    MainAspForSmartPhone = "main_sp.asp"
Dim ReserveAsp'			予約画面ＡＳＰのファイル名
    ReserveAsp = "reserve.asp"
Dim ReserveAspForSmartPhone'	予約画面ＡＳＰのファイル名
    ReserveAspForSmartPhone = "reserve_sp.asp"
Dim ErrorAsp'			エラー画面ＡＳＰのファイル名
    ErrorAsp = "error.asp"


'◆コース関連
Dim CourseGroup'		このアプリケーションが扱うコース
    CourseGroup = "'76', '77', '79', '95', '73', '74', '47', '48', '46', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40', '41', '43', '53', '54', '55', '56', '58', '61', '20', '21', '22', '23', '24', '25', '29'"


'◆クラス関連
Dim LessonCount'		残レッスン回数
Dim LessonStime, LessonEtime, LessonTeacher'	予約済レッスン開始時刻、終了時刻、教師名（グループ系コースの場合には、テキスト＆レッスン番号）

Dim SelectedCls'		キャンセル、予約するレッスンのクラス
Dim ClsTotal'			そのクラスのもともとの定員
Dim LesNo'			キャンセル、予約時に使用するLesのナンバー
Dim ClsCd'			レッスンのクラスＣＤ

'◆ユーザ関連
Dim Uid'			個人ＩＤ
'    If Len(Request.QueryString("Uid")) > 0 Then'		*******開発用*******
'      Uid = Trim(Request.QueryString("Uid"))'				*******開発用*******
'      Session.Contents("Uid") = Uid'				*******開発用*******
'    Else'							*******開発用*******
'      Uid = Trim(Session.Contents("uid"))
'    End If'							*******開発用*******


'◆データベース関連
Dim cn, rs, SQL'		ＳＱＬのための関数


'◆ログ関連
Dim LogEvent, strPath, fs, ts'	ログ保存のための関数


'◆その他
Dim i'				ループのための変数
Dim Message'			予約・キャンセル等の表示メッセージ

'******************************************************************
'　キャッシュ禁止
'******************************************************************
Response.Expires = 0
Response.Expiresabsolute = Now() - 1
Response.AddHeader "pragma","no-cache"
Response.AddHeader "cache-control","private"
Response.CacheControl = "no-cache"
Response.CodePage = 932
Response.Charset = "shift_jis"
Session.CodePage = 932


'************************************************************
'　データベース接続
'************************************************************
Set cn = Server.CreateObject("ADODB.Connection")
  cn.Mode = 3
'2014/11/21 LIF edit
'      cn.Open Application("dsn")
  cn.Open "DSN=mother;UID=sa;PASSWORD=minami1022;"
'  cn.Open "DSN=father;UID=sa;PASSWORD=minami1022;"'			*******開発用*******

    If Err.Number <> 0 Then
      Response.Redirect "error.asp?Message=" & Server.UrlEncode("データベース接続エラーが発生しました。もう一度おためし下さい。")
    End If



'************************************************************
'　セッションチェック
'************************************************************
'個人ＩＤ

If IsNull(Session.Contents("uid")) = True Or Session.Contents("uid") = "" Then 

  LogEvent = "エラー：個人ＩＤのセッションが切れました"
  Call LogRecord()
  Response.Redirect "error.asp?Message=" & Server.UrlEncode("サーバとの接続が切断されました。恐れ入りますがもう一度ログインを行ってください。")
End If
Uid = Trim(Session.Contents("uid"))

'コース情報
Private Sub SessionCourseCheck()

  If Len(Session.Contents("ThisCourse")) = 0 OR Len(Session.Contents("ThisCourseName")) = 0 OR Len(Session.Contents("ThisCourseType")) = 0 OR Len(Session.Contents("ThisNoRsvtime")) = 0 Then

    LogEvent = "エラー：コース情報のセッションが切れました"
    Call LogRecord()
    Response.Redirect "error.asp?Message=" & Server.UrlEncode("サーバとの接続が切断されました。恐れ入りますがもう一度ログインを行ってください。")

  End If

End Sub


'************************************************************
'　ログ保存のための関数
'************************************************************
Private Sub LogRecord()
  Dim fallbackPath, logDir

  On Error Resume Next

  strPath = "c:\log\hao\student_reservation.txt"
  fallbackPath = Server.MapPath("../student_reservation.txt")
  logDir = "c:\log\hao"

  Set fs = Server.CreateObject("Scripting.FileSystemObject")

  If Not fs.FolderExists(logDir) Then
    If Not fs.FolderExists("c:\log") Then
      fs.CreateFolder("c:\log")
    End If
    fs.CreateFolder(logDir)
  End If

  Set ts = fs.OpenTextFile(strPath, 8, True)
  If Err.Number <> 0 Then
    Err.Clear
    Set ts = fs.OpenTextFile(fallbackPath, 8, True)
  End If

  If Err.Number = 0 Then
    ts.WriteLine("")
    ts.WriteLine("【記録日時】" & Now())
    ts.WriteLine("【発生事象】" & LogEvent)
    ts.Close
    Set ts = Nothing
  End If

  Set fs = Nothing
  On Error GoTo 0

End Sub
%>
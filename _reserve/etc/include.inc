<%
'************************************************************
'　共通設定 / 共通ユーティリティ
'　この include は以下の役割を持つ
'　1. 画面遷移先のファイル名定義
'　2. 業務で利用する共通変数の宣言
'　3. DB 接続の初期化
'　4. セッション検証と簡易ログ出力
'************************************************************
'------------------------------------------------------------
' 画面ファイル名
' ASP 本体はこの名前を参照して画面遷移する
'------------------------------------------------------------
Dim IndexAsp'			初期画面（コース選択）ＡＳＰのファイル名
    IndexAsp = "index.asp"
Dim HomeAsp'			ホーム画面ＡＳＰのファイル名
    HomeAsp = "/netcampus/hao/login_new/login2.asp"
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


'------------------------------------------------------------
' 業務設定
'------------------------------------------------------------
Dim CourseGroup'		このアプリケーションが扱うコース
    CourseGroup = "'76', '77', '79', '95', '73', '74', '47', '48', '46', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40', '41', '43', '53', '54', '55', '56', '58', '61', '20', '21', '22', '23', '24', '25', '29'"


'------------------------------------------------------------
' 画面・業務処理で共有する変数
' Classic ASP の構造上、本体 ASP から暗黙利用される
'------------------------------------------------------------
Dim LessonCount'		残レッスン回数
Dim LessonStime, LessonEtime, LessonTeacher'	予約済レッスン開始時刻、終了時刻、教師名（グループ系コースの場合には、テキスト＆レッスン番号）

Dim SelectedCls'		キャンセル、予約するレッスンのクラス
Dim ClsTotal'			そのクラスのもともとの定員
Dim LesNo'			キャンセル、予約時に使用するLesのナンバー
Dim ClsCd'			レッスンのクラスＣＤ

Dim Uid'			個人ＩＤ


Dim cn, rs, SQL'		ＳＱＬのための関数


Dim LogEvent, strPath, fs, ts'	ログ保存のための関数


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


'************************************************************
'　データベース接続
'　接続失敗時は共通エラー画面へ遷移する
'************************************************************
Set cn = Server.CreateObject("ADODB.Connection")
  cn.Mode = 3
'2014/11/21 LIF edit
'      cn.Open Application("dsn")
  On Error Resume Next
  cn.Open "DSN=mother;UID=sa;PASSWORD=minami1022;"
  If Err.Number <> 0 Then
    On Error GoTo 0
    Response.Redirect "error.asp?Message=" & Server.UrlEncode("データベース接続エラーが発生しました。もう一度おためし下さい。")
  End If
  On Error GoTo 0



'************************************************************
'　セッションチェック
'　Uid は全画面で必須のため include 読み込み時に検証する
'************************************************************

If IsNull(Session.Contents("uid")) = True Or Session.Contents("uid") = "" Then 

  LogEvent = "エラー：個人ＩＤのセッションが切れました"
  Call LogRecord()
  Response.Redirect "error.asp?Message=" & Server.UrlEncode("サーバとの接続が切断されました。恐れ入りますがもう一度ログインを行ってください。")
End If
Uid = Trim(Session.Contents("uid"))
' コース情報は index.asp 通過後に保持される前提
Private Sub SessionCourseCheck()

  If Len(Session.Contents("ThisCourse")) = 0 OR Len(Session.Contents("ThisCourseName")) = 0 OR Len(Session.Contents("ThisCourseType")) = 0 OR Len(Session.Contents("ThisNoRsvtime")) = 0 Then

    LogEvent = "エラー：コース情報のセッションが切れました"
    Call LogRecord()
    Response.Redirect "error.asp?Message=" & Server.UrlEncode("サーバとの接続が切断されました。恐れ入りますがもう一度ログインを行ってください。")

  End If

End Sub


'************************************************************
'　ログ保存のための関数
'　ファイル書き込み失敗時のハンドリングは持たない簡易ログ
'************************************************************
Private Sub LogRecord()

strPath = "c:\log\hao\student_reservation.txt"
Set fs = Server.CreateObject("Scripting.FileSystemObject")
  Set ts = fs.OpenTextFile(strPath,8,True)

  ts.WriteLine("")
  ts.WriteLine("【記録日時】" & Now())
  ts.WriteLine("【発生事象】" & LogEvent)

  ts.Close
  Set ts = Nothing

Set fs= Nothing

End Sub
%>

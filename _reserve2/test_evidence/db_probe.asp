<%@ LANGUAGE="VBScript" CodePage=932 %>
<% Option Explicit %>
<%
Response.Buffer = True
Response.ContentType = "application/json"
Response.Charset = "shift_jis"

Dim classBuffer, courseCd, uid
classBuffer = Trim(Request.QueryString("class_buffer"))
courseCd = Trim(Request.QueryString("course"))
uid = Trim(Request.QueryString("uid"))

If classBuffer = "" Or courseCd = "" Then
  Response.Status = "400 Bad Request"
  Response.Write "{""error"":""class_buffer and course are required""}"
  Response.End
End If

Dim cn, rs, sql
Dim clsTotal, clsMaxTotal, clsStime
Dim liveClsTotal
Dim lesCount
clsTotal = ""
clsMaxTotal = ""
clsStime = ""
liveClsTotal = ""
lesCount = ""

Set cn = Server.CreateObject("ADODB.Connection")
cn.Mode = 3
cn.Open "DSN=mother;UID=sa;PASSWORD=minami1022;"

Set rs = Server.CreateObject("ADODB.Recordset")
sql = "SELECT TOP 1 class_buffer, course, total, maxtotal, CONVERT(varchar, stime, 120) AS stime FROM cls_mirror " & _
      "WHERE class_buffer = '" & Replace(classBuffer, "'", "''") & "' AND course = '" & Replace(courseCd, "'", "''") & "'"
rs.Open sql, cn, 3, 1

If rs.EOF Then
  Response.Write "{""found"":false}"
Else
  clsTotal = rs("total").Value
  clsMaxTotal = rs("maxtotal").Value
  clsStime = rs("stime").Value
End If

rs.Close
Set rs = Nothing

Set rs = Server.CreateObject("ADODB.Recordset")
sql = "SELECT TOP 1 total FROM cls WHERE class = '" & Replace(classBuffer, "'", "''") & "' AND course = '" & Replace(courseCd, "'", "''") & "'"
rs.Open sql, cn, 3, 1
If Not rs.EOF Then
  liveClsTotal = rs("total").Value
End If
rs.Close
Set rs = Nothing

If uid <> "" Then
  Set rs = Server.CreateObject("ADODB.Recordset")
  sql = "SELECT COUNT(*) AS les_count FROM les WHERE id = '" & Replace(uid, "'", "''") & "' AND course = '" & Replace(courseCd, "'", "''") & "' AND class = '" & Replace(classBuffer, "'", "''") & "' AND utt = -1"
  rs.Open sql, cn, 3, 1
  If Not rs.EOF Then
    lesCount = rs("les_count").Value
  End If
  rs.Close
  Set rs = Nothing
End If

If clsTotal <> "" Then
  Response.Write "{""found"":true,""class_buffer"":""" & classBuffer & """,""course"":""" & courseCd & """,""cls_mirror_total"":" & clsTotal & ",""cls_mirror_maxtotal"":" & clsMaxTotal & ",""cls_total"":" & liveClsTotal & ",""stime"":""" & clsStime & """"
  If uid <> "" Then
    Response.Write ",""uid"":""" & uid & """,""les_count"":" & lesCount
  End If
  Response.Write "}"
End If

cn.Close
Set cn = Nothing
%>

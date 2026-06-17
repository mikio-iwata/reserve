<%@ LANGUAGE="VBScript" CodePage=932 %>
<% Option Explicit %>
<%
Response.Buffer = True
Response.ContentType = "application/json"
Response.Charset = "shift_jis"

Dim classBuffer, courseCd
classBuffer = Trim(Request.QueryString("class_buffer"))
courseCd = Trim(Request.QueryString("course"))

If classBuffer = "" Or courseCd = "" Then
  Response.Status = "400 Bad Request"
  Response.Write "{""error"":""class_buffer and course are required""}"
  Response.End
End If

Function Q(value)
  Q = Replace(value, "'", "''")
End Function

Function J(value)
  If IsNull(value) Then
    J = ""
  Else
    J = Replace(CStr(value), """", "\""")
  End If
End Function

Dim cn, rs, sql
Dim textId, lno, textName, lessonName, textExists, lnoExists
textId = ""
lno = ""
textName = ""
lessonName = ""
textExists = 0
lnoExists = 0

Set cn = Server.CreateObject("ADODB.Connection")
cn.Mode = 3
cn.Open "DSN=mother;UID=sa;PASSWORD=minami1022;"

Set rs = Server.CreateObject("ADODB.Recordset")
sql = "SELECT TOP 1 cls_mirror.textid, cls_mirror.lno, cls_text_mst.text_name, cls_lno_mst.lesson_name " & _
      "FROM (cls_mirror LEFT JOIN cls_lno_mst ON (cls_mirror.lno = cls_lno_mst.lno) AND (cls_mirror.course = cls_lno_mst.course)) " & _
      "LEFT JOIN cls_text_mst ON (cls_mirror.textid = cls_text_mst.textid) AND (cls_mirror.course = cls_text_mst.course) " & _
      "WHERE cls_mirror.class_buffer = '" & Q(classBuffer) & "' AND cls_mirror.course = '" & Q(courseCd) & "'"
rs.Open sql, cn, 3, 1

If Not rs.EOF Then
  textId = J(rs("textid").Value)
  lno = J(rs("lno").Value)
  textName = J(rs("text_name").Value)
  lessonName = J(rs("lesson_name").Value)
End If
rs.Close
Set rs = Nothing

Set rs = Server.CreateObject("ADODB.Recordset")
sql = "SELECT COUNT(*) AS cnt FROM cls_text_mst WHERE course = '" & Q(courseCd) & "' AND textid = '" & Q(textId) & "'"
rs.Open sql, cn, 3, 1
If Not rs.EOF Then textExists = rs("cnt").Value
rs.Close
Set rs = Nothing

Set rs = Server.CreateObject("ADODB.Recordset")
sql = "SELECT COUNT(*) AS cnt FROM cls_lno_mst WHERE course = '" & Q(courseCd) & "' AND lno = '" & Q(lno) & "'"
rs.Open sql, cn, 3, 1
If Not rs.EOF Then lnoExists = rs("cnt").Value
rs.Close
Set rs = Nothing

Response.Write "{""class_buffer"":""" & J(classBuffer) & """,""course"":""" & J(courseCd) & """,""textid"":""" & textId & """,""lno"":""" & lno & """,""text_name"":""" & textName & """,""lesson_name"":""" & lessonName & """,""cls_text_mst_match"":" & textExists & ",""cls_lno_mst_match"":" & lnoExists & "}"

cn.Close
Set cn = Nothing
%>

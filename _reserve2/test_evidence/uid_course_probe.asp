<%@ LANGUAGE="VBScript" CodePage=932 %>
<% Option Explicit %>
<%
Response.Buffer = True
Response.ContentType = "text/plain"
Response.Charset = "shift_jis"

Dim uid
uid = Trim(Request.QueryString("uid"))
If uid = "" Then uid = "3070"

Function Q(value)
  Q = Replace(value, "'", "''")
End Function

Dim cn, rs, sql
Set cn = Server.CreateObject("ADODB.Connection")
cn.Mode = 3
cn.Open "DSN=mother;UID=sa;PASSWORD=minami1022;"

sql = "SELECT coursen, course.course, norsvtime " & _
      "FROM (les INNER JOIN course ON les.course = course.course) INNER JOIN cls_mst_course ON course.course = cls_mst_course.course " & _
      "WHERE les.id = '" & Q(uid) & "' AND les.course IN ('76', '77', '79', '95', '73', '74', '47', '48', '46', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40', '41', '43', '53', '54', '55', '56', '58', '61', '20', '21', '22', '23', '24', '25', '29') AND les.expired > GETDATE() " & _
      "GROUP BY coursen, course.course, norsvtime " & _
      "ORDER BY course.course"

Set rs = Server.CreateObject("ADODB.Recordset")
rs.Open sql, cn, 3, 1

Do Until rs.EOF
  Response.Write rs("course").Value & "|" & rs("coursen").Value & "|" & rs("norsvtime").Value & vbCrLf
  rs.MoveNext
Loop

rs.Close
Set rs = Nothing
cn.Close
Set cn = Nothing
%>

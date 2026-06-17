<%@ LANGUAGE="VBScript" CodePage=932 %>
<% Option Explicit %>
<%
Response.Buffer = True
Response.ContentType = "text/plain"
Response.Charset = "shift_jis"

Dim uid, courseCd
uid = Trim(Request.QueryString("uid"))
courseCd = Trim(Request.QueryString("course"))
If uid = "" Then uid = "3070"
If courseCd = "" Then courseCd = "61"

Function Q(value)
  Q = Replace(value, "'", "''")
End Function

Dim cn, rs, sql
Set cn = Server.CreateObject("ADODB.Connection")
cn.Mode = 3
cn.Open "DSN=mother;UID=sa;PASSWORD=minami1022;"

sql = "SELECT class_buffer AS class, CONVERT(varchar, stime, 120) AS stime_txt, CONVERT(varchar, etime, 120) AS etime_txt, " & _
      "ISNULL(CONVERT(varchar, cls_mirror.tid), '') AS tid_txt, ISNULL(cname, '') AS cname_txt " & _
      "FROM les INNER JOIN cls_mirror ON (les.course = cls_mirror.course AND les.class = cls_mirror.class_buffer) " & _
      "INNER JOIN cls_mst_teacher ON cls_mirror.tid = cls_mst_teacher.teacher_id " & _
      "WHERE cls_mirror.etime > GETDATE() AND les.id = '" & Q(uid) & "' AND les.course = '" & Q(courseCd) & "' AND cls_mst_teacher.del_flag = '0' AND cls_mirror.flag='0' " & _
      "ORDER BY stime;"

Set rs = Server.CreateObject("ADODB.Recordset")
rs.Open sql, cn, 3, 1

Do Until rs.EOF
  Response.Write rs("class").Value & "|" & rs("stime_txt").Value & "|" & rs("etime_txt").Value & "|" & rs("tid_txt").Value & "|" & rs("cname_txt").Value & vbCrLf
  rs.MoveNext
Loop

rs.Close
Set rs = Nothing
cn.Close
Set cn = Nothing
%>

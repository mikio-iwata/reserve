<%@ LANGUAGE="VBScript" CodePage=932 %>
<% Option Explicit %>
<%
Response.Buffer = True
Response.ContentType = "text/plain"
Response.Charset = "shift_jis"

Dim courseCd, schoolCd, fromDate, toDate, uid, noRsvHours
courseCd = Trim(Request.QueryString("course"))
schoolCd = Trim(Request.QueryString("school"))
fromDate = Trim(Request.QueryString("from"))
toDate = Trim(Request.QueryString("to"))
uid = Trim(Request.QueryString("uid"))
noRsvHours = Trim(Request.QueryString("no_rsv"))

If courseCd = "" Or schoolCd = "" Or fromDate = "" Or toDate = "" Then
  Response.Write "course, school, from, to are required"
  Response.End
End If

Dim cn, rs, sql
Set cn = Server.CreateObject("ADODB.Connection")
cn.Mode = 3
cn.Open "DSN=mother;UID=sa;PASSWORD=minami1022;"

sql = "SELECT class_buffer, CONVERT(varchar, stime, 120) AS stime_txt, CONVERT(varchar, etime, 120) AS etime_txt, total, " & _
      "ISNULL(text_name, '') AS text_name, ISNULL(lesson_name, '') AS lesson_name " & _
      "FROM (cls_mirror LEFT JOIN cls_lno_mst ON (cls_mirror.lno = cls_lno_mst.lno) AND (cls_mirror.course = cls_lno_mst.course)) " & _
      "LEFT JOIN cls_text_mst ON (cls_mirror.textid = cls_text_mst.textid) AND (cls_mirror.course = cls_text_mst.course) " & _
      "WHERE cls_mirror.course = '" & Replace(courseCd, "'", "''") & "' " & _
      "AND schoolcd = '" & Replace(schoolCd, "'", "''") & "' " & _
      "AND stime >= '" & Replace(fromDate, "'", "''") & "' " & _
      "AND stime < '" & Replace(toDate, "'", "''") & "' " & _
      "AND cls_mirror.flag = '0' " & _
      "ORDER BY stime, class_buffer"

Set rs = Server.CreateObject("ADODB.Recordset")
rs.Open sql, cn, 3, 1

Do Until rs.EOF
  Response.Write rs("class_buffer").Value & "|" & rs("stime_txt").Value & "|" & rs("etime_txt").Value & "|" & rs("total").Value & "|" & rs("text_name").Value & "|" & rs("lesson_name").Value

  If uid <> "" Then
    Dim rs2, sql2
    Set rs2 = Server.CreateObject("ADODB.Recordset")
    sql2 = "SELECT COUNT(*) AS reserved_count FROM les WHERE id = '" & Replace(uid, "'", "''") & "' AND course = '" & Replace(courseCd, "'", "''") & "' AND class = '" & Replace(rs("class_buffer").Value, "'", "''") & "' AND utt = -1"
    rs2.Open sql2, cn, 3, 1
    If Not rs2.EOF Then
      Response.Write "|reserved=" & rs2("reserved_count").Value
    End If
    rs2.Close
    Set rs2 = Nothing
  End If

  Response.Write vbCrLf
  rs.MoveNext
Loop

rs.Close
Set rs = Nothing
cn.Close
Set cn = Nothing
%>

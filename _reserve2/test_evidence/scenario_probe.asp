<%@ LANGUAGE="VBScript" CodePage=932 %>
<% Option Explicit %>
<%
Response.Buffer = True
Response.ContentType = "text/plain"
Response.Charset = "shift_jis"

Dim uid, courseCd, schoolCd, fromDate, toDate, noRsvHours
uid = Trim(Request.QueryString("uid"))
courseCd = Trim(Request.QueryString("course"))
schoolCd = Trim(Request.QueryString("school"))
fromDate = Trim(Request.QueryString("from"))
toDate = Trim(Request.QueryString("to"))
noRsvHours = Trim(Request.QueryString("no_rsv"))

If uid = "" Then uid = "3070"
If schoolCd = "" Then schoolCd = "5221"
If fromDate = "" Then fromDate = "2026-06-17 00:00:00"
If toDate = "" Then toDate = "2026-07-31 23:59:59"
If noRsvHours = "" Then noRsvHours = "12"

If courseCd = "" Then
  Response.Write "course is required"
  Response.End
End If

Function Q(value)
  Q = Replace(value, "'", "''")
End Function

Dim cn, rs, sql
Set cn = Server.CreateObject("ADODB.Connection")
cn.Mode = 3
cn.Open "DSN=mother;UID=sa;PASSWORD=minami1022;"

sql = "SELECT class_buffer, CONVERT(varchar, stime, 120) AS stime_txt, CONVERT(varchar, etime, 120) AS etime_txt, " & _
      "stime, etime, total, ISNULL(tid, '') AS tid " & _
      "FROM cls_mirror " & _
      "WHERE course = '" & Q(courseCd) & "' " & _
      "AND schoolcd = '" & Q(schoolCd) & "' " & _
      "AND stime >= '" & Q(fromDate) & "' " & _
      "AND stime <= '" & Q(toDate) & "' " & _
      "AND flag = '0' " & _
      "ORDER BY stime, class_buffer"

Set rs = Server.CreateObject("ADODB.Recordset")
rs.Open sql, cn, 3, 1

Do Until rs.EOF
  Dim classBuffer, stimeVal, etimeVal, totalVal
  Dim rs2, sql2, bookedCount, overlapCount
  Dim isBooked, isOverlap, isClosed, isFull, status

  classBuffer = rs("class_buffer").Value
  stimeVal = rs("stime").Value
  etimeVal = rs("etime").Value
  totalVal = rs("total").Value

  bookedCount = 0
  overlapCount = 0

  Set rs2 = Server.CreateObject("ADODB.Recordset")
  sql2 = "SELECT COUNT(*) AS cnt FROM les WHERE id = '" & Q(uid) & "' AND course = '" & Q(courseCd) & "' AND class = '" & Q(classBuffer) & "' AND utt = -1"
  rs2.Open sql2, cn, 3, 1
  If Not rs2.EOF Then bookedCount = rs2("cnt").Value
  rs2.Close
  Set rs2 = Nothing

  Set rs2 = Server.CreateObject("ADODB.Recordset")
  sql2 = "SELECT COUNT(*) AS cnt FROM les INNER JOIN cls ON (cls.class = les.class) AND (cls.course = les.course) " & _
         "WHERE les.id = '" & Q(uid) & "' AND les.utt = -1 " & _
         "AND NOT ('" & Year(stimeVal) & "-" & Right("0" & Month(stimeVal),2) & "-" & Right("0" & Day(stimeVal),2) & " " & Right("0" & Hour(stimeVal),2) & ":" & Right("0" & Minute(stimeVal),2) & ":" & Right("0" & Second(stimeVal),2) & "' >= cls.etime " & _
         "OR '" & Year(etimeVal) & "-" & Right("0" & Month(etimeVal),2) & "-" & Right("0" & Day(etimeVal),2) & " " & Right("0" & Hour(etimeVal),2) & ":" & Right("0" & Minute(etimeVal),2) & ":" & Right("0" & Second(etimeVal),2) & "' <= cls.stime)"
  rs2.Open sql2, cn, 3, 1
  If Not rs2.EOF Then overlapCount = rs2("cnt").Value
  rs2.Close
  Set rs2 = Nothing

  isBooked = (bookedCount > 0)
  isOverlap = (overlapCount > 0)
  isClosed = (stimeVal <= DateAdd("h", CInt(noRsvHours), Now()))
  isFull = (totalVal = 0)

  If isBooked Then
    status = "booked"
  ElseIf isFull Then
    status = "full"
  ElseIf isClosed Then
    status = "closed"
  ElseIf isOverlap Then
    status = "overlap"
  Else
    status = "available"
  End If

  Response.Write classBuffer & "|" & rs("stime_txt").Value & "|" & rs("etime_txt").Value & "|" & totalVal & _
                 "|booked=" & bookedCount & "|overlap=" & overlapCount & "|status=" & status & vbCrLf

  rs.MoveNext
Loop

rs.Close
Set rs = Nothing
cn.Close
Set cn = Nothing
%>

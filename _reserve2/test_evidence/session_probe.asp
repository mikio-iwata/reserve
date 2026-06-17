<%@ LANGUAGE="VBScript" CodePage=932 %>
<% Option Explicit %>
<%
Response.Buffer = True
Response.ContentType = "application/json"
Response.Charset = "shift_jis"

Function Js(value)
  If IsNull(value) Then
    Js = ""
  Else
    Js = Replace(CStr(value), """", "\""")
  End If
End Function

Response.Write "{"
Response.Write """uid"":""" & Js(Session.Contents("uid")) & ""","
Response.Write """ThisCourse"":""" & Js(Session.Contents("ThisCourse")) & ""","
Response.Write """ThisCourseName"":""" & Js(Session.Contents("ThisCourseName")) & ""","
Response.Write """ThisCourseType"":""" & Js(Session.Contents("ThisCourseType")) & ""","
Response.Write """ThisNoRsvtime"":""" & Js(Session.Contents("ThisNoRsvtime")) & ""","
Response.Write """CourseNumber"":""" & Js(Session.Contents("CourseNumber")) & """"
Response.Write "}"
%>

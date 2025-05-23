<%@ page session="true" contentType="text/html" pageEncoding="UTF-8" %>
<%
    // Invalidar sesión actual
    HttpSession sesionOk = request.getSession(false); // false para evitar crear sesión si no existe
    if (sesionOk != null) {
        sesionOk.invalidate();
    }
%>
<jsp:forward page="Login.jsp" />

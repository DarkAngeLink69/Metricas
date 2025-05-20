<%@ page session="true" contentType="text/html" pageEncoding="UTF-8" %>
<%-- 
    CerrarSesion.jsp 
    Este archivo invalida la sesión actual y redirige al login.
--%>

<%
    // Invalidar sesión actual
    HttpSession sesionOk = request.getSession(false); // false para evitar crear sesión si no existe
    if (sesionOk != null) {
        sesionOk.invalidate();
    }
%>

<jsp:forward page="Login.jsp" />

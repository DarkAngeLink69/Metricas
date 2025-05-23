<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, modelo.MenuDelDiaDAO, modelo.MenuDelDiaDAO.MenuDelDia" %>
<%
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("id_usuario") == null) {
%>
<jsp:forward page="Login.jsp">
    <jsp:param name="error" value="Es obligatorio identificarse"/>
</jsp:forward>
<%
        return;
    }

    String plantel = (String) sesion.getAttribute("plantel");
    MenuDelDiaDAO dao = new MenuDelDiaDAO();
    Map<String, Map<String, MenuDelDia>> semana = dao.obtenerMenuSemanal(plantel);

    String[] dias = {"Lunes", "Martes", "Miércoles", "Jueves", "Viernes"};
    Calendar cal = Calendar.getInstance();
    cal.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY);
    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");
%>
<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8">
        <title>Menú Semanal</title>
        <link rel="stylesheet" href="css/bootstrap.min.css">
        <style>
            body {
                font-family: Calibri, sans-serif;
                margin-top: 70px;
            }
            .calendario {
                display: grid;
                grid-template-columns: repeat(5, 1fr);
                gap: 15px;
            }
            .dia {
                border: 2px solid #27487D;
                border-radius: 12px;
                padding: 20px;
                min-height: 320px;
                background-color: #f8f9fa;
                font-size: 16px;
            }
            .dia h5 {
                color: #27487D;
            }
            .registro {
                margin-top: 15px;
            }
            .btn-sm {
                margin-top: 10px;
                width: 100%;
                font-weight: bold;
            }
        </style>
    </head>
    <body>
        <jsp:include page="AdminInicio.jsp" />
        <div class="container">
            <hr><!-- comment -->
            <hr><!-- comment -->

            <h3>Menú semanal - Plantel <%= plantel%></h3>
            <div class="calendario">
                <%
                    for (int i = 0; i < 5; i++) {
                        String fecha = sdf.format(cal.getTime());
                        Map<String, MenuDelDia> dia = semana.get(fecha);
                %>
                <div class="dia">
                    <h5><%= dias[i]%><br><small><%= fecha%></small></h5>

                    <%-- DESAYUNO --%>
                    <%
                        MenuDelDia desayuno = (dia != null) ? dia.get("Desayuno") : null;
                        if (desayuno != null) {
                    %>
                    <div class="registro text-primary">
                        ☀ <strong>Desayuno:</strong> <%= desayuno.platoPrincipal%>
                        <form method="get" action="AgregarMenu.jsp">
                            <input type="hidden" name="id" value="<%= desayuno.id%>">
                            <button class="btn btn-warning btn-sm">✏️</button>
                        </form>
                        <form action="AdminCRUD.jsp" method="post" onsubmit="return confirm('¿Eliminar desayuno del <%= fecha%>?');">
                            <input type="hidden" name="id" value="<%= desayuno.id%>">
                            <input type="hidden" name="fecha" value="<%= fecha%>">
                            <input type="hidden" name="accion" value="eliminar">
                            <input type="hidden" name="tipo" value="Desayuno">
                            <button class="btn btn-danger btn-sm">🗑️</button>
                        </form>
                    </div>
                    <% } else {%>
                    <form method="post" action="AgregarMenu.jsp">
                        <input type="hidden" name="fecha" value="<%= fecha%>">
                        <input type="hidden" name="tipo" value="Desayuno">
                        <button type="submit" class="btn btn-outline-primary btn-sm">Agregar desayuno</button>
                    </form>
                    <% } %>

                    <%-- COMIDA --%>
                    <%
                        MenuDelDia comida = (dia != null) ? dia.get("Comida") : null;
                        if (comida != null) {
                    %>
                    <div class="registro text-danger">
                        🍽 <strong>Comida:</strong> <%= comida.platoPrincipal%>
                        <form method="get" action="AgregarMenu.jsp">
                            <input type="hidden" name="id" value="<%= comida.id%>">
                            <button class="btn btn-warning btn-sm">✏️</button>
                        </form>
                        <form action="AdminCRUD.jsp" method="post" onsubmit="return confirm('¿Eliminar comida del <%= fecha%>?');">
                            <input type="hidden" name="id" value="<%= comida.id%>">
                            <input type="hidden" name="fecha" value="<%= fecha%>">
                            <input type="hidden" name="accion" value="eliminar">
                            <input type="hidden" name="tipo" value="Comida">
                            <button class="btn btn-danger btn-sm">🗑️</button>
                        </form>
                    </div>
                    <% } else {%>
                    <form method="post" action="AgregarMenu.jsp">
                        <input type="hidden" name="fecha" value="<%= fecha%>">
                        <input type="hidden" name="tipo" value="Comida">
                        <button type="submit" class="btn btn-outline-danger btn-sm">Agregar comida</button>
                    </form>
                    <% } %>
                </div>
                <%
                        cal.add(Calendar.DATE, 1);
                    }
                %>
            </div>
        </div>
    </body>
</html>

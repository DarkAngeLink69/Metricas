<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page session="true" import="java.sql.*, java.util.*, controlador.Conexion2" %>
<%
    HttpSession Sesion = request.getSession(false);
    if (Sesion == null || Sesion.getAttribute("id_usuario") == null) {
%>
<jsp:forward page="Login.jsp">
    <jsp:param name="error" value="Es obligatorio identificarse"/>
</jsp:forward>
<%
    }
    String plantel = (String) session.getAttribute("plantel");
    Conexion2 con = new Conexion2();
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
            .registro form {
                display: inline;
            }
            .navbar-custom {
                background-color: #3c1224;
            }
            .navbar-custom .navbar-brand,
            .navbar-custom .nav > li > a {
                color: white;
            }
            .navbar-custom .nav > li > a:hover {
                background-color: #27487D;
                color: white;
            }
        </style>
    </head>
    <body>
        <jsp:include page="AdminInicio.jsp" />
        <div class="container">
            <hr><!-- comment -->
            <hr><!-- comment -->
            <h3>Menú semanal - Plantel <%= plantel %></h3>
            <div class="calendario">
                <%
                    String[] dias = {"Lunes", "Martes", "Miércoles", "Jueves", "Viernes"};
                    Calendar cal = Calendar.getInstance();
                    cal.set(Calendar.DAY_OF_WEEK, Calendar.MONDAY);
                    java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");

                    for (int i = 0; i < 5; i++) {
                        String fecha = sdf.format(cal.getTime());

                        // Consulta desayuno parametrizada
                        String sqlDesayuno = "SELECT id, plato_principal FROM menu_deldia WHERE fecha = ? AND tipo = 'Desayuno' AND plantel = ?";
                        con.setRs(sqlDesayuno, fecha, plantel);
                        ResultSet rsDes = con.getRs();
                        boolean hayDesayuno = rsDes.next();
                        String desayuno = null;
                        String idDesayuno = null;
                        if (hayDesayuno) {
                            desayuno = rsDes.getString("plato_principal");
                            idDesayuno = rsDes.getString("id");
                        }
                        rsDes.close();

                        // Consulta comida parametrizada
                        String sqlComida = "SELECT id, plato_principal FROM menu_deldia WHERE fecha = ? AND tipo = 'Comida' AND plantel = ?";
                        con.setRs(sqlComida, fecha, plantel);
                        ResultSet rsCom = con.getRs();
                        boolean hayComida = rsCom.next();
                        String comida = null;
                        String idComida = null;
                        if (hayComida) {
                            comida = rsCom.getString("plato_principal");
                            idComida = rsCom.getString("id");
                        }
                        rsCom.close();
                %>
                <div class="dia">
                    <h5><%= dias[i] %><br><small><%= fecha %></small></h5>

                    <% if (hayDesayuno) { %>
                    <div class="registro text-primary">
                        ☀ <strong style="color:#1a73e8;">Desayuno:</strong> <%= desayuno %>
                        <form method="get" action="AgregarMenu.jsp">
                            <input type="hidden" name="id" value="<%= idDesayuno %>">
                            <button class="btn btn-warning btn-sm">✏️</button>
                        </form>
                        <form action="AdminCRUD.jsp" method="post" onsubmit="return confirm('¿Eliminar desayuno del <%= fecha %>?');">
                            <input type="hidden" name="fecha" value="<%= fecha %>">
                            <input type="hidden" name="id" value="<%= idDesayuno %>">
                            <input type="hidden" name="accion" value="eliminar">
                            <input type="hidden" name="tipo" value="Desayuno">
                            <button class="btn btn-danger btn-sm">🗑️</button>
                        </form>
                    </div>
                    <% } else { %>
                    <form method="post" action="AgregarMenu.jsp">
                        <input type="hidden" name="fecha" value="<%= fecha %>">
                        <input type="hidden" name="tipo" value="Desayuno">
                        <button type="submit" class="btn btn-outline-primary btn-sm">Agregar desayuno</button>
                    </form>
                    <% } %>

                    <% if (hayComida) { %>
                    <div class="registro text-danger">
                        🍽 <strong style="color:#d93025;">Comida:</strong> <%= comida %>
                        <form method="get" action="AgregarMenu.jsp">
                            <input type="hidden" name="id" value="<%= idComida %>">
                            <button class="btn btn-warning btn-sm">✏️</button>
                        </form>
                        <form action="AdminCRUD.jsp" method="post" onsubmit="return confirm('¿Eliminar comida del <%= fecha %>?');">
                            <input type="hidden" name="id" value="<%= idComida %>">
                            <input type="hidden" name="fecha" value="<%= fecha %>">
                            <input type="hidden" name="accion" value="eliminar">
                            <input type="hidden" name="tipo" value="Comida">
                            <button class="btn btn-danger btn-sm">🗑️</button>
                        </form>
                    </div>
                    <% } else { %>
                    <form method="post" action="AgregarMenu.jsp">
                        <input type="hidden" name="fecha" value="<%= fecha %>">
                        <input type="hidden" name="tipo" value="Comida">
                        <button type="submit" class="btn btn-outline-danger btn-sm">Agregar comida</button>
                    </form>
                    <% } %>
                </div>
                <%
                        cal.add(Calendar.DATE, 1);
                    }
                    con.cerrarConexion();
                %>
            </div>
        </div>
    </body>
</html>

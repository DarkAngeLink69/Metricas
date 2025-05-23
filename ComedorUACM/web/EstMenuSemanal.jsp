<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page session="true" import="java.sql.*, java.util.*, controlador.Conexion2" %>
<%
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("id_usuario") == null) {
        response.sendRedirect("Login.jsp");
        return;
    }

    String plantel = (String) sesion.getAttribute("plantel");
    if (plantel == null) {
        plantel = "Desconocido";
    }

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
            min-height: 300px;
            background-color: #f8f9fa;
            font-size: 16px;
        }
        .dia h5 {
            color: #27487D;
        }
        .registro {
            margin-top: 15px;
        }
    </style>
</head>
<body>
    <jsp:include page="EstuInicio.jsp" />
    <div class="container">
        <hr><hr>
        <h3 class="mb-4">Menú semanal - Plantel <%= plantel %></h3>

        <div class="calendario">
            <%
                String[] dias = new String[] {"Lunes", "Martes", "Miércoles", "Jueves", "Viernes"};
                java.util.Calendar cal = java.util.Calendar.getInstance();
                cal.set(java.util.Calendar.DAY_OF_WEEK, java.util.Calendar.MONDAY);
                java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("yyyy-MM-dd");

                for (int i = 0; i < 5; i++) {
                    String fecha = sdf.format(cal.getTime());

                    // Consulta desayuno
                    String sqlDesayuno = "SELECT plato_principal FROM menu_deldia WHERE fecha = ? AND tipo = 'Desayuno' AND plantel = ?";
                    con.setRs(sqlDesayuno, fecha, plantel);
                    ResultSet rsDes = con.getRs();
                    boolean hayDesayuno = rsDes.next();
                    String desayuno = null;
                    if (hayDesayuno) {
                        desayuno = rsDes.getString("plato_principal");
                    }
                    rsDes.close();

                    // Consulta comida
                    String sqlComida = "SELECT plato_principal FROM menu_deldia WHERE fecha = ? AND tipo = 'Comida' AND plantel = ?";
                    con.setRs(sqlComida, fecha, plantel);
                    ResultSet rsCom = con.getRs();
                    boolean hayComida = rsCom.next();
                    String comida = null;
                    if (hayComida) {
                        comida = rsCom.getString("plato_principal");
                    }
                    rsCom.close();
            %>
            <div class="dia">
                <h5><%= dias[i] %><br><small><%= fecha %></small></h5>

                <% if (hayDesayuno) { %>
                    <div class="registro text-primary">
                        ☀ <strong>Desayuno:</strong> <%= desayuno %>
                    </div>
                <% } else { %>
                    <p class="text-muted mt-3">No hay desayuno registrado.</p>
                <% } %>

                <% if (hayComida) { %>
                    <div class="registro text-danger">
                        🍽 <strong>Comida:</strong> <%= comida %>
                    </div>
                <% } else { %>
                    <p class="text-muted mt-3">No hay comida registrada.</p>
                <% } %>
            </div>
            <%
                    cal.add(java.util.Calendar.DATE, 1);
                }
                con.cerrarConexion();
            %>
        </div>
    </div>
</body>
</html>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.sql.*, modelo.MenuDelDiaDAO, modelo.MenuDelDiaDAO.MenuDelDia, controlador.Conexion2" %>
<%
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("id_usuario") == null) {
        response.sendRedirect("Login.jsp?error=Es obligatorio identificarse");
        return;
    }

    String plantel = (String) sesion.getAttribute("plantel");
    int tipoUsuario = (Integer) sesion.getAttribute("tipo_usuario");

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
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f1f4f9;
            margin-top: 70px;
        }

        .calendario {
            display: grid;
            grid-template-columns: repeat(5, 1fr);
            gap: 20px;
        }

        .dia {
            border-radius: 20px;
            padding: 20px;
            min-height: 320px;
            background: #ffffff;
            box-shadow: 0 6px 15px rgba(0, 0, 0, 0.08);
            transition: transform 0.2s ease, box-shadow 0.2s ease;
        }

        .dia:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 20px rgba(0, 0, 0, 0.12);
        }

        .dia h5 {
            color: #27487D;
            font-weight: 600;
            margin-bottom: 15px;
        }

        .registro {
            margin-top: 15px;
        }

        .btn-sm {
            margin-top: 8px;
            width: 100%;
            font-weight: bold;
            color: black !important;
        }

        .btn-warning.btn-sm,
        .btn-danger.btn-sm {
            background-color: transparent;
            border: 1px solid #ccc;
        }

        .btn-warning.btn-sm:hover,
        .btn-danger.btn-sm:hover {
            background-color: #e9ecef;
            color: black !important;
        }

        .text-primary {
            color: #1f77b4 !important;
        }

        .text-danger {
            color: #d62728 !important;
        }

        small {
            font-size: 85%;
            color: #6c757d;
        }
    </style>
</head>
<body>
    <jsp:include page="Inicio.jsp" />
    <div class="container">
        <hr><hr>
        <h3>Menú semanal - Plantel <%= plantel %></h3>
        <div class="calendario">
            <%
                if (tipoUsuario == 1) {
                    MenuDelDiaDAO dao = new MenuDelDiaDAO();
                    Map<String, Map<String, MenuDelDia>> semana = dao.obtenerMenuSemanal(plantel);

                    for (int i = 0; i < 5; i++) {
                        String fecha = sdf.format(cal.getTime());
                        Map<String, MenuDelDia> dia = semana.get(fecha);
            %>
            <div class="dia">
                <h5><%= dias[i] %><br><small><%= fecha %></small></h5>

                <% MenuDelDia desayuno = (dia != null) ? dia.get("Desayuno") : null;
                   if (desayuno != null) { %>
                <div class="registro text-primary">
                    ☀ <strong>Desayuno:</strong> <%= desayuno.platoPrincipal %>
                    <form method="get" action="AgregarMenu.jsp">
                        <input type="hidden" name="origen" value="MenuSemanal">
                        <input type="hidden" name="id" value="<%= desayuno.id %>">
                        <button class="btn btn-warning btn-sm">✏️</button>
                    </form>
                    <form method="post" action="AdminCRUD.jsp" onsubmit="return confirm('¿Eliminar desayuno del <%= fecha %>?');">
                        <input type="hidden" name="origen" value="MenuSemanal">
                        <input type="hidden" name="id" value="<%= desayuno.id %>">
                        <input type="hidden" name="fecha" value="<%= fecha %>">
                        <input type="hidden" name="accion" value="eliminar">
                        <input type="hidden" name="tipo" value="Desayuno">
                        <button class="btn btn-danger btn-sm">🗑️</button>
                    </form>
                </div>
                <% } else { %>
                <form method="post" action="AgregarMenu.jsp">
                    <input type="hidden" name="origen" value="MenuSemanal">
                    <input type="hidden" name="fecha" value="<%= fecha %>">
                    <input type="hidden" name="tipo" value="Desayuno">
                    <button class="btn btn-outline-primary btn-sm">Agregar desayuno</button>
                </form>
                <% }

                   MenuDelDia comida = (dia != null) ? dia.get("Comida") : null;
                   if (comida != null) { %>
                <div class="registro text-danger">
                    🍽 <strong>Comida:</strong> <%= comida.platoPrincipal %>
                    <form method="get" action="AgregarMenu.jsp">
                        <input type="hidden" name="origen" value="MenuSemanal">
                        <input type="hidden" name="id" value="<%= comida.id %>">
                        <button class="btn btn-warning btn-sm">✏️</button>
                    </form>
                    <form method="post" action="AdminCRUD.jsp" onsubmit="return confirm('¿Eliminar comida del <%= fecha %>?');">
                        <input type="hidden" name="origen" value="MenuSemanal">
                        <input type="hidden" name="id" value="<%= comida.id %>">
                        <input type="hidden" name="fecha" value="<%= fecha %>">
                        <input type="hidden" name="accion" value="eliminar">
                        <input type="hidden" name="tipo" value="Comida">
                        <button class="btn btn-danger btn-sm">🗑️</button>
                    </form>
                </div>
                <% } else { %>
                <form method="post" action="AgregarMenu.jsp">
                    <input type="hidden" name="origen" value="MenuSemanal">
                    <input type="hidden" name="fecha" value="<%= fecha %>">
                    <input type="hidden" name="tipo" value="Comida">
                    <button class="btn btn-outline-danger btn-sm">Agregar comida</button>
                </form>
                <% } %>
            </div>
            <%
                        cal.add(Calendar.DATE, 1);
                    }
                } else {
                    Conexion2 con = new Conexion2();
                    for (int i = 0; i < 5; i++) {
                        String fecha = sdf.format(cal.getTime());

                        String sqlDes = "SELECT plato_principal FROM menu_deldia WHERE fecha = ? AND tipo = 'Desayuno' AND plantel = ?";
                        con.setRs(sqlDes, fecha, plantel);
                        ResultSet rsDes = con.getRs();
                        boolean hayDesayuno = rsDes.next();
                        String desayuno = hayDesayuno ? rsDes.getString("plato_principal") : null;
                        rsDes.close();

                        String sqlCom = "SELECT plato_principal FROM menu_deldia WHERE fecha = ? AND tipo = 'Comida' AND plantel = ?";
                        con.setRs(sqlCom, fecha, plantel);
                        ResultSet rsCom = con.getRs();
                        boolean hayComida = rsCom.next();
                        String comida = hayComida ? rsCom.getString("plato_principal") : null;
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
                        cal.add(Calendar.DATE, 1);
                    }
                    con.cerrarConexion();
                }
            %>
        </div>
    </div>
</body>
</html>

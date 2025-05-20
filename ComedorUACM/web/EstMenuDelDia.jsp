<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page session="true" import="java.sql.*, controlador.Conexion2" %>
<%
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("id_usuario") == null) {
        response.sendRedirect("Login.jsp");
        return;
    }

    String plantel = (String) sesion.getAttribute("plantel");
    int idUsuario = Integer.parseInt(sesion.getAttribute("id_usuario").toString());

    if (plantel == null) {
        plantel = "Desconocido";
    }

    Conexion2 con = new Conexion2();
    String sql = "SELECT * FROM menu_deldia WHERE plantel = ? AND fecha = CURDATE() ORDER BY tipo";
    con.setRs(sql, plantel);
    ResultSet rs = con.getRs();
%>
<!DOCTYPE html>
<html>
<head>
    <title>Menú del Día</title>
    <link rel="stylesheet" href="css/bootstrap.min.css">
</head>
<body>
<jsp:include page="EstuInicio.jsp" />
<div class="container">
    <hr><hr>
    <div class="d-flex align-items-center justify-content-between mb-3">
        <h2 class="mb-0">Menú del Día - Plantel <%= plantel %></h2>
    </div>
    <hr>
    <h4>Registros actuales</h4>

    <%
        while (rs.next()) {
            String tipo = rs.getString("tipo");
            String claseTipo = "bg-primary text-white";
            String icono = "☀️";

            if ("Comida".equalsIgnoreCase(tipo)) {
                claseTipo = "bg-warning text-dark";
                icono = "🍽️";
            }

            int idMenu = rs.getInt("id");
            int likes = 0;
            int dislikes = 0;

            Conexion2 conVotos = new Conexion2();
            conVotos.setRs("SELECT tipo_voto FROM votos_menu WHERE id_menu = ?", idMenu);
            ResultSet rsVotos = conVotos.getRs();

            while (rsVotos.next()) {
                String voto = rsVotos.getString("tipo_voto");
                if ("like".equalsIgnoreCase(voto)) likes++;
                else if ("dislike".equalsIgnoreCase(voto)) dislikes++;
            }

            rsVotos.close();
            conVotos.cerrarConexion();

            // Obtener voto existente del usuario
            Conexion2 conCheck = new Conexion2();
            conCheck.setRs("SELECT tipo_voto FROM votos_menu WHERE id_usuario = ? AND id_menu = ?", idUsuario, idMenu);
            ResultSet rsCheck = conCheck.getRs();
            String votoExistente = null;
            if (rsCheck.next()) {
                votoExistente = rsCheck.getString("tipo_voto");
            }
            rsCheck.close();
            conCheck.cerrarConexion();
    %>

    <div class="card mb-4" style="border: 2px solid #007bff; border-radius: 15px; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);">
        <div class="card-header <%= claseTipo %> text-uppercase fw-bold" style="font-size: 2.5rem; padding: 20px; border-top-left-radius: 15px; border-top-right-radius: 15px;">
            <%= icono %> <%= tipo %>
        </div>
        <div class="card-body bg-light" style="font-size: 1.6rem; padding: 30px;">
            <p class="text-end text-muted" style="font-size: 1.5rem; margin-bottom: 20px;">📅 <strong>Fecha:</strong> <%= rs.getString("fecha") %></p>

            <div class="content-list" style="line-height: 2.5; font-size: 1.6rem; margin-bottom: 20px;">
                <p><strong>🍛 Plato principal:</strong> <%= rs.getString("plato_principal") %></p>
                <p><strong>🥗 Guarnición:</strong> <%= rs.getString("guarnicion") %></p>
                <p><strong>🥣 Entrada:</strong> <%= rs.getString("entrada") %></p>
                <p><strong>🧀 Acompañamiento:</strong> <%= rs.getString("acompanamiento") %></p>
                <p><strong>🧃 Bebida:</strong> <%= rs.getString("bebida") %></p>
                <p><strong>🍰 Postre:</strong> <%= rs.getString("postre") %></p>
            </div>

            <p style="font-size:1.4rem;">👍 Likes: <%= likes %> | 👎 Dislikes: <%= dislikes %></p>

            <div class="text-end mt-4">
                <form action="VotarMenu.jsp" method="post" style="display: inline;">
                    <input type="hidden" name="id_menu" value="<%= idMenu %>">

                    <button type="submit" name="tipo_voto" value="like" class="btn btn-outline-success btn-lg"
                        <% if ("like".equalsIgnoreCase(votoExistente)) { %> disabled <% } %>>
                        👍 Me gusta
                    </button>

                    <button type="submit" name="tipo_voto" value="dislike" class="btn btn-outline-danger btn-lg"
                        <% if ("dislike".equalsIgnoreCase(votoExistente)) { %> disabled <% } %>>
                        👎 No me gusta
                    </button>
                </form>

                <% if (votoExistente != null) { %>
                    <p class="text-info mt-2">Tu voto actual: <strong><%= votoExistente.toUpperCase() %></strong></p>
                <% } %>
            </div>
        </div>
    </div>
    <hr>
    <% } // while
        rs.close();
        con.cerrarConexion();
    %>
</div>
</body>
</html>

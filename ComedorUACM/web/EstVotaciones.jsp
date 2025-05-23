<%@page import="modelo.PropuestaDAO"%>
<%@page import="modelo.PropuestaDAO.Propuesta"%>
<%@page import="java.util.*, java.text.SimpleDateFormat"%>
<%@page import="java.sql.SQLException"%>

<%
    Integer id_usuario = (Integer) session.getAttribute("id_usuario");
    String plantel = (String) session.getAttribute("plantel");
    if (id_usuario == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    if (plantel == null) {
        plantel = "Desconocido";
    }

    PropuestaDAO dao = new PropuestaDAO();
    String mensajeError = null;
    String mensajeOk = null;

    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String votarIdStr = request.getParameter("votarId");
        if (votarIdStr != null) {
            try {
                int votarId = Integer.parseInt(votarIdStr);
                boolean exito = dao.votarPropuesta(votarId, id_usuario);
                if (exito) {
                    mensajeOk = "Voto registrado con éxito.";
                } else {
                    mensajeError = "Ya votaste por esta propuesta o hubo un error.";
                }
            } catch (NumberFormatException e) {
                mensajeError = "ID de propuesta inválido.";
            } catch (SQLException e) {
                mensajeError = "Error al registrar voto: " + e.getMessage();
            }
        }
    }
    List<Propuesta> propuestas = null;
    try {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        String hoy = sdf.format(new Date());
        propuestas = dao.obtenerPropuestas(hoy, plantel, id_usuario);
    } catch (SQLException e) {
        mensajeError = "Error al cargar propuestas: " + e.getMessage();
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <title>Votaciones</title>
        <link rel="stylesheet" href="css/bootstrap.min.css">
    </head>
    <body>
        <jsp:include page="EstuInicio.jsp" />

        <div class="container">
            <hr>
            <hr><!-- comment -->
            <hr><!-- comment -->
            <h2>Vota por tu propuesta favorita</h2>

            <% if (mensajeError != null) {%>
            <p style="color:red;"><%= mensajeError%></p>
            <% } %>
            <% if (mensajeOk != null) {%>
            <p style="color:green;"><%= mensajeOk%></p>
            <% } %>

            <%
                if (propuestas != null) {
                    for (Propuesta p : propuestas) {
            %>
            <form method="post" style="border:1px solid #ccc; padding:10px; margin:10px;">
                <strong><%= p.tipo.substring(0, 1).toUpperCase() + p.tipo.substring(1)%>:</strong> <%= p.descripcion%><br>
                <strong>Fecha:</strong> <%= p.fecha%><br>
                <strong>Likes:</strong> <%= p.likes%><br>

                <% if (p.yaVotado) { %>
                <em>Votaste por esta propuesta.</em>
                <% } else if (p.yaVotoPorEseTipo) { %>
                <!-- Ya votó por otra propuesta del mismo tipo -->
                <input type="submit" value="Me gusta" disabled style="color: gray; cursor: not-allowed;" onclick="return false;">
                <% } else {%>
                <input type="hidden" name="votarId" value="<%= p.id%>">
                <input type="submit" value="Me gusta">
                <% } %>
            </form>
            <%
                    }
                }
            %>
        </div>

    </body>
</html>
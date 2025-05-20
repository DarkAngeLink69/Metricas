<%@page import="java.util.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.sql.*"%>
<jsp:useBean id="con1" class="controlador.Conexion2" scope="page" />

<%
    Integer id_usuario = (Integer) session.getAttribute("id_usuario");
    String plantel = (String) session.getAttribute("plantel");

    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    String hoy = sdf.format(new java.util.Date());

    if (id_usuario == null) {
        out.println("<p style='color:red;'>No has iniciado sesión correctamente.</p>");
        return;
    }

    // Obtener votos del usuario
    String sqlVotos = "SELECT p.tipo, p.fecha FROM votos_propuestas v JOIN propuestas_menu p ON v.propuesta_id = p.id WHERE v.usuario_id = ?";
    con1.setRs(sqlVotos, id_usuario);
    ResultSet rsVotos = con1.getRs();
    Map votosPorFecha = new HashMap(); // Map<String, Set<String>>
    while (rsVotos.next()) {
        String fechaVoto = rsVotos.getString("fecha");
        String tipoVoto = rsVotos.getString("tipo");

        Set tipos = (Set) votosPorFecha.get(fechaVoto); // Set<String>
        if (tipos == null) {
            tipos = new HashSet();
            votosPorFecha.put(fechaVoto, tipos);
        }
        tipos.add(tipoVoto);
    }
    rsVotos.close();

    // --- Dar like a propuesta ---
    String votarId = request.getParameter("votarId");
    String tipoPropuesta = request.getParameter("tipoPropuesta");
    String fechaPropuesta = request.getParameter("fechaPropuesta");

    if (votarId != null && tipoPropuesta != null && fechaPropuesta != null) {
        Set yaVotados = (Set) votosPorFecha.get(fechaPropuesta);
        if (yaVotados == null || !yaVotados.contains(tipoPropuesta)) {
            String sqlLike = "INSERT IGNORE INTO votos_propuestas (propuesta_id, usuario_id) VALUES (?, ?)";
            con1.executeUpdate(sqlLike, votarId, id_usuario);
            // También actualizamos el mapa para reflejar el nuevo voto
            if (yaVotados == null) {
                yaVotados = new HashSet();
                votosPorFecha.put(fechaPropuesta, yaVotados);
            }
            yaVotados.add(tipoPropuesta);
        } else {
            out.println("<p style='color:red;'>Ya votaste por un(a) " + tipoPropuesta + " para " + fechaPropuesta + ".</p>");
        }
    }

    // Mostrar propuestas disponibles
    String sql = "SELECT p.*, (SELECT COUNT(*) FROM votos_propuestas v WHERE v.propuesta_id = p.id) AS likes " +
                 "FROM propuestas_menu p WHERE p.plantel = ? AND DATE_ADD(p.fecha, INTERVAL 1 DAY) >= ? ORDER BY p.fecha ASC";
    con1.setRs(sql, plantel, hoy);
    ResultSet rs = con1.getRs();
%>

<!DOCTYPE html>
<html>
<head>
    <title>Votaciones</title>
    <link rel="stylesheet" href="css/bootstrap.min.css">
</head>
<body>
<%@ include file="EstuInicio.jsp" %>
<div class="container">
    <h2>Vota por tu propuesta favorita</h2>
<%
    while (rs.next()) {
        int propuestaId = rs.getInt("id");
        String tipo = rs.getString("tipo");
        String descripcion = rs.getString("descripcion");
        String fecha = rs.getString("fecha");
        int likes = rs.getInt("likes");

        Set tiposYaVotados = (Set) votosPorFecha.get(fecha);
        boolean yaVotoEsteTipo = tiposYaVotados != null && tiposYaVotados.contains(tipo);
%>
    <form method="post" style="border:1px solid #ccc; padding:10px; margin:10px;">
        <strong><%= tipo.substring(0,1).toUpperCase() + tipo.substring(1) %>:</strong> <%= descripcion %><br>
        <strong>Fecha:</strong> <%= fecha %><br>
        <strong>Likes:</strong> <%= likes %><br>
        <% if (!yaVotoEsteTipo) { %>
            <input type="hidden" name="votarId" value="<%= propuestaId %>">
            <input type="hidden" name="tipoPropuesta" value="<%= tipo %>">
            <input type="hidden" name="fechaPropuesta" value="<%= fecha %>">
            <input type="submit" value="Me gusta">
        <% } else { %>
            <em>Ya votaste por un(a) <%= tipo %> para esta fecha.</em>
        <% } %>
    </form>
<%
    }
    rs.close();
%>
</div>
</body>
</html>

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

    // --- Dar like a propuesta ---
    String votarId = request.getParameter("votarId");
    if (votarId != null) {
        String sqlLike = "INSERT IGNORE INTO votos_propuestas (propuesta_id, usuario_id) VALUES (?, ?)";
        con1.executeUpdate(sqlLike, votarId, id_usuario);
    }

    // --- Eliminar propuesta ---
    String eliminarId = request.getParameter("eliminarId");
    if (eliminarId != null) {
        String sqlCheck = "SELECT fecha FROM propuestas_menu WHERE id = ? AND plantel = ? AND id_usuario = ?";
        con1.setRs(sqlCheck, eliminarId, plantel, id_usuario);
        ResultSet rsCheck = con1.getRs();
        if (rsCheck.next()) {
            String fecha = rsCheck.getString("fecha");
            if (fecha.compareTo(hoy) >= 0) {
                con1.executeUpdate("DELETE FROM votos_propuestas WHERE propuesta_id = ?", eliminarId);
                con1.executeUpdate("DELETE FROM propuestas_menu WHERE id = ? AND id_usuario = ?", eliminarId, id_usuario);
                out.println("<p style='color:green;'>Propuesta eliminada.</p>");
            } else {
                out.println("<p style='color:red;'>No se puede eliminar propuestas pasadas.</p>");
            }
        }
        rsCheck.close();
    }

    // --- Editar propuesta ---
    String editarId = request.getParameter("editarId");
    String nuevaPropuesta = request.getParameter("nuevaPropuesta");
    if (editarId != null && nuevaPropuesta != null && !nuevaPropuesta.trim().isEmpty()) {
        String sqlCheck = "SELECT fecha FROM propuestas_menu WHERE id = ? AND plantel = ? AND id_usuario = ?";
        con1.setRs(sqlCheck, editarId, plantel, id_usuario);
        ResultSet rsCheck = con1.getRs();
        if (rsCheck.next()) {
            String fecha = rsCheck.getString("fecha");
            if (fecha.compareTo(hoy) >= 0) {
                con1.executeUpdate("UPDATE propuestas_menu SET descripcion = ? WHERE id = ? AND id_usuario = ?", nuevaPropuesta, editarId, id_usuario);
                out.println("<p style='color:green;'>Propuesta actualizada.</p>");
            } else {
                out.println("<p style='color:red;'>No se puede editar propuestas pasadas.</p>");
            }
        }
        rsCheck.close();
    }

    // --- Agregar nueva propuesta ---
    String propuesta = request.getParameter("descripcion");
    String tipo = request.getParameter("tipo");
    String fecha = request.getParameter("fecha");

    if (propuesta != null && tipo != null && fecha != null) {
        if (fecha.compareTo(hoy) < 0) {
            out.println("<p style='color:red;'>No puedes proponer para fechas pasadas.</p>");
        } else {
            String sqlExiste = "SELECT DISTINCT fecha FROM propuestas_menu WHERE fecha > ? AND plantel = ? AND id_usuario = ?";
            con1.setRs(sqlExiste, hoy, plantel, id_usuario);
            ResultSet rsFechas = con1.getRs();

            boolean hayOtraFecha = false;
            String fechaPropuestaFutura = null;
            while (rsFechas.next()) {
                String otraFecha = rsFechas.getString("fecha");
                if (!otraFecha.equals(fecha)) {
                    hayOtraFecha = true;
                    fechaPropuestaFutura = otraFecha;
                    break;
                }
            }
            rsFechas.close();

            if (hayOtraFecha) {
                out.println("<p style='color:red;'>Ya propusiste para otra fecha futura (" + fechaPropuestaFutura + "). Solo puedes proponer para una fecha a la vez.</p>");
            } else {
                String sql = "INSERT INTO propuestas_menu (descripcion, tipo, fecha, plantel, id_usuario) VALUES (?, ?, ?, ?, ?)";
                con1.executeUpdate(sql, propuesta, tipo, fecha, plantel, id_usuario);
                out.println("<p style='color:green;'>Propuesta agregada.</p>");
            }
        }
    }

    // Obtener la fecha futura propuesta si existe
    String fechaPropuestaFutura = null;
    String sqlFutura = "SELECT DISTINCT fecha FROM propuestas_menu WHERE fecha > ? AND plantel = ? AND id_usuario = ?";
    con1.setRs(sqlFutura, hoy, plantel, id_usuario);
    ResultSet rsFutura = con1.getRs();
    if (rsFutura.next()) {
        fechaPropuestaFutura = rsFutura.getString("fecha");
    }
    rsFutura.close();
%>

<!DOCTYPE html>
<html>
<head>
    <title>Proponer Platillo</title>
    <link rel="stylesheet" href="css/bootstrap.min.css">
</head>
<body>
<%@ include file="AdminInicio.jsp" %>
<div class="container">
    <hr>
    <h2>Proponer platillos</h2>
    <form method="post">
        <label>Fecha:</label><br>
        <input type="date" name="fecha" id="fechaInput" required><br>
        
        <label>Tipo:</label><br>
        <select name="tipo">
            <option value="desayuno">Desayuno</option>
            <option value="comida">Comida</option>
        </select><br><br>
        
        <label>Descripción:</label><br>
        <input type="text" name="descripcion" required><br>

        <input type="submit" value="Agregar propuesta" class="btn btn-success">
    </form>

    <script>
        const inputFecha = document.getElementById("fechaInput");
        const hoy = new Date().toISOString().split('T')[0];
        inputFecha.min = hoy;

        <% if (fechaPropuestaFutura != null) { %>
            inputFecha.value = "<%= fechaPropuestaFutura %>";
            inputFecha.min = "<%= fechaPropuestaFutura %>";
            inputFecha.max = "<%= fechaPropuestaFutura %>";
            inputFecha.readOnly = true;
        <% } %>
    </script>

    <hr>
    <h2>Propuestas</h2>
    <%
        String sql = "SELECT p.*, (SELECT COUNT(*) FROM votos_propuestas v WHERE v.propuesta_id = p.id) AS likes, " +
                     "(SELECT COUNT(*) FROM votos_propuestas v WHERE v.propuesta_id = p.id AND v.usuario_id = ?) AS ya_votado " +
                     "FROM propuestas_menu p WHERE p.plantel = ? AND DATE_ADD(p.fecha, INTERVAL 1 DAY) >= ? ORDER BY p.fecha ASC";
        con1.setRs(sql, id_usuario, plantel, hoy);
        ResultSet rs = con1.getRs();
        while (rs.next()) {
            int propuestaId = rs.getInt("id");
            boolean esMia = rs.getInt("id_usuario") == id_usuario;
            boolean yaVotado = rs.getInt("ya_votado") > 0;
    %>
        <form method="post" style="border:1px solid #ccc; padding:10px; margin:10px;">
            <b><%= rs.getString("tipo") %></b> - <%= rs.getString("descripcion") %> 
            (<%= rs.getString("fecha") %>)<br>
            <b>Likes:</b> <%= rs.getInt("likes") %><br>

            <% if (esMia) { %>
                <input type="hidden" name="editarId" value="<%= propuestaId %>">
                <input type="text" name="nuevaPropuesta" placeholder="Editar propuesta" class="form-control mb-2">
                <button type="submit" class="btn btn-primary btn-sm">Actualizar</button>
                <button type="submit" name="eliminarId" value="<%= propuestaId %>" class="btn btn-danger btn-sm" onclick="return confirm('¿Estás seguro de eliminar esta propuesta?');">Eliminar</button>
            <% } else if (!yaVotado) { %>
                <input type="hidden" name="votarId" value="<%= propuestaId %>">
                <button type="submit" class="btn btn-success btn-sm">Me gusta ?</button>
            <% } else { %>
                <p><em>Ya votaste por esta propuesta.</em></p>
            <% } %>
        </form>
    <%
        }
        rs.close();
    %>
</div>
</body>
</html>

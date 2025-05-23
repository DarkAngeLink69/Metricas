<%@page import="modelo.PropuestaDAO.Propuesta"%>
<%@page import="modelo.PropuestaDAO"%>
<%@page import="java.util.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.List"%>
<%
    Integer id_usuario = (Integer) session.getAttribute("id_usuario");
    String plantel = (String) session.getAttribute("plantel");

    if (id_usuario == null) {
        out.println("<p style='color:red;'>No has iniciado sesión correctamente.</p>");
        return;
    }

    PropuestaDAO dao = new PropuestaDAO();
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    String hoy = sdf.format(new Date());

    String mensaje = "";
    String fechaPropuestaFutura = dao.obtenerFechaPropuestaFutura(hoy, plantel, id_usuario);

    // Acción: Votar
    String votarId = request.getParameter("votarId");
    if (votarId != null) {
        dao.votarPropuesta(Integer.parseInt(votarId), id_usuario);
    }

    // Acción: Eliminar
    String eliminarId = request.getParameter("eliminarId");
    if (eliminarId != null) {
        String fecha = dao.obtenerFechaPropuesta(Integer.parseInt(eliminarId), plantel, id_usuario);
        if (fecha != null && fecha.compareTo(hoy) >= 0) {
            dao.eliminarVotosDePropuesta(Integer.parseInt(eliminarId));
            dao.eliminarPropuesta(Integer.parseInt(eliminarId), plantel, id_usuario);
            mensaje = "<p style='color:green;'>Propuesta eliminada.</p>";
        } else {
            mensaje = "<p style='color:red;'>No se puede eliminar propuestas pasadas.</p>";
        }
    }

    // Acción: Editar
    String editarId = request.getParameter("editarId");
    String nuevaPropuesta = request.getParameter("nuevaPropuesta");
    if (editarId != null && nuevaPropuesta != null && !nuevaPropuesta.trim().isEmpty()) {
        String fecha = dao.obtenerFechaPropuesta(Integer.parseInt(editarId), plantel, id_usuario);
        if (fecha != null && fecha.compareTo(hoy) >= 0) {
            dao.actualizarPropuesta(Integer.parseInt(editarId), nuevaPropuesta, id_usuario);
            mensaje = "<p style='color:green;'>Propuesta actualizada.</p>";
        } else {
            mensaje = "<p style='color:red;'>No se puede editar propuestas pasadas.</p>";
        }
    }

    // Acción: Agregar nueva
    String descripcion = request.getParameter("descripcion");
    String tipo = request.getParameter("tipo");
    String fecha = request.getParameter("fecha");

    if (descripcion != null && tipo != null && fecha != null) {
        if (descripcion.length() > 255) {
            mensaje = "<p style='color:red;'>La descripción no puede tener más de 255 caracteres.</p>";
        } else if (fecha.compareTo(hoy) < 0) {
            mensaje = "<p style='color:red;'>No puedes proponer para fechas pasadas.</p>";
        } else if (fechaPropuestaFutura != null && !fechaPropuestaFutura.equals(fecha)) {
            mensaje = "<p style='color:red;'>Ya propusiste para otra fecha futura (" + fechaPropuestaFutura + "). Solo puedes proponer para una fecha a la vez.</p>";
        } else {
            dao.agregarPropuesta(descripcion, tipo, fecha, plantel, id_usuario);
            mensaje = "<p style='color:green;'>Propuesta agregada.</p>";
        }
    }

    List<Propuesta> propuestas = dao.obtenerPropuestas(hoy, plantel, id_usuario);
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
            <%= mensaje%>
            <form method="post">
                <label>Fecha:</label><br>
                <input type="date" name="fecha" id="fechaInput" required><br>

                <label>Tipo:</label><br>
                <select name="tipo">
                    <option value="desayuno">Desayuno</option>
                    <option value="comida">Comida</option>
                </select><br><br>

                <label>Descripción:</label><br>
                <input type="text" name="descripcion" maxlength="255" required><br>

                <input type="submit" value="Agregar propuesta" class="btn btn-success">
            </form>

            <script>
                const inputFecha = document.getElementById("fechaInput");
                const hoy = new Date().toISOString().split('T')[0];
                inputFecha.min = hoy;

                <% if (fechaPropuestaFutura != null) {%>
                inputFecha.value = "<%= fechaPropuestaFutura%>";
                inputFecha.min = "<%= fechaPropuestaFutura%>";
                inputFecha.max = "<%= fechaPropuestaFutura%>";
                inputFecha.readOnly = true;
                <% } %>
            </script>

            <hr>
            <h2>Propuestas</h2>
            <% for (Propuesta p : propuestas) {%>
            <form method="post" style="border:1px solid #ccc; padding:10px; margin:10px;">
                <b><%= p.tipo%></b> - <%= p.descripcion%> (<%= p.fecha%>)<br>
                <b>Likes:</b> <%= p.likes%><br>

                <% if (p.id_usuario == id_usuario) {%>
                <input type="hidden" name="editarId" value="<%= p.id%>">
                <input type="text" name="nuevaPropuesta" placeholder="Editar propuesta" class="form-control mb-2">
                <button type="submit" class="btn btn-primary btn-sm">Actualizar</button>
                <button type="submit" name="eliminarId" value="<%= p.id%>" class="btn btn-danger btn-sm"
                        onclick="return confirm('¿Estás seguro de eliminar esta propuesta?');">Eliminar</button>
                <% } else if (!p.yaVotado) {%>
                <input type="hidden" name="votarId" value="<%= p.id%>">
                <button type="submit" class="btn btn-success btn-sm">Me gusta ?</button>
                <% } else { %>
                <p><em>Ya votaste por esta propuesta.</em></p>
                <% } %>
            </form>
            <% }%>
        </div>
    </body>
</html>

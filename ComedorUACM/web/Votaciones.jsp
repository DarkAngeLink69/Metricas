<%@page import="modelo.PropuestaDAO.Propuesta"%>
<%@page import="modelo.PropuestaDAO"%>
<%@page import="java.util.*"%>
<%@page import="java.text.SimpleDateFormat"%>
<%@page import="java.util.Date"%>
<%@page import="java.util.List"%>
<%
    Integer id_usuario = (Integer) session.getAttribute("id_usuario");
    String plantel = (String) session.getAttribute("plantel");
    Integer tipo_usuario = (Integer) session.getAttribute("tipo_usuario"); // 1=Admin, 2=Estudiante

    if (id_usuario == null || tipo_usuario == null) {
        out.println("<p style='color:red;'>No has iniciado sesión correctamente.</p>");
        return;
    }

    PropuestaDAO dao = new PropuestaDAO();
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
    String hoy = sdf.format(new Date());

    String mensaje = "";
    String mensajeError = null;
    String mensajeOk = null;

    String fechaPropuestaFutura = dao.obtenerFechaPropuestaFutura(hoy, plantel, id_usuario);

    // Solo si es estudiante, puede votar
    if (tipo_usuario == 2) {
        String votarId = request.getParameter("votarId");
        if (votarId != null) {
            boolean exito = dao.votarPropuesta(Integer.parseInt(votarId), id_usuario);
            if (exito) {
                mensajeOk = "Voto registrado con éxito.";
            } else {
                mensajeError = "Ya votaste por esta propuesta o hubo un error.";
            }
        }
    }

    // Solo si es admin, puede eliminar, editar, agregar
    if (tipo_usuario == 1) {
        // Eliminar propuesta
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

        // Editar propuesta
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

        // Agregar nueva propuesta
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
    }

    List<Propuesta> propuestas = dao.obtenerPropuestas(hoy, plantel, id_usuario);
%>

<!DOCTYPE html>
<html>
    <head>
        <title><%= (tipo_usuario == 1) ? "Administrar Propuestas" : "Votaciones" %></title>
        <link rel="stylesheet" href="css/bootstrap.min.css">
    </head>
    <body>
         <jsp:include page="Inicio.jsp" />
        <div class="container">
            <hr>

            <% if (tipo_usuario == 1) { %>
                <!-- Panel Admin para agregar propuestas -->
                <h2>Proponer platillos</h2>
                <%= mensaje %>
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

                    <% if (fechaPropuestaFutura != null) { %>
                    inputFecha.value = "<%= fechaPropuestaFutura %>";
                    inputFecha.min = "<%= fechaPropuestaFutura %>";
                    inputFecha.max = "<%= fechaPropuestaFutura %>";
                    inputFecha.readOnly = true;
                    <% } %>
                </script>
            <% } else { %>
                <h2>Vota por tu propuesta favorita</h2>
                <% if (mensajeError != null) { %>
                    <p style="color:red;"><%= mensajeError %></p>
                <% } %>
                <% if (mensajeOk != null) { %>
                    <p style="color:green;"><%= mensajeOk %></p>
                <% } %>
            <% } %>

            <hr>
            <h2>Propuestas</h2>

            <% for (Propuesta p : propuestas) { %>
                <form method="post" style="border:1px solid #ccc; padding:10px; margin:10px;">
                    <b><%= p.tipo.substring(0,1).toUpperCase() + p.tipo.substring(1) %></b> - <%= p.descripcion %> (<%= p.fecha %>)<br>
                    <b>Likes:</b> <%= p.likes %><br>

                    <% if (tipo_usuario == 1) { %>
                        <%-- Admin puede editar y eliminar sólo si es dueño y fecha válida --%>
                        <% if (p.id_usuario == id_usuario) { %>
                            <input type="hidden" name="editarId" value="<%= p.id %>">
                            <input type="text" name="nuevaPropuesta" placeholder="Editar propuesta" class="form-control mb-2">
                            <button type="submit" class="btn btn-primary btn-sm">Actualizar</button>
                            <button type="submit" name="eliminarId" value="<%= p.id %>" class="btn btn-danger btn-sm"
                                onclick="return confirm('¿Estás seguro de eliminar esta propuesta?');">Eliminar</button>
                        <% } else { %>
                            <em>Sin permiso para editar o eliminar.</em>
                        <% } %>
                    <% } else if (tipo_usuario == 2) { %>
                        <%-- Estudiante sólo puede votar, y sólo si no ha votado --%>
                        <% if (p.yaVotado) { %>
                            <em>Ya votaste por esta propuesta.</em>
                        <% } else if (p.yaVotoPorEseTipo) { %>
                            <input type="submit" value="Me gusta" disabled style="color: gray; cursor: not-allowed;" onclick="return false;">
                        <% } else { %>
                            <input type="hidden" name="votarId" value="<%= p.id %>">
                            <input type="submit" value="Me gusta" class="btn btn-success btn-sm">
                        <% } %>
                    <% } %>
                </form>
            <% } %>
        </div>
    </body>
</html>
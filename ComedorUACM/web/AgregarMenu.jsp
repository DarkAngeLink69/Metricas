<%@ page session="true" import="java.sql.*, controlador.Conexion2" %>
<%
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("usuario") == null) {
        response.sendRedirect("Login.jsp");
        return;
    }

    String plantel = (String) sesion.getAttribute("plantel");
    Conexion2 con = new Conexion2();

    // Parámetros para prellenar
    String idParam = request.getParameter("id");
    String fechaParam = request.getParameter("fecha");
    String tipoParam = request.getParameter("tipo");

    String plato = "", guarnicion = "", entrada = "", acompanamiento = "", bebida = "", postre = "";
    boolean esEdicion = false;

    if (idParam != null && !idParam.isEmpty()) {
        esEdicion = true;
        String consulta = "SELECT * FROM menu_deldia WHERE id = ? AND plantel = ?";
        con.setRs(consulta, idParam, plantel);
        ResultSet rsMenu = con.getRs();
        if (rsMenu.next()) {
            fechaParam = rsMenu.getString("fecha");
            tipoParam = rsMenu.getString("tipo");
            plato = rsMenu.getString("plato_principal");
            guarnicion = rsMenu.getString("guarnicion");
            entrada = rsMenu.getString("entrada");
            acompanamiento = rsMenu.getString("acompanamiento");
            bebida = rsMenu.getString("bebida");
            postre = rsMenu.getString("postre");
        }
        rsMenu.close();
    }
    con.cerrarConexion();
%>
<!DOCTYPE html>
<html>
<head>
    <title><%= esEdicion ? "Editar Menú" : "Agregar Menú" %> - Plantel <%= plantel %></title>
    <link rel="stylesheet" href="css/bootstrap.min.css">
</head>
<body>
    <%@ include file="AdminInicio.jsp" %>
    <div class="container">
        <h2><%= esEdicion ? "Editar Menú" : "Agregar Menú" %> - Plantel <%= plantel %></h2>
        <form method="post" action="AdminCRUD.jsp">
            <div class="form-group">
                <label>Fecha:</label>
                <input type="date" name="fecha" required class="form-control" 
                       value="<%= fechaParam != null ? fechaParam : "" %>">
            </div>

            <div class="form-group">
                <label>Tipo:</label>
                <select name="tipo" class="form-control">
                    <option value="Desayuno" <%= "Desayuno".equals(tipoParam) ? "selected" : "" %>>Desayuno</option>
                    <option value="Comida" <%= "Comida".equals(tipoParam) ? "selected" : "" %>>Comida</option>
                </select>
            </div>

            <div class="form-group">
                <label>Plato principal:</label>
                <input type="text" name="plato_principal" required class="form-control" value="<%= plato %>">
            </div>

            <div class="form-group">
                <label>Guarnición:</label>
                <input type="text" name="guarnicion" required class="form-control" value="<%= guarnicion %>">
            </div>

            <div class="form-group">
                <label>Entrada:</label>
                <input type="text" name="entrada" required class="form-control" value="<%= entrada %>">
            </div>

            <div class="form-group">
                <label>Acompañamiento:</label>
                <input type="text" name="acompanamiento" class="form-control" value="<%= acompanamiento %>">
            </div>

            <div class="form-group">
                <label>Bebida:</label>
                <input type="text" name="bebida" class="form-control" value="<%= bebida %>">
            </div>

            <div class="form-group">
                <label>Postre:</label>
                <input type="text" name="postre" class="form-control" value="<%= postre %>">
            </div>

            <input type="hidden" name="plantel" value="<%= plantel %>">
            <% if (esEdicion) { %>
                <input type="hidden" name="id" value="<%= idParam %>">
            <% } %>

            <button type="submit" name="accion" value="<%= esEdicion ? "editar" : "agregar" %>" class="btn btn-success">
                <%= esEdicion ? "Guardar cambios" : "Agregar" %>
            </button>
        </form>
    </div>
</body>
</html>

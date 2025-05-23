<%@ page import="modelo.MenuDelDiaDAO, modelo.MenuDelDiaDAO.MenuDelDia" %>
<%@ page import="java.time.LocalDate" %>
<%@ page session="true" %>

<%!
    public String escapeHtml(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>

<%
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("usuario") == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    String plantel = (String) sesion.getAttribute("plantel");

    String idParam = request.getParameter("id");
    String fechaParametro = request.getParameter("fecha");
    String tipoParametro = request.getParameter("tipo");

    MenuDelDia menu = null;
    boolean esEdicion = false;

    if (idParam != null && !idParam.trim().isEmpty()) {
        esEdicion = true;
        try {
            MenuDelDiaDAO dao = new MenuDelDiaDAO();
            menu = dao.obtenerMenuPorIdYPlantel(idParam, plantel);
            if (menu == null) {
                menu = new MenuDelDia();
            }
        } catch (Exception e) {
            e.printStackTrace();
            menu = new MenuDelDia();
        }
    } else {
        menu = new MenuDelDia();

        if (fechaParametro != null && !fechaParametro.trim().isEmpty()) {
            menu.fecha = fechaParametro;
        } else {
            menu.fecha = LocalDate.now().toString();
        }

        if (tipoParametro != null && !tipoParametro.trim().isEmpty()) {
            menu.tipo = tipoParametro;
        } else {
            menu.tipo = "Desayuno";
        }

        menu.platoPrincipal = "";
        menu.guarnicion = "";
        menu.entrada = "";
        menu.acompanamiento = "";
        menu.bebida = "";
        menu.postre = "";
    }

    boolean bloquearFecha = (fechaParametro != null && !fechaParametro.trim().isEmpty()) || esEdicion;
    boolean bloquearTipo = esEdicion || (tipoParametro != null && !tipoParametro.trim().isEmpty());
%>

<!DOCTYPE html>
<html>
    <head>
        <meta charset="UTF-8" />
        <title><%= esEdicion ? "Editar Menú" : "Agregar Menú"%> - Plantel <%= escapeHtml(plantel)%></title>
        <link rel="stylesheet" href="css/bootstrap.min.css" />
    </head>
    <body>
        <%@ include file="AdminInicio.jsp" %>
        <div class="container">
            <hr />
            <hr />
            <h2><%= esEdicion ? "Editar Menú" : "Agregar Menú"%> - Plantel <%= escapeHtml(plantel)%></h2>
            <%
                String error = request.getParameter("error");
                if (error != null && !error.trim().isEmpty()) {
            %>
            <div class="alert alert-danger"><%= escapeHtml(error)%></div>
            <%
                }
            %>

            <form method="post" action="AdminCRUD.jsp" accept-charset="UTF-8">
                <div class="form-group">
                    <label>Fecha:</label>
                    <input type="date" name="fecha" required class="form-control"
                           value="<%= escapeHtml(menu.fecha)%>"
                           <%= bloquearFecha ? "readonly" : ""%> />
                </div>

                <div class="form-group">
                    <label>Tipo:</label>
                    <select name="tipo" required class="form-control" <%= bloquearTipo ? "disabled" : ""%>>
                        <option value="" disabled <%= (menu.tipo == null || menu.tipo.isEmpty()) ? "selected" : ""%>>-- Selecciona --</option>
                        <option value="Desayuno" <%= "Desayuno".equals(menu.tipo) ? "selected" : ""%>>Desayuno</option>
                        <option value="Comida" <%= "Comida".equals(menu.tipo) ? "selected" : ""%>>Comida</option>
                    </select>
                    <% if (bloquearTipo) {%>
                    <input type="hidden" name="tipo" value="<%= escapeHtml(menu.tipo)%>" />
                    <% }%>
                </div>

                <div class="form-group">
                    <label>Plato principal:</label>
                    <input type="text" name="plato_principal" required maxlength="255" class="form-control"
                           value="<%= escapeHtml(menu.platoPrincipal)%>" />
                </div>

                <div class="form-group">
                    <label>Guarnición:</label>
                    <input type="text" name="guarnicion" required maxlength="255" class="form-control"
                           value="<%= escapeHtml(menu.guarnicion)%>" />
                </div>

                <div class="form-group">
                    <label>Entrada:</label>
                    <input type="text" name="entrada" required maxlength="255" class="form-control"
                           value="<%= escapeHtml(menu.entrada)%>" />
                </div>

                <div class="form-group">
                    <label>Acompañamiento:</label>
                    <input type="text" name="acompanamiento" required maxlength="255" class="form-control"
                           value="<%= escapeHtml(menu.acompanamiento)%>" />
                </div>

                <div class="form-group">
                    <label>Bebida:</label>
                    <input type="text" name="bebida" required maxlength="255" class="form-control"
                           value="<%= escapeHtml(menu.bebida)%>" />
                </div>

                <div class="form-group">
                    <label>Postre:</label>
                    <input type="text" name="postre" required maxlength="255" class="form-control"
                           value="<%= escapeHtml(menu.postre)%>" />
                </div>

                <input type="hidden" name="plantel" value="<%= escapeHtml(plantel)%>" />
                <% if (esEdicion) {%>
                <input type="hidden" name="id" value="<%= escapeHtml(idParam)%>" />
                <% }%>

                <button type="submit" name="accion" value="<%= esEdicion ? "editar" : "agregar"%>" class="btn btn-success">
                    <%= esEdicion ? "Guardar cambios" : "Agregar"%>
                </button>
            </form>
        </div>
    </body>
</html>

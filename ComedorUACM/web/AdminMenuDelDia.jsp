<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, modelo.MenuDelDiaDAO, modelo.MenuDelDiaDAO.MenuDelDia" %>
<%
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("id_usuario") == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    int idUsuario = Integer.parseInt(sesion.getAttribute("id_usuario").toString());
    String plantel = (String) sesion.getAttribute("plantel");
    if (plantel == null) {
        plantel = "Desconocido";
    }

    MenuDelDiaDAO dao = new MenuDelDiaDAO();
    List<MenuDelDia> menus = dao.obtenerMenusDelDiaConVotoUsuario(plantel, idUsuario);

%>
<!DOCTYPE html>
<html>
<head>
    <title>Menú del Día</title>
    <link rel="stylesheet" href="css/bootstrap.min.css">
</head>
<body>
    <jsp:include page="AdminInicio.jsp" />
    <div class="container">
        <hr><hr>
        <div class="d-flex align-items-center justify-content-between mb-3">
            <h2 class="mb-0">Menú del Día - Plantel <%= plantel %></h2>
            <form method="post" action="AgregarMenu.jsp" class="mb-0">
                <button type="submit" name="accion" value="agregar" class="btn btn-success">Agregar</button>
            </form>
        </div>
        <hr>
        <h4>Registros actuales</h4>

        <%
            for (MenuDelDia menu : menus) {
                String claseTipo = "bg-primary text-white";
                String icono = "☀️";
                if ("Comida".equalsIgnoreCase(menu.tipo)) {
                    claseTipo = "bg-warning text-dark";
                    icono = "🍽️";
                }
        %>
        <div class="card mb-4" style="border: 2px solid #007bff; border-radius: 15px; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);">
            <div class="card-header <%= claseTipo %> text-uppercase fw-bold" style="font-size: 2.5rem; padding: 20px; border-top-left-radius: 15px; border-top-right-radius: 15px;">
                <%= icono %> <%= menu.tipo %>
            </div>
            <div class="card-body bg-light" style="font-size: 1.6rem; padding: 30px;">
                <p class="text-end text-muted" style="font-size: 1.5rem; margin-bottom: 20px;">📅 <strong>Fecha:</strong> <%= menu.fecha %></p>

                <div class="content-list" style="line-height: 2.5; font-size: 1.6rem; margin-bottom: 20px;">
                    <p><strong>🍛 Plato principal:</strong> <%= menu.platoPrincipal %></p>
                    <p><strong>🥗 Guarnición:</strong> <%= menu.guarnicion %></p>
                    <p><strong>🥣 Entrada:</strong> <%= menu.entrada %></p>
                    <p><strong>🧀 Acompañamiento:</strong> <%= menu.acompanamiento %></p>
                    <p><strong>🧃 Bebida:</strong> <%= menu.bebida %></p>
                    <p><strong>🍰 Postre:</strong> <%= menu.postre %></p>
                </div>

                <p style="font-size:1.4rem;">👍 Likes: <%= menu.likes %> | 👎 Dislikes: <%= menu.dislikes %></p>

                <div class="text-end mt-4">
                    <form method="post" action="AdminCRUD.jsp" style="display:inline;">
                        <input type="hidden" name="id" value="<%= menu.id %>">
                        <input type="hidden" name="fecha" value="<%= menu.fecha %>">
                        <input type="hidden" name="tipo" value="<%= menu.tipo %>">
                        <input type="hidden" name="plantel" value="<%= plantel %>">
                        <button type="submit" name="accion" value="eliminar" class="btn btn-outline-danger btn-lg"
                                onclick="return confirm('¿Estás seguro de eliminar este menú?');">🗑️ Eliminar</button>
                    </form>
                </div>
            </div>
        </div>
        <hr>
        <% } %>
    </div>
</body>
</html>

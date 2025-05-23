<%@page import="java.util.List"%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="modelo.MenuDelDiaDAO, modelo.MenuDelDiaDAO.MenuDelDia" %>
<%@ page session="true" %>
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

    MenuDelDiaDAO dao = new MenuDelDiaDAO();
    List<MenuDelDia> menus = dao.obtenerMenusDelDiaConVotoUsuario(plantel, idUsuario);
%>
<!DOCTYPE html>
<html>
<head>
    <title>Menú del Día - Plantel <%= plantel %></title>
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
                <form action="VotarMenu.jsp" method="post" style="display: inline;">
                    <input type="hidden" name="id_menu" value="<%= menu.id %>">

                    <button type="submit" name="tipo_voto" value="like" class="btn btn-outline-success btn-lg"
                        <%= "like".equalsIgnoreCase(menu.votoUsuario) ? "disabled" : "" %>>
                        👍 Me gusta
                    </button>

                    <button type="submit" name="tipo_voto" value="dislike" class="btn btn-outline-danger btn-lg"
                        <%= "dislike".equalsIgnoreCase(menu.votoUsuario) ? "disabled" : "" %>>
                        👎 No me gusta
                    </button>
                </form>

                <% if (menu.votoUsuario != null) { %>
                    <p class="text-info mt-2">Tu voto actual: <strong><%= menu.votoUsuario.toUpperCase() %></strong></p>
                <% } %>
            </div>
        </div>
    </div>
    <hr>
    <% } %>
</div>
</body>
</html>

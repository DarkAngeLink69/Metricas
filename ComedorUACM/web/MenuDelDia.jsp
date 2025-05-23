<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.util.*, modelo.MenuDelDiaDAO, modelo.MenuDelDiaDAO.MenuDelDia" %>
<%@ page session="true" %>
<%
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("id_usuario") == null) {
        response.sendRedirect("Login.jsp");
        return;
    }
    int idUsuario = Integer.parseInt(sesion.getAttribute("id_usuario").toString());
    String plantel = (String) sesion.getAttribute("plantel");
    int tipoUsuario = ((Integer) sesion.getAttribute("tipo_usuario"));
    if (plantel == null) plantel = "Desconocido";

    MenuDelDiaDAO dao = new MenuDelDiaDAO();
    List<MenuDelDia> menus = dao.obtenerMenusDelDiaConVotoUsuario(plantel, idUsuario);

    boolean hayDesayuno = false, hayComida = false;
    for (MenuDelDia menu : menus) {
        if ("Desayuno".equalsIgnoreCase(menu.tipo)) hayDesayuno = true;
        if ("Comida".equalsIgnoreCase(menu.tipo)) hayComida = true;
    }
    String fechaActual = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new Date());
    String tipoSiguiente = null;
    if (!hayDesayuno && hayComida) tipoSiguiente = "Desayuno";
    else if (!hayComida && hayDesayuno) tipoSiguiente = "Comida";
%>
<!DOCTYPE html>
<html>
<head>
    <title>Menú del Día - Plantel <%= plantel %></title>
    <link rel="stylesheet" href="css/bootstrap.min.css">
    <style>
        body {
            background-color: #f4f6fa;
            font-family: 'Segoe UI', sans-serif;
            padding-top: 70px;
        }
        .card {
            border-radius: 20px;
            box-shadow: 0 8px 20px rgba(0, 0, 0, 0.07);
        }
        .card-header {
            font-size: 1.8rem;
            padding: 20px;
            border-radius: 20px 20px 0 0;
        }
        .card-body {
            padding: 30px;
            background-color: #fdfdfd;
            font-size: 1.3rem;
        }
        .content-list p {
            margin-bottom: 10px;
        }
        .btn-lg {
            font-size: 1.2rem;
            margin: 5px;
        }
        .titulo-seccion {
            color: #2c3e50;
            font-weight: 700;
        }
        .btn-agregar {
            font-weight: bold;
        }
        .fecha-label {
            font-size: 1rem;
            color: #6c757d;
        }
        .texto-voto {
            font-size: 1rem;
            margin-top: 10px;
        }
    </style>
</head>
<body>
<jsp:include page="Inicio.jsp" />
<div class="container">
    <div class="d-flex justify-content-between align-items-center mb-4">
        <h2 class="titulo-seccion">🍽️ Menú del Día - Plantel <%= plantel %></h2>
        <% if (tipoUsuario == 1) { %>
        <form method="post" action="AgregarMenu.jsp" class="mb-0">
            <input type="hidden" name="origen" value="MenuDelDia">
            <input type="hidden" name="fecha" value="<%= fechaActual %>">
            <% if (tipoSiguiente != null) { %>
                <input type="hidden" name="tipo" value="<%= tipoSiguiente %>">
            <% } %>
            <button type="submit" class="btn btn-success btn-agregar" <%= (hayDesayuno && hayComida) ? "disabled" : "" %>>
                ➕ Agregar menú
            </button>
        </form>
        <% } %>
    </div>

    <% if (menus.isEmpty()) { %>
        <div class="alert alert-info">No hay menús registrados para hoy.</div>
    <% } %>
    <% for (MenuDelDia menu : menus) {
        String claseTipo = "bg-primary text-white";
        String icono = "☀️";
        if ("Comida".equalsIgnoreCase(menu.tipo)) {
            claseTipo = "bg-warning text-dark";
            icono = "🍽️";
        }
    %>
    <div class="card mb-4">
        <div class="card-header <%= claseTipo %>">
            <strong><%= icono %> <%= menu.tipo.toUpperCase() %></strong>
        </div>
        <div class="card-body">
            <p class="fecha-label text-end">📅 <strong>Fecha:</strong> <%= menu.fecha %></p>
            <div class="content-list">
                <p><strong>🍛 Plato principal:</strong> <%= menu.platoPrincipal %></p>
                <p><strong>🥗 Guarnición:</strong> <%= menu.guarnicion %></p>
                <p><strong>🥣 Entrada:</strong> <%= menu.entrada %></p>
                <p><strong>🧀 Acompañamiento:</strong> <%= menu.acompanamiento %></p>
                <p><strong>🧃 Bebida:</strong> <%= menu.bebida %></p>
                <p><strong>🍰 Postre:</strong> <%= menu.postre %></p>
            </div>
            <p class="mt-3">👍 <strong>Likes:</strong> <%= menu.likes %> &nbsp;&nbsp; 👎 <strong>Dislikes:</strong> <%= menu.dislikes %></p>
            <div class="text-end mt-4">
                <% if (tipoUsuario == 1) { %>
                    <form method="post" action="AdminCRUD.jsp" style="display:inline;">
                        <input type="hidden" name="id" value="<%= menu.id %>">
                        <input type="hidden" name="fecha" value="<%= menu.fecha %>">
                        <input type="hidden" name="tipo" value="<%= menu.tipo %>">
                        <input type="hidden" name="plantel" value="<%= plantel %>">
                        <input type="hidden" name="origen" value="MenuDelDia">
                        <button type="submit" name="accion" value="eliminar" class="btn btn-outline-danger btn-lg"
                                onclick="return confirm('¿Eliminar este menú?');">
                            🗑️ Eliminar
                        </button>
                    </form>
                <% } else { %>
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
                        <p class="texto-voto text-info">Tu voto actual: <strong><%= menu.votoUsuario.toUpperCase() %></strong></p>
                    <% } %>
                <% } %>
            </div>
        </div>
    </div>
    <% } %>
</div>
</body>
</html>
<%@ page import="java.sql.*, controlador.Conexion2" %>
<%@ page session="true" %>
<%
    HttpSession sesion = request.getSession(false);
    if (sesion == null || sesion.getAttribute("id_usuario") == null) {
        response.sendRedirect("Login.jsp");
        return;
    }

    int idUsuario = Integer.parseInt(sesion.getAttribute("id_usuario").toString());
    int idMenu = Integer.parseInt(request.getParameter("id_menu"));
    String tipoVoto = request.getParameter("tipo_voto");

    if (!("like".equals(tipoVoto) || "dislike".equals(tipoVoto))) {
        response.sendRedirect("EstMenuDelDia.jsp");
        return;
    }

    Conexion2 con = new Conexion2();

    // Verificar si ya existe un voto del usuario para este menú
    String sqlCheck = "SELECT COUNT(*) FROM votos_menu WHERE id_usuario = ? AND id_menu = ?";
    con.setRs(sqlCheck, idUsuario, idMenu);
    ResultSet rsCheck = con.getRs();
    rsCheck.next();
    int count = rsCheck.getInt(1);
    rsCheck.close();

    if (count == 0) {
        // Insertar nuevo voto
        String sqlInsert = "INSERT INTO votos_menu (id_usuario, id_menu, tipo_voto, fecha_voto) VALUES (?, ?, ?, CURDATE())";
        con.executeUpdate(sqlInsert, idUsuario, idMenu, tipoVoto);
    } else {
        // Actualizar voto existente
        String sqlUpdate = "UPDATE votos_menu SET tipo_voto = ?, fecha_voto = CURDATE() WHERE id_usuario = ? AND id_menu = ?";
        con.executeUpdate(sqlUpdate, tipoVoto, idUsuario, idMenu);
    }

    con.cerrarConexion();
    response.sendRedirect("EstMenuDelDia.jsp");
%>

<%@page import="java.sql.*, controlador.Conexion2"%>
<%
    request.setCharacterEncoding("UTF-8");
    String accion = request.getParameter("accion");
    Conexion2 con = new Conexion2();

    try {
        if ("agregar".equals(accion)) {
            String fecha = request.getParameter("fecha");
            String tipo = request.getParameter("tipo");
            String plato = request.getParameter("plato_principal");
            String guarnicion = request.getParameter("guarnicion");
            String entrada = request.getParameter("entrada");
            String acompanamiento = request.getParameter("acompanamiento");
            String bebida = request.getParameter("bebida");
            String postre = request.getParameter("postre");
            String plantel = request.getParameter("plantel");

            String insert = "INSERT INTO menu_deldia (fecha, tipo, plato_principal, guarnicion, entrada, acompanamiento, bebida, postre, plantel) " +
                            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            con.executeUpdate(insert, fecha, tipo, plato, guarnicion, entrada, acompanamiento, bebida, postre, plantel);

        } else if ("eliminar".equals(accion)) {
            String id = request.getParameter("id");
            String fecha = request.getParameter("fecha");
            String tipo = request.getParameter("tipo");
            String plantel = (String) session.getAttribute("plantel");

            if (id != null && fecha != null && tipo != null && plantel != null) {
                // ? Primero elimina los votos asociados al menú
                String deleteVotos = "DELETE FROM votos_menu WHERE id_menu = ?";
                con.executeUpdate(deleteVotos, id);

                // ? Luego elimina el menú
                String deleteMenu = "DELETE FROM menu_deldia WHERE id = ? AND fecha = ? AND tipo = ? AND plantel = ?";
                con.executeUpdate(deleteMenu, id, fecha, tipo, plantel);
            }

        } else if ("editar".equals(accion)) {
            String fecha = request.getParameter("fecha");
            String tipo = request.getParameter("tipo");
            String plato = request.getParameter("plato_principal");
            String guarnicion = request.getParameter("guarnicion");
            String entrada = request.getParameter("entrada");
            String acompanamiento = request.getParameter("acompanamiento");
            String bebida = request.getParameter("bebida");
            String postre = request.getParameter("postre");
            String plantel = request.getParameter("plantel");

            String update = "UPDATE menu_deldia SET " +
                            "plato_principal = ?, guarnicion = ?, entrada = ?, acompanamiento = ?, bebida = ?, postre = ? " +
                            "WHERE fecha = ? AND tipo = ? AND plantel = ?";
            con.executeUpdate(update, plato, guarnicion, entrada, acompanamiento, bebida, postre, fecha, tipo, plantel);
        }

    } catch (SQLException e) {
        out.println("<p>Error en la operación: " + e.getMessage() + "</p>");
    } finally {
        con.cerrarConexion();
        response.sendRedirect("AdminMenuDelDia.jsp");
    }
%>

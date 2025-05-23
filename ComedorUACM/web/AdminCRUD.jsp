<%@page import="java.sql.*, controlador.Conexion2"%>
<%
    request.setCharacterEncoding("UTF-8");
    String accion = request.getParameter("accion");
    String origen = request.getParameter("origen");
    String destino = (origen != null && origen.equals("MenuSemanal")) ? "MenuSemanal.jsp" : "MenuDelDia.jsp";

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

            if (fecha != null && !fecha.trim().isEmpty() && fecha.length() <= 255
                    && tipo != null && !tipo.trim().isEmpty() && tipo.length() <= 255
                    && plato != null && !plato.trim().isEmpty() && plato.length() <= 255
                    && guarnicion != null && !guarnicion.trim().isEmpty() && guarnicion.length() <= 255
                    && entrada != null && !entrada.trim().isEmpty() && entrada.length() <= 255
                    && acompanamiento != null && !acompanamiento.trim().isEmpty() && acompanamiento.length() <= 255
                    && bebida != null && !bebida.trim().isEmpty() && bebida.length() <= 255
                    && postre != null && !postre.trim().isEmpty() && postre.length() <= 255
                    && plantel != null && !plantel.trim().isEmpty() && plantel.length() <= 255) {

                String insert = "INSERT INTO menu_deldia (fecha, tipo, plato_principal, guarnicion, entrada, acompanamiento, bebida, postre, plantel) "
                        + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
                con.executeUpdate(insert, fecha, tipo, plato, guarnicion, entrada, acompanamiento, bebida, postre, plantel);

            } else {
                out.println("<p style='color:red;'>Error: Todos los campos son obligatorios y deben tener máximo 255 caracteres.</p>");
                return;
            }

            response.sendRedirect(destino);

        } else if ("eliminar".equals(accion)) {
            String id = request.getParameter("id");
            String fecha = request.getParameter("fecha");
            String tipo = request.getParameter("tipo");
            String plantel = (String) session.getAttribute("plantel");

            if (id != null && fecha != null && tipo != null && plantel != null) {
                String deleteVotos = "DELETE FROM votos_menu WHERE id_menu = ?";
                con.executeUpdate(deleteVotos, id);

                String deleteMenu = "DELETE FROM menu_deldia WHERE id = ? AND fecha = ? AND tipo = ? AND plantel = ?";
                con.executeUpdate(deleteMenu, id, fecha, tipo, plantel);
            }

            response.sendRedirect(destino);

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

            if (fecha != null && !fecha.trim().isEmpty() && fecha.length() <= 255
                    && tipo != null && !tipo.trim().isEmpty() && tipo.length() <= 255
                    && plato != null && !plato.trim().isEmpty() && plato.length() <= 255
                    && guarnicion != null && !guarnicion.trim().isEmpty() && guarnicion.length() <= 255
                    && entrada != null && !entrada.trim().isEmpty() && entrada.length() <= 255
                    && acompanamiento != null && !acompanamiento.trim().isEmpty() && acompanamiento.length() <= 255
                    && bebida != null && !bebida.trim().isEmpty() && bebida.length() <= 255
                    && postre != null && !postre.trim().isEmpty() && postre.length() <= 255
                    && plantel != null && !plantel.trim().isEmpty() && plantel.length() <= 255) {

                String update = "UPDATE menu_deldia SET "
                        + "plato_principal = ?, guarnicion = ?, entrada = ?, acompanamiento = ?, bebida = ?, postre = ? "
                        + "WHERE fecha = ? AND tipo = ? AND plantel = ?";
                con.executeUpdate(update, plato, guarnicion, entrada, acompanamiento, bebida, postre, fecha, tipo, plantel);

            } else {
                out.println("<p style='color:red;'>Error: Todos los campos son obligatorios y deben tener máximo 255 caracteres.</p>");
                return;
            }

            response.sendRedirect(destino);
        }

    } catch (SQLException e) {
        e.printStackTrace();

        String mensajeError = "Error en la operacion: asegurate de que todos los campos tengan maximo 255 caracteres.";

        String url = "AgregarMenu.jsp?"
                + "error=" + java.net.URLEncoder.encode(mensajeError, "UTF-8")
                + "&fecha=" + java.net.URLEncoder.encode(request.getParameter("fecha"), "UTF-8")
                + "&tipo=" + java.net.URLEncoder.encode(request.getParameter("tipo"), "UTF-8")
                + "&id=" + java.net.URLEncoder.encode(request.getParameter("id") != null ? request.getParameter("id") : "", "UTF-8")
                + "&origen=" + java.net.URLEncoder.encode(origen != null ? origen : "", "UTF-8"); // AÑADIDO

        response.sendRedirect(url);
        return;
    }
%>

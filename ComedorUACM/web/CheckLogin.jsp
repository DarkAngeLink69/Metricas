<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page session="true" language="java" import="java.util.*" %>
<%@page import="controlador.Conexion2, java.sql.*" %>
<%
    String usuario = request.getParameter("usuario");
    String clave = request.getParameter("clave");

    Conexion2 con = new Conexion2();

    // Validamos usuario y obtenemos su información usando consulta parametrizada
    String sql = "SELECT u.id_usuario, u.nombres, tu.nombre_rol, u.id_tipo_usuario, u.plantel "
            + "FROM usuarios u "
            + "JOIN tipo_usuario tu ON u.id_tipo_usuario = tu.id_tipo_usuario "
            + "WHERE u.usuario = ? AND u.password = SHA2(?, 256)";

    con.setRs(sql, usuario, clave);
    ResultSet rs = con.getRs();

    if (rs.next()) {
        int idUsuario = rs.getInt("id_usuario");
        String nombre = rs.getString("nombres");
        String rol = rs.getString("nombre_rol");
        int idTipo = rs.getInt("id_tipo_usuario");
        String plantel = rs.getString("plantel");

        HttpSession sesionOk = request.getSession();
        sesionOk.setAttribute("usuario", usuario);
        sesionOk.setAttribute("id_usuario", idUsuario);
        sesionOk.setAttribute("nombre", nombre);
        sesionOk.setAttribute("rol", rol);
        sesionOk.setAttribute("id_tipo", idTipo);
        sesionOk.setAttribute("plantel", plantel);

        rs.close();
        con.cerrarConexion();

        if ("Admin".equalsIgnoreCase(rol)) {
%><jsp:forward page="AdminMenuDelDia.jsp"/><%
        } else {
%><jsp:forward page="EstMenuDelDia.jsp"/><%
            }
        } else {
            rs.close();
            con.cerrarConexion();
%><jsp:forward page="Login.jsp">
    <jsp:param name="error" value="Usuario o contraseña incorrectos"/>
</jsp:forward><%
    }

%>

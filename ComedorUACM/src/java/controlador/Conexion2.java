package controlador;

import java.sql.*;

public class Conexion2 {
    private Connection conexion = null;
    private Statement s = null;
    private ResultSet rs = null;
    private PreparedStatement ps = null;

    public Conexion2() throws SQLException {
        try {
            Class.forName("com.mysql.jdbc.Driver");
            conexion = DriverManager.getConnection("jdbc:mysql://localhost/bdmetricasdejesus", "root", "");
            s = conexion.createStatement();
        } catch (ClassNotFoundException e1) {
            System.out.println("ERROR: No encuentro el driver de la BD: " + e1.getMessage());
        }
    }

    public ResultSet getRs() {
        return rs;
    }

    public void setRs(String sql, Object... params) throws SQLException {
        if (ps != null && !ps.isClosed()) {
            ps.close();
        }
        ps = conexion.prepareStatement(sql);
        for (int i = 0; i < params.length; i++) {
            ps.setObject(i + 1, params[i]);
        }
        rs = ps.executeQuery();
    }

    // Aquí agregamos el método executeUpdate
    public int executeUpdate(String sql, Object... params) throws SQLException {
        if (ps != null && !ps.isClosed()) {
            ps.close();
        }
        ps = conexion.prepareStatement(sql);
        for (int i = 0; i < params.length; i++) {
            ps.setObject(i + 1, params[i]);
        }
        int filasAfectadas = ps.executeUpdate();
        return filasAfectadas;
    }

    public void cerrarConexion() throws SQLException {
        if (rs != null && !rs.isClosed()) rs.close();
        if (ps != null && !ps.isClosed()) ps.close();
        if (s != null && !s.isClosed()) s.close();
        if (conexion != null && !conexion.isClosed()) conexion.close();
    }

    // Opcional para acceder a la conexión si necesitas hacer prepared statements en JSP
    public Connection getConexion() {
        return conexion;
    }
}

package modelo;

import controlador.Conexion2;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PropuestaDAO {

    public static class Propuesta {

        public int id;
        public String descripcion;
        public String tipo;
        public String fecha;
        public String plantel;
        public int id_usuario;
        public int likes;
        public boolean yaVotado;
        public boolean yaVotoPorEseTipo;

    }

    // Método auxiliar para validar cadenas (no nulas, no vacías, max 255)
    private boolean esValido(String s) {
        return s != null && !s.trim().isEmpty() && s.length() <= 255;
    }

    public boolean agregarPropuesta(String descripcion, String tipo, String fecha, String plantel, int idUsuario) throws SQLException {
        if (!esValido(descripcion) || !esValido(tipo) || !esValido(fecha) || !esValido(plantel)) {
            throw new IllegalArgumentException("Campos inválidos o mayores a 255 caracteres");
        }
        Conexion2 con = new Conexion2();
        String sql = "INSERT INTO propuestas_menu (descripcion, tipo, fecha, plantel, id_usuario) VALUES (?, ?, ?, ?, ?)";
        int filas = con.executeUpdate(sql, descripcion, tipo, fecha, plantel, idUsuario);
        con.cerrarConexion();
        return filas > 0;
    }

    public boolean votarPropuesta(int propuestaId, int usuarioId) throws SQLException {
        Conexion2 con = new Conexion2();

        // 1. Obtener tipo y fecha de la propuesta
        String tipo = null;
        String fecha = null;
        String sql1 = "SELECT tipo, fecha FROM propuestas_menu WHERE id = ?";
        con.setRs(sql1, propuestaId);
        ResultSet rs = con.getRs();
        if (rs.next()) {
            tipo = rs.getString("tipo");
            fecha = rs.getString("fecha");
        } else {
            rs.close();
            con.cerrarConexion();
            return false; // No existe
        }
        rs.close();

        // 2. Verificar si ya votó por ese tipo en esa fecha
        if (yaVotoPorTipo(tipo, usuarioId, fecha)) {
            con.cerrarConexion();
            return false;
        }

        // 3. Registrar el voto
        String sql2 = "INSERT IGNORE INTO votos_propuestas (propuesta_id, usuario_id) VALUES (?, ?)";
        int filas = con.executeUpdate(sql2, propuestaId, usuarioId);
        con.cerrarConexion();
        return filas > 0;
    }

    public boolean eliminarPropuesta(int propuestaId, String plantel, int usuarioId) throws SQLException {
        if (!esValido(plantel)) {
            throw new IllegalArgumentException("Plantel inválido o mayor a 255 caracteres");
        }
        Conexion2 con = new Conexion2();
        String sql = "DELETE FROM propuestas_menu WHERE id = ? AND plantel = ? AND id_usuario = ?";
        int filas = con.executeUpdate(sql, propuestaId, plantel, usuarioId);
        con.cerrarConexion();
        return filas > 0;
    }

    public boolean eliminarVotosDePropuesta(int propuestaId) throws SQLException {
        Conexion2 con = new Conexion2();
        String sql = "DELETE FROM votos_propuestas WHERE propuesta_id = ?";
        int filas = con.executeUpdate(sql, propuestaId);
        con.cerrarConexion();
        return filas > 0;
    }

    public boolean actualizarPropuesta(int propuestaId, String nuevaDescripcion, int usuarioId) throws SQLException {
        if (!esValido(nuevaDescripcion)) {
            throw new IllegalArgumentException("Descripción inválida o mayor a 255 caracteres");
        }
        Conexion2 con = new Conexion2();
        String sql = "UPDATE propuestas_menu SET descripcion = ? WHERE id = ? AND id_usuario = ?";
        int filas = con.executeUpdate(sql, nuevaDescripcion, propuestaId, usuarioId);
        con.cerrarConexion();
        return filas > 0;
    }

    public String obtenerFechaPropuesta(int propuestaId, String plantel, int usuarioId) throws SQLException {
        if (!esValido(plantel)) {
            throw new IllegalArgumentException("Plantel inválido o mayor a 255 caracteres");
        }
        Conexion2 con = new Conexion2();
        String sql = "SELECT fecha FROM propuestas_menu WHERE id = ? AND plantel = ? AND id_usuario = ?";
        con.setRs(sql, propuestaId, plantel, usuarioId);
        ResultSet rs = con.getRs();
        String fecha = null;
        if (rs.next()) {
            fecha = rs.getString("fecha");
        }
        rs.close();
        con.cerrarConexion();
        return fecha;
    }

    public String obtenerFechaPropuestaFutura(String hoy, String plantel, int usuarioId) throws SQLException {
        if (!esValido(hoy) || !esValido(plantel)) {
            throw new IllegalArgumentException("Fecha o plantel inválido o mayor a 255 caracteres");
        }
        Conexion2 con = new Conexion2();
        String sql = "SELECT DISTINCT fecha FROM propuestas_menu WHERE fecha > ? AND plantel = ? AND id_usuario = ?";
        con.setRs(sql, hoy, plantel, usuarioId);
        ResultSet rs = con.getRs();
        String fecha = null;
        if (rs.next()) {
            fecha = rs.getString("fecha");
        }
        rs.close();
        con.cerrarConexion();
        return fecha;
    }

    public List<Propuesta> obtenerPropuestas(String hoy, String plantel, int usuarioId) throws SQLException {
        if (!esValido(hoy) || !esValido(plantel)) {
            throw new IllegalArgumentException("Fecha o plantel inválido o mayor a 255 caracteres");
        }
        List<Propuesta> lista = new ArrayList<>();
        Conexion2 con = new Conexion2();
        String sql = "SELECT p.*, "
                + "(SELECT COUNT(*) FROM votos_propuestas v WHERE v.propuesta_id = p.id) AS likes, "
                + "(SELECT COUNT(*) FROM votos_propuestas v WHERE v.propuesta_id = p.id AND v.usuario_id = ?) AS ya_votado "
                + "FROM propuestas_menu p WHERE p.plantel = ? AND DATE_ADD(p.fecha, INTERVAL 1 DAY) >= ? ORDER BY p.fecha ASC";
        con.setRs(sql, usuarioId, plantel, hoy);
        ResultSet rs = con.getRs();
        while (rs.next()) {
            Propuesta p = new Propuesta();
            p.id = rs.getInt("id");
            p.descripcion = rs.getString("descripcion");
            p.tipo = rs.getString("tipo");
            p.fecha = rs.getString("fecha");
            p.plantel = rs.getString("plantel");
            p.id_usuario = rs.getInt("id_usuario");
            p.likes = rs.getInt("likes");
            p.yaVotado = rs.getInt("ya_votado") > 0;
            p.yaVotoPorEseTipo = yaVotoPorTipo(p.tipo, usuarioId, p.fecha); // NUEVO
            lista.add(p);
        }
        rs.close();
        con.cerrarConexion();
        return lista;
    }

    public boolean yaVotoPorTipo(String tipo, int usuarioId, String fecha) throws SQLException {
        Conexion2 con = new Conexion2();
        String sql = "SELECT COUNT(*) FROM votos_propuestas vp "
                + "JOIN propuestas_menu pm ON vp.propuesta_id = pm.id "
                + "WHERE vp.usuario_id = ? AND pm.tipo = ? AND pm.fecha = ?";
        con.setRs(sql, usuarioId, tipo, fecha);
        ResultSet rs = con.getRs();
        boolean resultado = false;
        if (rs.next()) {
            resultado = rs.getInt(1) > 0;
        }
        rs.close();
        con.cerrarConexion();
        return resultado;
    }

}

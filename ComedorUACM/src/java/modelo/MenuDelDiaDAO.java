// src/modelo/MenuDelDiaDAO.java
package modelo;

import controlador.Conexion2;
import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class MenuDelDiaDAO {

    public static class MenuDelDia {

        public int id;
        public int idUsuario;
        public String fecha;
        public String tipo;
        public String platoPrincipal;
        public String guarnicion;
        public String entrada;
        public String acompanamiento;
        public String bebida;
        public String postre;
        public int likes;
        public int dislikes;
        public String votoUsuario;
    }

    
public List<MenuDelDia> obtenerMenusDelDiaConVotoUsuario(String plantel, int idUsuario) throws SQLException {
    List<MenuDelDia> lista = new ArrayList<>();
    Conexion2 con = new Conexion2();
    String sql = "SELECT * FROM menu_deldia WHERE plantel = ? AND fecha = CURDATE() ORDER BY FIELD(tipo, 'Desayuno', 'Comida')";
    con.setRs(sql, plantel);
    ResultSet rs = con.getRs();

    while (rs.next()) {
        MenuDelDia menu = new MenuDelDia();
        menu.id = rs.getInt("id");
        menu.fecha = rs.getString("fecha");
        menu.tipo = rs.getString("tipo");
        menu.platoPrincipal = rs.getString("plato_principal");
        menu.guarnicion = rs.getString("guarnicion");
        menu.entrada = rs.getString("entrada");
        menu.acompanamiento = rs.getString("acompanamiento");
        menu.bebida = rs.getString("bebida");
        menu.postre = rs.getString("postre");

        // Obtener votos totales
        Conexion2 conVotos = new Conexion2();
        String votosSQL = "SELECT tipo_voto FROM votos_menu WHERE id_menu = ?";
        conVotos.setRs(votosSQL, menu.id);
        ResultSet rsVotos = conVotos.getRs();
        while (rsVotos.next()) {
            String voto = rsVotos.getString("tipo_voto");
            if ("like".equalsIgnoreCase(voto)) {
                menu.likes++;
            } else if ("dislike".equalsIgnoreCase(voto)) {
                menu.dislikes++;
            }
        }
        rsVotos.close();
        conVotos.cerrarConexion();

        // Obtener voto del usuario
        Conexion2 conVotoUsuario = new Conexion2();
        String sqlVotoUsuario = "SELECT tipo_voto FROM votos_menu WHERE id_usuario = ? AND id_menu = ?";
        conVotoUsuario.setRs(sqlVotoUsuario, idUsuario, menu.id);
        ResultSet rsVotoUsuario = conVotoUsuario.getRs();
        if (rsVotoUsuario.next()) {
            menu.votoUsuario = rsVotoUsuario.getString("tipo_voto");
        } else {
            menu.votoUsuario = null;
        }
        rsVotoUsuario.close();
        conVotoUsuario.cerrarConexion();

        lista.add(menu);
    }

    rs.close();
    con.cerrarConexion();
    return lista;
}


    public Map<String, Map<String, MenuDelDia>> obtenerMenuSemanal(String plantel) throws SQLException {
        Map<String, Map<String, MenuDelDia>> semana = new LinkedHashMap<>();
        Conexion2 con = new Conexion2();

        String sql = "SELECT * FROM menu_deldia WHERE plantel = ? AND WEEK(fecha, 1) = WEEK(CURDATE(), 1)";
        con.setRs(sql, plantel);
        ResultSet rs = con.getRs();

        while (rs.next()) {
            MenuDelDia menu = new MenuDelDia();
            menu.id = rs.getInt("id");
            menu.fecha = rs.getString("fecha");
            menu.tipo = rs.getString("tipo");
            menu.platoPrincipal = rs.getString("plato_principal");

            semana
                    .computeIfAbsent(menu.fecha, f -> new HashMap<>())
                    .put(menu.tipo, menu);
        }

        rs.close();
        con.cerrarConexion();
        return semana;
    }
    // En MenuDelDiaDAO.java
public MenuDelDia obtenerMenuPorIdYPlantel(String idStr, String plantel) throws SQLException {
    int id = Integer.parseInt(idStr);
    MenuDelDia menu = null;
    Conexion2 con = new Conexion2();
    String sql = "SELECT * FROM menu_deldia WHERE id = ? AND plantel = ?";
    con.setRs(sql, id, plantel);
    ResultSet rs = con.getRs();
    if (rs.next()) {
        menu = new MenuDelDia();
        menu.id = rs.getInt("id");
        menu.fecha = rs.getString("fecha");
        menu.tipo = rs.getString("tipo");
        menu.platoPrincipal = rs.getString("plato_principal");
        menu.guarnicion = rs.getString("guarnicion");
        menu.entrada = rs.getString("entrada");
        menu.acompanamiento = rs.getString("acompanamiento");
        menu.bebida = rs.getString("bebida");
        menu.postre = rs.getString("postre");
    }
    rs.close();
    con.cerrarConexion();
    return menu;
}
public String obtenerVotoUsuario(int idUsuario, int idMenu) throws SQLException {
    String voto = null;
    Conexion2 con = new Conexion2();
    String sql = "SELECT tipo_voto FROM votos_menu WHERE id_usuario = ? AND id_menu = ?";
    con.setRs(sql, idUsuario, idMenu);
    ResultSet rs = con.getRs();
    if (rs.next()) {
        voto = rs.getString("tipo_voto");
    }
    rs.close();
    con.cerrarConexion();
    return voto;
}
}

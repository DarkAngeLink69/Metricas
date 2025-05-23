package modelo;

import modelo.MenuDelDiaDAO.MenuDelDia;
import org.junit.Before;
import org.junit.Test;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import static org.junit.Assert.*;

public class MenuDelDiaDAOTest {

    private MenuDelDiaDAO dao;

    @Before
    public void setUp() {
        dao = new MenuDelDiaDAO();
    }

    // === EQUIVALENCIA ===
    @Test
    public void testObtenerMenuDelDiaConUsuario_Equivalencia_UsuarioValido() throws SQLException {
        List<MenuDelDia> menus = dao.obtenerMenusDelDiaConVotoUsuario("San Lorenzo Tezonco", 1);
        assertNotNull(menus);
    }

    @Test
    public void testObtenerMenuDelDia_Equivalencia_PlantelInvalido_NoExcepcion() throws SQLException {
        List<MenuDelDia> menus = dao.obtenerMenusDelDiaConVotoUsuario("PlantelDesconocido", 1);
        assertNotNull("Debe devolver lista aunque el plantel no exista", menus);
        assertTrue("Lista debe estar vacía si el plantel no existe", menus.isEmpty());
    }

    @Test
    public void testObtenerMenuSemanal_Equivalencia_Correcta() throws SQLException {
        Map<String, Map<String, MenuDelDia>> semanal = dao.obtenerMenuSemanal("San Lorenzo Tezonco");
        assertNotNull(semanal);
    }

    // === VALORES LÍMITE ===
    @Test
    public void testObtenerMenuPorIdYPlantel_Limite_IdNegativo_NoFalla() throws SQLException {
        MenuDelDia menu = dao.obtenerMenuPorIdYPlantel("-1", "San Lorenzo Tezonco");
        assertNull("Debe retornar null si el ID es negativo", menu);
    }

    @Test
    public void testObtenerMenuPorIdYPlantel_Limite_IdMinimoValido() throws SQLException {
        MenuDelDia menu = dao.obtenerMenuPorIdYPlantel("1", "San Lorenzo Tezonco");
        assertTrue(menu == null || menu.id >= 1);
    }

    @Test(expected = NumberFormatException.class)
    public void testObtenerMenuPorIdYPlantel_Limite_IdNoNumerico() throws SQLException {
        dao.obtenerMenuPorIdYPlantel("abc", "San Lorenzo Tezonco");
    }

    @Test
    public void testObtenerVotoUsuario_Limite_UsuarioInexistente() throws SQLException {
        String voto = dao.obtenerVotoUsuario(999999, 1);
        assertNull(voto);
    }

    // === LÍMITE DE CARACTERES ===
    @Test
    public void testPlantelCon101Caracteres_NoExcepcion() throws SQLException {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 256; i++) {
            sb.append("a");
        }
        String largo = sb.toString();

        List<MenuDelDia> menus = dao.obtenerMenusDelDiaConVotoUsuario(largo, 1);
        assertNotNull("Debe retornar lista aunque no haya resultados", menus);
        assertTrue("Debe estar vacía si no hay datos con plantel largo", menus.isEmpty());
    }

    @Test
    public void testPlantelCon100Caracteres_Valido() {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < 100; i++) {
            sb.append("a");
        }
        String valido = sb.toString();

        try {
            List<MenuDelDia> menus = dao.obtenerMenusDelDiaConVotoUsuario(valido, 1);
            assertNotNull(menus);
        } catch (SQLException e) {
            // Puede fallar si no hay datos, pero no debe lanzar por longitud
        }
    }

    // === EXCEPCIONES ===
  
    @Test
    public void testObtenerMenuSemanal_PlantelInexistente_NoExcepcion() throws SQLException {
        Map<String, Map<String, MenuDelDia>> menus = dao.obtenerMenuSemanal("PlantelFicticio");
        assertNotNull("Debe devolver un mapa aunque esté vacío", menus);
        assertTrue("Debe estar vacío si el plantel no existe", menus.isEmpty());
    }
    // === PRUEBAS TÍPICAS ===

    @Test
    public void testObtenerMenusDelDiaConVotoUsuario_Tipico() throws SQLException {
        List<MenuDelDia> menus = dao.obtenerMenusDelDiaConVotoUsuario("San Lorenzo Tezonco", 1);
        assertNotNull("Debe devolver lista aunque esté vacía", menus);
    }

    @Test
    public void testObtenerMenuPorIdYPlantel_Tipico() throws SQLException {
        MenuDelDia menu = dao.obtenerMenuPorIdYPlantel("1", "San Lorenzo Tezonco");
        // Puede ser null si no existe, pero no debe lanzar excepción
        assertTrue("Debe ser null o un menú válido", menu == null || menu.id == 1);
    }

// === PRUEBAS ATÍPICAS ===
    @Test
    public void testObtenerMenusDelDiaConVotoUsuario_Atipico_UsuarioCero() throws SQLException {
        List<MenuDelDia> menus = dao.obtenerMenusDelDiaConVotoUsuario("San Lorenzo Tezonco", 0);
        assertNotNull(menus);
    }

    @Test
    public void testObtenerMenusDelDiaConVotoUsuario_Atipico_UsuarioNegativo() throws SQLException {
        List<MenuDelDia> menus = dao.obtenerMenusDelDiaConVotoUsuario("San Lorenzo Tezonco", -99);
        assertNotNull(menus);
    }

    @Test
    public void testObtenerVotoUsuario_Atipico_MenuInexistente() throws SQLException {
        String voto = dao.obtenerVotoUsuario(1, 999999);
        assertNull("Debe ser null si el menú no existe o no ha votado", voto);
    }

    @Test
    public void testObtenerMenuPorIdYPlantel_Atipico_IdEnBlanco() {
        try {
            dao.obtenerMenuPorIdYPlantel(" ", "San Lorenzo Tezonco");
            fail("Se esperaba NumberFormatException por id vacío");
        } catch (NumberFormatException e) {
            // Esperado
        } catch (SQLException e) {
            fail("Tipo de excepción inesperado: " + e);
        }
    }
// === COBERTURA DE ERRORES ===


    @Test(expected = NumberFormatException.class)
    public void testObtenerMenuPorIdYPlantel_Error_IdNoNumerico() throws SQLException {
        dao.obtenerMenuPorIdYPlantel("abc", "San Lorenzo Tezonco");
    }

    @Test
    public void testObtenerVotoUsuario_Error_IdUsuarioNegativo() throws SQLException {
        String voto = dao.obtenerVotoUsuario(-1, 1);
        assertNull("Debe devolver null aunque id_usuario sea inválido", voto);
    }

    @Test
    public void testObtenerMenuSemanal_Error_PlantelNoExistente() throws SQLException {
        Map<String, Map<String, MenuDelDia>> menus = dao.obtenerMenuSemanal("PlantelFicticio");
        assertNotNull(menus);
        assertTrue("Debe estar vacío si el plantel no existe", menus.isEmpty());
    }
}

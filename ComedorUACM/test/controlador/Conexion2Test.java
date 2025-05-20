package controlador;

import org.junit.*;
import java.sql.*;

import static org.junit.Assert.*;

public class Conexion2Test {

    private Conexion2 conexion;

    @Before
    public void setUp() {
        try {
            conexion = new Conexion2();
        } catch (SQLException e) {
            fail("No se pudo establecer conexión: " + e.getMessage());
        }
    }

    @After
    public void tearDown() {
        try {
            if (conexion != null) {
                conexion.cerrarConexion();
            }
        } catch (SQLException e) {
            System.out.println("Error al cerrar la conexión: " + e.getMessage());
        }
    }

    @Test
    public void testInsertarYEliminarUsuarioCompleto() {
        System.out.println("InsertarYEliminarUsuarioCompleto");
        String nombres = "Juan";
        String apellidos = "Pérez";
        int edad = 25;
        String usuario = "juanprueba";
        String password = "123456";
        int id_tipo_usuario = 1; // Asegúrate que este existe en tipo_usuario
        String plantel = "San Lorenzo Tezonco";

        try {
            // INSERT
            String sqlInsert = "INSERT INTO usuarios (nombres, apellidos, edad, usuario, password, id_tipo_usuario, plantel) " +
                               "VALUES (?, ?, ?, ?, ?, ?, ?)";
            int filas = conexion.executeUpdate(sqlInsert, nombres, apellidos, edad, usuario, password, id_tipo_usuario, plantel);
            assertEquals(1, filas);

            // SELECT
            String sqlSelect = "SELECT * FROM usuarios WHERE usuario = ?";
            conexion.setRs(sqlSelect, usuario);
            ResultSet rs = conexion.getRs();
            assertTrue("El usuario debe existir en la base de datos", rs.next());

            // DELETE
            String sqlDelete = "DELETE FROM usuarios WHERE usuario = ?";
            int eliminados = conexion.executeUpdate(sqlDelete, usuario);
            assertEquals(1, eliminados);

        } catch (SQLException e) {
            fail("Error en la prueba de usuarios: " + e.getMessage());
        }
    }
}

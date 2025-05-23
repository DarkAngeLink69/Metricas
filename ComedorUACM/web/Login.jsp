<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
    <head>
        <title>Comedor UACM</title>
        <meta charset = "utf-8">
        <meta http-equiv="X-UA-Compatible"content="IE=edge">
        <meta name = "viewport"content="width=device-width, initial-scale=1">
        <link rel="stylesheet"href="css/bootstrap.min.css">
    </head>
    <body>
        <div class="container-fluid">
            <div class="row">
                <div class="col-sm-4 col-sm-offset-4">
                    <hr><!-- comment -->
                    <hr><!-- comment -->
                    <hr>
                    <h2><center>Comedor UACM</center></h2>
                    <hr>
                        <%
                            if (request.getParameter("error") != null) {
                        %>
                    <div class="alert alert-danger">
                        <strong>Error!</strong><%=request.getParameter("error")%>
                        <br>
                    </div>
                    <%
                        }//Findelif #3c1224
                    %>
                    <form action="CheckLogin.jsp" method="post">
                        <h4><center>Inicio de sesion</center></h4>
                        <div class="form-group">
                            <input type="text" class="form-control" id="usuario" placeholder="Nombre de usuario" name="usuario" required>
                        </div>
                        <div class="form-group">
                            <input type="password" class="form-control" id="clave" placeholder="Contraseña" name="clave" required>
                        </div>
                        <h5>¿No tienes aún una cuenta? 
                            <a href="crearUsuario.jsp">Crear una cuenta</a>
                        </h5>
                        <div class="form-group">
                            <button class="btn btn-lg btn-block" style="background-color: #27487D; color: white" type="submit">Iniciar sesión</button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </body>
</html>
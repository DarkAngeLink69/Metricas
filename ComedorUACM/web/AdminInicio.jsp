<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page session="true" %>
<%
    HttpSession miSesion = request.getSession(false);
    if (miSesion == null || miSesion.getAttribute("id_usuario") == null) {
        response.sendRedirect("Login.jsp?error=Es obligatorio identificarse");
        return;
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <title>Menú Principal</title>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1">

        <link rel="stylesheet" href="css/bootstrap.min.css">
        <script src="js/jquery.js"></script>
        <script src="js/bootstrap.min.js"></script>

        <style type="text/css">
            body, input {
                font-family: Calibri, Arial;
            }

            .navbar-custom {
                background-color: #3c1224;
            }

            .navbar-custom .navbar-brand,
            .navbar-custom .nav > li > a {
                color: white;
            }

            .navbar-custom .nav > li > a:hover {
                background-color: #27487D;
                color: white;
            }

            .container {
                margin-top: 70px;
            }
        </style>

        <script type="text/javascript">
            window.history.forward();
            function noBack() {
                window.history.forward();
            }
        </script>
    </head>
    <body onload="noBack();" onpageshow="if (event.persisted) noBack();" onunload="">

        <nav class="navbar navbar-custom navbar-fixed-top">
            <div class="container">
                <a class="navbar-brand" href="#">Comedor UACM</a>
                <div id="navbar" class="navbar-collapse collapse">
                    <ul class="nav navbar-nav">
                        <li><a href="AdminMenuDelDia.jsp">Menú del día</a></li>
                        <li><a href="AdminMenuSemanal.jsp">Menú semanal</a></li>
                        <li><a href="AdminPropuestas.jsp">Votaciones</a></li>
                        <li><a>Plantel: <%= miSesion.getAttribute("plantel") %></a></li>
                    </ul>
                    <ul class="nav navbar-nav navbar-right">
                        <li>
                            <p class="navbar-text">
                                <a href="CerrarSesion.jsp" style="color:white;">
                                    <%= miSesion.getAttribute("usuario") %> (cerrar sesión)
                                </a>
                            </p>
                        </li>
                    </ul>
                </div>
            </div>
        </nav>
    </body>
</html>

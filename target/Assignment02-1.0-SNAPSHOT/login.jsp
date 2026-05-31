<html>
<head><title>Login</title></head>
<body>

<h2>Login</h2>

<form action="login" method="post">

    Email: <br>
    <input type="email" name="email" required><br><br>

    Password: <br>
    <input type="password" name="password" required><br><br>

    <input type="submit" value="Login">

</form>

<% if (request.getParameter("error") != null) { %>
<p style="color:red;">Invalid email or password</p>
<% } %>

</body>
</html>
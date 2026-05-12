<%@ page language="java" contentType="text/html; charset=UTF-8"
		 pageEncoding="UTF-8"%>

<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<html>
<head>
	<style>
		body {
			font-family: Arial, sans-serif;
			background: #f4f6f9;
			margin: 0;
			padding: 0;
		}

		h1 {
			margin-top: 20px;
			color: #333;
		}

		.container {
			width: 80%;
			margin: 30px auto;
			background: white;
			padding: 20px;
			border-radius: 10px;
			box-shadow: 0px 0px 15px rgba(0,0,0,0.1);
		}

		table {
			width: 100%;
			border-collapse: collapse;
			margin-top: 20px;
		}

		th {
			background: #007bff;
			color: white;
			padding: 10px;
			text-align: left;
		}

		td {
			padding: 10px;
			border-bottom: 1px solid #ddd;
		}

		tr:hover {
			background: #f1f1f1;
		}

		a {
			text-decoration: none;
			padding: 6px 12px;
			border-radius: 5px;
			font-size: 14px;
			margin: 0 3px;
		}

		.btn-add {
			background: #28a745;
			color: white;
		}

		.btn-add:hover {
			background: #218838;
		}

		.btn-edit {
			background: #ffc107;
			color: black;
		}

		.btn-edit:hover {
			background: #e0a800;
		}

		.btn-delete {
			background: #dc3545;
			color: white;
		}

		.btn-delete:hover {
			background: #c82333;
		}

		.top-bar {
			display: flex;
			justify-content: space-between;
			align-items: center;
		}
	</style>
	<title>User Management Application</title>
</head>

<body>

<center>
	<h1>User Management</h1>

	<h2>
		<!-- ✅ FIXED LINKS -->
		<a href="users?action=new">Add New User</a>
		&nbsp;&nbsp;&nbsp;
		<a href="users">List All Users</a>
	</h2>
</center>

<div align="center">

	<!-- EDIT FORM -->
	<c:if test="${user != null}">
	<form action="users?action=update" method="post">
		</c:if>

		<!-- INSERT FORM -->
		<c:if test="${user == null}">
		<form action="users?action=insert" method="post">
			</c:if>

			<table border="1" cellpadding="5">

				<caption>
					<h2>
						<c:if test="${user != null}">
							Edit User
						</c:if>
						<c:if test="${user == null}">
							Add New User
						</c:if>
					</h2>
				</caption>

				<!-- Hidden ID for update -->
				<c:if test="${user != null}">
					<input type="hidden" name="id" value="${user.id}" />
				</c:if>

				<!-- NAME -->
				<tr>
					<th>User Name:</th>
					<td>
						<input type="text" name="name" size="45"
							   value="${user.name}" required />
					</td>
				</tr>

				<!-- EMAIL -->
				<tr>
					<th>User Email:</th>
					<td>
						<input type="email" name="email" size="45"
							   value="${user.email}" required />
					</td>
				</tr>

				<!-- COUNTRY -->
				<tr>
					<th>Country:</th>
					<td>
						<input type="text" name="country" size="15"
							   value="${user.country}" required />
					</td>
				</tr>

				<!-- PASSWORD -->
				<tr>
					<th>Password:</th>
					<td>
						<input type="password" name="password" size="45"
							   value="${user.password}" required />
					</td>
				</tr>

				<!-- SUBMIT -->
				<tr>
					<td colspan="2" align="center">
						<input type="submit" value="Save" />
					</td>
				</tr>

			</table>

		</form>

</div>

</body>
</html>